import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const serviceClient = createClient(supabaseUrl, serviceRoleKey);

// --- Default models per provider ---
const DEFAULT_MODELS: Record<string, string> = {
  openai: "gpt-4o",
  google: "gemini-2.0-flash",
  anthropic: "claude-sonnet-4-20250514",
};

// --- In-memory rate limiting (per-company, 1 hour window) ---
const rateLimitMap = new Map<string, { count: number; windowStart: number }>();

// --- CORS ---
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function respond(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...corsHeaders },
  });
}

// --- Interfaces ---

interface AiMessage {
  role: "system" | "user" | "assistant" | "tool";
  content?: string;
  toolCallId?: string;
  toolCalls?: AiToolCall[];
}

interface AiToolCall {
  id: string;
  name: string;
  arguments: Record<string, unknown>;
}

interface AiTool {
  name: string;
  description: string;
  parameters: Record<string, unknown>;
}

interface ChatRequest {
  action: "chat";
  messages: AiMessage[];
  tools?: AiTool[];
  model?: string;
  maxTokens?: number;
  temperature?: number;
  stream?: boolean;
}

interface TranscribeRequest {
  action: "transcribe";
  audio: string; // base64
  format: string; // "wav", "mp3", etc.
  language?: string;
}

type ProxyRequest = ChatRequest | TranscribeRequest;

// --- Main handler ---

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Step 1: Authenticate
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return respond({ error: "Missing Authorization header" }, 401);
    }

    const token = authHeader.replace("Bearer ", "");
    const {
      data: { user: authUser },
      error: authError,
    } = await serviceClient.auth.getUser(token);

    if (authError || !authUser) {
      return respond(
        { error: `Auth failed: ${authError?.message ?? "no user"}` },
        401
      );
    }

    // Step 2: Look up user in users table → get company_id and user id
    const { data: userRow, error: userError } = await serviceClient
      .from("users")
      .select("id, company_id")
      .eq("auth_user_id", authUser.id)
      .is("deleted_at", null)
      .limit(1)
      .single();

    if (userError || !userRow) {
      return respond({ error: "User not found in users table" }, 403);
    }

    const userId = userRow.id as string;
    const companyId = userRow.company_id as string;

    // Step 3: Get company settings
    const { data: settings, error: settingsError } = await serviceClient
      .from("company_settings")
      .select(
        "ai_enabled, ai_provider_type, ai_model, ai_rate_limit_per_hour, ai_max_tokens_per_request"
      )
      .eq("company_id", companyId)
      .is("deleted_at", null)
      .limit(1)
      .single();

    if (settingsError || !settings) {
      return respond({ error: "Company settings not found" }, 400);
    }

    if (!settings.ai_enabled) {
      return respond({ error: "AI assistant is disabled" }, 400);
    }

    const providerType = settings.ai_provider_type as string;
    if (providerType === "none") {
      return respond({ error: "AI not configured" }, 400);
    }

    // Step 4: Check ai.use permission
    const { data: hasPermission } = await serviceClient.rpc(
      "check_user_permission",
      {
        p_user_id: userId,
        p_company_id: companyId,
        p_permission_code: "ai.use",
      }
    );

    if (!hasPermission) {
      return respond({ error: "Permission denied: ai.use" }, 403);
    }

    // Step 5: Server-side rate limiting
    const rateLimit = (settings.ai_rate_limit_per_hour as number) || 60;
    const now = Date.now();
    const windowMs = 60 * 60 * 1000; // 1 hour

    let entry = rateLimitMap.get(companyId);
    if (!entry || now - entry.windowStart > windowMs) {
      entry = { count: 0, windowStart: now };
      rateLimitMap.set(companyId, entry);
    }

    if (entry.count >= rateLimit) {
      return respond({ error: "Rate limit exceeded" }, 429);
    }
    entry.count++;

    // Step 6: Parse request body
    const body: ProxyRequest = await req.json();

    // Step 7: Get API key from env
    const apiKeyEnvMap: Record<string, string> = {
      openai: "AI_OPENAI_API_KEY",
      google: "AI_GOOGLE_API_KEY",
      anthropic: "AI_ANTHROPIC_API_KEY",
    };

    const apiKeyEnv = apiKeyEnvMap[providerType];
    if (!apiKeyEnv) {
      return respond({ error: `Unknown provider type: ${providerType}` }, 400);
    }

    const apiKey = Deno.env.get(apiKeyEnv);
    if (!apiKey) {
      return respond(
        { error: `API key not configured for provider: ${providerType}` },
        500
      );
    }

    const model =
      (body as ChatRequest).model ||
      (settings.ai_model as string) ||
      DEFAULT_MODELS[providerType] ||
      "gpt-4o";

    const maxTokens = Math.min(
      (body as ChatRequest).maxTokens || 4096,
      (settings.ai_max_tokens_per_request as number) || 4096
    );

    const temperature = (body as ChatRequest).temperature ?? 0.3;

    // Step 8: Dispatch
    if (body.action === "transcribe") {
      // Prefer Google (Gemini) for transcription, fall back to OpenAI Whisper
      const googleKey = Deno.env.get("AI_GOOGLE_API_KEY");
      if (googleKey) {
        return await handleTranscribeGoogle(body as TranscribeRequest, googleKey);
      }
      const openaiKey = Deno.env.get("AI_OPENAI_API_KEY");
      if (openaiKey) {
        return await handleTranscribeOpenAi(body as TranscribeRequest, openaiKey);
      }
      return respond(
        { error: "No transcription API key configured (need AI_GOOGLE_API_KEY or AI_OPENAI_API_KEY)" },
        500
      );
    }

    const chatReq = body as ChatRequest;
    if (chatReq.stream) {
      return await handleChatStream(
        chatReq,
        apiKey,
        providerType,
        model,
        maxTokens,
        temperature
      );
    }
    return await handleChat(chatReq, apiKey, providerType, model, maxTokens, temperature);
  } catch (err) {
    console.error("ai-proxy error:", err);
    return respond(
      { error: `Internal error: ${(err as Error).message}` },
      500
    );
  }
});

// --- Chat (non-streaming) ---

async function handleChat(
  req: ChatRequest,
  apiKey: string,
  providerType: string,
  model: string,
  maxTokens: number,
  temperature: number
): Promise<Response> {
  const requestBody =
    providerType === "anthropic"
      ? buildAnthropicBody(req, model, maxTokens, false, temperature)
      : buildOpenAiBody(req, model, maxTokens, false, temperature);

  const apiUrl = getApiUrl(providerType, model);
  const headers = getApiHeaders(providerType, apiKey);

  const response = await fetch(apiUrl, {
    method: "POST",
    headers,
    body: JSON.stringify(requestBody),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error(`AI API error (${response.status}):`, errorText);
    return respond(
      { error: `AI provider error: ${response.status}`, details: errorText },
      502
    );
  }

  const json = await response.json();

  // Anthropic returns a different response format
  if (providerType === "anthropic") {
    return respond(parseAnthropicResponse(json));
  }

  // OpenAI / Google: normalize response to unified format
  const choice = json.choices?.[0];
  const message = choice?.message;
  const usage = json.usage;

  const toolCalls = message?.tool_calls?.map(
    (tc: { id: string; function: { name: string; arguments: string } }) => ({
      id: tc.id,
      name: tc.function.name,
      arguments: JSON.parse(tc.function.arguments || "{}"),
    })
  );

  return respond({
    content: message?.content || null,
    finishReason: choice?.finish_reason || "stop",
    usage: {
      promptTokens: usage?.prompt_tokens || 0,
      completionTokens: usage?.completion_tokens || 0,
    },
    ...(toolCalls ? { toolCalls } : {}),
  });
}

// --- Chat (streaming) ---

async function handleChatStream(
  req: ChatRequest,
  apiKey: string,
  providerType: string,
  model: string,
  maxTokens: number,
  temperature: number
): Promise<Response> {
  // Anthropic: non-streaming call + fake SSE wrapper
  // (supabase_flutter SDK buffers the whole response anyway)
  if (providerType === "anthropic") {
    const requestBody = buildAnthropicBody(req, model, maxTokens, false, temperature);
    const apiUrl = getApiUrl(providerType, model);
    const headers = getApiHeaders(providerType, apiKey);

    const response = await fetch(apiUrl, {
      method: "POST",
      headers,
      body: JSON.stringify(requestBody),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error(`AI API stream error (${response.status}):`, errorText);
      return respond(
        { error: `AI provider error: ${response.status}`, details: errorText },
        502
      );
    }

    const json = await response.json();
    const unified = parseAnthropicResponse(json);
    const sseText = buildFakeSse(unified);

    return new Response(sseText, {
      status: 200,
      headers: {
        "Content-Type": "text/event-stream",
        "Cache-Control": "no-cache",
        Connection: "keep-alive",
        ...corsHeaders,
      },
    });
  }

  // OpenAI / Google: proxy SSE stream transparently
  const openaiBody = buildOpenAiBody(req, model, maxTokens, true, temperature);

  const apiUrl = getApiUrl(providerType, model);
  const headers = getApiHeaders(providerType, apiKey);

  const response = await fetch(apiUrl, {
    method: "POST",
    headers,
    body: JSON.stringify(openaiBody),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error(`AI API stream error (${response.status}):`, errorText);
    return respond(
      { error: `AI provider error: ${response.status}`, details: errorText },
      502
    );
  }

  return new Response(response.body, {
    status: 200,
    headers: {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      Connection: "keep-alive",
      ...corsHeaders,
    },
  });
}

// --- Transcribe (Google Gemini) ---

async function handleTranscribeGoogle(
  req: TranscribeRequest,
  apiKey: string
): Promise<Response> {
  const prompt = req.language
    ? `Transcribe this audio exactly as spoken in ${req.language}. Output only the transcription text, nothing else.`
    : "Transcribe this audio exactly as spoken. Output only the transcription text, nothing else.";

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{
          parts: [
            { text: prompt },
            { inlineData: { mimeType: `audio/${req.format}`, data: req.audio } },
          ],
        }],
      }),
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    return respond({ error: `Transcription error: ${response.status}`, details: errorText }, 502);
  }

  const json = await response.json();
  const text = json.candidates?.[0]?.content?.parts?.[0]?.text || "";
  return respond({ text });
}

// --- Transcribe (OpenAI Whisper fallback) ---

async function handleTranscribeOpenAi(
  req: TranscribeRequest,
  apiKey: string
): Promise<Response> {
  const audioBytes = Uint8Array.from(atob(req.audio), (c) => c.charCodeAt(0));

  const formData = new FormData();
  formData.append(
    "file",
    new Blob([audioBytes], { type: `audio/${req.format}` }),
    `audio.${req.format}`
  );
  formData.append("model", "whisper-1");
  if (req.language) {
    formData.append("language", req.language);
  }

  const response = await fetch(
    "https://api.openai.com/v1/audio/transcriptions",
    {
      method: "POST",
      headers: { Authorization: `Bearer ${apiKey}` },
      body: formData,
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    return respond({ error: `Transcription error: ${response.status}`, details: errorText }, 502);
  }

  const json = await response.json();
  return respond({ text: json.text });
}

// --- Helpers ---

function buildOpenAiBody(
  req: ChatRequest,
  model: string,
  maxTokens: number,
  stream: boolean,
  temperature: number
) {
  const messages = req.messages.map((m) => {
    if (m.role === "tool") {
      return {
        role: "tool" as const,
        tool_call_id: m.toolCallId,
        content: m.content || "",
      };
    }
    if (m.role === "assistant" && m.toolCalls) {
      return {
        role: "assistant" as const,
        content: m.content || null,
        tool_calls: m.toolCalls.map((tc) => ({
          id: tc.id,
          type: "function" as const,
          function: {
            name: tc.name,
            arguments: JSON.stringify(tc.arguments),
          },
        })),
      };
    }
    return { role: m.role, content: m.content || "" };
  });

  const tools =
    req.tools?.map((t) => ({
      type: "function" as const,
      function: {
        name: t.name,
        description: t.description,
        parameters: t.parameters,
      },
    })) || undefined;

  return {
    model,
    messages,
    max_tokens: maxTokens,
    temperature,
    stream,
    ...(stream ? { stream_options: { include_usage: true } } : {}),
    ...(tools && tools.length > 0 ? { tools } : {}),
  };
}

// --- Anthropic-specific body builder ---

function buildAnthropicBody(
  req: ChatRequest,
  model: string,
  maxTokens: number,
  stream: boolean,
  temperature: number
) {
  // Extract system message (Anthropic requires it as a top-level field)
  let system: string | undefined;
  const messages: Array<Record<string, unknown>> = [];

  for (const m of req.messages) {
    if (m.role === "system") {
      system = m.content || "";
      continue;
    }

    if (m.role === "assistant" && m.toolCalls) {
      // Assistant with tool calls → content blocks
      const content: Array<Record<string, unknown>> = [];
      if (m.content) {
        content.push({ type: "text", text: m.content });
      }
      for (const tc of m.toolCalls) {
        content.push({
          type: "tool_use",
          id: tc.id,
          name: tc.name,
          input: tc.arguments,
        });
      }
      messages.push({ role: "assistant", content });
    } else if (m.role === "tool") {
      // Tool result → user message with tool_result content block
      messages.push({
        role: "user",
        content: [
          {
            type: "tool_result",
            tool_use_id: m.toolCallId,
            content: m.content || "",
          },
        ],
      });
    } else {
      messages.push({ role: m.role, content: m.content || "" });
    }
  }

  const tools =
    req.tools?.map((t) => ({
      name: t.name,
      description: t.description,
      input_schema: t.parameters,
    })) || undefined;

  return {
    model,
    ...(system ? { system } : {}),
    messages,
    max_tokens: maxTokens,
    temperature,
    ...(stream ? { stream: true } : {}),
    ...(tools && tools.length > 0 ? { tools } : {}),
  };
}

// --- Anthropic response parser ---

function parseAnthropicResponse(
  json: Record<string, unknown>
): Record<string, unknown> {
  const contentBlocks =
    (json.content as Array<Record<string, unknown>>) || [];

  let textContent = "";
  const toolCalls: Array<Record<string, unknown>> = [];

  for (const block of contentBlocks) {
    if (block.type === "text") {
      textContent += (block.text as string) || "";
    } else if (block.type === "tool_use") {
      toolCalls.push({
        id: block.id,
        name: block.name,
        arguments: block.input,
      });
    }
  }

  const usage = (json.usage as Record<string, number>) || {};
  const stopReason = json.stop_reason as string;
  const finishReason =
    stopReason === "end_turn"
      ? "stop"
      : stopReason === "tool_use"
        ? "tool_calls"
        : stopReason || "stop";

  return {
    content: textContent || null,
    finishReason,
    usage: {
      promptTokens: usage.input_tokens || 0,
      completionTokens: usage.output_tokens || 0,
    },
    ...(toolCalls.length > 0 ? { toolCalls } : {}),
  };
}

// --- Fake SSE wrapper (for Anthropic streaming fallback) ---

function buildFakeSse(unified: Record<string, unknown>): string {
  const lines: string[] = [];

  // Text content delta
  if (unified.content) {
    lines.push(
      `data: ${JSON.stringify({
        choices: [
          { delta: { content: unified.content }, finish_reason: null },
        ],
      })}`
    );
  }

  // Tool calls
  const toolCalls = unified.toolCalls as
    | Array<Record<string, unknown>>
    | undefined;
  if (toolCalls) {
    for (let i = 0; i < toolCalls.length; i++) {
      const tc = toolCalls[i];
      // Start
      lines.push(
        `data: ${JSON.stringify({
          choices: [
            {
              delta: {
                tool_calls: [
                  { index: i, id: tc.id, function: { name: tc.name } },
                ],
              },
              finish_reason: null,
            },
          ],
        })}`
      );
      // Arguments (single chunk)
      lines.push(
        `data: ${JSON.stringify({
          choices: [
            {
              delta: {
                tool_calls: [
                  {
                    index: i,
                    function: {
                      arguments: JSON.stringify(tc.arguments),
                    },
                  },
                ],
              },
              finish_reason: null,
            },
          ],
        })}`
      );
    }
  }

  // Finish
  const usage = (unified.usage as Record<string, number>) || {};
  lines.push(
    `data: ${JSON.stringify({
      choices: [
        { delta: {}, finish_reason: unified.finishReason || "stop" },
      ],
      usage: {
        prompt_tokens: usage.promptTokens || 0,
        completion_tokens: usage.completionTokens || 0,
      },
    })}`
  );

  lines.push("data: [DONE]");
  return lines.join("\n\n") + "\n\n";
}

function getApiUrl(providerType: string, model: string): string {
  switch (providerType) {
    case "openai":
      return "https://api.openai.com/v1/chat/completions";
    case "google":
      return `https://generativelanguage.googleapis.com/v1beta/openai/chat/completions`;
    case "anthropic":
      return "https://api.anthropic.com/v1/messages";
    default:
      return "https://api.openai.com/v1/chat/completions";
  }
}

function getApiHeaders(
  providerType: string,
  apiKey: string
): Record<string, string> {
  const base = { "Content-Type": "application/json" };
  switch (providerType) {
    case "openai":
      return { ...base, Authorization: `Bearer ${apiKey}` };
    case "google":
      return { ...base, Authorization: `Bearer ${apiKey}` };
    case "anthropic":
      return {
        ...base,
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
      };
    default:
      return { ...base, Authorization: `Bearer ${apiKey}` };
  }
}

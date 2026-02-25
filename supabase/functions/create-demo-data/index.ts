import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const serviceClient = createClient(supabaseUrl, serviceRoleKey);

const JSON_HEADERS = { "Content-Type": "application/json" };

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function respond(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...JSON_HEADERS, ...corsHeaders },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // --- Authenticate ---
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return respond(
        { ok: false, message: "Missing Authorization header" },
        401,
      );
    }

    const token = authHeader.replace("Bearer ", "");
    const {
      data: { user },
      error: userError,
    } = await serviceClient.auth.getUser(token);

    if (userError || !user) {
      return respond(
        {
          ok: false,
          message: `Auth failed: ${userError?.message ?? "no user"}`,
        },
        401,
      );
    }

    // --- Guard: prevent demo abuse (one company per user) ---
    const { count } = await serviceClient
      .from("companies")
      .select("id", { count: "exact", head: true })
      .eq("auth_user_id", user.id)
      .is("deleted_at", null);

    if (count && count > 0) {
      return respond(
        { ok: false, message: "User already has a company" },
        409,
      );
    }

    // --- Parse params ---
    const { locale, mode, currency_code, company_name } = await req.json();

    if (!locale || !mode || !currency_code || !company_name) {
      return respond(
        { ok: false, message: "Missing required params: locale, mode, currency_code, company_name" },
        400,
      );
    }

    if (!["cs", "en"].includes(locale)) {
      return respond({ ok: false, message: "Invalid locale" }, 400);
    }
    if (!["gastro", "retail"].includes(mode)) {
      return respond({ ok: false, message: "Invalid mode" }, 400);
    }

    // --- Call PL/pgSQL function ---
    const { data, error: rpcError } = await serviceClient.rpc(
      "create_demo_company",
      {
        p_auth_user_id: user.id,
        p_locale: locale,
        p_mode: mode,
        p_currency_code: currency_code,
        p_company_name: company_name,
      },
    );

    if (rpcError) {
      console.error("create_demo_company RPC error:", rpcError);
      return respond(
        { ok: false, message: rpcError.message },
        500,
      );
    }

    // --- Mark company as demo with 24h expiry ---
    const companyId = data?.company_id;
    if (companyId) {
      const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
      const { error: updateError } = await serviceClient
        .from("companies")
        .update({ is_demo: true, demo_expires_at: expiresAt })
        .eq("id", companyId);

      if (updateError) {
        console.error("Failed to mark company as demo:", updateError);
        // Non-fatal — company was created successfully, demo flag is nice-to-have
      }
    }

    // --- Return result ---
    return respond({ ok: true, ...data });
  } catch (error) {
    console.error("create-demo-data error:", error);
    return new Response(
      JSON.stringify({ ok: false, message: String(error) }),
      { status: 500, headers: { ...JSON_HEADERS, ...corsHeaders } },
    );
  }
});

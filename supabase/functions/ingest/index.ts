import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const serviceClient = createClient(supabaseUrl, serviceRoleKey);

const ALLOWED_TABLES = new Set([
  "companies",
  "company_settings",
  "sections",
  "categories",
  "items",
  "modifier_groups",
  "modifier_group_items",
  "item_modifier_groups",
  "tax_rates",
  "payment_methods",
  "users",
  "user_permissions",
  "tables",
  "map_elements",
  "registers",
  "display_devices",
  "layout_items",
  "bills",
  "orders",
  "order_items",
  "order_item_modifiers",
  "payments",
  "register_sessions",
  "cash_movements",
  "shifts",
  "customers",
  "customer_transactions",
  "reservations",
  "vouchers",
  "suppliers",
  "manufacturers",
  "product_recipes",
  "warehouses",
  "stock_levels",
  "stock_documents",
  "stock_movements",
  "company_currencies",
  "session_currency_cash",
]);

interface IngestRequest {
  table: string;
  operation: string;
  payload: Record<string, unknown>;
  idempotency_key?: string;
}

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
    const body: IngestRequest = await req.json();
    const { table, operation, payload, idempotency_key } = body;

    // --- Validate request ---
    if (!table || !operation || !payload || !payload.id) {
      return respond(
        { ok: false, error_type: "rejected", message: "Missing required fields: table, operation, payload (with id)" },
      );
    }

    if (!ALLOWED_TABLES.has(table)) {
      return respond(
        { ok: false, error_type: "rejected", message: `Unknown table: ${table}` },
      );
    }

    // --- Authenticate (verify_jwt=false, we validate manually for better errors) ---
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return respond(
        { ok: false, error_type: "rejected", message: "Missing Authorization header" },
      );
    }

    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: userError } = await serviceClient.auth.getUser(token);

    if (userError || !user) {
      return respond(
        { ok: false, error_type: "rejected", message: `Auth failed: ${userError?.message ?? 'no user'}` },
      );
    }

    // --- Authorize: verify company ownership ---
    const companyId = payload.company_id as string | undefined;
    const entityId = payload.id as string;

    if (table === "companies") {
      if (payload.auth_user_id !== user.id) {
        await logAudit(user.id, companyId, table, entityId, operation, idempotency_key, "forbidden");
        return respond(
          { ok: false, error_type: "rejected", message: "Company auth_user_id mismatch" },
        );
      }
    } else {
      if (!companyId) {
        return respond(
          { ok: false, error_type: "rejected", message: "Missing company_id in payload" },
        );
      }

      const { data: company } = await serviceClient
        .from("companies")
        .select("id")
        .eq("id", companyId)
        .eq("auth_user_id", user.id)
        .is("deleted_at", null)
        .maybeSingle();

      if (!company) {
        await logAudit(user.id, companyId, table, entityId, operation, idempotency_key, "forbidden");
        return respond(
          { ok: false, error_type: "rejected", message: "Not authorized for this company" },
        );
      }
    }

    // --- Strip server-authoritative fields that clients must not set ---
    const SERVER_ONLY_FIELDS: Record<string, string[]> = {
      companies: ["is_demo", "demo_expires_at", "status"],
    };
    const stripped = { ...payload };
    for (const field of SERVER_ONLY_FIELDS[table] ?? []) {
      delete stripped[field];
    }

    // --- Write to target table ---
    const { error: upsertError } = await serviceClient
      .from(table)
      .upsert(stripped as Record<string, unknown>, { onConflict: "id" });

    if (upsertError) {
      const code = upsertError.code ?? "";

      // LWW conflict — not an error, server version wins
      if (code === "P0001" && upsertError.message?.includes("LWW_CONFLICT")) {
        await logAudit(user.id, companyId, table, entityId, operation, idempotency_key, "lww_conflict");
        return respond({ ok: false, error_type: "lww_conflict" });
      }

      // FK violation — parent row may not be synced yet, client should retry
      if (code === "23503") {
        await logAudit(user.id, companyId, table, entityId, operation, idempotency_key, "fk_pending", `${code}: ${upsertError.message}`);
        return respond(
          { ok: false, error_type: "transient", code, message: upsertError.message },
        );
      }

      // Permanent DB errors — client should not retry
      if (code.startsWith("23") || code.startsWith("PGRST") || code.startsWith("42")) {
        await logAudit(user.id, companyId, table, entityId, operation, idempotency_key, "error", `${code}: ${upsertError.message}`);
        return respond(
          { ok: false, error_type: "permanent", code, message: upsertError.message },
        );
      }

      // Transient DB error — propagate as 500 so client retries
      throw upsertError;
    }

    // --- Success ---
    await logAudit(user.id, companyId, table, entityId, operation, idempotency_key, "success");
    return respond({ ok: true });
  } catch (error) {
    console.error("Ingest error:", error);
    return new Response(
      JSON.stringify({ ok: false, error_type: "transient", message: String(error) }),
      { status: 500, headers: { ...JSON_HEADERS, ...corsHeaders } },
    );
  }
});

async function logAudit(
  authUserId: string,
  companyId: string | undefined,
  tableName: string,
  entityId: string,
  operation: string,
  idempotencyKey: string | undefined,
  status: string,
  errorMessage?: string,
) {
  try {
    await serviceClient.from("audit_log").insert({
      auth_user_id: authUserId,
      company_id: companyId ?? null,
      table_name: tableName,
      entity_id: entityId,
      operation,
      idempotency_key: idempotencyKey ?? null,
      status,
      error_message: errorMessage ?? null,
    });
  } catch (e) {
    // Never fail the main operation because of audit logging failure
    console.error("Audit log write failed:", e);
  }
}

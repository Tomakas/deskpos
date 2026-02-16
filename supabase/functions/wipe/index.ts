import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const serviceClient = createClient(supabaseUrl, serviceRoleKey);

const JSON_HEADERS = { "Content-Type": "application/json" };

function respond(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: JSON_HEADERS });
}

// Tables in reverse FK dependency order (children first, parents last).
// Company-scoped tables are deleted WHERE company_id = ?.
// Global tables are deleted unconditionally (1 company = 1 Supabase project).
const COMPANY_TABLES = [
  "stock_movements",
  "stock_documents",
  "stock_levels",
  "customer_transactions",
  "vouchers",
  "shifts",
  "cash_movements",
  "register_sessions",
  "payments",
  "order_items",
  "orders",
  "bills",
  "layout_items",
  "display_devices",
  "registers",
  "product_recipes",
  "reservations",
  "customers",
  "warehouses",
  "map_elements",
  "tables",
  "user_permissions",
  "users",
  "items",
  "manufacturers",
  "suppliers",
  "categories",
  "payment_methods",
  "tax_rates",
  "sections",
  "company_settings",
];

const GLOBAL_TABLES = [
  "role_permissions",
  "permissions",
  "roles",
  "currencies",
];

Deno.serve(async (req) => {
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
    const { data: { user }, error: userError } = await serviceClient.auth.getUser(token);

    if (userError || !user) {
      return respond(
        { ok: false, message: `Auth failed: ${userError?.message ?? "no user"}` },
        401,
      );
    }

    // --- Find company owned by this user ---
    const { data: company, error: companyError } = await serviceClient
      .from("companies")
      .select("id")
      .eq("auth_user_id", user.id)
      .maybeSingle();

    if (companyError) {
      return respond(
        { ok: false, message: `Company lookup failed: ${companyError.message}` },
        500,
      );
    }

    if (!company) {
      // No company found — nothing to wipe, that's OK
      return respond({ ok: true, message: "No company found for this user" });
    }

    const companyId = company.id as string;
    const errors: string[] = [];

    // --- Delete company-scoped tables ---
    for (const table of COMPANY_TABLES) {
      const { error } = await serviceClient
        .from(table)
        .delete()
        .eq("company_id", companyId);

      if (error) {
        errors.push(`${table}: ${error.code} ${error.message}`);
        console.error(`Wipe ${table} failed:`, error);
      }
    }

    // --- Delete the company itself ---
    {
      const { error } = await serviceClient
        .from("companies")
        .delete()
        .eq("id", companyId);

      if (error) {
        errors.push(`companies: ${error.code} ${error.message}`);
        console.error("Wipe companies failed:", error);
      }
    }

    // --- Delete global tables (1 company = 1 Supabase project) ---
    for (const table of GLOBAL_TABLES) {
      const { error } = await serviceClient
        .from(table)
        .delete()
        .neq("id", "__never_matches__");  // delete all rows

      if (error) {
        errors.push(`${table}: ${error.code} ${error.message}`);
        console.error(`Wipe ${table} failed:`, error);
      }
    }

    // --- Clean audit log ---
    await serviceClient.from("audit_log").delete().eq("company_id", companyId);

    if (errors.length > 0) {
      console.error(`Wipe completed with ${errors.length} errors:`, errors);
      return respond({ ok: true, warnings: errors });
    }

    return respond({ ok: true });
  } catch (error) {
    console.error("Wipe error:", error);
    return new Response(
      JSON.stringify({ ok: false, message: String(error) }),
      { status: 500, headers: JSON_HEADERS },
    );
  }
});

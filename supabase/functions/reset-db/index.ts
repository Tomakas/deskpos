import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const resetSecret = Deno.env.get("RESET_SECRET")!;

const serviceClient = createClient(supabaseUrl, serviceRoleKey);

const JSON_HEADERS = { "Content-Type": "application/json" };

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-reset-secret",
};

function respond(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...JSON_HEADERS, ...corsHeaders },
  });
}

// Tables in reverse FK dependency order (children first, parents last).
// Global tables survive reset: currencies, roles, permissions, role_permissions, seed_demo_data.
const COMPANY_TABLES = [
  "stock_movements",
  "stock_documents",
  "stock_levels",
  "customer_transactions",
  "vouchers",
  "shifts",
  "cash_movements",
  "session_currency_cash",
  "register_sessions",
  "payments",
  "order_item_modifiers",
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
  "item_modifier_groups",
  "modifier_group_items",
  "items",
  "modifier_groups",
  "manufacturers",
  "suppliers",
  "categories",
  "payment_methods",
  "tax_rates",
  "sections",
  "company_currencies",
  "company_settings",
];

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // --- Authenticate via shared secret ---
    const secret = req.headers.get("X-Reset-Secret");
    if (!secret || secret !== resetSecret) {
      return respond({ ok: false, message: "Unauthorized" }, 401);
    }

    const errors: string[] = [];
    let deletedRows = 0;

    // --- Get all companies ---
    const { data: companies, error: companyError } = await serviceClient
      .from("companies")
      .select("id");

    if (companyError) {
      return respond(
        { ok: false, message: `Company lookup failed: ${companyError.message}` },
        500,
      );
    }

    // --- Delete company-scoped data for each company ---
    for (const company of companies ?? []) {
      for (const table of COMPANY_TABLES) {
        const { error, count } = await serviceClient
          .from(table)
          .delete({ count: "exact" })
          .eq("company_id", company.id);

        if (error) {
          errors.push(`${table}: ${error.code} ${error.message}`);
          console.error(`Reset ${table} failed:`, error);
        } else {
          deletedRows += count ?? 0;
        }
      }
    }

    // --- Delete all companies ---
    {
      const { error, count } = await serviceClient
        .from("companies")
        .delete({ count: "exact" })
        .neq("id", "00000000-0000-0000-0000-000000000000"); // match all

      if (error) {
        errors.push(`companies: ${error.code} ${error.message}`);
        console.error("Reset companies failed:", error);
      } else {
        deletedRows += count ?? 0;
      }
    }

    // --- Clean system tables ---
    {
      const { error } = await serviceClient
        .from("sync_queue")
        .delete()
        .neq("id", "00000000-0000-0000-0000-000000000000");

      if (error) {
        errors.push(`sync_queue: ${error.code} ${error.message}`);
      }
    }
    {
      const { error } = await serviceClient
        .from("audit_log")
        .delete()
        .neq("id", 0);

      if (error) {
        errors.push(`audit_log: ${error.code} ${error.message}`);
      }
    }

    // --- Delete all auth users ---
    let deletedUsers = 0;
    const { data: authUsers, error: listError } = await serviceClient.auth.admin.listUsers();

    if (listError) {
      errors.push(`listUsers: ${listError.message}`);
      console.error("List auth users failed:", listError);
    } else {
      for (const authUser of authUsers.users) {
        const { error } = await serviceClient.auth.admin.deleteUser(authUser.id);
        if (error) {
          errors.push(`deleteUser ${authUser.email}: ${error.message}`);
          console.error(`Delete auth user ${authUser.email} failed:`, error);
        } else {
          deletedUsers++;
        }
      }
    }

    const result: Record<string, unknown> = {
      ok: true,
      deleted_rows: deletedRows,
      deleted_users: deletedUsers,
    };

    if (errors.length > 0) {
      result.warnings = errors;
    }

    return respond(result);
  } catch (error) {
    console.error("Reset error:", error);
    return new Response(
      JSON.stringify({ ok: false, message: String(error) }),
      { status: 500, headers: { ...JSON_HEADERS, ...corsHeaders } },
    );
  }
});

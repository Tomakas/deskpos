-- Broadcast from Database triggers
-- Replaces Postgres Changes (CDC) with Supabase Broadcast for <2s sync.
-- Each AFTER INSERT OR UPDATE trigger calls realtime.send() to push
-- the full row as JSON to channel sync:{company_id}.
-- DELETE is not triggered — the system uses soft deletes (UPDATE on deleted_at).

-- Trigger function for 35 company-scoped tables (have company_id column)
CREATE OR REPLACE FUNCTION public.broadcast_sync_change()
RETURNS trigger
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM realtime.send(
    jsonb_build_object(
      'table', TG_TABLE_NAME,
      'type', TG_OP,
      'record', to_jsonb(NEW)
    ),
    'change',
    'sync:' || NEW.company_id
  );
  RETURN NULL;
EXCEPTION WHEN OTHERS THEN
  RAISE WARNING 'broadcast_sync_change(%) failed: %', TG_TABLE_NAME, SQLERRM;
  RETURN NULL;
END;
$$;

-- Trigger function for companies table (uses id, not company_id)
CREATE OR REPLACE FUNCTION public.broadcast_company_sync_change()
RETURNS trigger
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM realtime.send(
    jsonb_build_object(
      'table', TG_TABLE_NAME,
      'type', TG_OP,
      'record', to_jsonb(NEW)
    ),
    'change',
    'sync:' || NEW.id
  );
  RETURN NULL;
EXCEPTION WHEN OTHERS THEN
  RAISE WARNING 'broadcast_company_sync_change failed: %', SQLERRM;
  RETURN NULL;
END;
$$;

-- Trigger on companies (special — uses id)
CREATE TRIGGER trg_companies_broadcast
  AFTER INSERT OR UPDATE ON companies
  FOR EACH ROW EXECUTE FUNCTION broadcast_company_sync_change();

-- Triggers on 35 company-scoped tables
DO $$
DECLARE
  tbl text;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY[
    'company_settings', 'sections', 'tax_rates', 'payment_methods',
    'categories', 'users', 'user_permissions', 'tables', 'map_elements',
    'suppliers', 'manufacturers', 'items', 'modifier_groups',
    'modifier_group_items', 'item_modifier_groups', 'product_recipes',
    'registers', 'display_devices', 'layout_items', 'customers',
    'reservations', 'warehouses', 'bills', 'orders', 'order_items',
    'order_item_modifiers', 'payments', 'register_sessions',
    'cash_movements', 'shifts', 'customer_transactions', 'vouchers',
    'stock_levels', 'stock_documents', 'stock_movements'
  ])
  LOOP
    EXECUTE format(
      'CREATE TRIGGER trg_%s_broadcast
       AFTER INSERT OR UPDATE ON %I
       FOR EACH ROW EXECUTE FUNCTION broadcast_sync_change()',
      tbl, tbl
    );
  END LOOP;
END;
$$;

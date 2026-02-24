-- Hourly hard-delete of expired demo companies (all child records + company)
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
  'cleanup-expired-demos',
  '0 * * * *',
  $$
    DO $body$
    DECLARE
      v_company_id text;
    BEGIN
      FOR v_company_id IN
        SELECT id FROM companies
        WHERE is_demo = true
          AND demo_expires_at < now()
          AND deleted_at IS NULL
      LOOP
        -- Delete child records in FK dependency order
        DELETE FROM order_item_modifiers WHERE company_id = v_company_id;
        DELETE FROM order_items WHERE company_id = v_company_id;
        DELETE FROM payments WHERE company_id = v_company_id;
        DELETE FROM orders WHERE company_id = v_company_id;
        DELETE FROM bills WHERE company_id = v_company_id;
        DELETE FROM cash_movements WHERE company_id = v_company_id;
        DELETE FROM session_currency_cash WHERE company_id = v_company_id;
        DELETE FROM register_sessions WHERE company_id = v_company_id;
        DELETE FROM shifts WHERE company_id = v_company_id;
        DELETE FROM customer_transactions WHERE company_id = v_company_id;
        DELETE FROM reservations WHERE company_id = v_company_id;
        DELETE FROM stock_movements WHERE company_id = v_company_id;
        DELETE FROM stock_documents WHERE company_id = v_company_id;
        DELETE FROM stock_levels WHERE company_id = v_company_id;
        DELETE FROM warehouses WHERE company_id = v_company_id;
        DELETE FROM product_recipes WHERE company_id = v_company_id;
        DELETE FROM vouchers WHERE company_id = v_company_id;
        DELETE FROM customers WHERE company_id = v_company_id;
        DELETE FROM suppliers WHERE company_id = v_company_id;
        DELETE FROM manufacturers WHERE company_id = v_company_id;
        DELETE FROM display_devices WHERE company_id = v_company_id;
        DELETE FROM layout_items WHERE company_id = v_company_id;
        DELETE FROM item_modifier_groups WHERE company_id = v_company_id;
        DELETE FROM modifier_group_items WHERE company_id = v_company_id;
        DELETE FROM modifier_groups WHERE company_id = v_company_id;
        DELETE FROM map_elements WHERE company_id = v_company_id;
        DELETE FROM tables WHERE company_id = v_company_id;
        DELETE FROM items WHERE company_id = v_company_id;
        DELETE FROM categories WHERE company_id = v_company_id;
        DELETE FROM sections WHERE company_id = v_company_id;
        DELETE FROM tax_rates WHERE company_id = v_company_id;
        DELETE FROM payment_methods WHERE company_id = v_company_id;
        DELETE FROM user_permissions WHERE company_id = v_company_id;
        DELETE FROM users WHERE company_id = v_company_id;
        DELETE FROM company_currencies WHERE company_id = v_company_id;
        DELETE FROM company_settings WHERE company_id = v_company_id;
        DELETE FROM registers WHERE company_id = v_company_id;
        DELETE FROM audit_log WHERE company_id = v_company_id;
        -- Hard-delete the company itself
        DELETE FROM companies WHERE id = v_company_id;
      END LOOP;
    END $body$;
  $$
);

-- Hourly hard-delete of expired demo companies (all child records + company)
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
  'cleanup-expired-demos',
  '0 * * * *',
  $$
    DO $body$
    DECLARE
      v_company_id text;
      v_created_at timestamptz;
      v_last_activity timestamptz;
      v_usage jsonb;
    BEGIN
      FOR v_company_id IN
        SELECT id FROM companies
        WHERE is_demo = true
          AND demo_expires_at < now()
          AND deleted_at IS NULL
      LOOP
        -- --- Update demo_log with usage metrics before deletion ---
        SELECT dl.created_at INTO v_created_at
        FROM demo_log dl
        WHERE dl.company_id = v_company_id::uuid
          AND dl.expired_at IS NULL
        ORDER BY dl.created_at DESC
        LIMIT 1;

        IF v_created_at IS NOT NULL THEN
          -- Compute last_activity_at across key tables (only records created > 1 min after demo)
          SELECT MAX(t.ts) INTO v_last_activity
          FROM (
            SELECT MAX(created_at) AS ts FROM bills WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'
            UNION ALL
            SELECT MAX(created_at) FROM orders WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'
            UNION ALL
            SELECT MAX(created_at) FROM items WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'
            UNION ALL
            SELECT MAX(created_at) FROM categories WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'
            UNION ALL
            SELECT MAX(created_at) FROM register_sessions WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'
            UNION ALL
            SELECT MAX(created_at) FROM stock_documents WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'
            UNION ALL
            SELECT MAX(created_at) FROM reservations WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'
            UNION ALL
            SELECT MAX(created_at) FROM vouchers WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'
            UNION ALL
            SELECT MAX(created_at) FROM users WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'
            UNION ALL
            SELECT MAX(created_at) FROM tables WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'
            UNION ALL
            SELECT MAX(created_at) FROM map_elements WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'
          ) t;

          -- Build usage JSONB
          SELECT jsonb_build_object(
            'sessions', (SELECT count(*) FROM register_sessions WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'),
            'selling', jsonb_build_object(
              'bills', (SELECT count(*) FROM bills WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'),
              'orders', (SELECT count(*) FROM orders WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'),
              'items_sold', (SELECT coalesce(sum(quantity), 0) FROM order_items oi JOIN orders o ON o.id = oi.order_id AND o.company_id = oi.company_id WHERE oi.company_id = v_company_id AND oi.created_at > v_created_at + interval '1 minute'),
              'revenue', (SELECT coalesce(sum(total_amount), 0) FROM bills WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'),
              'payments', (
                SELECT coalesce(jsonb_object_agg(pm.name, cnt), '{}'::jsonb)
                FROM (
                  SELECT p.payment_method_id, count(*) AS cnt
                  FROM payments p
                  WHERE p.company_id = v_company_id AND p.created_at > v_created_at + interval '1 minute'
                  GROUP BY p.payment_method_id
                ) sub
                JOIN payment_methods pm ON pm.id = sub.payment_method_id AND pm.company_id = v_company_id
              )
            ),
            'inventory', jsonb_build_object(
              'stock_documents', (SELECT count(*) FROM stock_documents WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'),
              'stock_movements', (SELECT count(*) FROM stock_movements WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute')
            ),
            'catalog', jsonb_build_object(
              'items_created', (SELECT count(*) FROM items WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'),
              'categories_created', (SELECT count(*) FROM categories WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute')
            ),
            'setup', jsonb_build_object(
              'map_edited', (SELECT count(*) > 0 FROM map_elements WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'),
              'tables_created', (SELECT count(*) FROM tables WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'),
              'users_created', (SELECT count(*) FROM users WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute')
            ),
            'customers', jsonb_build_object(
              'reservations', (SELECT count(*) FROM reservations WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute'),
              'vouchers_created', (SELECT count(*) FROM vouchers WHERE company_id = v_company_id AND created_at > v_created_at + interval '1 minute')
            )
          ) INTO v_usage;

          UPDATE demo_log
          SET expired_at = now(),
              last_activity_at = v_last_activity,
              usage = v_usage
          WHERE company_id = v_company_id::uuid
            AND expired_at IS NULL;
        END IF;

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

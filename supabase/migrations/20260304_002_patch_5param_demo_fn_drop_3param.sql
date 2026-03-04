-- ============================================================================
-- Migration: 20260304_002_patch_5param_demo_fn_drop_3param
-- Description: Patch the 5-param create_demo_company (used by edge function)
--              to include prep_area/color/template columns in categories & items
--              INSERT. Drop the unused 3-param overload.
-- ============================================================================

-- STEP 1: Drop the unused 3-param overload
DROP FUNCTION IF EXISTS create_demo_company(uuid, text, text);

-- STEP 2: Patch the 5-param overload (returns jsonb)
DO $$
DECLARE
  v_src text;
BEGIN
  SELECT prosrc INTO v_src
  FROM pg_proc p
  JOIN pg_namespace n ON p.pronamespace = n.oid
  WHERE p.proname = 'create_demo_company'
    AND n.nspname = 'public'
    AND pg_get_function_arguments(p.oid) LIKE '%p_currency_code%';

  IF v_src IS NULL THEN
    RAISE NOTICE 'No 5-param create_demo_company found — skipping';
    RETURN;
  END IF;

  -- 2a: Patch categories INSERT column list
  v_src := regexp_replace(
    v_src,
    'INSERT INTO categories \(id, company_id, name, is_active, parent_id, client_created_at, client_updated_at\)',
    'INSERT INTO categories (id, company_id, name, is_active, parent_id, prep_area, default_sale_tax_rate_id, default_purchase_tax_rate_id, default_is_sellable, color, item_color, client_created_at, client_updated_at)'
  );

  -- 2b: Patch categories VALUES — match the unique "true," line before parent_ref
  v_src := regexp_replace(
    v_src,
    E'(      true,\\n'
    || E'      CASE WHEN v_rec\\.data->>''parent_ref'' IS NOT NULL\\n'
    || E'        THEN \\(SELECT id FROM _ref_map WHERE ref = v_rec\\.data->>''parent_ref''\\)\\n'
    || E'        ELSE NULL\\n'
    || E'      END,\\n'
    || E'      v_now, v_now\\n'
    || E'    \\);)',
    E'      true,\n'
    || E'      CASE WHEN v_rec.data->>''parent_ref'' IS NOT NULL\n'
    || E'        THEN (SELECT id FROM _ref_map WHERE ref = v_rec.data->>''parent_ref'')\n'
    || E'        ELSE NULL\n'
    || E'      END,\n'
    || E'      CASE WHEN v_rec.data->>''prep_area'' IS NOT NULL\n'
    || E'        THEN (v_rec.data->>''prep_area'')::prep_area\n'
    || E'        ELSE NULL\n'
    || E'      END,\n'
    || E'      CASE WHEN v_rec.data->>''default_sale_tax_rate_ref'' IS NOT NULL\n'
    || E'        THEN (SELECT id FROM _ref_map WHERE ref = v_rec.data->>''default_sale_tax_rate_ref'')\n'
    || E'        ELSE NULL\n'
    || E'      END,\n'
    || E'      CASE WHEN v_rec.data->>''default_purchase_tax_rate_ref'' IS NOT NULL\n'
    || E'        THEN (SELECT id FROM _ref_map WHERE ref = v_rec.data->>''default_purchase_tax_rate_ref'')\n'
    || E'        ELSE NULL\n'
    || E'      END,\n'
    || E'      (v_rec.data->>''default_is_sellable'')::boolean,\n'
    || E'      v_rec.data->>''color'',\n'
    || E'      v_rec.data->>''item_color'',\n'
    || E'      v_now, v_now\n'
    || E'    );'
  );

  -- 2c: Patch items INSERT column list
  v_src := regexp_replace(
    v_src,
    E'INSERT INTO items \\(id, company_id, category_id, name, description, item_type, sku, unit_price,\\n'
    || E'                       sale_tax_rate_id, is_sellable, is_active, unit, alt_sku, purchase_price,\\n'
    || E'                       purchase_tax_rate_id, is_stock_tracked, min_quantity, manufacturer_id, supplier_id, parent_id,\\n'
    || E'                       client_created_at, client_updated_at\\)',
    E'INSERT INTO items (id, company_id, category_id, name, description, item_type, sku, unit_price,\n'
    || E'                       sale_tax_rate_id, is_sellable, is_active, unit, alt_sku, purchase_price,\n'
    || E'                       purchase_tax_rate_id, is_stock_tracked, min_quantity, manufacturer_id, supplier_id, parent_id,\n'
    || E'                       prep_area, color,\n'
    || E'                       client_created_at, client_updated_at)'
  );

  -- 2d: Patch items VALUES — match "supplier_ref" CASE before parent_ref (unique to items)
  v_src := regexp_replace(
    v_src,
    E'(CASE WHEN v_rec\\.data->>''supplier_ref'' IS NOT NULL\\n'
    || E'        THEN \\(SELECT id FROM _ref_map WHERE ref = v_rec\\.data->>''supplier_ref''\\)\\n'
    || E'        ELSE NULL\\n'
    || E'      END,\\n'
    || E'      CASE WHEN v_rec\\.data->>''parent_ref'' IS NOT NULL\\n'
    || E'        THEN \\(SELECT id FROM _ref_map WHERE ref = v_rec\\.data->>''parent_ref''\\)\\n'
    || E'        ELSE NULL\\n'
    || E'      END,\\n'
    || E'      v_now, v_now\\n'
    || E'    \\);)',
    E'CASE WHEN v_rec.data->>''supplier_ref'' IS NOT NULL\n'
    || E'        THEN (SELECT id FROM _ref_map WHERE ref = v_rec.data->>''supplier_ref'')\n'
    || E'        ELSE NULL\n'
    || E'      END,\n'
    || E'      CASE WHEN v_rec.data->>''parent_ref'' IS NOT NULL\n'
    || E'        THEN (SELECT id FROM _ref_map WHERE ref = v_rec.data->>''parent_ref'')\n'
    || E'        ELSE NULL\n'
    || E'      END,\n'
    || E'      CASE WHEN v_rec.data->>''prep_area'' IS NOT NULL\n'
    || E'        THEN (v_rec.data->>''prep_area'')::prep_area\n'
    || E'        ELSE NULL\n'
    || E'      END,\n'
    || E'      v_rec.data->>''color'',\n'
    || E'      v_now, v_now\n'
    || E'    );'
  );

  -- Recreate with correct return type (jsonb)
  EXECUTE format(
    $func$
    CREATE OR REPLACE FUNCTION create_demo_company(
      p_auth_user_id uuid,
      p_locale text DEFAULT 'cs',
      p_mode text DEFAULT 'gastro',
      p_currency_code text DEFAULT 'CZK',
      p_company_name text DEFAULT NULL
    ) RETURNS jsonb
    LANGUAGE plpgsql
    SECURITY DEFINER
    SET statement_timeout = '30s'
    AS $body$
    %s
    $body$;
    $func$,
    v_src
  );
END $$;

NOTIFY pgrst, 'reload schema';

-- ============================================================================
-- Migration: 20260304_001_add_prep_area_and_category_templates
-- Description: Add prep_area enum, category template columns (default tax,
--              sellable, colors), item prep_area + color, company auto-print.
-- ============================================================================

-- STEP 1: Create prep_area enum type
CREATE TYPE prep_area AS ENUM ('kitchen', 'bar', 'all', 'none');

-- STEP 2: Categories — add 6 columns
ALTER TABLE categories
  ADD COLUMN IF NOT EXISTS prep_area prep_area,
  ADD COLUMN IF NOT EXISTS default_sale_tax_rate_id text REFERENCES tax_rates(id),
  ADD COLUMN IF NOT EXISTS default_purchase_tax_rate_id text REFERENCES tax_rates(id),
  ADD COLUMN IF NOT EXISTS default_is_sellable boolean,
  ADD COLUMN IF NOT EXISTS color text,
  ADD COLUMN IF NOT EXISTS item_color text;

-- STEP 3: Items — add 2 columns
ALTER TABLE items
  ADD COLUMN IF NOT EXISTS prep_area prep_area,
  ADD COLUMN IF NOT EXISTS color text;

-- STEP 4: Companies — add auto-print setting
ALTER TABLE companies
  ADD COLUMN IF NOT EXISTS auto_print_order_tickets boolean DEFAULT false;

-- STEP 5: Update seed_demo_data — categories with prep_area, color, item_color, default_sale_tax_rate_ref

-- cs/gastro categories
UPDATE seed_demo_data SET data = '{"name":"Nápoje","prep_area":"bar","color":"#4CAF50","item_color":"linear:135:#66BB6A,#2E7D32","default_sale_tax_rate_ref":"tax:12","default_purchase_tax_rate_ref":"tax:12","default_is_sellable":true}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'cat:napoje';
UPDATE seed_demo_data SET data = '{"name":"Pivo","prep_area":"bar","color":"#FF9800","item_color":"linear:135:#FFB74D,#E65100","default_sale_tax_rate_ref":"tax:21","default_purchase_tax_rate_ref":"tax:21","default_is_sellable":true}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'cat:pivo';
UPDATE seed_demo_data SET data = '{"name":"Hlavní jídla","prep_area":"kitchen","color":"#F44336","item_color":"linear:135:#EF5350,#C62828","default_sale_tax_rate_ref":"tax:12","default_purchase_tax_rate_ref":"tax:12","default_is_sellable":true}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'cat:hlavni_jidla';
UPDATE seed_demo_data SET data = '{"name":"Předkrmy","prep_area":"kitchen","color":"#9C27B0","item_color":"linear:135:#CE93D8,#7B1FA2","default_sale_tax_rate_ref":"tax:12","default_purchase_tax_rate_ref":"tax:12","default_is_sellable":true}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'cat:predkrmy';
UPDATE seed_demo_data SET data = '{"name":"Dezerty","prep_area":"kitchen","color":"#E91E63","item_color":"linear:135:#F48FB1,#C2185B","default_sale_tax_rate_ref":"tax:12","default_purchase_tax_rate_ref":"tax:12","default_is_sellable":true}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'cat:dezerty';
UPDATE seed_demo_data SET data = '{"name":"Suroviny","color":"#795548","item_color":"linear:135:#8D6E63,#4E342E","default_sale_tax_rate_ref":"tax:12","default_purchase_tax_rate_ref":"tax:12","default_is_sellable":false}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'cat:suroviny';
UPDATE seed_demo_data SET data = '{"name":"Služby","color":"#607D8B","item_color":"linear:135:#78909C,#37474F","default_sale_tax_rate_ref":"tax:21","default_purchase_tax_rate_ref":"tax:21","default_is_sellable":true}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'cat:sluzby';

-- en/gastro categories
UPDATE seed_demo_data SET data = '{"name":"Beverages","prep_area":"bar","color":"#4CAF50","item_color":"linear:135:#66BB6A,#2E7D32","default_sale_tax_rate_ref":"tax:12","default_purchase_tax_rate_ref":"tax:12","default_is_sellable":true}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'cat:napoje';
UPDATE seed_demo_data SET data = '{"name":"Beer","prep_area":"bar","color":"#FF9800","item_color":"linear:135:#FFB74D,#E65100","default_sale_tax_rate_ref":"tax:21","default_purchase_tax_rate_ref":"tax:21","default_is_sellable":true}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'cat:pivo';
UPDATE seed_demo_data SET data = '{"name":"Main Courses","prep_area":"kitchen","color":"#F44336","item_color":"linear:135:#EF5350,#C62828","default_sale_tax_rate_ref":"tax:12","default_purchase_tax_rate_ref":"tax:12","default_is_sellable":true}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'cat:hlavni_jidla';
UPDATE seed_demo_data SET data = '{"name":"Starters","prep_area":"kitchen","color":"#9C27B0","item_color":"linear:135:#CE93D8,#7B1FA2","default_sale_tax_rate_ref":"tax:12","default_purchase_tax_rate_ref":"tax:12","default_is_sellable":true}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'cat:predkrmy';
UPDATE seed_demo_data SET data = '{"name":"Desserts","prep_area":"kitchen","color":"#E91E63","item_color":"linear:135:#F48FB1,#C2185B","default_sale_tax_rate_ref":"tax:12","default_purchase_tax_rate_ref":"tax:12","default_is_sellable":true}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'cat:dezerty';
UPDATE seed_demo_data SET data = '{"name":"Ingredients","color":"#795548","item_color":"linear:135:#8D6E63,#4E342E","default_sale_tax_rate_ref":"tax:12","default_purchase_tax_rate_ref":"tax:12","default_is_sellable":false}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'cat:suroviny';
UPDATE seed_demo_data SET data = '{"name":"Services","color":"#607D8B","item_color":"linear:135:#78909C,#37474F","default_sale_tax_rate_ref":"tax:21","default_purchase_tax_rate_ref":"tax:21","default_is_sellable":true}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'cat:sluzby';

-- cs/retail categories
UPDATE seed_demo_data SET data = '{"name":"Nápoje","color":"#4CAF50","item_color":"linear:135:#66BB6A,#2E7D32","default_sale_tax_rate_ref":"tax:21","default_purchase_tax_rate_ref":"tax:21","default_is_sellable":true}'
  WHERE locale = 'cs' AND mode = 'retail' AND ref = 'cat:beverages_r';
UPDATE seed_demo_data SET data = '{"name":"Potraviny","color":"#FF9800","item_color":"linear:135:#FFB74D,#E65100","default_sale_tax_rate_ref":"tax:21","default_purchase_tax_rate_ref":"tax:21","default_is_sellable":true}'
  WHERE locale = 'cs' AND mode = 'retail' AND ref = 'cat:groceries';
UPDATE seed_demo_data SET data = '{"name":"Drogerie","color":"#9C27B0","item_color":"linear:135:#CE93D8,#7B1FA2","default_sale_tax_rate_ref":"tax:21","default_purchase_tax_rate_ref":"tax:21","default_is_sellable":true}'
  WHERE locale = 'cs' AND mode = 'retail' AND ref = 'cat:household';
UPDATE seed_demo_data SET data = '{"name":"Alkohol & Tabák","color":"#F44336","item_color":"linear:135:#EF5350,#C62828","default_sale_tax_rate_ref":"tax:21","default_purchase_tax_rate_ref":"tax:21","default_is_sellable":true}'
  WHERE locale = 'cs' AND mode = 'retail' AND ref = 'cat:alcohol';
UPDATE seed_demo_data SET data = '{"name":"Noviny & Časopisy","color":"#546E7A","item_color":"linear:135:#78909C,#37474F","default_sale_tax_rate_ref":"tax:21","default_purchase_tax_rate_ref":"tax:21","default_is_sellable":true}'
  WHERE locale = 'cs' AND mode = 'retail' AND ref = 'cat:press';

-- en/retail categories
UPDATE seed_demo_data SET data = '{"name":"Beverages","color":"#4CAF50","item_color":"linear:135:#66BB6A,#2E7D32","default_sale_tax_rate_ref":"tax:21","default_purchase_tax_rate_ref":"tax:21","default_is_sellable":true}'
  WHERE locale = 'en' AND mode = 'retail' AND ref = 'cat:beverages_r';
UPDATE seed_demo_data SET data = '{"name":"Groceries","color":"#FF9800","item_color":"linear:135:#FFB74D,#E65100","default_sale_tax_rate_ref":"tax:21","default_purchase_tax_rate_ref":"tax:21","default_is_sellable":true}'
  WHERE locale = 'en' AND mode = 'retail' AND ref = 'cat:groceries';
UPDATE seed_demo_data SET data = '{"name":"Household","color":"#9C27B0","item_color":"linear:135:#CE93D8,#7B1FA2","default_sale_tax_rate_ref":"tax:21","default_purchase_tax_rate_ref":"tax:21","default_is_sellable":true}'
  WHERE locale = 'en' AND mode = 'retail' AND ref = 'cat:household';
UPDATE seed_demo_data SET data = '{"name":"Alcohol & Tobacco","color":"#F44336","item_color":"linear:135:#EF5350,#C62828","default_sale_tax_rate_ref":"tax:21","default_purchase_tax_rate_ref":"tax:21","default_is_sellable":true}'
  WHERE locale = 'en' AND mode = 'retail' AND ref = 'cat:alcohol';
UPDATE seed_demo_data SET data = '{"name":"Press","color":"#546E7A","item_color":"linear:135:#78909C,#37474F","default_sale_tax_rate_ref":"tax:21","default_purchase_tax_rate_ref":"tax:21","default_is_sellable":true}'
  WHERE locale = 'en' AND mode = 'retail' AND ref = 'cat:press';

-- STEP 6: Patch create_demo_company() — add new columns to categories + items INSERT
--
-- Strategy: use unique surrounding context to avoid ambiguous matches.
-- Categories block has "true," before parent_ref (is_active).
-- Items block has "supplier_ref" before parent_ref.
DO $$
DECLARE
  v_src text;
BEGIN
  SELECT prosrc INTO v_src
  FROM pg_proc
  WHERE proname = 'create_demo_company';

  -- 6a: Patch categories INSERT column list
  v_src := regexp_replace(
    v_src,
    'INSERT INTO categories \(id, company_id, name, is_active, parent_id, client_created_at, client_updated_at\)',
    'INSERT INTO categories (id, company_id, name, is_active, parent_id, prep_area, default_sale_tax_rate_id, default_purchase_tax_rate_id, default_is_sellable, color, item_color, client_created_at, client_updated_at)'
  );

  -- 6b: Patch categories VALUES — match the unique "true," line before parent_ref
  --     to distinguish from items block (which has supplier_ref before parent_ref)
  v_src := regexp_replace(
    v_src,
    E'(      true,\n'                                                              -- is_active (unique to categories)
    || E'      CASE WHEN v_rec\\.data->>''parent_ref'' IS NOT NULL\n'
    || E'        THEN \\(SELECT id FROM _ref_map WHERE ref = v_rec\\.data->>''parent_ref''\\)\n'
    || E'        ELSE NULL\n'
    || E'      END,\n'
    || E'      v_now, v_now\n'
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

  -- 6c: Patch items INSERT column list
  v_src := regexp_replace(
    v_src,
    E'INSERT INTO items \\(id, company_id, category_id, name, description, item_type, sku, unit_price,\n'
    || E'                       sale_tax_rate_id, is_sellable, is_active, unit, alt_sku, purchase_price,\n'
    || E'                       purchase_tax_rate_id, is_stock_tracked, min_quantity, manufacturer_id, supplier_id, parent_id,\n'
    || E'                       client_created_at, client_updated_at\\)',
    E'INSERT INTO items (id, company_id, category_id, name, description, item_type, sku, unit_price,\n'
    || E'                       sale_tax_rate_id, is_sellable, is_active, unit, alt_sku, purchase_price,\n'
    || E'                       purchase_tax_rate_id, is_stock_tracked, min_quantity, manufacturer_id, supplier_id, parent_id,\n'
    || E'                       prep_area, color,\n'
    || E'                       client_created_at, client_updated_at)'
  );

  -- 6d: Patch items VALUES — match "supplier_ref" CASE before parent_ref (unique to items)
  v_src := regexp_replace(
    v_src,
    E'(CASE WHEN v_rec\\.data->>''supplier_ref'' IS NOT NULL\n'    -- unique anchor: supplier_ref
    || E'        THEN \\(SELECT id FROM _ref_map WHERE ref = v_rec\\.data->>''supplier_ref''\\)\n'
    || E'        ELSE NULL\n'
    || E'      END,\n'
    || E'      CASE WHEN v_rec\\.data->>''parent_ref'' IS NOT NULL\n'
    || E'        THEN \\(SELECT id FROM _ref_map WHERE ref = v_rec\\.data->>''parent_ref''\\)\n'
    || E'        ELSE NULL\n'
    || E'      END,\n'
    || E'      v_now, v_now\n'
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

  -- Recreate function with patched source
  EXECUTE format(
    $func$
    CREATE OR REPLACE FUNCTION create_demo_company(
      p_user_id uuid,
      p_locale text DEFAULT 'cs',
      p_mode text DEFAULT 'gastro'
    ) RETURNS uuid
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

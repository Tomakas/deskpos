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

-- STEP 6: Update seed_demo_data — floor map layout (tables + map_elements)
-- Tables: update colors to match current layout, remove font_size
-- Both locales share same layout, only names differ

-- tbl:1,2,3 — round tables: solid brown
UPDATE seed_demo_data SET data = '{"name":"Stůl 1","section_ref":"sec:hlavni","capacity":4,"grid_row":1,"grid_col":1,"grid_width":4,"grid_height":4,"shape":"round","color":"#6D4C41","fill_style":2}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'tbl:1';
UPDATE seed_demo_data SET data = '{"name":"Stůl 2","section_ref":"sec:hlavni","capacity":4,"grid_row":7,"grid_col":1,"grid_width":4,"grid_height":4,"shape":"round","color":"#6D4C41","fill_style":2}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'tbl:2';
UPDATE seed_demo_data SET data = '{"name":"Stůl 3","section_ref":"sec:hlavni","capacity":4,"grid_row":13,"grid_col":1,"grid_width":4,"grid_height":4,"shape":"round","color":"#6D4C41","fill_style":2}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'tbl:3';
-- tbl:4,5,6 — diamond tables: remove font_size
UPDATE seed_demo_data SET data = '{"name":"Stůl 4","section_ref":"sec:hlavni","capacity":4,"grid_row":1,"grid_col":9,"grid_width":4,"grid_height":4,"shape":"diamond","color":"linear:135:#AB47BC,#5C6BC0","fill_style":2}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'tbl:4';
UPDATE seed_demo_data SET data = '{"name":"Stůl 5","section_ref":"sec:hlavni","capacity":4,"grid_row":1,"grid_col":17,"grid_width":4,"grid_height":4,"shape":"diamond","color":"linear:135:#AB47BC,#5C6BC0","fill_style":2}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'tbl:5';
UPDATE seed_demo_data SET data = '{"name":"Stůl 6","section_ref":"sec:hlavni","grid_row":1,"grid_col":25,"grid_width":4,"grid_height":4,"shape":"diamond","color":"linear:135:#AB47BC,#5C6BC0","fill_style":2}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'tbl:6';
-- tbl:7 — large table: updated gradient
UPDATE seed_demo_data SET data = '{"name":"Stůl 7","section_ref":"sec:hlavni","grid_row":10,"grid_col":10,"grid_width":7,"grid_height":4,"color":"linear:135:#6D4C41,#FF5722","fill_style":2}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'tbl:7';
-- bar tables: remove font_size
UPDATE seed_demo_data SET data = '{"name":"Bar 1","section_ref":"sec:hlavni","grid_row":8,"grid_col":22,"grid_width":2,"grid_height":2,"color":"linear:135:#43A047,#C0CA33","fill_style":2}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'tbl:bar1';
UPDATE seed_demo_data SET data = '{"name":"Bar 2","section_ref":"sec:hlavni","grid_row":11,"grid_col":22,"grid_width":2,"grid_height":2,"color":"linear:135:#43A047,#C0CA33","fill_style":2}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'tbl:bar2';
UPDATE seed_demo_data SET data = '{"name":"Bar 3","section_ref":"sec:hlavni","grid_row":14,"grid_col":22,"grid_width":2,"grid_height":2,"color":"linear:135:#43A047,#C0CA33","fill_style":2}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'tbl:bar3';

-- en/gastro tables — same layout, English names
UPDATE seed_demo_data SET data = '{"name":"Table 1","section_ref":"sec:hlavni","capacity":4,"grid_row":1,"grid_col":1,"grid_width":4,"grid_height":4,"shape":"round","color":"#6D4C41","fill_style":2}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'tbl:1';
UPDATE seed_demo_data SET data = '{"name":"Table 2","section_ref":"sec:hlavni","capacity":4,"grid_row":7,"grid_col":1,"grid_width":4,"grid_height":4,"shape":"round","color":"#6D4C41","fill_style":2}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'tbl:2';
UPDATE seed_demo_data SET data = '{"name":"Table 3","section_ref":"sec:hlavni","capacity":4,"grid_row":13,"grid_col":1,"grid_width":4,"grid_height":4,"shape":"round","color":"#6D4C41","fill_style":2}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'tbl:3';
UPDATE seed_demo_data SET data = '{"name":"Table 4","section_ref":"sec:hlavni","capacity":4,"grid_row":1,"grid_col":9,"grid_width":4,"grid_height":4,"shape":"diamond","color":"linear:135:#AB47BC,#5C6BC0","fill_style":2}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'tbl:4';
UPDATE seed_demo_data SET data = '{"name":"Table 5","section_ref":"sec:hlavni","capacity":4,"grid_row":1,"grid_col":17,"grid_width":4,"grid_height":4,"shape":"diamond","color":"linear:135:#AB47BC,#5C6BC0","fill_style":2}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'tbl:5';
UPDATE seed_demo_data SET data = '{"name":"Table 6","section_ref":"sec:hlavni","grid_row":1,"grid_col":25,"grid_width":4,"grid_height":4,"shape":"diamond","color":"linear:135:#AB47BC,#5C6BC0","fill_style":2}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'tbl:6';
UPDATE seed_demo_data SET data = '{"name":"Table 7","section_ref":"sec:hlavni","grid_row":10,"grid_col":10,"grid_width":7,"grid_height":4,"color":"linear:135:#6D4C41,#FF5722","fill_style":2}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'tbl:7';
UPDATE seed_demo_data SET data = '{"name":"Bar 1","section_ref":"sec:hlavni","grid_row":8,"grid_col":22,"grid_width":2,"grid_height":2,"color":"linear:135:#43A047,#C0CA33","fill_style":2}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'tbl:bar1';
UPDATE seed_demo_data SET data = '{"name":"Bar 2","section_ref":"sec:hlavni","grid_row":11,"grid_col":22,"grid_width":2,"grid_height":2,"color":"linear:135:#43A047,#C0CA33","fill_style":2}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'tbl:bar2';
UPDATE seed_demo_data SET data = '{"name":"Bar 3","section_ref":"sec:hlavni","grid_row":14,"grid_col":22,"grid_width":2,"grid_height":2,"color":"linear:135:#43A047,#C0CA33","fill_style":2}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'tbl:bar3';

-- Map elements: update wall styles, BAR gradient, bar_h position, exit position
-- cs/gastro
UPDATE seed_demo_data SET data = '{"section_ref":"sec:hlavni","grid_row":0,"grid_col":6,"grid_width":1,"grid_height":11,"color":"#000000","fill_style":2,"border_style":0}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'me:wall1';
UPDATE seed_demo_data SET data = '{"section_ref":"sec:hlavni","grid_row":7,"grid_col":24,"grid_width":2,"grid_height":11,"label":"BAR","color":"linear:135:#6D4C41,#FF5722","font_size":14,"fill_style":2,"border_style":2}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'me:bar_v';
UPDATE seed_demo_data SET data = '{"section_ref":"sec:hlavni","grid_row":7,"grid_col":25,"grid_width":7,"grid_height":2,"color":"#6D4C41","fill_style":2,"border_style":0}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'me:bar_h';
UPDATE seed_demo_data SET data = '{"section_ref":"sec:hlavni","grid_row":13,"grid_col":6,"grid_width":1,"grid_height":7,"color":"#000000","fill_style":2,"border_style":0}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'me:wall2';
UPDATE seed_demo_data SET data = '{"section_ref":"sec:hlavni","grid_row":18,"grid_col":11,"grid_width":9,"grid_height":2,"label":"EXIT","font_size":20,"fill_style":2,"border_style":2}'
  WHERE locale = 'cs' AND mode = 'gastro' AND ref = 'me:exit';
-- en/gastro
UPDATE seed_demo_data SET data = '{"section_ref":"sec:hlavni","grid_row":0,"grid_col":6,"grid_width":1,"grid_height":11,"color":"#000000","fill_style":2,"border_style":0}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'me:wall1';
UPDATE seed_demo_data SET data = '{"section_ref":"sec:hlavni","grid_row":7,"grid_col":24,"grid_width":2,"grid_height":11,"label":"BAR","color":"linear:135:#6D4C41,#FF5722","font_size":14,"fill_style":2,"border_style":2}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'me:bar_v';
UPDATE seed_demo_data SET data = '{"section_ref":"sec:hlavni","grid_row":7,"grid_col":25,"grid_width":7,"grid_height":2,"color":"#6D4C41","fill_style":2,"border_style":0}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'me:bar_h';
UPDATE seed_demo_data SET data = '{"section_ref":"sec:hlavni","grid_row":13,"grid_col":6,"grid_width":1,"grid_height":7,"color":"#000000","fill_style":2,"border_style":0}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'me:wall2';
UPDATE seed_demo_data SET data = '{"section_ref":"sec:hlavni","grid_row":18,"grid_col":11,"grid_width":9,"grid_height":2,"label":"EXIT","font_size":20,"fill_style":2,"border_style":2}'
  WHERE locale = 'en' AND mode = 'gastro' AND ref = 'me:exit';

-- STEP 7: Patch create_demo_company() — add new columns to categories + items INSERT
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

  -- 7a: Patch categories INSERT column list
  v_src := regexp_replace(
    v_src,
    'INSERT INTO categories \(id, company_id, name, is_active, parent_id, client_created_at, client_updated_at\)',
    'INSERT INTO categories (id, company_id, name, is_active, parent_id, prep_area, default_sale_tax_rate_id, default_purchase_tax_rate_id, default_is_sellable, color, item_color, client_created_at, client_updated_at)'
  );

  -- 7b: Patch categories VALUES — match the unique "true," line before parent_ref
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

  -- 7c: Patch items INSERT column list
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

  -- 7d: Patch items VALUES — match "supplier_ref" CASE before parent_ref (unique to items)
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
      p_auth_user_id uuid,
      p_locale text,
      p_mode text,
      p_currency_code text,
      p_company_name text
    ) RETURNS uuid
    LANGUAGE plpgsql
    SECURITY DEFINER
    SET statement_timeout = '60s'
    AS $body$
    %s
    $body$;
    $func$,
    v_src
  );
END $$;

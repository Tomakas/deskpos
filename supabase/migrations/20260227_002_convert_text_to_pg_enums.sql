-- ============================================================================
-- Migration: convert 4 text columns to PG enum types
--
-- Columns:
--   registers.sell_mode              -> sell_mode enum
--   companies.business_type          -> business_type enum
--   company_settings.negative_stock_policy -> negative_stock_policy enum
--   items.negative_stock_policy      -> negative_stock_policy enum (shared type)
--
-- Dart changes: NONE (PostgREST auto-casts text<->enum transparently)
-- ============================================================================

-- STEP 1: Create the 3 new enum types

CREATE TYPE sell_mode AS ENUM ('gastro', 'retail');

CREATE TYPE business_type AS ENUM (
  'restaurant', 'bar', 'cafe', 'canteen', 'bistro', 'bakery', 'foodTruck',
  'grocery', 'clothing', 'electronics', 'generalStore', 'florist',
  'hairdresser', 'beautySalon', 'fitness', 'autoService',
  'other'
);

CREATE TYPE negative_stock_policy AS ENUM ('allow', 'warn', 'block');

-- STEP 2: Drop CHECK constraint (incompatible with enum type)

ALTER TABLE registers DROP CONSTRAINT IF EXISTS chk_sell_mode;

-- STEP 3: Convert columns

ALTER TABLE registers
  ALTER COLUMN sell_mode DROP DEFAULT,
  ALTER COLUMN sell_mode TYPE sell_mode USING sell_mode::sell_mode,
  ALTER COLUMN sell_mode SET DEFAULT 'gastro'::sell_mode;

ALTER TABLE companies
  ALTER COLUMN business_type TYPE business_type USING business_type::business_type;

ALTER TABLE company_settings
  ALTER COLUMN negative_stock_policy DROP DEFAULT,
  ALTER COLUMN negative_stock_policy TYPE negative_stock_policy USING negative_stock_policy::negative_stock_policy,
  ALTER COLUMN negative_stock_policy SET DEFAULT 'allow'::negative_stock_policy;

ALTER TABLE items
  ALTER COLUMN negative_stock_policy TYPE negative_stock_policy USING negative_stock_policy::negative_stock_policy;

-- STEP 4: Patch create_demo_company() — add explicit enum casts
-- Also fixes latent bug: ELSE p_mode -> ELSE 'other' (p_mode values are not
-- valid business_type labels, the ELSE branch was effectively dead code but
-- would crash after enum migration if ever reached)

DO $$
DECLARE
  v_src text;
BEGIN
  SELECT prosrc INTO v_src
  FROM pg_proc
  WHERE proname = 'create_demo_company';

  -- 4a: sell_mode — wrap CASE in ::sell_mode cast
  v_src := regexp_replace(
    v_src,
    E'CASE p_mode WHEN ''retail'' THEN ''retail'' ELSE ''gastro'' END,',
    E'(CASE p_mode WHEN ''retail'' THEN ''retail'' ELSE ''gastro'' END)::sell_mode,',
    'g'
  );

  -- 4b: business_type — wrap CASE in ::business_type cast + fix ELSE branch
  v_src := regexp_replace(
    v_src,
    E'CASE p_mode WHEN ''gastro'' THEN ''restaurant'' WHEN ''retail'' THEN ''generalStore'' ELSE p_mode END,',
    E'(CASE p_mode WHEN ''gastro'' THEN ''restaurant'' WHEN ''retail'' THEN ''generalStore'' ELSE ''other'' END)::business_type,',
    'g'
  );

  EXECUTE format(
    $fn$
    CREATE OR REPLACE FUNCTION create_demo_company(
      p_auth_user_id uuid,
      p_locale text,
      p_mode text,
      p_currency_code text,
      p_company_name text
    ) RETURNS jsonb
    LANGUAGE plpgsql
    SECURITY DEFINER
    SET search_path = public, extensions
    SET statement_timeout = '300s'
    AS $body$%s$body$
    $fn$,
    v_src
  );
END;
$$;

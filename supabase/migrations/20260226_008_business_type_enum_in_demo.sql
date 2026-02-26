-- ============================================================================
-- Migration: 20260226_008_business_type_enum_in_demo
-- Description: Patch create_demo_company() to map p_mode ('gastro'/'retail')
--              to valid BusinessType enum values ('restaurant'/'generalStore')
--              in the business_type column.
-- Approach:    Replace the function body using CREATE OR REPLACE, but only
--              change the single line that inserts p_mode into business_type.
-- ============================================================================

-- We use a DO block with dynamic SQL to patch the existing function source.
-- This avoids duplicating the entire 1800-line function definition.
DO $$
DECLARE
  v_src text;
BEGIN
  -- Get current function source
  SELECT prosrc INTO v_src
  FROM pg_proc
  WHERE proname = 'create_demo_company';

  -- Replace the literal "p_mode," that inserts into business_type
  -- with a CASE expression mapping to valid enum values.
  -- The pattern: line ending with "p_mode," followed by whitespace and "true, v_now"
  v_src := regexp_replace(
    v_src,
    E'(CASE p_locale WHEN ''cs'' THEN ''Europe/Prague'' ELSE ''Europe/Vienna'' END,\n    )p_mode,',
    E'\\1CASE p_mode WHEN ''gastro'' THEN ''restaurant'' WHEN ''retail'' THEN ''generalStore'' ELSE p_mode END,',
    'g'
  );

  -- Re-create the function with patched source
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

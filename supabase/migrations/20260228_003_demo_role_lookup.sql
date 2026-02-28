-- Replace hardcoded role UUIDs with SELECT lookups in create_demo_company().
-- This makes the function resilient to role UUID changes.

DO $outer$
DECLARE
  v_src text;
  v_old_begin text;
  v_new_begin text;
BEGIN
  SELECT prosrc INTO v_src
  FROM pg_proc
  WHERE proname = 'create_demo_company';

  -- Replace hardcoded UUID assignments with uninitialized declarations
  v_src := replace(v_src, $$v_role_admin    text := '01930000-0000-7000-8000-000000000103';$$, $$v_role_admin    text;$$);
  v_src := replace(v_src, $$v_role_manager  text := '01930000-0000-7000-8000-000000000104';$$, $$v_role_manager  text;$$);
  v_src := replace(v_src, $$v_role_operator text := '01930000-0000-7000-8000-000000000102';$$, $$v_role_operator text;$$);
  v_src := replace(v_src, $$v_role_helper   text := '01930000-0000-7000-8000-000000000101';$$, $$v_role_helper   text;$$);

  -- Update the comment
  v_src := replace(v_src, '-- Role IDs (fixed, from global seed)', '-- Role IDs (looked up from roles table)');

  -- Insert SELECT lookups right after the first BEGIN
  v_old_begin := 'BEGIN' || chr(10) || '  -- ========================================================================' || chr(10) || '  -- STEP 1: Setup';
  v_new_begin := 'BEGIN' || chr(10)
    || '  -- Look up role IDs dynamically instead of hardcoding UUIDs' || chr(10)
    || '  SELECT id::text INTO STRICT v_role_admin    FROM roles WHERE name = ''admin'';' || chr(10)
    || '  SELECT id::text INTO STRICT v_role_manager  FROM roles WHERE name = ''manager'';' || chr(10)
    || '  SELECT id::text INTO STRICT v_role_operator FROM roles WHERE name = ''operator'';' || chr(10)
    || '  SELECT id::text INTO STRICT v_role_helper   FROM roles WHERE name = ''helper'';' || chr(10)
    || chr(10)
    || '  -- ========================================================================' || chr(10)
    || '  -- STEP 1: Setup';
  v_src := replace(v_src, v_old_begin, v_new_begin);

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
$outer$;

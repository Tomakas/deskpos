-- Move pgcrypto from public to extensions schema (Supabase security best practice).
-- Only create_demo_company uses gen_random_bytes() and digest() from pgcrypto.
-- gen_random_uuid() has a pg_catalog fallback (PG 13+), so it's unaffected.
ALTER EXTENSION pgcrypto SET SCHEMA extensions;

-- Update create_demo_company search_path so it can find pgcrypto functions.
ALTER FUNCTION create_demo_company(uuid, text, text, text, text)
  SET search_path = public, extensions;

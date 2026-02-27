-- ============================================================================
-- Migration: Revoke unnecessary anon write grants + lock down create_demo_company
--
-- The anon key is embedded in the Flutter client (publicly extractable).
-- RLS already blocks anon on all tables, but revoking grants adds defense-in-depth.
-- ============================================================================

-- STEP 1: Revoke write grants from anon on ALL existing public tables
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA public FROM anon;

-- STEP 2: Prevent future tables (created by postgres role) from getting anon write grants
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
  REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON TABLES FROM anon;

-- STEP 3: Revoke EXECUTE on create_demo_company from anon and public
-- Only service_role (Edge Function) should call this function.
REVOKE EXECUTE ON FUNCTION public.create_demo_company FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.create_demo_company FROM anon;
REVOKE EXECUTE ON FUNCTION public.create_demo_company FROM authenticated;
GRANT EXECUTE ON FUNCTION public.create_demo_company TO service_role;
GRANT EXECUTE ON FUNCTION public.create_demo_company TO postgres;

-- NOTE: lookup_display_device_by_code MUST keep EXECUTE for anon
-- (called pre-auth from display device pairing screen)

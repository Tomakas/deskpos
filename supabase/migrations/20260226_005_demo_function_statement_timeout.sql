-- ============================================================================
-- Migration: 20260226_005_demo_function_statement_timeout
-- Description: Set statement_timeout on create_demo_company() to prevent
--              timeout errors on Supabase (default is too short for ~7k inserts).
-- ============================================================================

ALTER FUNCTION create_demo_company(uuid, text, text, text, text)
  SET statement_timeout = '300s';

-- Enable RLS on currencies table
-- The existing currencies_select_all policy (SELECT, true, authenticated) becomes active.
-- anon role will be blocked (no matching policy).
-- service_role and SECURITY DEFINER functions bypass RLS — unaffected.
ALTER TABLE public.currencies ENABLE ROW LEVEL SECURITY;

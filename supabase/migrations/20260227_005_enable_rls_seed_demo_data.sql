-- Enable RLS on seed_demo_data table
-- No policies needed: only accessed by create_demo_company() which is SECURITY DEFINER.
-- Both anon and authenticated will be fully blocked (correct — no client access needed).
ALTER TABLE public.seed_demo_data ENABLE ROW LEVEL SECURITY;

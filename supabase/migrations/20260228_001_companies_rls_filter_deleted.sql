DROP POLICY IF EXISTS companies_select_own ON public.companies;
CREATE POLICY companies_select_own ON public.companies
  FOR SELECT USING (
    auth_user_id = (SELECT auth.uid()) AND deleted_at IS NULL
  );

-- Guard: prevent removing the last admin user from a company.
-- Covers both role change (role_id) and soft delete (deleted_at).

CREATE OR REPLACE FUNCTION public.guard_last_admin()
RETURNS trigger LANGUAGE plpgsql
SET search_path = 'public'
AS $$
DECLARE
  admin_role_id text;
  admin_count integer;
BEGIN
  SELECT id INTO admin_role_id FROM roles WHERE name = 'admin' LIMIT 1;
  IF admin_role_id IS NULL THEN RETURN NEW; END IF;

  IF (OLD.role_id = admin_role_id AND NEW.role_id != admin_role_id)
     OR (OLD.role_id = admin_role_id AND OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL)
  THEN
    SELECT count(*) INTO admin_count
    FROM users
    WHERE company_id = OLD.company_id
      AND role_id = admin_role_id
      AND deleted_at IS NULL
      AND id != OLD.id;

    IF admin_count < 1 THEN
      RAISE EXCEPTION 'Cannot remove the last admin user from company %', OLD.company_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_users_guard_last_admin
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION guard_last_admin();

-- Internal Accounts (House Accounts)
-- Allows transferring bills to internal accounts (employee meals, owner, write-offs, etc.)

-- 1. Add 'transferred' to bill_status enum for internal account transfers
ALTER TYPE bill_status ADD VALUE IF NOT EXISTS 'transferred';

-- 2. Create internal_accounts table
CREATE TABLE public.internal_accounts (
  id text PRIMARY KEY,
  company_id text NOT NULL REFERENCES companies(id),
  name text NOT NULL,
  user_id text REFERENCES users(id),
  is_active boolean NOT NULL DEFAULT true,
  client_created_at timestamptz,
  client_updated_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX idx_internal_accounts_company_updated ON internal_accounts(company_id, updated_at);

ALTER TABLE internal_accounts ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER trg_internal_accounts_timestamps BEFORE INSERT OR UPDATE ON internal_accounts
  FOR EACH ROW EXECUTE FUNCTION set_server_timestamps();

CREATE TRIGGER trg_internal_accounts_lww BEFORE UPDATE ON internal_accounts
  FOR EACH ROW EXECUTE FUNCTION enforce_lww();

CREATE POLICY internal_accounts_select_own ON internal_accounts
  FOR SELECT USING (company_id IN (SELECT get_my_company_ids()));

-- 3. Create internal_account_settlements table
CREATE TABLE public.internal_account_settlements (
  id text PRIMARY KEY,
  company_id text NOT NULL REFERENCES companies(id),
  internal_account_id text NOT NULL REFERENCES internal_accounts(id),
  settled_by_user_id text NOT NULL REFERENCES users(id),
  settled_at timestamptz NOT NULL,
  total_amount integer NOT NULL DEFAULT 0,
  settled_amount integer NOT NULL DEFAULT 0,
  forgiven_amount integer NOT NULL DEFAULT 0,
  discount_amount integer NOT NULL DEFAULT 0,
  note text,
  client_created_at timestamptz,
  client_updated_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX idx_internal_account_settlements_company_updated ON internal_account_settlements(company_id, updated_at);

ALTER TABLE internal_account_settlements ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER trg_internal_account_settlements_timestamps BEFORE INSERT OR UPDATE ON internal_account_settlements
  FOR EACH ROW EXECUTE FUNCTION set_server_timestamps();

CREATE TRIGGER trg_internal_account_settlements_lww BEFORE UPDATE ON internal_account_settlements
  FOR EACH ROW EXECUTE FUNCTION enforce_lww();

CREATE POLICY internal_account_settlements_select_own ON internal_account_settlements
  FOR SELECT USING (company_id IN (SELECT get_my_company_ids()));

-- 4. Extend bills table
ALTER TABLE bills ADD COLUMN IF NOT EXISTS internal_account_id text REFERENCES internal_accounts(id);
ALTER TABLE bills ADD COLUMN IF NOT EXISTS settlement_id text REFERENCES internal_account_settlements(id);

-- 5. Permission catalog
-- internal_accounts.manage = 1080
-- internal_accounts.transfer = 1081
INSERT INTO permissions (id, code, name, category, client_created_at, client_updated_at)
VALUES
  ('01930000-0000-7000-8000-000000001080', 'internal_accounts.manage', 'Manage internal accounts', 'internal_accounts', now(), now()),
  ('01930000-0000-7000-8000-000000001081', 'internal_accounts.transfer', 'Transfer bill to internal account', 'internal_accounts', now(), now())
ON CONFLICT (id) DO NOTHING;

-- Role assignments:
--   admin (0103): manage + transfer
--   manager (0104): manage + transfer
--   operator (0102): transfer only
INSERT INTO role_permissions (id, role_id, permission_id, client_created_at, client_updated_at)
VALUES
  -- admin: manage
  ('01930000-0000-7000-8000-000000002138', '01930000-0000-7000-8000-000000000103', '01930000-0000-7000-8000-000000001080', now(), now()),
  -- admin: transfer
  ('01930000-0000-7000-8000-000000002139', '01930000-0000-7000-8000-000000000103', '01930000-0000-7000-8000-000000001081', now(), now()),
  -- manager: manage
  ('01930000-0000-7000-8000-00000000213a', '01930000-0000-7000-8000-000000000104', '01930000-0000-7000-8000-000000001080', now(), now()),
  -- manager: transfer
  ('01930000-0000-7000-8000-00000000213b', '01930000-0000-7000-8000-000000000104', '01930000-0000-7000-8000-000000001081', now(), now()),
  -- operator: transfer
  ('01930000-0000-7000-8000-00000000213c', '01930000-0000-7000-8000-000000000102', '01930000-0000-7000-8000-000000001081', now(), now())
ON CONFLICT (id) DO NOTHING;

NOTIFY pgrst, 'reload schema';

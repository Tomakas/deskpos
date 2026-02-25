-- Multi-currency support: company currencies, payment foreign fields, session currency cash

-- 1. Company currencies (alternative currencies with exchange rates)
CREATE TABLE public.company_currencies (
  id text PRIMARY KEY,
  company_id text NOT NULL REFERENCES companies(id),
  currency_id text NOT NULL REFERENCES currencies(id),
  exchange_rate double precision NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0,
  client_created_at timestamptz,
  client_updated_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX idx_company_currencies_company_updated ON company_currencies(company_id, updated_at);
ALTER TABLE company_currencies ENABLE ROW LEVEL SECURITY;
CREATE TRIGGER trg_company_currencies_timestamps BEFORE INSERT OR UPDATE ON company_currencies FOR EACH ROW EXECUTE FUNCTION set_server_timestamps();
CREATE TRIGGER trg_company_currencies_lww BEFORE UPDATE ON company_currencies FOR EACH ROW EXECUTE FUNCTION enforce_lww();
CREATE POLICY company_currencies_select_own ON company_currencies FOR SELECT USING (company_id IN (SELECT get_my_company_ids()));

-- 2. Payment foreign currency fields
ALTER TABLE public.payments
  ADD COLUMN foreign_currency_id text REFERENCES currencies(id),
  ADD COLUMN foreign_amount integer,
  ADD COLUMN exchange_rate double precision;

-- 3. Session currency cash (foreign currency cash tracking per session)
CREATE TABLE public.session_currency_cash (
  id text PRIMARY KEY,
  company_id text NOT NULL REFERENCES companies(id),
  register_session_id text NOT NULL REFERENCES register_sessions(id),
  currency_id text NOT NULL REFERENCES currencies(id),
  opening_cash integer NOT NULL DEFAULT 0,
  closing_cash integer,
  expected_cash integer,
  difference integer,
  client_created_at timestamptz,
  client_updated_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX idx_session_currency_cash_company_updated ON session_currency_cash(company_id, updated_at);
ALTER TABLE session_currency_cash ENABLE ROW LEVEL SECURITY;
CREATE TRIGGER trg_session_currency_cash_timestamps BEFORE INSERT OR UPDATE ON session_currency_cash FOR EACH ROW EXECUTE FUNCTION set_server_timestamps();
CREATE TRIGGER trg_session_currency_cash_lww BEFORE UPDATE ON session_currency_cash FOR EACH ROW EXECUTE FUNCTION enforce_lww();
CREATE POLICY session_currency_cash_select_own ON session_currency_cash FOR SELECT USING (company_id IN (SELECT get_my_company_ids()));

-- Broadcast triggers for realtime sync (<2s)
CREATE TRIGGER trg_company_currencies_broadcast
  AFTER INSERT OR UPDATE ON company_currencies
  FOR EACH ROW EXECUTE FUNCTION broadcast_sync_change();

CREATE TRIGGER trg_session_currency_cash_broadcast
  AFTER INSERT OR UPDATE ON session_currency_cash
  FOR EACH ROW EXECUTE FUNCTION broadcast_sync_change();

-- ============================================================================
-- Migration: add indexes on 3 FK columns that were missing coverage
--
-- All other FK columns already have indexes; these 3 were the only gaps.
-- Zero practical impact (tiny tables), added for consistency.
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_company_currencies_currency_id
  ON public.company_currencies (currency_id);

CREATE INDEX IF NOT EXISTS idx_payments_foreign_currency_id
  ON public.payments (foreign_currency_id);

CREATE INDEX IF NOT EXISTS idx_session_currency_cash_currency_id
  ON public.session_currency_cash (currency_id);

ALTER TABLE public.cash_movements
  ADD COLUMN currency_id text REFERENCES currencies(id);

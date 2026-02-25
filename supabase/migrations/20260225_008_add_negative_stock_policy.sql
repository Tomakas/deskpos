ALTER TABLE public.company_settings
  ADD COLUMN IF NOT EXISTS negative_stock_policy text NOT NULL DEFAULT 'allow';

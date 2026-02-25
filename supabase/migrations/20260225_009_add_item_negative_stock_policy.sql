ALTER TABLE public.items
  ADD COLUMN IF NOT EXISTS negative_stock_policy text;

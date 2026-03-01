-- Fix: customer_transactions.order_id actually stores bill IDs, not order IDs.
-- The FK was incorrectly referencing orders(id) instead of bills(id).
ALTER TABLE public.customer_transactions
  DROP CONSTRAINT customer_transactions_order_id_fkey;

ALTER TABLE public.customer_transactions
  ADD CONSTRAINT customer_transactions_order_id_fkey
  FOREIGN KEY (order_id) REFERENCES public.bills(id);

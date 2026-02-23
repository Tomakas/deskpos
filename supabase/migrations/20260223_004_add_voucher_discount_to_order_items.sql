-- Add per-item voucher discount column to order_items.
-- For discount-type vouchers, the discount is embedded per-item (items are physically split).
-- For gift/deposit vouchers, the discount remains bill-level (voucherDiscountAmount on bills).
ALTER TABLE order_items
  ADD COLUMN voucher_discount integer NOT NULL DEFAULT 0;

-- Add created_by_user_id to vouchers to track who created each voucher.
ALTER TABLE vouchers
  ADD COLUMN created_by_user_id text;

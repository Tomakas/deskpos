-- 1. Add 'voucher' to the payment_type enum (used by payment_methods.type).
ALTER TYPE payment_type ADD VALUE IF NOT EXISTS 'voucher' BEFORE 'other';

-- 2. Add missing payment type flags to registers table.
--    Existing flags: allow_cash, allow_card, allow_transfer, allow_refunds.
--    New flags default to TRUE (all payment types allowed by default).
ALTER TABLE registers
  ADD COLUMN IF NOT EXISTS allow_credit  boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS allow_voucher boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS allow_other   boolean NOT NULL DEFAULT true;

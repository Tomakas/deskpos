-- Remove vouchers.view from helper role — helpers can redeem vouchers during
-- payment (vouchers.redeem) but should not access the voucher management screen.
DELETE FROM role_permissions
WHERE id = '01930000-0000-7000-8000-00000000200f';

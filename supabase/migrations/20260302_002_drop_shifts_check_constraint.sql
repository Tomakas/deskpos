-- Remove CHECK constraint added in 20260302_001 — repository validates this in Dart,
-- server-side CHECK would cause sync failures on clock skew / timezone edge cases.
ALTER TABLE shifts DROP CONSTRAINT IF EXISTS chk_shifts_login_before_logout;

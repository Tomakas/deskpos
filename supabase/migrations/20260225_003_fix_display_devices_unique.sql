-- Fix display_devices unique constraint: per-company instead of global
-- The global UNIQUE (code) blocks demo creation when soft-deleted demo data
-- still has records with the same code (e.g. DSP-001).
ALTER TABLE display_devices DROP CONSTRAINT display_devices_code_key;
CREATE UNIQUE INDEX display_devices_code_company_unique
  ON display_devices (company_id, code)
  WHERE deleted_at IS NULL;

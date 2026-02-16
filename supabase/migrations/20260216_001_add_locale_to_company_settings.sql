-- Add locale column to company_settings
ALTER TABLE company_settings
  ADD COLUMN IF NOT EXISTS locale text NOT NULL DEFAULT 'cs';

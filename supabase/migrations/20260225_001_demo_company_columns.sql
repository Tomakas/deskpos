-- Add demo company tracking columns
ALTER TABLE companies
  ADD COLUMN is_demo boolean NOT NULL DEFAULT false,
  ADD COLUMN demo_expires_at timestamptz;

CREATE INDEX idx_companies_demo_expires ON companies (demo_expires_at)
  WHERE is_demo = true AND deleted_at IS NULL;

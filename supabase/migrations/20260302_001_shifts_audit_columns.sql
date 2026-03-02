-- Add audit columns for shift editing
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS original_login_at timestamptz;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS original_logout_at timestamptz;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS edited_by text;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS edited_at timestamptz;

-- Demo log: track demo company creation and usage metrics
CREATE TABLE demo_log (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        uuid,             -- reference without FK (company gets hard-deleted)
  company_name      text,
  auth_user_id      uuid,
  locale            text,
  mode              text,
  currency_code     text,
  ip_address        inet,
  user_agent        text,
  created_at        timestamptz NOT NULL DEFAULT now(),
  -- cron job fills before deletion:
  expired_at        timestamptz,
  last_activity_at  timestamptz,
  usage             jsonb
);

CREATE INDEX idx_demo_log_created_at ON demo_log (created_at DESC);

ALTER TABLE demo_log ENABLE ROW LEVEL SECURITY;
-- No policies: access only via service role

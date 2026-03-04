-- AI Assistant: tables, RLS policies, helper functions, permission
BEGIN;

-- =========================================================================
-- STEP 1: AI tables
-- =========================================================================

CREATE TABLE public.ai_conversations (
  id text PRIMARY KEY,
  company_id text NOT NULL REFERENCES companies(id),
  user_id text NOT NULL REFERENCES users(id),
  title text,
  screen_context text,
  is_archived boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX idx_ai_conversations_company_user
  ON ai_conversations(company_id, user_id);

CREATE TABLE public.ai_messages (
  id text PRIMARY KEY,
  company_id text NOT NULL REFERENCES companies(id),
  conversation_id text NOT NULL REFERENCES ai_conversations(id),
  role text NOT NULL,
  content text NOT NULL,
  tool_calls text,
  tool_results text,
  status text NOT NULL DEFAULT 'pending',
  error_message text,
  token_count integer,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX idx_ai_messages_conversation
  ON ai_messages(conversation_id, created_at);

CREATE TABLE public.ai_undo_logs (
  id text PRIMARY KEY,
  company_id text NOT NULL REFERENCES companies(id),
  conversation_id text NOT NULL REFERENCES ai_conversations(id),
  message_id text NOT NULL REFERENCES ai_messages(id),
  tool_call_id text NOT NULL,
  operation_type text NOT NULL,
  entity_type text NOT NULL,
  entity_id text NOT NULL,
  snapshot_before text,
  snapshot_after text,
  is_undone boolean NOT NULL DEFAULT false,
  undone_at timestamptz,
  expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX idx_ai_undo_logs_conversation
  ON ai_undo_logs(conversation_id, created_at);
CREATE INDEX idx_ai_undo_logs_message
  ON ai_undo_logs(message_id);

-- =========================================================================
-- STEP 2: company_settings AI columns
-- =========================================================================

ALTER TABLE company_settings
  ADD COLUMN IF NOT EXISTS ai_enabled boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS ai_provider_type text NOT NULL DEFAULT 'none',
  ADD COLUMN IF NOT EXISTS ai_model text,
  ADD COLUMN IF NOT EXISTS ai_rate_limit_per_hour integer NOT NULL DEFAULT 60,
  ADD COLUMN IF NOT EXISTS ai_max_tokens_per_request integer NOT NULL DEFAULT 4096,
  ADD COLUMN IF NOT EXISTS ai_max_conversation_tokens integer NOT NULL DEFAULT 16000;

-- =========================================================================
-- STEP 3: RLS helper — get user IDs for a company
-- =========================================================================

CREATE OR REPLACE FUNCTION get_my_user_ids_for_company(p_company_id text)
RETURNS SETOF text
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT u.id FROM users u
  WHERE u.company_id = p_company_id
    AND u.auth_user_id = auth.uid()::text
    AND u.deleted_at IS NULL;
$$;

-- =========================================================================
-- STEP 4: Edge Function helper — check permission by code
-- =========================================================================

CREATE OR REPLACE FUNCTION check_user_permission(
  p_user_id text,
  p_company_id text,
  p_permission_code text
)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    -- Role-based permission
    SELECT 1
    FROM users u
    JOIN role_permissions rp ON rp.role_id = u.role_id
    JOIN permissions p ON p.id = rp.permission_id
    WHERE u.id = p_user_id
      AND u.company_id = p_company_id
      AND u.deleted_at IS NULL
      AND p.code = p_permission_code

    UNION ALL

    -- User-specific permission override
    SELECT 1
    FROM user_permissions up
    JOIN permissions p ON p.id = up.permission_id
    WHERE up.user_id = p_user_id
      AND up.company_id = p_company_id
      AND up.deleted_at IS NULL
      AND p.code = p_permission_code
  );
$$;

-- =========================================================================
-- STEP 5: RLS policies — ai_conversations (user-scoped)
-- =========================================================================

ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY ai_conversations_select_own ON ai_conversations
  FOR SELECT USING (
    company_id IN (SELECT get_my_company_ids())
    AND user_id IN (SELECT get_my_user_ids_for_company(company_id))
  );

CREATE POLICY ai_conversations_insert_own ON ai_conversations
  FOR INSERT WITH CHECK (
    company_id IN (SELECT get_my_company_ids())
    AND user_id IN (SELECT get_my_user_ids_for_company(company_id))
  );

CREATE POLICY ai_conversations_update_own ON ai_conversations
  FOR UPDATE USING (
    company_id IN (SELECT get_my_company_ids())
    AND user_id IN (SELECT get_my_user_ids_for_company(company_id))
  );

CREATE POLICY ai_conversations_delete_own ON ai_conversations
  FOR DELETE USING (
    company_id IN (SELECT get_my_company_ids())
    AND user_id IN (SELECT get_my_user_ids_for_company(company_id))
  );

-- =========================================================================
-- STEP 6: RLS policies — ai_messages (user-scoped via conversation)
-- =========================================================================

ALTER TABLE ai_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY ai_messages_select_own ON ai_messages
  FOR SELECT USING (
    conversation_id IN (
      SELECT id FROM ai_conversations
      WHERE company_id IN (SELECT get_my_company_ids())
        AND user_id IN (SELECT get_my_user_ids_for_company(company_id))
    )
  );

CREATE POLICY ai_messages_insert_own ON ai_messages
  FOR INSERT WITH CHECK (
    conversation_id IN (
      SELECT id FROM ai_conversations
      WHERE company_id IN (SELECT get_my_company_ids())
        AND user_id IN (SELECT get_my_user_ids_for_company(company_id))
    )
  );

CREATE POLICY ai_messages_update_own ON ai_messages
  FOR UPDATE USING (
    conversation_id IN (
      SELECT id FROM ai_conversations
      WHERE company_id IN (SELECT get_my_company_ids())
        AND user_id IN (SELECT get_my_user_ids_for_company(company_id))
    )
  );

CREATE POLICY ai_messages_delete_own ON ai_messages
  FOR DELETE USING (
    conversation_id IN (
      SELECT id FROM ai_conversations
      WHERE company_id IN (SELECT get_my_company_ids())
        AND user_id IN (SELECT get_my_user_ids_for_company(company_id))
    )
  );

-- =========================================================================
-- STEP 7: RLS policies — ai_undo_logs (company-scoped)
-- =========================================================================

ALTER TABLE ai_undo_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY ai_undo_logs_select_company ON ai_undo_logs
  FOR SELECT USING (company_id IN (SELECT get_my_company_ids()));

CREATE POLICY ai_undo_logs_insert_company ON ai_undo_logs
  FOR INSERT WITH CHECK (company_id IN (SELECT get_my_company_ids()));

CREATE POLICY ai_undo_logs_update_company ON ai_undo_logs
  FOR UPDATE USING (company_id IN (SELECT get_my_company_ids()));

CREATE POLICY ai_undo_logs_delete_company ON ai_undo_logs
  FOR DELETE USING (company_id IN (SELECT get_my_company_ids()));

-- =========================================================================
-- STEP 8: ai.use permission (manager + admin)
-- =========================================================================

INSERT INTO permissions (id, code, name, category, client_created_at, client_updated_at)
VALUES (
  '01930000-0000-7000-8000-000000001079',
  'ai.use',
  'Use AI assistant',
  'ai',
  now(), now()
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO role_permissions (id, role_id, permission_id, client_created_at, client_updated_at)
VALUES
  -- manager
  ('01930000-0000-7000-8000-000000002137',
   (SELECT id FROM roles WHERE name = 'manager' LIMIT 1),
   '01930000-0000-7000-8000-000000001079',
   now(), now()),
  -- admin
  ('01930000-0000-7000-8000-000000002136',
   (SELECT id FROM roles WHERE name = 'admin' LIMIT 1),
   '01930000-0000-7000-8000-000000001079',
   now(), now())
ON CONFLICT (id) DO NOTHING;

COMMIT;

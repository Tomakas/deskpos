-- Split stock.view into 3 granular view permissions:
--   stock.view_levels, stock.view_documents, stock.view_movements
--
-- Role IDs:
--   helper:   01930000-0000-7000-8000-000000000101
--   operator: 01930000-0000-7000-8000-000000000102
--   admin:    01930000-0000-7000-8000-000000000103
--   manager:  01930000-0000-7000-8000-000000000104
--
-- Old permission:
--   stock.view: 01930000-0000-7000-8000-000000001038
--
-- New permission IDs:
--   stock.view_levels:    01930000-0000-7000-8000-000000001074
--   stock.view_documents: 01930000-0000-7000-8000-000000001075
--   stock.view_movements: 01930000-0000-7000-8000-000000001076
--
-- New role_permission IDs: 2126-212e (9 rows: 3 perms × 3 roles)

BEGIN;

-- 1. Remove stock.view from user_permissions, role_permissions, then permissions
DELETE FROM user_permissions
WHERE permission_id = '01930000-0000-7000-8000-000000001038';

DELETE FROM role_permissions
WHERE permission_id = '01930000-0000-7000-8000-000000001038';

DELETE FROM permissions
WHERE id = '01930000-0000-7000-8000-000000001038';

-- 2. Insert 3 new permissions
INSERT INTO permissions (id, code, name, category, created_at, updated_at)
VALUES
  ('01930000-0000-7000-8000-000000001074', 'stock.view_levels',    'View stock levels',    'stock', now(), now()),
  ('01930000-0000-7000-8000-000000001075', 'stock.view_documents', 'View stock documents', 'stock', now(), now()),
  ('01930000-0000-7000-8000-000000001076', 'stock.view_movements', 'View stock movements', 'stock', now(), now())
ON CONFLICT (id) DO NOTHING;

-- 3. Insert 9 role_permissions (operator, manager, admin × 3 perms)
INSERT INTO role_permissions (id, role_id, permission_id, created_at, updated_at)
VALUES
  -- operator
  ('01930000-0000-7000-8000-000000002126', '01930000-0000-7000-8000-000000000102', '01930000-0000-7000-8000-000000001074', now(), now()),
  ('01930000-0000-7000-8000-000000002127', '01930000-0000-7000-8000-000000000102', '01930000-0000-7000-8000-000000001075', now(), now()),
  ('01930000-0000-7000-8000-000000002128', '01930000-0000-7000-8000-000000000102', '01930000-0000-7000-8000-000000001076', now(), now()),
  -- manager
  ('01930000-0000-7000-8000-000000002129', '01930000-0000-7000-8000-000000000104', '01930000-0000-7000-8000-000000001074', now(), now()),
  ('01930000-0000-7000-8000-00000000212a', '01930000-0000-7000-8000-000000000104', '01930000-0000-7000-8000-000000001075', now(), now()),
  ('01930000-0000-7000-8000-00000000212b', '01930000-0000-7000-8000-000000000104', '01930000-0000-7000-8000-000000001076', now(), now()),
  -- admin
  ('01930000-0000-7000-8000-00000000212c', '01930000-0000-7000-8000-000000000103', '01930000-0000-7000-8000-000000001074', now(), now()),
  ('01930000-0000-7000-8000-00000000212d', '01930000-0000-7000-8000-000000000103', '01930000-0000-7000-8000-000000001075', now(), now()),
  ('01930000-0000-7000-8000-00000000212e', '01930000-0000-7000-8000-000000000103', '01930000-0000-7000-8000-000000001076', now(), now())
ON CONFLICT (id) DO NOTHING;

COMMIT;

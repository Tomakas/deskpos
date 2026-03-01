-- Phase 0: Permission cleanup — delete 4 unused permissions, add payments.method_bank
-- Permissions before: 115, after: 112

-- Step 1: Remove role_permission assignments for deleted permissions
DELETE FROM role_permissions WHERE permission_id IN (
  '01930000-0000-7000-8000-000000001003',  -- orders.view_all
  '01930000-0000-7000-8000-000000001008',  -- orders.edit_others
  '01930000-0000-7000-8000-000000001029',  -- shifts.clock_in_out
  '01930000-0000-7000-8000-00000000106e'   -- settings_register.displays
);

-- Step 2: Remove user_permissions for deleted permissions (if any users had custom assignments)
DELETE FROM user_permissions WHERE permission_id IN (
  '01930000-0000-7000-8000-000000001003',
  '01930000-0000-7000-8000-000000001008',
  '01930000-0000-7000-8000-000000001029',
  '01930000-0000-7000-8000-00000000106e'
);

-- Step 3: Remove the permission definitions
DELETE FROM permissions WHERE id IN (
  '01930000-0000-7000-8000-000000001003',
  '01930000-0000-7000-8000-000000001008',
  '01930000-0000-7000-8000-000000001029',
  '01930000-0000-7000-8000-00000000106e'
);

-- Step 4: Add payments.method_bank permission
-- ID 1077 = next available after 1076 (stock_view_split migration 009)
INSERT INTO permissions (id, code, name, category, client_created_at, client_updated_at) VALUES
  ('01930000-0000-7000-8000-000000001077', 'payments.method_bank', 'Bank transfer payment', 'payments', now(), now());

-- Step 5: Assign payments.method_bank to operator, manager, admin roles
-- (Helper role does NOT get payment method permissions — consistent with existing pattern)
-- IDs 212f+ = next available after 212e (stock_view_split migration 009)
INSERT INTO role_permissions (id, role_id, permission_id, client_created_at, client_updated_at) VALUES
  -- operator
  ('01930000-0000-7000-8000-00000000212f', '01930000-0000-7000-8000-000000000102', '01930000-0000-7000-8000-000000001077', now(), now()),
  -- manager
  ('01930000-0000-7000-8000-000000002130', '01930000-0000-7000-8000-000000000104', '01930000-0000-7000-8000-000000001077', now(), now()),
  -- admin
  ('01930000-0000-7000-8000-000000002131', '01930000-0000-7000-8000-000000000103', '01930000-0000-7000-8000-000000001077', now(), now());

-- Permission catalog cleanup: remove 8 redundant permissions, add register.open_close,
-- add mealTicket payment type, add allow_meal_ticket column to registers.

BEGIN;

-- ========================================================================
-- STEP 1: Delete 8 redundant permissions + their role/user assignments
-- ========================================================================

DELETE FROM role_permissions WHERE permission_id IN (
  '01930000-0000-7000-8000-000000001047',  -- venue.view
  '01930000-0000-7000-8000-00000000102a',  -- shifts.view_own
  '01930000-0000-7000-8000-00000000102b',  -- shifts.view_all
  '01930000-0000-7000-8000-00000000101c',  -- payments.adjust_tip
  '01930000-0000-7000-8000-000000001022',  -- register.open_session
  '01930000-0000-7000-8000-000000001023',  -- register.close_session
  '01930000-0000-7000-8000-000000001024',  -- register.view_session
  '01930000-0000-7000-8000-000000001025'   -- register.view_all_sessions
);

DELETE FROM user_permissions WHERE permission_id IN (
  '01930000-0000-7000-8000-000000001047',
  '01930000-0000-7000-8000-00000000102a',
  '01930000-0000-7000-8000-00000000102b',
  '01930000-0000-7000-8000-00000000101c',
  '01930000-0000-7000-8000-000000001022',
  '01930000-0000-7000-8000-000000001023',
  '01930000-0000-7000-8000-000000001024',
  '01930000-0000-7000-8000-000000001025'
);

DELETE FROM permissions WHERE id IN (
  '01930000-0000-7000-8000-000000001047',
  '01930000-0000-7000-8000-00000000102a',
  '01930000-0000-7000-8000-00000000102b',
  '01930000-0000-7000-8000-00000000101c',
  '01930000-0000-7000-8000-000000001022',
  '01930000-0000-7000-8000-000000001023',
  '01930000-0000-7000-8000-000000001024',
  '01930000-0000-7000-8000-000000001025'
);

-- ========================================================================
-- STEP 2: Add register.open_close permission (replaces open/close_session)
-- ========================================================================

INSERT INTO permissions (id, code, name, category, description)
VALUES (
  '01930000-0000-7000-8000-000000001078',
  'register.open_close',
  'Open/close register',
  'register',
  'Open or close a register session'
);

-- Assign to operator, manager, admin (same roles that had open_session + close_session)
INSERT INTO role_permissions (id, role_id, permission_id)
VALUES
  ('01930000-0000-7000-8000-000000002132',
   (SELECT id FROM roles WHERE name = 'operator' LIMIT 1),
   '01930000-0000-7000-8000-000000001078'),
  ('01930000-0000-7000-8000-000000002133',
   (SELECT id FROM roles WHERE name = 'manager' LIMIT 1),
   '01930000-0000-7000-8000-000000001078'),
  ('01930000-0000-7000-8000-000000002134',
   (SELECT id FROM roles WHERE name = 'admin' LIMIT 1),
   '01930000-0000-7000-8000-000000001078');

-- ========================================================================
-- STEP 3: Add mealTicket to payment_type enum
-- ========================================================================

ALTER TYPE payment_type ADD VALUE IF NOT EXISTS 'mealTicket' BEFORE 'other';

-- ========================================================================
-- STEP 4: Add allow_meal_ticket column to registers
-- ========================================================================

ALTER TABLE registers ADD COLUMN IF NOT EXISTS allow_meal_ticket boolean NOT NULL DEFAULT true;

COMMIT;

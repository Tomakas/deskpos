-- Tiered discount permissions:
-- - Add max_item_discount_percent and max_bill_discount_percent to company_settings
-- - Add 2 new *_limited permissions
-- - Remove discounts.custom and discounts.price_override
-- - Update role_permissions: operator gets limited only, manager/admin get both
--
-- Role IDs (from seed):
--   helper:   01930000-0000-7000-8000-000000000101
--   operator: 01930000-0000-7000-8000-000000000102
--   admin:    01930000-0000-7000-8000-000000000103
--   manager:  01930000-0000-7000-8000-000000000104
--
-- Existing discount permission IDs:
--   discounts.apply_item:     01930000-0000-7000-8000-00000000101d
--   discounts.apply_bill:     01930000-0000-7000-8000-00000000101e
--   discounts.custom:         01930000-0000-7000-8000-00000000101f
--   discounts.price_override: 01930000-0000-7000-8000-000000001020
--   discounts.loyalty:        01930000-0000-7000-8000-000000001021
--
-- New permission IDs:
--   discounts.apply_item_limited: 01930000-0000-7000-8000-000000001072
--   discounts.apply_bill_limited: 01930000-0000-7000-8000-000000001073

BEGIN;

-- 1. Add discount limit columns to company_settings
ALTER TABLE company_settings
  ADD COLUMN max_item_discount_percent integer NOT NULL DEFAULT 2000,
  ADD COLUMN max_bill_discount_percent integer NOT NULL DEFAULT 2000;

-- 2. Insert new limited permissions
INSERT INTO permissions (id, code, name, category, created_at, updated_at)
VALUES
  ('01930000-0000-7000-8000-000000001072', 'discounts.apply_item_limited', 'Item discount (limited)', 'discounts', now(), now()),
  ('01930000-0000-7000-8000-000000001073', 'discounts.apply_bill_limited', 'Bill discount (limited)', 'discounts', now(), now())
ON CONFLICT (id) DO NOTHING;

-- 3. Remove discounts.custom and discounts.price_override
--    First from user_permissions, then role_permissions, then permissions
DELETE FROM user_permissions
WHERE permission_id IN (
  '01930000-0000-7000-8000-00000000101f',  -- discounts.custom
  '01930000-0000-7000-8000-000000001020'   -- discounts.price_override
);

DELETE FROM role_permissions
WHERE permission_id IN (
  '01930000-0000-7000-8000-00000000101f',  -- discounts.custom
  '01930000-0000-7000-8000-000000001020'   -- discounts.price_override
);

DELETE FROM permissions
WHERE id IN (
  '01930000-0000-7000-8000-00000000101f',  -- discounts.custom
  '01930000-0000-7000-8000-000000001020'   -- discounts.price_override
);

-- 4. Update role_permissions
--    operator: remove unlimited apply_item/apply_bill, add limited variants
DELETE FROM role_permissions
WHERE role_id = '01930000-0000-7000-8000-000000000102'  -- operator
  AND permission_id IN (
    '01930000-0000-7000-8000-00000000101d',  -- discounts.apply_item
    '01930000-0000-7000-8000-00000000101e'   -- discounts.apply_bill
  );

INSERT INTO role_permissions (id, role_id, permission_id, created_at, updated_at)
VALUES
  -- operator: limited only
  ('01930000-0000-7000-8000-000000002120', '01930000-0000-7000-8000-000000000102', '01930000-0000-7000-8000-000000001072', now(), now()),
  ('01930000-0000-7000-8000-000000002121', '01930000-0000-7000-8000-000000000102', '01930000-0000-7000-8000-000000001073', now(), now()),
  -- manager: add limited (already has unlimited)
  ('01930000-0000-7000-8000-000000002122', '01930000-0000-7000-8000-000000000104', '01930000-0000-7000-8000-000000001072', now(), now()),
  ('01930000-0000-7000-8000-000000002123', '01930000-0000-7000-8000-000000000104', '01930000-0000-7000-8000-000000001073', now(), now()),
  -- admin: add limited (already has unlimited)
  ('01930000-0000-7000-8000-000000002124', '01930000-0000-7000-8000-000000000103', '01930000-0000-7000-8000-000000001072', now(), now()),
  ('01930000-0000-7000-8000-000000002125', '01930000-0000-7000-8000-000000000103', '01930000-0000-7000-8000-000000001073', now(), now())
ON CONFLICT (id) DO NOTHING;

COMMIT;

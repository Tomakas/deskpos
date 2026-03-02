-- Grant orders.view_detail to helper role — allows opening bill detail dialog.
-- Actions inside the detail (void, refund, discount, etc.) remain gated by their own permissions.
INSERT INTO role_permissions (id, role_id, permission_id)
VALUES (
  '01930000-0000-7000-8000-000000002135',
  '01930000-0000-7000-8000-000000000101',
  '01930000-0000-7000-8000-000000001006'
);

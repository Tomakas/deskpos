-- Add UNIQUE constraints on global tables to prevent duplicates.
-- Run AFTER wiping the Supabase database (drop all data, fresh start).

ALTER TABLE currencies
  ADD CONSTRAINT currencies_code_key UNIQUE (code);

ALTER TABLE roles
  ADD CONSTRAINT roles_name_key UNIQUE (name);

ALTER TABLE permissions
  ADD CONSTRAINT permissions_code_key UNIQUE (code);

ALTER TABLE role_permissions
  ADD CONSTRAINT role_permissions_pair_key UNIQUE (role_id, permission_id);

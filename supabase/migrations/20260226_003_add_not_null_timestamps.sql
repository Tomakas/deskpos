-- Fix nullable client_created_at / client_updated_at on 6 tables.
-- All other company-scoped tables already have NOT NULL + DEFAULT now().
-- Without NOT NULL, a NULL value bypasses the enforce_lww trigger
-- (NULL < timestamp → NULL, not TRUE, so RAISE EXCEPTION never fires).

-- company_currencies
ALTER TABLE company_currencies
  ALTER COLUMN client_created_at SET DEFAULT now(),
  ALTER COLUMN client_created_at SET NOT NULL,
  ALTER COLUMN client_updated_at SET DEFAULT now(),
  ALTER COLUMN client_updated_at SET NOT NULL;

-- item_modifier_groups
ALTER TABLE item_modifier_groups
  ALTER COLUMN client_created_at SET DEFAULT now(),
  ALTER COLUMN client_created_at SET NOT NULL,
  ALTER COLUMN client_updated_at SET DEFAULT now(),
  ALTER COLUMN client_updated_at SET NOT NULL;

-- modifier_groups
ALTER TABLE modifier_groups
  ALTER COLUMN client_created_at SET DEFAULT now(),
  ALTER COLUMN client_created_at SET NOT NULL,
  ALTER COLUMN client_updated_at SET DEFAULT now(),
  ALTER COLUMN client_updated_at SET NOT NULL;

-- modifier_group_items
ALTER TABLE modifier_group_items
  ALTER COLUMN client_created_at SET DEFAULT now(),
  ALTER COLUMN client_created_at SET NOT NULL,
  ALTER COLUMN client_updated_at SET DEFAULT now(),
  ALTER COLUMN client_updated_at SET NOT NULL;

-- order_item_modifiers
ALTER TABLE order_item_modifiers
  ALTER COLUMN client_created_at SET DEFAULT now(),
  ALTER COLUMN client_created_at SET NOT NULL,
  ALTER COLUMN client_updated_at SET DEFAULT now(),
  ALTER COLUMN client_updated_at SET NOT NULL;

-- session_currency_cash
ALTER TABLE session_currency_cash
  ALTER COLUMN client_created_at SET DEFAULT now(),
  ALTER COLUMN client_created_at SET NOT NULL,
  ALTER COLUMN client_updated_at SET DEFAULT now(),
  ALTER COLUMN client_updated_at SET NOT NULL;

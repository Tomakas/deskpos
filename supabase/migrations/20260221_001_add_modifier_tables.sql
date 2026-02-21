-- Migration: Add modifier system tables
-- Applied: 2026-02-21 on project rrnvlsguhkelracusofe

CREATE TABLE public.modifier_groups (
  id text PRIMARY KEY,
  company_id text NOT NULL REFERENCES companies(id),
  name text NOT NULL,
  min_selections integer NOT NULL DEFAULT 0,
  max_selections integer,
  sort_order integer NOT NULL DEFAULT 0,
  client_created_at timestamptz,
  client_updated_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX idx_modifier_groups_company_updated ON modifier_groups(company_id, updated_at);
ALTER TABLE modifier_groups ENABLE ROW LEVEL SECURITY;
CREATE TRIGGER trg_modifier_groups_timestamps BEFORE INSERT OR UPDATE ON modifier_groups FOR EACH ROW EXECUTE FUNCTION set_server_timestamps();
CREATE TRIGGER trg_modifier_groups_lww BEFORE UPDATE ON modifier_groups FOR EACH ROW EXECUTE FUNCTION enforce_lww();

CREATE TABLE public.modifier_group_items (
  id text PRIMARY KEY,
  company_id text NOT NULL REFERENCES companies(id),
  modifier_group_id text NOT NULL REFERENCES modifier_groups(id),
  item_id text NOT NULL REFERENCES items(id),
  sort_order integer NOT NULL DEFAULT 0,
  is_default boolean NOT NULL DEFAULT false,
  client_created_at timestamptz,
  client_updated_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX idx_modifier_group_items_company_updated ON modifier_group_items(company_id, updated_at);
ALTER TABLE modifier_group_items ENABLE ROW LEVEL SECURITY;
CREATE TRIGGER trg_modifier_group_items_timestamps BEFORE INSERT OR UPDATE ON modifier_group_items FOR EACH ROW EXECUTE FUNCTION set_server_timestamps();
CREATE TRIGGER trg_modifier_group_items_lww BEFORE UPDATE ON modifier_group_items FOR EACH ROW EXECUTE FUNCTION enforce_lww();

CREATE TABLE public.item_modifier_groups (
  id text PRIMARY KEY,
  company_id text NOT NULL REFERENCES companies(id),
  item_id text NOT NULL REFERENCES items(id),
  modifier_group_id text NOT NULL REFERENCES modifier_groups(id),
  sort_order integer NOT NULL DEFAULT 0,
  client_created_at timestamptz,
  client_updated_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX idx_item_modifier_groups_company_updated ON item_modifier_groups(company_id, updated_at);
ALTER TABLE item_modifier_groups ENABLE ROW LEVEL SECURITY;
CREATE TRIGGER trg_item_modifier_groups_timestamps BEFORE INSERT OR UPDATE ON item_modifier_groups FOR EACH ROW EXECUTE FUNCTION set_server_timestamps();
CREATE TRIGGER trg_item_modifier_groups_lww BEFORE UPDATE ON item_modifier_groups FOR EACH ROW EXECUTE FUNCTION enforce_lww();

CREATE TABLE public.order_item_modifiers (
  id text PRIMARY KEY,
  company_id text NOT NULL REFERENCES companies(id),
  order_item_id text NOT NULL REFERENCES order_items(id),
  modifier_item_id text NOT NULL REFERENCES items(id),
  modifier_group_id text NOT NULL REFERENCES modifier_groups(id),
  modifier_item_name text NOT NULL DEFAULT '',
  quantity double precision NOT NULL DEFAULT 1.0,
  unit_price integer NOT NULL,
  tax_rate integer NOT NULL,
  tax_amount integer NOT NULL,
  client_created_at timestamptz,
  client_updated_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX idx_order_item_modifiers_company_updated ON order_item_modifiers(company_id, updated_at);
ALTER TABLE order_item_modifiers ENABLE ROW LEVEL SECURITY;
CREATE TRIGGER trg_order_item_modifiers_timestamps BEFORE INSERT OR UPDATE ON order_item_modifiers FOR EACH ROW EXECUTE FUNCTION set_server_timestamps();
CREATE TRIGGER trg_order_item_modifiers_lww BEFORE UPDATE ON order_item_modifiers FOR EACH ROW EXECUTE FUNCTION enforce_lww();

-- RLS policies (SELECT only — writes go through ingest edge function with service role)
CREATE POLICY modifier_groups_select_own ON modifier_groups FOR SELECT USING (company_id IN (SELECT get_my_company_ids()));
CREATE POLICY modifier_group_items_select_own ON modifier_group_items FOR SELECT USING (company_id IN (SELECT get_my_company_ids()));
CREATE POLICY item_modifier_groups_select_own ON item_modifier_groups FOR SELECT USING (company_id IN (SELECT get_my_company_ids()));
CREATE POLICY order_item_modifiers_select_own ON order_item_modifiers FOR SELECT USING (company_id IN (SELECT get_my_company_ids()));

ALTER PUBLICATION supabase_realtime ADD TABLE modifier_groups, modifier_group_items, item_modifier_groups, order_item_modifiers;

# Maty — Database Schema (Full Specification)

Kompletní technická specifikace databázového modelu Drift (SQLite) a Supabase (PostgreSQL).

---

## 1. Architektura a principy
- **Offline-first:** SQLite je primární zdroj pravdy.
- **UUID v7:** PK jsou chronologicky řazené pro optimální výkon indexů.
- **SyncColumnsMixin:** Každá doménová tabulka obsahuje sloupce: `client_created_at` (D), `client_updated_at` (D), `server_created_at` (D?), `server_updated_at` (D?), `last_synced_at` (D?), `version` (I), `deleted_at` (D?).

---

## 2. Kompletní seznam tabulek (45)

> Typy: **T** (Text), **I** (Int), **R** (Real), **B** (Bool), **D** (DateTime). FK označen → tabulka.

### A. Prodej (bills, orders, payments)
- **bills:** id (T), company_id (T), section_id (T?), table_id (T?), opened_by_user_id (T), register_id (T?), last_register_id (T?), register_session_id (T?), bill_number (T), number_of_guests (I, def 0), is_takeaway (B, def false), status (T), currency_id (T), customer_id (T?), customer_name (T?), subtotal_gross (I, def 0), subtotal_net (I, def 0), discount_amount (I, def 0), discount_type (T?), tax_total (I, def 0), total_gross (I, def 0), rounding_amount (I, def 0), paid_amount (I, def 0), loyalty_points_used (I, def 0), loyalty_discount_amount (I, def 0), loyalty_points_earned (I, def 0), voucher_discount_amount (I, def 0), voucher_id (T?), opened_at (D), closed_at (D?), map_pos_x (I?), map_pos_y (I?).
- **orders:** id (T), company_id (T), bill_id (T), created_by_user_id (T), register_id (T?), order_number (T), notes (T?), status (T), item_count (I, def 0), subtotal_gross (I, def 0), subtotal_net (I, def 0), tax_total (I, def 0), is_storno (B, def false), storno_source_order_id (T?), prep_started_at (D?), ready_at (D?), delivered_at (D?).
- **order_items:** id (T), company_id (T), order_id (T), item_id (T), item_name (T), quantity (R), unit (T), voucher_discount (I, def 0), sale_price_att (I), sale_tax_rate_att (I), sale_tax_amount (I), discount (I, def 0), discount_type (T?), notes (T?), status (T), prep_started_at (D?), ready_at (D?), delivered_at (D?).
- **payments:** id (T), company_id (T), bill_id (T), register_id (T?), register_session_id (T?), payment_method_id (T), user_id (T?), amount (I), paid_at (D), currency_id (T), tip_included_amount (I, def 0), notes (T?), transaction_id (T?), payment_provider (T?), card_last4 (T?), authorization_code (T?), foreign_currency_id (T?), foreign_amount (I?), exchange_rate (R?).
- **payment_methods:** id (T), company_id (T), name (T), type (T), is_active (B, def true).
- **company_currencies:** id (T), company_id (T), currency_id (T), exchange_rate (R), is_active (B, def true), sort_order (I, def 0).
- **session_currency_cash:** id (T), company_id (T), register_session_id (T), currency_id (T), opening_cash (I, def 0), closing_cash (I?), expected_cash (I?), difference (I?).

### B. Katalog a Položky
- **items:** id (T), company_id (T), category_id (T?), name (T), description (T?), item_type (T), sku (T?), alt_sku (T?), unit_price (I?), sale_tax_rate_id (T?), purchase_price (I?), purchase_tax_rate_id (T?), is_sellable (B, def true), is_active (B, def true), is_on_sale (B, def true), is_stock_tracked (B, def false), min_quantity (R?), unit (T), manufacturer_id (T?), supplier_id (T?), parent_id (T?), negative_stock_policy (T?).
- **categories:** id (T), company_id (T), name (T), parent_id (T?), is_active (B, def true).
- **modifier_groups:** id (T), company_id (T), name (T), min_selections (I, def 0), max_selections (I?), sort_order (I, def 0).
- **modifier_group_items:** id (T), company_id (T), modifier_group_id (T), item_id (T), sort_order (I, def 0), is_default (B, def false).
- **item_modifier_groups:** id (T), company_id (T), item_id (T), modifier_group_id (T), sort_order (I, def 0).
- **order_item_modifiers:** id (T), company_id (T), order_item_id (T), modifier_item_id (T), modifier_group_id (T), modifier_item_name (T), quantity (R, def 1.0), unit_price (I), tax_rate (I), tax_amount (I).
- **product_recipes:** id (T), company_id (T), parent_product_id (T), component_product_id (T), quantity_required (R).
- **tax_rates:** id (T), company_id (T), label (T), type (T), rate (I), is_default (B, def false).
- **currencies:** id (T), code (T), symbol (T), name (T), decimal_places (I).

### C. Firma a Uživatelé
- **companies:** id (T), name (T), status (T), business_id (T?), address (T?), phone (T?), email (T?), vat_number (T?), country (T?), city (T?), postal_code (T?), timezone (T?), business_type (T?), default_currency_id (T), auth_user_id (T), is_demo (B, def false), demo_expires_at (D?), trial_expires_at (D?), license_expires_at (D?), license_last_check_at (D?).
- **company_settings:** id (T), company_id (T), require_pin_on_switch (B, def true), auto_lock_timeout_minutes (I?), loyalty_earn_rate (I, def 0), loyalty_point_value (I, def 0), locale (T, def 'cs'), negative_stock_policy (T, def 'allow'), max_item_discount_percent (I, def 2000), max_bill_discount_percent (I, def 2000), bill_age_warning_minutes (I, def 15), bill_age_danger_minutes (I, def 30), bill_age_critical_minutes (I, def 45).
- **users:** id (T), company_id (T), auth_user_id (T?), username (T), full_name (T), email (T?), phone (T?), pin_hash (T), pin_enabled (B, def true), role_id (T), is_active (B, def true).
- **roles:** id (T), name (T).
- **permissions:** id (T), code (T), name (T), description (T?), category (T).
- **role_permissions:** id (T), role_id (T), permission_id (T).
- **user_permissions:** id (T), company_id (T), user_id (T), permission_id (T), granted_by (T).
- **shifts:** id (T), company_id (T), register_session_id (T), user_id (T), login_at (D), logout_at (D?), original_login_at (D?), original_logout_at (D?), edited_by (T?), edited_at (D?).

### D. Provozovna a Pokladna
- **sections:** id (T), company_id (T), name (T), color (T?), is_active (B, def true), is_default (B, def false), sort_order (I, def 0).
- **tables:** id (T), company_id (T), section_id (T?), table_name (T), capacity (I, def 0), is_active (B, def true), grid_row (I, def 0), grid_col (I, def 0), grid_width (I, def 3), grid_height (I, def 3), shape (T, def rectangle), color (T?), font_size (I?), fill_style (I, def 1), border_style (I, def 1).
- **map_elements:** id (T), company_id (T), section_id (T?), grid_row (I, def 0), grid_col (I, def 0), grid_width (I, def 2), grid_height (I, def 2), label (T?), color (T?), shape (T, def rectangle), font_size (I?), fill_style (I, def 1), border_style (I, def 1).
- **registers:** id (T), company_id (T), code (T), name (T, def ''), register_number (I, def 1), parent_register_id (T?), is_main (B, def false), is_active (B, def true), type (T), allow_cash (B, def true), allow_card (B, def true), allow_transfer (B, def true), allow_credit (B, def true), allow_voucher (B, def true), allow_meal_ticket (B, def true), allow_other (B, def true), allow_refunds (B, def false), bound_device_id (T?), active_bill_id (T?), grid_rows (I, def 7), grid_cols (I, def 8), display_cart_json (T?), sell_mode (T, def gastro), show_stock_badge (B, def false).
- **register_sessions:** id (T), company_id (T), register_id (T), opened_by_user_id (T), parent_session_id (T?), opened_at (D), closed_at (D?), order_counter (I, def 0), bill_counter (I, def 0), opening_cash (I?), closing_cash (I?), expected_cash (I?), difference (I?), open_bills_at_open_count (I?), open_bills_at_open_amount (I?), open_bills_at_close_count (I?), open_bills_at_close_amount (I?).
- **cash_movements:** id (T), company_id (T), register_session_id (T), user_id (T), type (T), amount (I), reason (T?), currency_id (T?).
- **display_devices:** id (T), company_id (T), parent_register_id (T?), code (T), name (T, def ''), welcome_text (T, def ''), type (T), is_active (B, def true).
- **layout_items:** id (T), company_id (T), register_id (T), page (I, def 0), grid_row (I), grid_col (I), type (T), item_id (T?), category_id (T?), label (T?), color (T?).

### E. Sklad (stock)
- **warehouses:** id (T), company_id (T), name (T), is_default (B, def false), is_active (B, def true).
- **stock_levels:** id (T), company_id (T), warehouse_id (T), item_id (T), quantity (R, def 0.0), min_quantity (R?).
- **stock_documents:** id (T), company_id (T), warehouse_id (T), supplier_id (T?), user_id (T), document_number (T), type (T), purchase_price_strategy (T?), note (T?), total_amount (I, def 0), document_date (D).
- **stock_movements:** id (T), company_id (T), stock_document_id (T?), bill_id (T?), item_id (T), quantity (R), purchase_price (I?), direction (T), purchase_price_strategy (T?).

### F. CRM a Rezervace
- **customers:** id (T), company_id (T), first_name (T), last_name (T), email (T?), phone (T?), address (T?), points (I, def 0), credit (I, def 0), total_spent (I, def 0), last_visit_date (D?), birthdate (D?).
- **customer_transactions:** id (T), company_id (T), customer_id (T), points_change (I), credit_change (I), order_id (T?), processed_by_user_id (T), reference (T?), note (T?).
- **reservations:** id (T), company_id (T), customer_id (T?), table_id (T?), customer_name (T), customer_phone (T?), reservation_date (D), party_size (I, def 2), duration_minutes (I, def 90), status (T), notes (T?).
- **vouchers:** id (T), company_id (T), code (T), type (T), status (T), value (I), discount_type (T?), discount_scope (T?), item_id (T?), category_id (T?), min_order_value (I?), max_uses (I, def 1), used_count (I, def 0), customer_id (T?), source_bill_id (T?), redeemed_on_bill_id (T?), expires_at (D?), redeemed_at (D?), created_by_user_id (T?), note (T?).

### G. Sync a Lokální
- **sync_queue:** id (T), company_id (T), entity_type (T), entity_id (T), operation (T), payload (T), status (T), idempotency_key (T), retry_count (I), error_message (T?), last_error_at (D?), processed_at (D?), created_at (D).
- **sync_metadata:** id (T), company_id (T), table_name (T), last_pulled_at (T), updated_at (D).
- **device_registrations:** id (T), company_id (T), register_id (T), created_at (D).

---

## 3. Indexy
- Index na `company_id` + `updated_at` na všech doménových tabulkách.
- `sync_queue`: `company_id + status`, `entity_type + entity_id`, `created_at`.
- `companies`: `idx_companies_demo_expires`.
- `stock_levels`: Composite index na `warehouse_id + item_id`.

---

## 4. PostgreSQL Triggery
- `set_server_timestamps`: Nastavuje `server_updated_at = now()`.
- `enforce_lww`: BEFORE UPDATE trigger pro Last Write Wins.
- `broadcast_sync_change`: AFTER INSERT/UPDATE trigger volající `realtime.send()`.
- `guard_last_admin`: Brání smazání posledního admina firmy.
- `aa_protect_license_fields`: Chrání licenční pole na `companies`.

# Changelog

## 2026-02-21 — Varianty a Modifikátory

### Features
- **Variant picker** (sell screen): Tap na produkt s variantami otevře výběrový dialog; varianty v košíku vždy jako konkrétní varianta
- **Variant management** (katalog): ExpansionTile v product edit dialogu, CRUD sub-dialog (název, cena, SKU, alt SKU)
- **Modifier groups**: Kompletní CRUD — skupiny s pravidly výběru (min/max selections), správa modifier items ve skupinách
- **Modifier assignment**: Přiřazení modifier groups k produktům přes catalog edit dialog, dědičnost na varianty
- **Modifier selection** (sell screen): Dialog s radio buttons (single-select) a checkboxy (multi-select), running total, validace povinných skupin
- **Cart modifiers**: Modifikátory zobrazeny pod položkou, effectiveUnitPrice = base + Σ(modifier prices), dedup klíč zahrnuje sorted modifier set
- **Order tracking**: Snapshot modifikátorů v `order_item_modifiers` (denormalizovaný název, cena, daň)
- **Storno**: Kopírování modifikátorů do storno objednávky, reversování stock, zahrnutí modifier cen v totals
- **KDS display**: Modifikátory pod položkou (+ name, bodySmall)
- **Customer display**: Modifikátory v effectiveUnitPrice
- **Bill detail**: Modifikátory pod order items
- **Receipt PDF**: Modifikátory odsazené pod položkou, menší font, cena trailing

### Schema
- 4 nové tabulky: `modifier_groups`, `modifier_group_items`, `item_modifier_groups`, `order_item_modifiers`
- Supabase migrace: `20260221_001_add_modifier_tables.sql` (CREATE TABLE, indexes, RLS, triggers, realtime)

### New Files
- `lib/core/database/tables/modifier_groups.dart`
- `lib/core/database/tables/modifier_group_items.dart`
- `lib/core/database/tables/item_modifier_groups.dart`
- `lib/core/database/tables/order_item_modifiers.dart`
- `lib/core/data/models/modifier_group_model.dart`
- `lib/core/data/models/modifier_group_item_model.dart`
- `lib/core/data/models/item_modifier_group_model.dart`
- `lib/core/data/models/order_item_modifier_model.dart`
- `lib/core/data/repositories/modifier_group_repository.dart`
- `lib/core/data/repositories/modifier_group_item_repository.dart`
- `lib/core/data/repositories/item_modifier_group_repository.dart`
- `lib/core/data/repositories/order_item_modifier_repository.dart`
- `lib/features/catalog/widgets/catalog_modifiers_tab.dart`
- `supabase/migrations/20260221_001_add_modifier_tables.sql`

### Modified
- `lib/features/sell/screens/screen_sell.dart` — _CartItem + _CartModifier, variant picker, modifier dialog, cart dedup, order item modifier inputs
- `lib/core/data/repositories/order_repository.dart` — createOrderWithItems (modifier insert + totals), voidItem (modifier copy + stock), _recalculateOrderTotals
- `lib/core/data/repositories/bill_repository.dart` — updateTotals (batch-load modifiers, include in gross/tax)
- `lib/core/data/repositories/item_repository.dart` — watchVariants, hasVariants, search filter (exclude modifiers)
- `lib/core/printing/receipt_data.dart` — ReceiptModifierData, modifiers on ReceiptItemData
- `lib/core/printing/printing_service.dart` — orderItemModifierRepo dependency, load modifiers per item
- `lib/core/printing/receipt_pdf_builder.dart` — render modifier lines
- `lib/core/data/providers/repository_providers.dart` — 4 new repository providers
- `lib/core/data/providers/printing_providers.dart` — orderItemModifierRepo
- `lib/core/data/mappers/entity_mappers.dart` — 4 new fromEntity/toCompanion pairs
- `lib/core/data/mappers/supabase_mappers.dart` — 4 new toSupabaseJson functions
- `lib/core/data/mappers/supabase_pull_mappers.dart` — 4 new fromSupabasePull cases
- `lib/core/database/app_database.dart` — 4 new tables registered
- `lib/core/sync/sync_service.dart` — tableDependencyOrder + _getDriftTable
- `lib/core/sync/realtime_service.dart` — 3 new realtime tables
- `lib/core/data/services/seed_service.dart` — modifier groups, items, assignments seed data
- `lib/features/catalog/screens/screen_catalog.dart` — Modifiers tab (7 tabs)
- `lib/features/catalog/widgets/catalog_products_tab.dart` — _ModifierGroupsExpansionTile, _VariantsExpansionTile
- `lib/features/orders/screens/screen_kds.dart` — modifier display on KDS cards
- `lib/features/bills/widgets/dialog_bill_detail.dart` — modifier display under order items
- `supabase/functions/ingest/index.ts` — 4 new ALLOWED_TABLES
- `supabase/functions/wipe/index.ts` — 4 new COMPANY_TABLES

### Localization
- Added keys: variants, addVariant, editVariant, noVariants, variantPickerTitle, modifiers, modifierGroups, modifierGroupName, addModifierGroup, editModifierGroup, deleteModifierGroup, minSelections, maxSelections, required, optional, unlimited, addModifier, selectModifiers, noModifierGroups, modifierTotal, modifierGroupRequired, assignModifierGroup, removeModifierGroup

### Documentation
- PROJECT.md: Active tables 39→43, 4 new table columns, removed planned tables section, updated seed data, Gastro/Pokročilé produkty sections

---

## 2026-02-16 (evening) — Loyalty reversal

### Features
- **refundBill**: Reverse earned loyalty points, return redeemed points, reverse totalSpent on full bill refund
- **refundItem**: Proportional reversal of earned loyalty points, partial totalSpent reversal; returns redeemed points when bill is fully refunded via item refunds
- **cancelBill**: Return redeemed loyalty points when cancelling bill with loyalty discount
- **recordPayment**: Store `loyaltyPointsEarned` on bill inside transaction (ensures correct sync to Supabase)

### Schema
- Added `loyalty_points_earned` (int, default 0) column to `bills` table (Drift + Supabase migration)
- `updateTrackingOnPayment`: Added `updateLastVisit` parameter, `totalSpent` floored at 0

### Documentation
- PROJECT.md: Updated bills schema, BillRepository method descriptions, cancelBill rules, BillStatus notes with loyalty reversal workflow

---

## 2026-02-16 — Audit fixes (TMR audit)

### Supabase Migrations
- **F-02**: Removed stale `inPrep` value from `prep_status` enum (recreated type without it)
- **F-03**: Dropped redundant columns from `display_devices` (`server_created_at`, `server_updated_at`, `last_synced_at`, `version`), set NOT NULL on `client_created_at`/`client_updated_at`
- **F-05**: Added missing FK indexes on `display_devices` (`company_id`, `parent_register_id`)
- **F-06**: Replaced broad anon SELECT policy on `display_devices` with SECURITY DEFINER RPC `lookup_display_device_by_code`
- **F-08**: Renamed triggers to `trg_display_devices_lww` / `trg_display_devices_timestamps` (consistent naming)
- **F-10**: Renamed `loyalty_earn_per_hundred_czk` → `loyalty_earn_rate`, `loyalty_point_value_halere` → `loyalty_point_value` in `company_settings`

### Fixes
- **F-01**: Wipe Edge Function — added missing `customers` table, removed non-existent `device_registrations` and `sync_metadata` references
- **F-09**: Drift `tables` — changed `gridWidth`/`gridHeight` defaults from 1 to 3 (matches Supabase and pull mapper fallbacks)
- **F-10**: Updated push/pull mappers for renamed `company_settings` loyalty columns

### Security
- **F-06**: `display_device_repository.dart` — `lookupByCode` now uses narrow RPC instead of direct table query (anon access scoped to single record, 4 fields only)

### Documentation
- PROJECT.md: Updated `tables` grid defaults, wipe EF description, RLS anon access policy, display_devices pairing RPC

---

## 2026-02-12 — Milník 3.9: Multi-register architektura (6 fází)

### Phase 1 — Schema + Device Binding
- **device_registrations** — nová lokální tabulka (nesync) pro vazbu zařízení↔pokladna
- **registers** — přidáno: `name`, `register_number`, `parent_register_id` (pro mobile→local hierarchii)
- **register_sessions** — přidáno: `bill_counter`
- **orders** — přidáno: `register_id` (atribuce objednávky k pokladně)
- **payments** — přidáno: `register_id` (atribuce platby k pokladně)
- `DeviceRegistrationRepository` — bind/unbind/getForCompany (lokální, bez sync)
- `activeRegisterProvider` — device binding lookup (vrací null bez device binding)
- `deviceRegistrationProvider` — lokální lookup pro aktuální firmu

### Phase 2 — CRUD pokladen + Payment Enforcement
- `RegistersTab` — nový PosTable widget se správou pokladen (add/edit/delete, HardwareType, parent register, payment flags)
- `ScreenRegisterSettings` — rozšířen z 1 sekce na 3 taby (Aktuální pokladna, Správa pokladen, Device binding)
- `RegisterRepository` — create (auto `registerNumber` + `code` REG-N), update, delete, getFirstActive, watchAll, getNextRegisterNumber
- `DialogPayment` — filtruje platební metody dle `register.allowCash/Card/Transfer`
- `DialogVoucherCreate` — respektuje `register.allowRefunds`

### Phase 3 — Z-report per register + Cash Handover
- `CashMovementType.handover` — nová enum hodnota pro mobile→local předání hotovosti
- `ZReportService.buildVenueZReport` — agregace N sessions s per-register breakdowns
- `ZReportService.getSessionSummaries` — filtrovatelné dle registeru a data
- `RegisterSessionRepository` — `incrementBillCounter`, rozšířený `getClosedSessions`
- `DialogZReport` — sekce per-register breakdown, shift durations, open bills
- `DialogZReportList` — filtrování dle registeru
- `DialogCashJournal` — typ `handover` pro cash movements

### Phase 4 — Supabase Realtime <2s Sync
- `RealtimeService` — subscribuje PostgresChanges na 21 company-scoped tabulek
- `SyncService.mergeRow` — LWW merge přes `insertOnConflictUpdate`
- Reconnect → okamžitý `pullAll` (flag `_wasSubscribed`)
- Dual sync strategie: polling 5min (fallback) + Realtime (instant)
- `realtimeServiceProvider` + integrace do `SyncLifecycleManager`

### Phase 5 — KDS (Kitchen Display System)
- `ScreenKds` — touch-optimized grid karet s objednávkami, elapsed-time badge
- Per-item a full-order status bumping (created→inPrep→ready→delivered)
- `_isBumping` guard proti double-tap přeskočení statusu
- Status filter chips (Připravuje se/Hotové/Doručené)
- Storno ordery vyloučeny z KDS

### Phase 6 — Customer Display
- `ScreenCustomerDisplay` — read-only zákaznický displej pro sekundární monitor
- Register-centric architektura: displej sleduje `activeBillId` a `displayCartJson` na registru (sync přes outbox)
- 4 stavy: idle (jméno firmy), cart preview (z `displayCartJson`), active (reálné objednávky), ThankYou (5s po platbě)
- Discount výpočet z `subtotalGross - totalGross + roundingAmount`
- Filtrování storno orderů a voided/cancelled položek
- `DialogModeSelector` + enum `RegisterMode` (pos, kds, customerDisplay) pro přepínání režimu zařízení
- Tlačítko „Zák. displej" v `DialogBillDetail` — toggle s eye/eye-off ikonou pro manuální zobrazení účtu na displeji
- ScreenSell: debounced sync košíku do `displayCartJson` (300ms), auto-clear při submit/pay/dispose

### Routing
- `/kds` — permission `orders.view`
- `/customer-display` a `/customer-display/:registerId` — bez permission guardu
- `/settings/register` — 2 taby (Pokladna, Režim)

### Schema
- 38 tabulek v @DriftDatabase (35 doménových + 1 lokální + 2 sync)
- `CashMovementType` enum — přidáno `handover`
- `registers` — přidáno: `is_main`, `bound_device_id`, `active_bill_id`, `display_cart_json`
- `register_sessions` — přidáno: `parent_session_id`
- `bills` — přidáno: `register_id`, `last_register_id`, `register_session_id`, `customer_name`

### New Files
- `lib/core/database/tables/device_registrations.dart`
- `lib/core/data/models/device_registration_model.dart`
- `lib/core/data/repositories/device_registration_repository.dart`
- `lib/core/sync/realtime_service.dart`
- `lib/features/orders/screens/screen_kds.dart`
- `lib/features/sell/screens/screen_customer_display.dart`
- `lib/features/settings/widgets/registers_tab.dart`

### L10n
- +55 nových klíčů v `app_cs.arb` (registr, KDS, customer display, Z-report, device binding)
- Odstraněny nepoužité klíče: `kdsAllCategories`, `ordersFilterAll`

### Fixes
- `ScreenOrders` + `ScreenKds` — sjednocení barvy `PrepStatus.cancelled` na `Colors.pink`
- `ScreenCustomerDisplay` — oprava CRITICAL bugu: discount počítán z computed totals místo raw `discountAmount` (který ukládá basis points pro procentní slevy)

### Documentation
- PROJECT.md: Milník 3.9, aktualizace schématu, routes, providers, Realtime sync, KDS/Customer Display layouty, ScreenRegisterSettings 2 taby, device_registrations tabulka, Supabase deployment requirements
- PROJECT.md: Důkladná aktualizace na základě 3-agentového auditu — schema enum anotace, Ingest Edge Function sekce, companyRepos 17 repos, repository providers 34, register-centric customer display, collapsible panel + InfoPanel stats, opravený activeRegisterProvider popis

---

## 2026-02-11 — Per-item status transitions + order status aggregation

### Features
- **Per-item status**: Individual order items can now transition through statuses independently (created → inPrep → ready → delivered)
- **Order status aggregation**: Order.status is automatically derived from item statuses via `_deriveOrderStatus()` — no more bulk order-level status changes
- **ScreenOrders**: Per-item status buttons replace order-level action buttons; each item row shows status dot + next-status button
- **DialogBillDetail**: Status popup menu now operates per-item instead of per-order
- **Item-level timestamps**: `prep_started_at`, `ready_at`, `delivered_at` on each order item
- **ScreenOrders grid layout**: Responsive 2–3 column grid (Wrap) instead of single-column ListView

### Data Layer
- 3 new nullable columns in `order_items` Drift table: `prep_started_at`, `ready_at`, `delivered_at`
- OrderItemModel: 3 new optional DateTime fields
- Entity mapper, Supabase push mapper, Supabase pull mapper updated for new fields
- OrderRepository: new `updateItemStatus()` method + `_deriveOrderStatus()` aggregation logic

### Documentation
- PROJECT.md: order_items schema updated, aggregation rules documented as implemented

## 2026-02-11 — Add sectionId to bills

### Features
- Bills now store `section_id` directly — bills without a table are filterable by section in the bills overview
- DialogNewBill passes selected section to bill creation
- Quick sale and convert-to-bill resolve default section automatically

### Data Layer
- New nullable column `section_id` in `bills` Drift table + BillModel + all mappers (entity, supabase push, supabase pull)
- BillRepository.createBill: new optional `sectionId` parameter
- BillRepository.watchByCompany: section filter now matches bills by `tableId` (via tables in section) or by `sectionId` (for table-less bills)
- Supabase migration: `ALTER TABLE bills ADD COLUMN section_id text REFERENCES sections(id)` + index

### Documentation
- PROJECT.md: bills schema, DialogNewBill fields, quick sale flow, BillRepository API updated

## 2026-02-11 — Milestone 3.8: Order Management

### Features
- **Storno orders**: Void jednotlivé položky na otevřeném účtu → vytvoří storno order (isStorno, X-XXXX prefix, reference na zdrojový order, stock reversal, auto-void při prázdném orderu)
- **Status timestamps**: Ordery ukládají prep_started_at, ready_at, delivered_at při změně stavu
- **Cart separator**: Tlačítko "Oddělit" v ScreenSell — jedno odeslání vytvoří N oddělených objednávek (chodů)
- **ScreenOrders**: Nová obrazovka `/orders` — kartový přehled objednávek, scope toggle (Session/Vše), status filtry (Aktivní/Vytvořené/Připravované/Hotové/Doručené/Stornované), akční tlačítka pro změnu stavu, void z karty

### Data Layer
- 5 nových sloupců v `orders` tabulce: is_storno, storno_source_order_id, prep_started_at, ready_at, delivered_at
- Supabase migrace: ALTER TABLE orders + FK constraint
- OrderRepository: voidItem(), watchByCompany(), _reverseStockForSingleItem(), _recalculateOrderTotals(), _autoVoidOrderIfEmpty()
- BillRepository.updateTotals: filtruje storno ordery

### New Files
- `lib/features/orders/screens/screen_orders.dart`

### L10n
- +17 nových klíčů v `app_cs.arb` (storno, ordery, filtry, separator)

### Routing
- `/orders` route s permission guardem `orders.view`
- "Objednávky" entry v DALŠÍ menu na ScreenBills

### Documentation
- PROJECT.md: oprava permission `/orders` z bills.manage na orders.view

## 2026-02-11 — Sjednocení dialogového systému

### Features
- **PosDialogTheme**: Nové konstanty pro unified dialog system (padding, spacing, button heights, numpad profily)
- **PosDialogShell**: Shared wrapper nahrazující opakovaný `Dialog > ConstrainedBox > Padding > Column` pattern
- **PosDialogActions**: Shared akční tlačítková řada s rovnoměrným rozložením
- **PosNumpad**: Sdílený numpad widget se dvěma velikostmi (large/compact), konfigurovatelnými tlačítky (clear, dot, bottomLeftChild)
- Migrace 22 z 26 dialogů na sdílené widgety (4 ponechány s vlastním layoutem: bill_detail, payment, grid_editor, cash_journal)

### New Files
- `lib/core/widgets/pos_dialog_theme.dart` — konstanty
- `lib/core/widgets/pos_dialog_shell.dart` — dialog wrapper
- `lib/core/widgets/pos_dialog_actions.dart` — button row
- `lib/core/widgets/pos_numpad.dart` — sdílený numpad

### L10n
- +3 nové klíče: `actionConfirm`, `voucherRedeemedAt`, `voucherIdLabel`

### Documentation
- PROJECT.md: Přidána sekce Dialog System do Core Widgets

## 2026-02-11 — Dekorativní prvky mapy + resize handles

### Features
- **MapElement entita**: Nová tabulka `map_elements` (Drift + Supabase) pro dekorativní prvky mapy — stěny, bary, zóny, popisky
- **Editor — selection model**: Single tap = výběr se 4 rohovými resize handles (s resize kurzory), double tap = edit dialog
- **Editor — resize**: Drag za rohový handle mění velikost prvku/stolu (grid snap, live preview, minimum 1×1)
- **Editor — dekorativní prvky**: Dialog přidání s přepínačem Stůl/Prvek, paleta 8 barev + žádná, volitelný popisek
- **Runtime rendering**: Neinteraktivní vrstvení — barevné prvky pod stoly, textové popisky nad stoly

### New Files
- `lib/core/database/tables/map_elements.dart` — Drift table definition
- `lib/core/data/models/map_element_model.dart` — Freezed model
- `lib/core/data/repositories/map_element_repository.dart` — repository

### L10n
- +8 nových klíčů v `app_cs.arb` pro prvky mapy

### Documentation
- PROJECT.md: Aktualizována sekce FloorMapEditorTab, přidán `map_elements` do schématu a Drift tabulek, aktualizována Gastro rozšíření

## 2026-02-11 — Milník 3.7: Rezervace

### Features
- **Rezervace**: Nová tabulka `reservations` s Drift definicí, Freezed modelem, repository, mappers (entity, supabase push, supabase pull), sync registrací a provider
- **ReservationStatus enum**: `created`, `confirmed`, `seated`, `cancelled`
- **DialogReservationsList**: Seznam rezervací s date range filtrem (výchozí: dnes + 7 dní), 7 sloupců (datum, čas, jméno, telefon, počet, stůl, stav), kliknutí na řádek otevře edit dialog
- **DialogReservationEdit**: Create/edit formulář — jméno, telefon, propojení zákazníka z DB (pre-fill), date/time picker, party size, table dropdown, poznámka, status segmented button (edit only), delete (edit only)
- **Menu wiring**: Aktivován stub "Rezervace" v menu "Další" na ScreenBills (přístup pro všechny uživatele)

### New Files
- `lib/core/database/tables/reservations.dart` — Drift table definition
- `lib/core/data/enums/reservation_status.dart` — status enum
- `lib/core/data/models/reservation_model.dart` — Freezed model
- `lib/core/data/repositories/reservation_repository.dart` — repository s `watchByDateRange`
- `lib/features/bills/widgets/dialog_reservations_list.dart` — list dialog
- `lib/features/bills/widgets/dialog_reservation_edit.dart` — create/edit dialog

### L10n
- +27 nových klíčů v `app_cs.arb` pro rezervace

## 2026-02-11 — Milník 3.6: Tisk (účtenky + Z-report)

### Features
- **Účtenka PDF**: Generování 80mm thermal receipt PDF — hlavička firmy (název, adresa, IČO, DIČ), info účtu, položky se slevami a poznámkami, DPH rekapitulace (tabulka), platby se spropitným, patička
- **Z-report PDF**: A4 PDF se strukturou kopírující `DialogZReport` — session info, tržby dle plateb, DPH, spropitné, slevy, počty účtů, cash reconciliation, směny
- **Tlačítka tisku**: Aktivována stub tlačítka v `DialogBillDetail` (sidebar + footer) a `DialogZReport`
- **České fonty**: Bundled Roboto Regular + Bold TTF pro správné zobrazení diakritiky v PDF

### New Files
- `assets/fonts/Roboto-Regular.ttf`, `Roboto-Bold.ttf` — fonty pro PDF
- `lib/core/printing/pdf_font_loader.dart` — singleton lazy-loading fontů z assets
- `lib/core/printing/receipt_data.dart` — datové třídy `ReceiptData`, `ReceiptLabels`, `ZReportLabels`
- `lib/core/printing/receipt_pdf_builder.dart` — receipt PDF builder (80mm šířka)
- `lib/core/printing/z_report_pdf_builder.dart` — Z-report PDF builder (A4)
- `lib/core/printing/printing_service.dart` — orchestrace: sběr dat z repozitářů + generování PDF
- `lib/core/data/providers/printing_providers.dart` — Riverpod provider pro `PrintingService`
- `lib/features/bills/widgets/dialog_receipt_preview.dart` — `showReceiptPrintDialog()` funkce

### Dependencies
- `pdf: ^3.11.1` — cross-platform PDF generování
- `printing: ^5.13.4` — (zatím nevyužito pro nativní tisk, macOS desktop kompatibilita)

### L10n
- +33 nových klíčů v `app_cs.arb` pro popisky účtenky a Z-reportu

## 2026-02-10 — Milník 3.4: Product Catalog Expansion (/catalog)

### Schema
- **3 new tables**: `suppliers` (supplier_name, contact_person, email, phone), `manufacturers` (name), `product_recipes` (parent_product_id, component_product_id, quantity_required)
- **items**: Added 8 columns — `alt_sku`, `purchase_price`, `purchase_tax_rate_id`, `is_on_sale` (default true), `is_stock_tracked` (default false), `manufacturer_id`, `supplier_id`, `parent_id`
- **categories**: Added `parent_id` for hierarchical categories (max 3 levels)
- **ItemType enum**: Extended with `recipe`, `ingredient`, `variant`, `modifier`
- Table count: 25 → 28 active (26 domain + 2 sync)

### Features
- **ScreenCatalog** (`/catalog`): New route with 5 tabs — Produkty, Kategorie, Dodavatelé, Výrobci, Receptury
- **CatalogProductsTab**: Extended product management with supplier/manufacturer dropdowns, purchase price, alt SKU, on-sale/stock-tracked toggles
- **CatalogCategoriesTab**: Category management with parent category dropdown (self-reference filtered)
- **SuppliersTab**: CRUD for suppliers (name, contact person, email, phone)
- **ManufacturersTab**: CRUD for manufacturers (name)
- **RecipesTab**: CRUD for product recipes with parent/component item dropdowns and quantity
- **ScreenDev**: Reduced from 6 to 4 tabs (Products + Categories moved to Catalog)
- **"Další" menu**: Added "Katalog" item → `/catalog`

### Sync
- 3 new tables added to `_pullTables` (suppliers, manufacturers before items; product_recipes after items)
- 3 new `_getDriftTable` cases
- 3 new repositories extend `BaseCompanyScopedRepository` (auto outbox)
- Pull table count: 22 → 25

### New Files
- `lib/core/database/tables/suppliers.dart`, `manufacturers.dart`, `product_recipes.dart`
- `lib/core/data/models/supplier_model.dart`, `manufacturer_model.dart`, `product_recipe_model.dart`
- `lib/core/data/repositories/supplier_repository.dart`, `manufacturer_repository.dart`, `product_recipe_repository.dart`
- `lib/features/catalog/screens/screen_catalog.dart`
- `lib/features/catalog/widgets/catalog_products_tab.dart`, `catalog_categories_tab.dart`, `suppliers_tab.dart`, `manufacturers_tab.dart`, `recipes_tab.dart`

### Modified
- `lib/core/data/enums/item_type.dart` — 4 new enum values
- `lib/core/database/tables/items.dart` — 8 new columns
- `lib/core/database/tables/categories.dart` — parentId column
- `lib/core/data/models/item_model.dart`, `category_model.dart` — new fields
- `lib/core/data/mappers/entity_mappers.dart` — 3 new + 2 updated mapper pairs
- `lib/core/data/mappers/supabase_mappers.dart` — 3 new + 2 updated push mappers
- `lib/core/data/mappers/supabase_pull_mappers.dart` — 3 new + 2 updated pull cases
- `lib/core/data/repositories/item_repository.dart`, `category_repository.dart` — new fields in toUpdateCompanion
- `lib/core/data/providers/repository_providers.dart` — 3 new providers
- `lib/core/database/app_database.dart` — 3 new tables registered
- `lib/core/sync/sync_service.dart` — 3 new pull tables + getDriftTable cases
- `lib/core/routing/app_router.dart` — /catalog route with permission guard
- `lib/features/bills/screens/screen_bills.dart` — "Katalog" in "Další" menu
- `lib/features/settings/screens/screen_dev.dart` — reduced to 4 tabs

### Deleted Files
- `lib/features/settings/widgets/products_tab.dart` — moved to catalog
- `lib/features/settings/widgets/categories_tab.dart` — moved to catalog

### Localization
- Added 22 Czech keys: catalogTitle, catalogTabProducts, catalogTabCategories, catalogTabSuppliers, catalogTabManufacturers, catalogTabRecipes, fieldSupplierName, fieldContactPerson, fieldEmail, fieldPhone, fieldManufacturer, fieldSupplier, fieldParentCategory, fieldAltSku, fieldPurchasePrice, fieldPurchaseTaxRate, fieldOnSale, fieldStockTracked, fieldParentProduct, fieldComponent, fieldQuantityRequired, moreCatalog

### Documentation
- PROJECT.md: Updated table counts (28 active, 26 domain), added /catalog route, updated ScreenDev (4 tabs), added ScreenCatalog section, updated items/categories column docs, updated ItemType enum, updated sync table counts, updated "Další" menu, moved implemented items from "Možná rozšíření"

---

## 2026-02-10 (evening) — Settings restructure: 3 tabs (Firma / Pokladna / Uživatelé)

### Features
- **ScreenSettings restructure**: Replaced 3 old tabs (Zabezpečení, Prodej, Cloud) with new structure:
  - **Firma** (`CompanyTab`): Company info form (name, IČO, DIČ, address, phone, email + save), security settings (PIN toggle, auto-lock), cloud auth (embedded `ScreenCloudAuth`)
  - **Pokladna** (`RegisterTab`): Grid display settings (rows, columns)
  - **Uživatelé** (`UsersTab`): Moved from ScreenDev — user management (DataTable, add/edit/delete)
- **ScreenDev**: Reduced from 7 to 6 tabs (Users tab removed, now in Settings)
- **Company info editing**: New form in Settings allows editing company name, IČO, DIČ, address, phone, email via `CompanyRepository.update()`

### Removed Files
- `security_tab.dart` — content merged into `CompanyTab`
- `sales_tab.dart` — content moved to `RegisterTab`

### Localization
- New keys: `settingsTabCompany`, `settingsTabRegister`, `settingsTabUsers`, `settingsSectionCompanyInfo`, `settingsSectionSecurity`, `settingsSectionCloud`, `settingsSectionGrid`, `companyFieldVatNumber`
- Removed keys: `settingsTabSecurity`, `settingsTabSales`, `settingsTabCloud`

## 2026-02-10 (Settings: Security/Sales tabs + PIN-skip + Auto-lock)

### Features
- **`company_settings` table**: New table for per-company settings — `require_pin_on_switch` (bool, default true), `auto_lock_timeout_minutes` (int?, nullable = disabled)
- **Security tab** (`SecurityTab`): Toggle PIN requirement on user switch + auto-lock timeout dropdown (off / 1, 2, 5, 10, 15, 30 min)
- **Sales tab** (`SalesTab`): Edit grid rows (1–10) and columns (1–12) for the active register
- **PIN-skip**: When `require_pin_on_switch` is off, switching to already-logged-in user skips PIN entry; new login always requires PIN
- **Auto-lock**: `InactivityDetector` wraps the app — after configured inactivity timeout, shows `LockOverlay` with user selection + PIN; shifts keep running during lock
- **Register grid update**: `RegisterRepository.updateGrid()` with sync queue enqueue

### Schema
- New table: `company_settings` (id, company_id, require_pin_on_switch, auto_lock_timeout_minutes + sync columns)

### New Files
- `lib/core/database/tables/company_settings.dart` — Drift table definition
- `lib/core/data/models/company_settings_model.dart` — Freezed model
- `lib/core/data/repositories/company_settings_repository.dart` — Repository with `watchByCompany`, `getByCompany`, `getOrCreate`
- `lib/features/settings/widgets/security_tab.dart` — Security settings tab
- `lib/features/settings/widgets/sales_tab.dart` — Sales settings tab
- `lib/core/widgets/inactivity_detector.dart` — Inactivity timer + lock trigger
- `lib/core/widgets/lock_overlay.dart` — Full-screen lock overlay with user selection + PIN

### Modified
- `lib/core/database/app_database.dart` — registered `CompanySettings` table (24 → 25 tables)
- `lib/core/data/mappers/entity_mappers.dart` — `companySettingsFromEntity`, `companySettingsToCompanion`
- `lib/core/data/mappers/supabase_mappers.dart` — `companySettingsToSupabaseJson`
- `lib/core/data/mappers/supabase_pull_mappers.dart` — `company_settings` pull case
- `lib/core/data/providers/repository_providers.dart` — `companySettingsRepositoryProvider`, `registerRepositoryProvider` now with syncQueueRepo
- `lib/core/data/providers/sync_providers.dart` — `companySettingsRepositoryProvider` added to `companyRepos`
- `lib/core/sync/sync_service.dart` — `company_settings` in pull tables + `_getDriftTable`
- `lib/core/data/repositories/register_repository.dart` — `updateGrid()` with sync support
- `lib/features/settings/screens/screen_settings.dart` — wired `SecurityTab` and `SalesTab`
- `lib/features/bills/screens/screen_bills.dart` — PIN-skip logic in `_selectUser`
- `lib/app.dart` — wrapped with `InactivityDetector`

### Localization
- Added 8 Czech keys: `settingsRequirePinOnSwitch`, `settingsAutoLockTimeout`, `settingsAutoLockDisabled`, `settingsAutoLockMinutes`, `settingsGridRows`, `settingsGridCols`, `lockScreenTitle`, `lockScreenSubtitle`

### Documentation
- `PROJECT.md` — added `company_settings` table, updated table counts (24→25), updated settings screen docs, updated sync table counts (22→23)

---

## 2026-02-10 (Open Bills Warning + Z-Report Tracking)

### Features
- **Open bills warning**: When closing a session (Uzávěrka), if there are open (unpaid) bills, a warning dialog shows count + total value; user can cancel or continue
- **Open bills snapshot**: 4 new columns on `register_sessions` — `open_bills_at_open_count`, `open_bills_at_open_amount`, `open_bills_at_close_count`, `open_bills_at_close_amount` — stored at session open and close
- **Closing dialog**: Shows "Otevřené účty" row with count and amount when open bills exist
- **Z-Report**: Displays open bills at session open and close

### Schema
- `register_sessions` table: added 4 nullable integer columns for open bills tracking

### Modified
- `lib/core/database/tables/register_sessions.dart` — 4 new columns
- `lib/core/data/models/register_session_model.dart` — 4 new fields
- `lib/core/data/mappers/entity_mappers.dart` — register session entity mapper
- `lib/core/data/mappers/supabase_mappers.dart` — push mapper
- `lib/core/data/mappers/supabase_pull_mappers.dart` — pull mapper
- `lib/core/data/repositories/register_session_repository.dart` — new params in `openSession()` and `closeSession()`
- `lib/features/bills/screens/screen_bills.dart` — warning dialog + open bills data for open/close
- `lib/features/bills/widgets/dialog_closing_session.dart` — 2 fields + display row
- `lib/features/bills/widgets/dialog_z_report.dart` — open bills rows
- `lib/features/bills/models/z_report_data.dart` — 4 new fields
- `lib/features/bills/services/z_report_service.dart` — reads from session model

### Localization
- Added 6 Czech keys: `closingOpenBillsWarningTitle`, `closingOpenBillsWarningMessage`, `closingOpenBillsContinue`, `closingOpenBills`, `zReportOpenBillsAtOpen`, `zReportOpenBillsAtClose`

### Documentation
- `PROJECT.md` — updated `register_sessions` column docs

---

## 2026-02-10 (PROJECT.md audit)

### Documentation
- **PROJECT.md**: Comprehensive audit — fix 12+ discrepancies between docs and code reality
  - Table counts: 24 (22 domain + 2 sync), not 23 (21 + 2)
  - Moved `shifts` from "Plánované" to active domain tables
  - Added `discount_type` column to bills and order_items column docs
  - Added `user_id` column to payments column docs
  - Added `shifts` column schema docs (Pokladna section)
  - Fixed enum count: 12 (not 11), repo count: 21 (not 20), model count: 22 (not 21)
  - Fixed ScreenBills filter chips: 3 chips (not 4) — refunded under "Zaplacené"
  - Updated sync table counts: 22 domain tables in pullAll
  - Added ShiftRepository to Repository API docs
  - Updated bills/widgets structure (added DialogDiscount, DialogChangeTotalToPay, DialogZReport, DialogZReportList, DialogShiftsList)
  - Added bills/providers, bills/services, bills/models to project structure
  - Added 2 Known Issues: shifts Supabase table missing, payments.user_id missing in Supabase

---

## 2026-02-10 (Shifts List Dialog)

### Features
- **Shifts list dialog**: Přehled všech směn přístupný přes DALŠÍ → Směny (vyžaduje `settings.manage`)
  - Datumový filtr (výchozí: posledních 7 dní)
  - Sloupce: Datum, Obsluha, Přihlášení, Odhlášení, Trvání
  - Probíhající směny zvýrazněny primární barvou s textem „probíhá"

### New files
- `lib/features/bills/widgets/dialog_shifts_list.dart` — Dialog widget + `ShiftDisplayRow` data class

### Modified
- `ShiftRepository` — added `getByCompany(companyId)` query
- `screen_bills.dart` — "Směny" item in "Další" dropdown, `_showShifts()` method, `onShifts` callback
- `PROJECT.md` — updated "Další" menu description, marked shifts/Z-Report as implemented

### Localization
- Added 9 Czech keys for shifts list (`moreShifts`, `shiftsListTitle`, `shiftsListEmpty`, column headers, `shiftsOngoing`)

---

## 2026-02-10 (Task 3.13 — Z-Report)

### Schema
- **payments.userId**: New nullable `TextColumn` — tracks which user made each payment (for tips-per-user in Z-Report)
- **shifts table**: New table with `registerSessionId`, `userId`, `loginAt`, `logoutAt` — tracks user login/logout durations per register session

### Features
- **Z-Report**: Daily closing summary accessible via "Další" dropdown → "Reporty" (requires `settings.manage` permission)
  - Session list dialog with date range filter, showing all closed sessions
  - Detail dialog showing: revenue by payment type, DPH breakdown, tips (total + per user), discounts, bill counts, cash reconciliation, shift durations
- **Shift tracking**: Automatic shift creation on login / user switch; shift closure on logout / session close

### New files
- `lib/core/database/tables/shifts.dart` — Drift table definition
- `lib/core/data/models/shift_model.dart` — Freezed model
- `lib/core/data/repositories/shift_repository.dart` — CRUD + sync enqueue
- `lib/features/bills/models/z_report_data.dart` — Data classes for Z-Report
- `lib/features/bills/services/z_report_service.dart` — Aggregation service
- `lib/features/bills/providers/z_report_providers.dart` — Riverpod provider
- `lib/features/bills/widgets/dialog_z_report_list.dart` — Session list dialog
- `lib/features/bills/widgets/dialog_z_report.dart` — Z-Report detail dialog

### Modified
- `BillRepository.recordPayment()` — accepts optional `userId` parameter
- `RegisterSessionRepository` — added `getClosedSessions()`, `getById()`
- `OrderRepository` — added `getOrderItemsByBill()`
- `screen_login.dart` — creates shift on login
- `screen_bills.dart` — shift hooks (login/logout/switch/session open/close), Z-Report menu integration
- `dialog_payment.dart` — passes `activeUserProvider.id` as `userId` to `recordPayment()`
- Sync: `shifts` added to `_pullTables`, `_getDriftTable()`, `_initialPush()`

### Localization
- Added 30+ Z-Report Czech localization keys to `app_cs.arb`

---

## 2026-02-10 (Post-M3.2 Audit — 2nd pass)

### Transactions
- **BillRepository.createBill()**: Bill number generation (`_generateBillNumber`) now runs inside `db.transaction()` together with INSERT — eliminates race condition for duplicate bill numbers
- **BillRepository.generateBillNumber()**: Made private (`_generateBillNumber`), callers removed from ScreenBills and ScreenSell

### Sync
- **CompanyRepository**: Added `SyncQueueRepository` injection and `_enqueueCompany()` helper; `update()` and `updateAuthUserId()` now enqueue changes for sync (was local-only)
- **OutboxProcessor**: Added periodic cleanup of completed entries (hourly interval inside `processQueue()`)

### Robustness
- **SyncService.pullAll()**: Added `_isPulling` guard to prevent concurrent pull cycles from timer overlap

---

## 2026-02-10 (Post-M3.2 Audit)

### Supabase
- **cash_movements triggers**: Renamed `enforce_lww` → `trg_cash_movements_lww` (UPDATE only, was INSERT+UPDATE), added missing `trg_cash_movements_timestamps` (INSERT+UPDATE)
- **cash_movements RLS**: Added `WITH CHECK` to `update_cash_movements` policy (was USING-only)

### Sync
- **SyncQueue.markProcessing()**: Now sets `processedAt` as processing-started timestamp
- **SyncQueue.resetStuck()**: Uses `processedAt` instead of `createdAt` — measures actual processing duration
- **SectionRepository.clearDefault()**: Now enqueues affected records for sync (was local-only update)
- **TaxRateRepository.clearDefault()**: Now enqueues affected records for sync (was local-only update)

### Transactions
- **LayoutItemRepository.setCell()**: Wrapped soft-delete + insert in `db.transaction()` (prevents orphaned deletes on insert failure)
- **RegisterSessionRepository.incrementOrderCounter()**: Wrapped read + write in `db.transaction()` (prevents counter collisions)

### Konzistence
- **cash_movements.type**: Changed from `intEnum` → `textEnum` (matches all other 13 enum columns in project)

### Documentation
- **PROJECT.md**: Updated retry strategie (processedAt-based resetStuck), added custom method enqueue pattern

---

## 2026-02-10 (M3.2 — Pokročilý prodej)

### Pre-M3.2 Fixy

#### Supabase migrace
- `sections`: Added `is_default` boolean column
- `cash_movements`: Added indexes on `company_id` and `updated_at`

#### OutboxProcessor fix
- `_isPermanentError`: Fixed prefix matching (`startsWith` instead of `==` for PGRST and 42 codes)
- Added LWW_CONFLICT handling: `P0001` with `LWW_CONFLICT` message → mark completed (server wins)

#### BillRepository transaction safety
- `recordPayment`: Wrapped INSERT payment + UPDATE bill in `_db.transaction()`
- `cancelBill`: Wrapped cascade cancel/void orders + UPDATE bill in `_db.transaction()`
- Enqueue sync always outside transaction

### Task 3.9 — Poznámky k objednávce

- **OrderRepository**: `OrderItemInput` +`notes`, `createOrderWithItems` +`orderNotes` parameter, new `updateOrderNotes`, `updateItemNotes` methods
- **ScreenSell**: Cart item tap → notes dialog, toolbar chip "Poznámka" activated for order-level notes, notes displayed under cart items
- **DialogBillDetail**: Order notes displayed with icon, item notes under item rows, editable via tap (when bill is opened)

### Task 3.7 + 3.8 — Slevy (položka + účet)

#### Schema
- New enum `DiscountType` (`absolute`, `percent`) — Dart + Supabase
- Drift tables: `order_items` + `bills` +`discountType` (nullable textEnum)
- Models: `OrderItemModel` + `BillModel` +`discountType`
- Entity/push/pull mappers updated for `discount_type`

#### Logic
- `BillRepository.updateTotals`: Item discount calc (percent=basis points/10000, absolute=haléře) + bill-level discount
- `BillRepository.updateDiscount(billId, discountType, discountAmount)`: Sets bill discount + recalc totals
- `OrderRepository.updateItemDiscount(itemId, discountType, discount)`: Sets item discount + enqueue

#### UI
- New `DialogDiscount` widget: DiscountType toggle (Kč/%), numpad, preview of effective discount, Cancel/Delete/OK
- `DialogBillDetail`: Right panel "SLEVA" button for bill discount (opened bills), item tap → discount button in notes dialog

### Task 3.10 — Split payment

- **DialogPayment**: Rewritten for split payment — stays open after partial payment, shows list of already-made payments, dynamic remaining amount
- `_customAmount` state: null=full remaining, set via "Upravit částku" button
- Overpayment → `tipAmount` parameter in `recordPayment` → `payments.tip_included_amount`
- Cancel button returns `true` if any payments were made (partial payment scenario)
- New `DialogChangeTotalToPay` widget: Quick buttons (rounded 10/50/100/500), numpad, original/edited amount display

### Task 3.11b — Refund

#### Schema
- `BillStatus.refunded` added to Dart enum + Supabase `bill_status` type

#### Logic
- `BillRepository.refundBill`: Creates negative payment per original payment, sets status=refunded, auto CashMovement (withdrawal) for cash payments. All in transaction.
- `BillRepository.refundItem`: Creates negative payment for item value, voids item, updates bill paidAmount, auto CashMovement for cash. If fully refunded → status=refunded.

#### UI
- `DialogBillDetail`: REFUND button (orange) in footer for paid bills, per-item refund via tap on item
- `ScreenBills`: Added `refunded` filter chip (orange), row color for refunded bills

### Documentation
- **PROJECT.md**: Updated M3.2 tasks (✅), BillStatus enum (+refunded), DiscountType enum, discount calc, BillRepository methods, DialogPayment split payment, DialogBillDetail buttons, ScreenBills filters

---

## 2026-02-10 (late night)

### SectionModel.isDefault — výchozí sekce

#### Schema
- **sections**: Added `is_default` boolean column (default false) — max 1 per company

#### Models & Mappers
- **SectionModel**: +`isDefault` field (default false)
- **Entity mappers**: Added `isDefault` to `sectionFromEntity` and `sectionToCompanion`
- **Push mappers**: Added `'is_default': m.isDefault` to `sectionToSupabaseJson`
- **Pull mappers**: Added `isDefault: Value(json['is_default'] as bool? ?? false)` to sections case

#### Repository
- **SectionRepository**: Added `clearDefault(companyId, {exceptId})` — resets all other sections' isDefault to false. Added `isDefault: Value(m.isDefault)` to `toUpdateCompanion`.

#### UI
- **SectionsTab** (ScreenDev): Added "Výchozí" column to DataTable (icon), added SwitchListTile in edit dialog, clearDefault on save
- **DialogNewBill**: Pre-selects default section (`isDefault=true`) on dialog open via `addPostFrameCallback`

### Documentation
- **PROJECT.md**: Comprehensive audit and update of entire document (~30 corrections):
  - Fixed sync pull count (22→21 tables — matches actual `_pullTables`)
  - Fixed FilterChip layout description (Wrap→Row with Expanded)
  - Updated ScreenBills right panel (all 4 button rows, info panel details, session toggle)
  - Rewrote DialogBillDetail layout (750×520, 3-row structure, status indicator, conditional footer)
  - Added DialogPayment section (3-column click-to-pay, payment method buttons)
  - Fixed DialogBillDetail button table (added STORNO, corrected ZAVŘÍT description)
  - Fixed ConnectCompanyScreen pull order (removed duplicated tables)
  - Updated sections columns (added is_default)

## 2026-02-10 (night)

### Task3.11 + Task3.12 — Cash Management (Milník 3.3)

#### Schema

- **register_sessions**: Added 4 nullable int columns (`opening_cash`, `closing_cash`, `expected_cash`, `difference`) — haléře
- **cash_movements**: New table — id, companyId, registerSessionId, userId, type (deposit/withdrawal/expense), amount, reason + SyncColumnsMixin
- **CashMovementType** enum: `deposit`, `withdrawal`, `expense`
- **Supabase migration**: `cash_movement_type` enum, `cash_movements` table with RLS + LWW trigger, `register_sessions` ALTER +4 columns

#### Models & Mappers

- **CashMovementModel** (freezed): New model for cash movements
- **RegisterSessionModel**: +4 nullable int fields (openingCash, closingCash, expectedCash, difference)
- **Entity mappers**: `cashMovementFromEntity`, updated `registerSessionFromEntity`
- **Push mappers**: `cashMovementToSupabaseJson`, updated `registerSessionToSupabaseJson`
- **Pull mappers**: `cash_movements` case, updated `register_sessions` case

#### Repository

- **CashMovementRepository** (new): `create()`, `getBySession()`, `watchBySession()` with outbox sync
- **RegisterSessionRepository**: `openSession()` +openingCash param, `closeSession()` +closingCash/expectedCash/difference params, new `getLastClosingCash()`
- **BillRepository**: Added `getByCompany()` for closing dialog data
- **PaymentMethodRepository**: Added `getAll()` for closing dialog data
- **cashMovementRepositoryProvider**: New provider with syncQueueRepo wired

#### Sync

- **SyncService**: Added `cash_movements` to `_pullTables` (21 tables) and `_getDriftTable()`
- **SyncLifecycleManager**: Added `cash_movements` to `_initialPush()` after register_sessions

#### UI Integration

- **DialogOpeningCash**: Added `initialAmount` parameter for pre-fill from previous session
- **Opening flow**: Shows DialogOpeningCash, pre-fills from last closing cash, creates correction cash_movement if amounts differ
- **Closing flow**: Shows DialogClosingSession with full summary (payment breakdown, cash reconciliation, expected vs actual), replaces simple confirm dialog
- **Cash movement button**: "POKLADNÍ DENÍK" enabled during active session, opens DialogCashMovement
- **Info panel**: Shows opening cash amount during active session

#### Documentation

- **PROJECT.md**: Task3.11 ✅, Task3.12 ✅, sync table count 20→21, cash_movements Plánovaná→Aktivní

## 2026-02-10 (evening)

### Task3.4 — ConnectCompanyScreen + sync pro 20 tabulek

#### Sync — 8 new tables

- **Push mappers** (supabase_mappers.dart): Added `currencyToSupabaseJson`, `roleToSupabaseJson`, `permissionToSupabaseJson`, `rolePermissionToSupabaseJson`, `registerToSupabaseJson`, `registerSessionToSupabaseJson`, `layoutItemToSupabaseJson`, `userPermissionToSupabaseJson`. Added `_baseGlobalSyncFields` helper for global tables (no company_id).
- **Pull mappers** (supabase_pull_mappers.dart): Added 8 case branches (`currencies`, `roles`, `permissions`, `role_permissions`, `registers`, `register_sessions`, `layout_items`, `user_permissions`)
- **SyncService**: Extended `_pullTables` from 12 → 20 tables in FK-respecting order. Added `_globalTables` set. `pullTable()` now distinguishes 3 types: companies (id filter), global (no filter), company-scoped (company_id filter). Added 8 `_getDriftTable` cases.
- **SyncLifecycleManager**: Added `AppDatabase` dependency. `_initialPush()` now enqueues global tables (currencies, roles, permissions, role_permissions) + registers + user_permissions before company repos.

#### Outbox — 3 repositories

- **RegisterSessionRepository**: Added `syncQueueRepo`, enqueue in `openSession()` (insert), `closeSession()` (update), `incrementOrderCounter()` (update)
- **LayoutItemRepository**: Added `syncQueueRepo`, enqueue in `setCell()` (delete old + insert new), `clearCell()` (delete)
- **PermissionRepository**: Added `syncQueueRepo`, enqueue in `applyRoleToUser()` (delete old + insert new user_permissions)
- **Provider wiring**: `registerSessionRepositoryProvider`, `layoutItemRepositoryProvider`, `permissionRepositoryProvider` now receive `syncQueueRepo`

#### ConnectCompanyScreen

- **New screen**: `screen_connect_company.dart` — multi-step flow (credentials → searching → company preview → syncing → done)
- **InitialSync**: Uses `syncService.pullAll(companyId)` to download all 20 tables. Inserts completed marker in sync_queue to prevent initial push.
- **Routing**: Added `/connect-company` route, updated redirect logic to allow access during onboarding
- **ScreenOnboarding**: Enabled "Připojit se k firmě" button (was disabled with `onPressed: null`)

#### Localization

- Added 10 Czech l10n keys: `connectCompanyTitle`, `connectCompanySubtitle`, `connectCompanySearching`, `connectCompanyFound`, `connectCompanyNotFound`, `connectCompanyConnect`, `connectCompanySyncing`, `connectCompanySyncComplete`, `connectCompanySyncFailed`

#### Documentation

- **PROJECT.md**: Task3.4 ⬜ → ✅, updated sync status (20 tables), added ConnectCompanyScreen flow, added Known Issues section
- Removed `onboardingJoinCompanyDisabled` text from onboarding screen

## 2026-02-10

### Etapa 3.1 — Sync infrastructure

- **BaseCompanyScopedRepository**: Extracted from 7 company-scoped repos — provides CRUD + automatic outbox enqueue in same transaction
- **Outbox pattern**: SyncQueue table, SyncQueueRepository, OutboxProcessor (5s interval, FIFO, retry with backoff)
- **Pull sync**: SyncService with 5-min auto-pull for 12 tables (companies, sections, categories, items, tables, payment_methods, tax_rates, users, bills, orders, order_items, payments)
- **LWW conflict resolution**: Server-side `enforce_lww` trigger + pull-side merge with `client_updated_at` comparison
- **SyncLifecycleManager**: Orchestrates sync start/stop, initial push, crash recovery
- **ScreenCloudAuth**: Admin email/password for Supabase session
- **SupabaseAuthService**: SignIn/SignUp, session management
- **Supabase mappers**: Push (supabase_mappers.dart) and pull (supabase_pull_mappers.dart) for all entities
- **Companies**: Added `auth_user_id` column for Supabase Auth binding

### Fixes

- **Supabase mappers**: Changed all mapper function parameters from `dynamic` to typed models (SectionModel, CategoryModel, etc.) — prevents runtime dispatch errors on enum `.name` access
- **Numpad double Expanded**: Removed nested `Expanded` from `_numpadButton()` in screen_login.dart and screen_bills.dart — bottom row now wraps at call-site

### Sync — sales entities

- **Push mappers** (supabase_mappers.dart): Added `billToSupabaseJson`, `orderToSupabaseJson`, `orderItemToSupabaseJson`, `paymentToSupabaseJson`
- **Pull mappers** (supabase_pull_mappers.dart): Added 4 case branches (`bills`, `orders`, `order_items`, `payments`) with all fields, enum parsing, DateTime handling
- **BillRepository**: Injected `SyncQueueRepository`, added `_enqueueBill`, `_enqueueOrder`, `_enqueueOrderItem`, `_enqueuePayment` helpers. Enqueue in: createBill, updateTotals, recordPayment (payment insert + bill update), cancelBill cascade (orders + items + bill)
- **OrderRepository**: Injected `SyncQueueRepository`, added `_enqueueOrder`, `_enqueueOrderItem` helpers. Enqueue in: createOrderWithItems (order + items), updateStatus (order + items — covers all delegating methods)
- **SyncService**: Added `bills`, `orders`, `order_items`, `payments` to `_pullTables` (after items, FK order) and `_getDriftTable()`
- **Provider wiring**: `billRepositoryProvider` and `orderRepositoryProvider` now receive `syncQueueRepo`
- **Pattern**: Manual enqueue (not BaseCompanyScopedRepository) — sales repos have complex business methods that don't fit CRUD pattern

### Documentation

- Updated PROJECT.md: sync section status, Milník 3.1 progress (Task3.2b ✅), two outbox patterns (auto vs manual enqueue), Data Flow updated, BillRepository/OrderRepository API updated with sync details, companies.auth_user_id, sync file structure, typed mapper convention, BaseCompanyScopedRepository status

## 2026-02-09

### Features — Etapa 2: Základní prodej

- **M2.1 Bill creation**: DialogNewBill (three-step wizard: type → table → guests), DialogBillDetail (bill header, order list, footer actions), BillRepository (createBill, updateTotals, cancelBill, generateBillNumber, watchByCompany with section filtering)
- **M2.2 Orders & Items**: ScreenSell (left cart panel + right product grid), OrderRepository (createOrderWithItems in transaction, status transitions), OrderItemInput class, ATT tax calculation
- **M2.3 Payment**: DialogPayment (payment method selection, amount entry), recordPayment (creates payment record, updates bill paidAmount/status)
- **M2.4 Grid editor**: LayoutItemRepository (watchByRegister, setCell, clearCell), edit mode in ScreenSell with GridEditDialog for assigning item/category/clear to grid cells
- **M2.5 Register session**: RegisterSessionRepository (openSession, closeSession, watchActiveSession, incrementOrderCounter), RegisterRepository, dynamic session toggle button on ScreenBills
- **ScreenBills integration**: Bills table with live data from DB, status filter (opened/paid/cancelled), section filter, bill row click opens DialogBillDetail, "Vytvořit účet" and "Rychlý účet" buttons wired to bill creation, register session gate (bill creation disabled without active session)

### Repositories

- Added: BillRepository, OrderRepository, RegisterRepository, RegisterSessionRepository, LayoutItemRepository
- Added `getById()` to TaxRateRepository
- Fixed missing `drift` import in RegisterRepository

### Providers

- Added: billRepositoryProvider, orderRepositoryProvider, registerRepositoryProvider, registerSessionRepositoryProvider, layoutItemRepositoryProvider
- Added: activeRegisterProvider (FutureProvider), activeRegisterSessionProvider (StreamProvider)

### Localization

- Added ~70 Czech strings for all Stage 2 UI: DialogNewBill, DialogBillDetail, ScreenSell, payment, prep statuses, grid editor, register session

### Routing

- Added `/sell/:billId` route to app_router.dart

## 2026-02-09 (evening)

### Fixes — Phase 2 review

- **Host column**: Removed billNumber display, column is empty in E1-2 (CRM feature)
- **Empty state**: Removed placeholder text from bills table
- **Default filters**: Changed default to "Otevřené" only (was all three)
- **Last order column**: Shows relative time (< 1min, Xmin, Xh Ym) via reactive stream
- **Logout**: Fixed auto-promote — `logoutActive()` now sets `_activeUser = null`, router redirects to `/login`
- **Create bill flow**: DialogNewBill → creates bill → opens DialogBillDetail (not ScreenSell)

### Features

- **Quick sale workflow**: New `/sell` route (no billId) for quick sale. Creates bill+order at payment time, cancels bill if payment cancelled. `isTakeaway` repurposed from "takeaway" to "quick sale" — displays as "Rychlý účet"
- **DialogNewBill**: Removed takeaway option, only "Stůl" and "Bez stolu" remain
- **ShaderMask fade**: Grid item buttons use ShaderMask with LinearGradient for smooth text fade at edges

### Repositories

- Added: PaymentRepository (extracted from BillRepository) — `watchByBill`, `getByBill`
- Added: `watchLastOrderTimesByCompany` to OrderRepository
- Added: paymentRepositoryProvider

### Documentation

- Updated PROJECT.md: routing, quick sale workflow, DialogNewBill (no takeaway), logout behavior, ScreenBills UI details (FilterChip colors, default filters, host column, relative time), ScreenSell dual mode, ShaderMask fade, Order.status aggregation note for E3, feature folder structure corrected

## 2026-02-09 (E3 prep review)

### Architecture decisions

- Sync logic will live directly in repositories (no DataSource abstraction layer)
- `BaseCompanyScopedRepository<T>` to be created before E3 (standardize CRUD + outbox)
- `partiallyPaid` status removed — payments must always cover full amount
- Split payment (multiple methods) replaces partial payment (Task3.10)
- `refunded` status (E3.2) will show under "Zaplacené" filter in ScreenBills

### Code

- **DialogNewBill**: Simplified from 3-step wizard to single-step dialog (guests + optional table selection). Removed `_BillType` enum, removed dead takeaway code. Selected table now toggleable (click to select/deselect).
- Removed unused l10n keys: `newBillTakeaway`, `newBillTable`, `newBillNoTable`

### Documentation

- PROJECT.md: removed DataSource pattern, updated folder structure (enums, mappers), updated Core Data Layer conventions, updated BillStatus (removed partiallyPaid, added refunded E3.2), updated BillRepository/OrderRepository API to match reality, updated DialogNewBill workflow (single step), updated Task3.10 (split payment), added Task3.11b (refund)


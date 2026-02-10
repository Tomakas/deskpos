# Changelog

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


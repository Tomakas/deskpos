# Changelog

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


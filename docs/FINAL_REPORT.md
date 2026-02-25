# Consistency Audit Report

## Summary

| Metric | Value |
|--------|-------|
| Files checked | ~238 Dart source files (excl. generated) |
| Agents | 24 agents across 6 phases |
| Supabase tables | 37 public tables |
| Drift tables | 37 registered tables |
| dart analyze | 0 issues |

### Findings by Severity

| Severity | Count |
|----------|-------|
| HIGH | 12 |
| MEDIUM | 40 |
| LOW | 13 |

---

## Findings by Category

### 1. Architecture (Repositories, Patterns)

#### HIGH

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| A-1 | BillRepository: `applyLoyaltyDiscount`, `updateDiscount`, `applyVoucher`, `removeVoucher` perform DB writes outside transactions -- not atomic with `updateTotals` | `bill_repository.dart` | C2 |
| A-2 | RegisterRepository: `updateGrid` returns raw `RegisterModel?` (no `Result<T>`, no try/catch); `setBoundDevice`, `setActiveBill`, `clearBoundDevice` return `Future<void>` with zero error handling | `register_repository.dart` | C2 |
| A-3 | 10 entities missing `*ToCompanion()` in `entity_mappers.dart`: Bill, Order, OrderItem, Payment, Register, RegisterSession, CashMovement, DeviceRegistration, Shift, LayoutItem. Pattern inconsistency -- these entities write via inline companions in repos. | `entity_mappers.dart` | C3 |

#### MEDIUM

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| A-4 | TaxRateRepository overrides `getById` adding `deletedAt.isNull()` filter -- diverges from base class contract | `tax_rate_repository.dart:106` | C1 |
| A-5 | Missing `deletedAt.isNull()` filter on `getById`/`watchById` in BillRepository, CompanyRepository, RegisterRepository, RegisterSessionRepository | Multiple repos | C2 |
| A-6 | Missing `Result<T>` return on public write methods: `OrderRepository.reassignOrdersToBill/splitItemsToNewOrder`, `ShiftRepository.closeAllForSession`, `StockMovementRepository.createMovement` | Multiple repos | C2 |
| A-7 | `LayoutItemRepository.clearCell` -- soft-delete + enqueue as two separate operations outside transaction | `layout_item_repository.dart` | C2 |
| A-8 | Company push mapper does not use `_baseGlobalSyncFields` helper (functionally identical output) | `supabase_mappers.dart` | C4 |

#### LOW

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| A-9 | `entityName` values use inconsistent naming (snake_case vs space-separated vs single word) -- affects log messages only | 17 BaseCompanyScopedRepository inheritors | C1 |

---

### 2. Data Layer (Models, Drift, Mappers)

#### MEDIUM

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| ~~D-1~~ | ~~gridWidth/gridHeight default mismatch~~ — **FIXED.** Drift defaults aligned to `Constant(1)` matching Model `@Default(1)`. | — | — |
| D-2 | Missing FK indexes on 18 Drift tables. Priority: `OrderItems(orderId)`, `Orders(billId)`, `Payments(billId)`, `Bills(registerSessionId)` | All table definition files | C6 |

#### LOW

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| D-3 | `real()` used for physical quantities (ProductRecipes, StockLevels, StockMovements, OrderItems) -- intentional but should be documented as distinct from integer-for-money rule | 4 table files | C6 |

---

### 3. Sync Engine

#### LOW

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| S-1 | `companyRepos` push order has minor FK ordering concerns: `items` enqueued before `suppliers`/`manufacturers`; `vouchers` before `customers`/`bills`. Mitigated by Edge Function using `service_role`. | `sync_lifecycle_manager.dart` | C7 |
| S-2 | `resetStuck()` only called at startup, not periodically. If an entry gets stuck during runtime, it stays stuck until restart. Mitigated by Dart async model. | `sync_lifecycle_manager.dart` | C7 |

---

### 4. Supabase Schema (RLS, Triggers, Indexes, Drift↔Supabase)

#### HIGH

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| SB-1 | `audit_log` has RLS enabled but ZERO policies -- table is effectively inaccessible via client. Needs confirmation this is intentional (service_role-only). | Supabase `audit_log` | C24 |
| SB-2 | `sync_queue` UPDATE policy missing `WITH CHECK` -- a user could theoretically mutate `company_id` to impersonate another company | Supabase `sync_queue` | C24 |
| SB-3 | Auth leaked password protection is disabled -- users can register with known-compromised passwords | Supabase Auth config | C24 |

#### MEDIUM

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| SB-4 | No INSERT/UPDATE RLS policies on data tables (by design -- all writes via ingest Edge Function with service_role). Should be documented. | All data tables | C24 |
| SB-5 | `audit_log` has no `set_server_timestamps` trigger (breaks universal pattern) | Supabase `audit_log` | C24 |
| SB-6 | `cash_movements` SELECT policy uses inconsistent naming (`select_cash_movements` vs expected `cash_movements_select_own`) | Supabase `cash_movements` | C24 |

#### LOW

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| ~~SB-7~~ | ~~`map_elements.shape` stored as plain `text`~~ — **FIXED.** Created `table_shape` enum (used by `map_elements.shape` + `tables.shape`) and `display_device_type` enum (used by `display_devices.type`). All 3 columns converted from `text` to proper enum types. | — | — |
| SB-8 | `sync_queue` has 3 Drift↔Supabase mismatches: `operation`/`status` use `text()` in Drift vs enum in Supabase; `payload` nullability differs | `sync_queue.dart` vs Supabase | C23 |
| SB-9 | 3 clearly redundant indexes safe to drop: `idx_map_elements_company_id`, `idx_cash_movements_updated_at`, `idx_companies_updated_at` | Supabase indexes | C24 |
| SB-10 | 14 unused indexes flagged by performance advisor (5 to keep, 5 to review, 3 to drop, 1 borderline) | Supabase indexes | C24 |

---

### 5. Enums

#### MEDIUM

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| E-1 | No fallback/orElse on deserialization for ANY enum. Unknown values from Supabase crash the pull with `ArgumentError`. Brittle against schema evolution. | `supabase_pull_mappers.dart` | C8 |

#### LOW

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| E-2 | `payment_type` order mismatch: Dart `[cash,card,bank,credit,other]` vs Supabase `[cash,card,bank,other,credit]`. Safe for `.name` matching but `.index` would differ. | `payment_type.dart` vs Supabase | C8 |
| E-3 | `sync_operation`/`sync_status` have no Dart enum -- stored as raw text strings, typos not caught at compile time | `sync_queue.dart` | C8 |
| ~~E-4~~ | ~~`table_shape` is Dart-only enum with no Supabase type constraint~~ — **FIXED.** `table_shape` and `display_device_type` enum types created in Supabase. | — | — |

---

### 6. Auth & Routing

#### MEDIUM

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| AU-1 | `AsyncError` not handled in router redirect -- if `appInitProvider` fails (DB corruption), user hits dead-end at `/login` with no recovery | `app_router.dart:27-55` | C10 |
| AU-2 | Brute-force bypass for 4-5 digit PINs -- "progressive check" calls `PinHelper.verifyPin()` silently without incrementing lockout counter. 10,000 combinations explorable without lockout. | `screen_login.dart:178-203`, `lock_overlay.dart:292-315` | C10 |

#### LOW

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| AU-3 | `pinEnabled` flag on `UserModel` never checked during login | `screen_login.dart` | C10 |

---

### 7. UI Patterns

#### HIGH

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| ~~UI-1~~ | ~~Hardcoded currency strings~~ — **FIXED.** Fallback currency is now neutral (empty code/symbol), `_currencyLocale` covers 5 currencies (CZK/EUR/USD/PLN/HUF), onboarding offers all 5 options. Seed data `'Kč'` is correct (CZK seed definition). | — | — |
| UI-2 | `cloud_tab.dart` directly accesses `appDatabaseProvider` to close/delete DB + performs filesystem operations + sync lifecycle management. Bypasses repository pattern entirely. | `cloud_tab.dart` | C12 |
| UI-3 | `screen_connect_company.dart` directly manipulates sync queue by inserting `_initial_sync_marker`. Sync engine internals exposed in UI. | `screen_connect_company.dart` | C12 |
| UI-4 | **FutureBuilder with inline future in build()** -- 4 instances in `dialog_bill_detail.dart` and `dialog_payment.dart`. Recreates future on every rebuild. | `dialog_bill_detail.dart:154,265,365`, `dialog_payment.dart` | C11,C14 |

#### MEDIUM

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| UI-5 | Hardcoded `Colors.*` reduced from 125 to ~28 via `AppColorsExtension` ThemeExtension. Remaining ~28 are legitimate: floor map canvas colors, `Colors.transparent`, `Colors.white`, `colorSchemeSeed`, KDS `_urgencyColor`, one-off decorative icons. | `floor_map_view.dart`, `floor_map_editor_tab.dart`, `registers_tab.dart`, `screen_kds.dart` | C11,C12,C13,C20 |
| UI-6 | Missing `mounted` checks after `await` in 14+ methods across bills widgets, catalog CRUD tabs, settings tabs | `dialog_bill_detail.dart`, all `*_tab.dart` CRUD files | C11,C12,C13 |
| UI-7 | Missing processing guards (`_isProcessing` flag) on ~15 async action methods allowing duplicate operations on rapid taps | `dialog_bill_detail.dart`, `dialog_loyalty_redeem.dart`, catalog tabs, settings tabs | C11,C12,C13 |
| UI-8 | Hardcoded locale `'cs'` in 3 `DateFormat` instances in printing code | `z_report_pdf_builder.dart:51-52`, `receipt_pdf_builder.dart:44` | C11 |
| UI-9 | Business logic in UI: tax calculation in screen_sell, session closing aggregation in screen_bills, voucher creation multi-step transaction in dialog_voucher_create, storno order number generation | Multiple screen/dialog files | C11,C12,C13 |
| UI-10 | Duplicated helper functions (`_statusLabel`, `_nextStatus`, `_nextStatusLabel`) identically copy-pasted between `screen_kds.dart` and `screen_orders.dart`. `_statusColor` was extracted to `PrepStatusColor` enum extension. | `screen_kds.dart`, `screen_orders.dart` | C13 |
| UI-11 | 5-level nested StreamBuilder pyramids in `screen_bills.dart` (`_BillsTable`) and `catalog_products_tab.dart` | 2 files | C13,C14 |

---

### 8. Riverpod Patterns

#### MEDIUM

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| R-1 | Missing `ref.onDispose` on `outboxProcessorProvider`, `syncServiceProvider`, `realtimeServiceProvider` -- hold timers/channels. Mitigated by `syncLifecycleManagerProvider` cascading `stop()`. | `sync_providers.dart` | C9 |
| R-2 | Dual-state pattern: `SessionManager` + `activeUserProvider`/`loggedInUsersProvider` StateProviders imperatively overwritten from 4+ locations. Synchronization cannot be compiler-enforced. | `auth_providers.dart`, `session_manager.dart` | C9 |
| R-3 | `ref.read(currentCompanyProvider)` in build-phase helpers in `lock_overlay.dart` -- won't rebuild if company changes | `lock_overlay.dart` | C14 |
| R-4 | Two `.when(error:)` handlers silently swallow errors with `SizedBox.shrink()` | `register_tab.dart`, `dialog_grid_editor.dart` | C14 |
| R-5 | `ref.read` called in `dispose()` in `dialog_bill_detail.dart` without caching reference first (unlike `screen_sell.dart` which correctly uses `late final`) | `dialog_bill_detail.dart` | C14 |

---

### 9. Error Handling

#### HIGH

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| ~~EH-1~~ | ~~Catch bez logování~~ — **FIXED.** Added `AppLogger.error()` with stack trace capture. | `voucher_repository.dart:137` | C15 |
| ~~EH-2~~ | ~~Catch bez stack trace~~ — **FIXED.** Changed `catch (e)` to `catch (e, s)` + `AppLogger.error()` with stack trace. | `outbox_processor.dart:118` | C15 |

---

### 10. Naming & Formatting

#### MEDIUM

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| N-1 | ~20 boolean variables lack `is`/`has`/`can`/`should` prefix: `_saving`, `_loaded`, `_initialized`, `_processing`, `_showWizard`, `_showMap`, `_sortAscending`, `_enteringName`, `_sessionScope` | Across feature widgets | C16 |
| N-2 | 2 Stream-returning methods named `search()` instead of `watchSearch*()` -- inconsistent with all other 26 Stream methods | `item_repository.dart`, `customer_repository.dart` | C16 |

#### LOW

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| N-3 | `ScreenCompanySettings` lives in `screen_settings.dart` -- file-class name mismatch | `screen_settings.dart` | C16 |

---

### 11. Code Quality & Best Practices

#### HIGH

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| Q-1 | 26 force unwraps on nullable `syncQueueRepo!` at every mutation call site in 17 repositories. If a repo is instantiated without sync dependency, every write throws null-deref at runtime. | 17 repository files | C19 |
| ~~Q-2~~ | ~~52 methods accept `dynamic l` for localization parameter~~ — **FIXED.** All 52 occurrences across 20 files changed to `AppLocalizations l` with proper imports. | — | — |

#### MEDIUM

| # | Finding | File(s) | Agent |
|---|---------|---------|-------|
| Q-3 | `DateTime.now()` called in 14 tab widget files when constructing entity models in UI before passing to repositories. Not a bug (repos overwrite), but timestamp responsibility leaks into UI layer. | 14 `*_tab.dart` files | C17 |
| Q-4 | ~19 instances of `x != null && x!.method` pattern -- safe at runtime but fragile to refactoring. Should use local variable or `if-let` pattern. | Multiple files | C19 |
| Q-5 | Multiple methods exceed 80 lines. Worst: `_showPlaceDialog` (391 lines), `_buildCart` (193 lines) | Multiple files | C19 |
| Q-6 | 7 DRY violations: sync enqueue boilerplate repeated 27x in 16 repos, bill-session filter expression repeated 5x, discount calculation duplicated 3x | Multiple repos | C19 |
| Q-7 | N+1 query patterns: sequential `await` in loops for per-bill payment queries during session close/cash journal, per-item DB lookups in stock deduction | `screen_bills.dart`, `stock_document_repository.dart` | C20 |
| Q-8 | 7 `as dynamic` casts in sync layer -- known Drift limitation, all for generic table/entity access | `sync_service.dart`, `sync_lifecycle_manager.dart` | C19 |
| Q-9 | Currency conversion literal `100` (halere to CZK) appears 34 times across 15 files -- candidate for named constant | Multiple files | C17 |

---

## Passing Areas (Notable Positives)

| Area | Result |
|------|--------|
| `dart analyze` | 0 issues (zero errors, warnings, info) |
| UUID version | 100% v7, zero v4 (48 occurrences) |
| UUID instantiation | 100% `const Uuid()` |
| `print()` statements | 0 found -- AppLogger used consistently |
| TODO/FIXME/HACK | 0 found -- clean codebase |
| Import ordering | HIGH consistency -- group order correct in all 25+ sampled files |
| Import style | 100% relative imports, no `package:maty/` |
| Trailing commas | Consistent across all sampled files |
| `part`/`part of` | 100% consistent across Freezed models |
| Push mapper coverage | 35/35 synced entities have complete push mappers |
| Pull mapper coverage | 35/35 synced entities have complete pull mappers |
| Enum serialization | 100% consistent `.name` on push |
| Enum deserialization | 100% consistent `_enumFromName` on pull |
| Drift↔Supabase columns | 358 of 361 columns match (3 mismatches, all on `sync_queue`) |
| FK ordering in pull | All 35 tables in correct FK dependency order |
| Timer/subscription cleanup | All properly managed with `ref.onDispose` |
| RLS enabled | 37/37 public tables (100%) |
| Drift table registration | 37/37 tables registered |
| SyncColumnsMixin | 34/34 domain tables correct; 3 infrastructure tables correctly omit |
| Zero empty catch blocks | Confirmed across entire codebase |
| Zero rethrows | Consistent swallow+log+return pattern |
| `const` constructors | All sampled widgets have `const` where possible |
| `const` collections | Consistently used |
| Hardcoded paths | 0 found |
| Circular provider deps | 0 found |
| Secrets in client code | 0 found (anon key is expected/public) |

---

## Quick-Fix Table

| # | Severity | File:Line | What to Change |
|---|----------|-----------|----------------|
| ~~1~~ | ~~HIGH~~ | ~~`voucher_repository.dart:136`~~ | ~~FIXED~~ |
| ~~2~~ | ~~HIGH~~ | ~~`outbox_processor.dart:118`~~ | ~~FIXED~~ |
| 3 | HIGH | `dialog_bill_detail.dart:154,265,365` | Cache futures in `initState` instead of inline in `build()` |
| ~~4~~ | ~~MEDIUM~~ | ~~`table_entities.dart:17-18`~~ | ~~FIXED — defaults aligned to 1~~ |
| 5 | MEDIUM | `app_router.dart:27-55` | Add `AsyncError` handling in redirect (show error screen or retry) |
| 6 | MEDIUM | `screen_login.dart:178-203` | Increment lockout counter for failed progressive PIN checks |
| 7 | MEDIUM | `screen_kds.dart` / `screen_orders.dart` | Extract shared `_statusLabel`/`_nextStatus`/`_nextStatusLabel` to a common file |
| 8 | MEDIUM | `supabase_pull_mappers.dart` | Add fallback/default for `_enumFromName` on unknown values |
| 9 | MEDIUM | 14 `*_tab.dart` files | Add `if (!mounted) return;` after `await` calls |
| 10 | LOW | Supabase `sync_queue` | Add `WITH CHECK` to UPDATE policy |
| ~~11~~ | ~~LOW~~ | ~~Supabase `map_elements.shape`~~ | ~~FIXED — created `table_shape` + `display_device_type` enums~~ |
| 12 | LOW | Supabase indexes | Drop 3 redundant: `idx_map_elements_company_id`, `idx_cash_movements_updated_at`, `idx_companies_updated_at` |

---

*Last verified: 2026-02-13. Removed: EH-1 (fixed), EH-2 (fixed), EH-3 (fixed), AU-4 (fixed), UI-1 (fixed). Updated: UI-5, UI-10 (partially fixed). Corrected counts: A-2, Q-1, Q-2, Q-4, Q-5, Q-9.*

# Consistency Audit — Sequential Phased Architecture

## Cíl

100% kontrola konzistence kódu a architektury. Každý soubor, každý řádek. Audit je **READ-ONLY** — žádné změny, žádné commity.

## Architektura

```
FÁZE 0 — Prerekvizity (hlavní konverzace, manuálně)
  │  Supabase dotazy po skupinách → /tmp/audit/phase0/
  │
  ▼
FÁZE 1 — Repositories + Mappers (4 agenti)
  │  C1: BaseCompanyScoped repos    C3: Entity mappers
  │  C2: Manuální repos             C4: Push + Pull mappers
  │  → /tmp/audit/phase1/
  ▼
FÁZE 2 — Data Layer (4 agenti)
  │  C5: Model↔Drift match          C7: Sync engine
  │  C6: Drift tabulky              C8: Enum konzistence
  │  → /tmp/audit/phase2/
  ▼
FÁZE 3 — Providers + Auth + UI/1 (4 agenti)
  │  C9: Providery                  C11: UI Sell+Bills
  │  C10: Auth+Routing              C12: UI Auth+Onboard+Settings
  │  → /tmp/audit/phase3/
  ▼
FÁZE 4 — UI/2 + Cross-cutting (4 agenti)
  │  C13: UI remaining              C15: Error handling
  │  C14: Riverpod patterns         C16: Naming conventions
  │  → /tmp/audit/phase4/
  ▼
FÁZE 5 — Code Quality (4 agenti)
  │  C17: UUID+DateTime+Const       C19: Static analysis
  │  C18: Imports+Structure          C20: Best practices
  │  → /tmp/audit/phase5/
  ▼
FÁZE 6 — Drift↔Supabase (4 agenti)
  │  C21: Tabulky A-I               C23: Tabulky P-Z
  │  C22: Tabulky I-O               C24: RLS+Triggers+Indexes
  │  → /tmp/audit/phase6/
  ▼
FÁZE 7 — Sloučení (hlavní konverzace)
  │  Přečíst VŠECHNY /tmp/audit/phase*/
  │  → /tmp/audit/FINAL_REPORT.md
```

**24 agentů × max 4 paralelně = 6 sekvenčních fází + merge.**

---

## KRITICKÁ PRAVIDLA

1. **Max 4 agenti najednou** — nikdy víc. Claude Code nezvládne 10+ paralelních agentů.
2. **Výsledky do souborů** — každý agent MUSÍ zapsat výsledky do přiděleného souboru v `/tmp/audit/`. NIKDY nevracet velký text zpět do konverzace — to vyčerpá context window.
3. **Fáze spouštěj SEKVENČNĚ** — nespouštěj další fázi, dokud předchozí nedokončí a neověříš výstupní soubory.
4. **SQL dotazy po skupinách** — NIKDY nedotazuj celé `information_schema.columns` najednou (100K+ znaků = MCP error). Vždy filtruj `WHERE table_name IN (...)` po skupinách max 5-8 tabulek.
5. **Agent MUSÍ přečíst KAŽDÝ řádek** přidělených souborů — ne jen proletět, ale skutečně zkontrolovat dle checklistu.
6. **Pokud agent selže** (context limit) — spusť ho znovu JEDNOTLIVĚ, ne celou fázi.
7. **Hlavní konverzace NEČTE výsledky agentů průběžně** — čte je až ve fázi sloučení.

---

## Globální pravidla

### Prompt šablona pro každého agenta

Každý agent dostane v promptu:
1. Svůj checklist (z tohoto dokumentu)
2. Instrukci: "Zapiš výsledky do souboru `[cesta]` pomocí Write tool"
3. Instrukci: "Přečti KAŽDÝ řádek přidělených souborů"

### Výstupní formát

```
# Agent [ID]: [název]
Zkontrolováno souborů: X
Zkontrolováno řádků: ~X

## Nálezy

### [ZÁVAŽNOST] Popis nálezu
**Soubor:** `cesta:řádek`
**Pravidlo:** Které pravidlo je porušeno
**Očekávání:** Co by tam mělo být (vzor z jiného souboru)
**Realita:** Co tam je
**Řešení:** Jak sjednotit

## Bez nálezu (zkontrolováno, vše OK)
- [seznam bodů checklistu které prošly]
```

### Závažnosti

| Závažnost | Definice |
|-----------|----------|
| **VYSOKÉ** | Nekonzistence způsobující runtime chybu nebo ztrátu dat |
| **STŘEDNÍ** | Nekonzistence porušující architektonický vzor projektu |
| **NÍZKÉ** | Kosmetická nekonzistence (naming, ordering, formatting) |

### Pravidla analýzy

1. **Čti KAŽDÝ řádek** přidělených souborů. Neskákej, neskipuj.
2. **Porovnávej se vzorovým souborem** — pokud instrukce říká "vzor: X", přečti X jako referenci.
3. **Reportuj POUZE skutečné nekonzistence** — ne stylistické preference.
4. **Uveď VŽDY oba konce** — kde je vzor a kde je odchylka.
5. **Nespekuluj** — pokud si nejsi jistý, nereportuj.

### Známé vzory — NE nález

1. Drift `text()` pro UUID = OK (SQLite nemá UUID typ)
2. Drift `text()` pro Supabase `text`/`varchar`/`uuid`/`jsonb` = OK
3. Supabase anon key v kódu = OK (designově veřejný, RLS chrání)
4. Sync-only sloupce pouze v Drift (`lastSyncedAt`, `version`, `serverCreatedAt`, `serverUpdatedAt`) = OK
5. `sync_queue` bez `enforce_lww` triggeru = OK (jednosměrný outbox)
6. `as dynamic` v sync engine = max NÍZKÉ (Drift limitation, nemá společné rozhraní)
7. Globální tabulky s RLS `SELECT true` = OK
8. `whereCompanyScope` v subclass filtruje `deletedAt` = OK (VŽDY přečti 2+ subclass implementace)
9. Neimplementované budoucí features z PROJECT.md = NE nález
10. `sync_metadata` a `device_registrations` pouze v Drift (local-only) = OK
11. Chybějící FK constraints na Supabase = OK (offline-first, entity sync v libovolném pořadí)

---

## FÁZE 0 — Prerekvizity (hlavní konverzace, BEZ agentů)

### 0.1 Setup

```bash
mkdir -p /tmp/audit/phase0 /tmp/audit/phase1 /tmp/audit/phase2 /tmp/audit/phase3 /tmp/audit/phase4 /tmp/audit/phase5 /tmp/audit/phase6
```

1. **Supabase project ID** — zjisti z `lib/core/network/supabase_config.dart`
2. **Git status** — `git status` a `git log --oneline -5`
3. **Strom souborů** — `Glob lib/**/*.dart` → zapiš do `/tmp/audit/phase0/file_tree.txt`

### 0.2 Supabase schéma dotazy (PO SKUPINÁCH)

**DŮLEŽITÉ:** Dotaz na všechny sloupce najednou vrací 100K+ znaků a způsobí MCP error. Musíš dotazovat po skupinách max 5-8 tabulek.

#### Skupina A: bills, categories, cash_movements, companies, company_settings, currencies, customers, customer_transactions

```sql
SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('bills', 'categories', 'cash_movements', 'companies', 'company_settings', 'currencies', 'customers', 'customer_transactions')
ORDER BY table_name, ordinal_position;
```
→ zapiš do `/tmp/audit/phase0/supabase_columns_A.txt`

#### Skupina B: items, layout_items, manufacturers, map_elements, orders, order_items

```sql
SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('items', 'layout_items', 'manufacturers', 'map_elements', 'orders', 'order_items')
ORDER BY table_name, ordinal_position;
```
→ `/tmp/audit/phase0/supabase_columns_B.txt`

#### Skupina C: payments, payment_methods, permissions, product_recipes, registers, register_sessions, reservations

```sql
SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('payments', 'payment_methods', 'permissions', 'product_recipes', 'registers', 'register_sessions', 'reservations')
ORDER BY table_name, ordinal_position;
```
→ `/tmp/audit/phase0/supabase_columns_C.txt`

#### Skupina D: roles, role_permissions, sections, shifts, stock_documents, stock_levels, stock_movements

```sql
SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('roles', 'role_permissions', 'sections', 'shifts', 'stock_documents', 'stock_levels', 'stock_movements')
ORDER BY table_name, ordinal_position;
```
→ `/tmp/audit/phase0/supabase_columns_D.txt`

#### Skupina E: suppliers, sync_queue, tables, tax_rates, users, user_permissions, vouchers, warehouses

```sql
SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('suppliers', 'sync_queue', 'tables', 'tax_rates', 'users', 'user_permissions', 'vouchers', 'warehouses')
ORDER BY table_name, ordinal_position;
```
→ `/tmp/audit/phase0/supabase_columns_E.txt`

#### Ostatní dotazy (malé, lze spustit najednou)

```sql
-- Enumy
SELECT t.typname, e.enumlabel FROM pg_type t JOIN pg_enum e ON t.oid = e.enumtypid ORDER BY t.typname, e.enumsortorder;
```
→ `/tmp/audit/phase0/supabase_enums.txt`

```sql
-- RLS enabled
SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';
```
→ `/tmp/audit/phase0/supabase_rls_enabled.txt`

```sql
-- RLS policies
SELECT schemaname, tablename, policyname, cmd, qual, with_check FROM pg_policies WHERE schemaname = 'public';
```
→ `/tmp/audit/phase0/supabase_rls_policies.txt`

```sql
-- Triggery
SELECT trigger_name, event_manipulation, event_object_table FROM information_schema.triggers WHERE trigger_schema = 'public';
```
→ `/tmp/audit/phase0/supabase_triggers.txt`

```sql
-- Indexy
SELECT tablename, indexname, indexdef FROM pg_indexes WHERE schemaname = 'public';
```
→ `/tmp/audit/phase0/supabase_indexes.txt`

```sql
-- FK bez indexu
SELECT tc.table_name, kcu.column_name FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public'
AND NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = tc.table_name AND indexdef LIKE '%' || kcu.column_name || '%');
```
→ `/tmp/audit/phase0/supabase_fk_no_index.txt`

**+ Advisors (MCP tool, ne SQL):**
- `get_advisors(type: "security")` → `/tmp/audit/phase0/advisors_security.txt`
- `get_advisors(type: "performance")` → `/tmp/audit/phase0/advisors_performance.txt`

### 0.3 Ověření

Ověř, že VŠECHNY soubory v `/tmp/audit/phase0/` existují a mají obsah (`ls -la /tmp/audit/phase0/`). Pokud některý chybí nebo je prázdný, oprav.

---

## FÁZE 1 — Repositories + Mappers (4 agenti paralelně)

### Agent C1: Repository Pattern — BaseCompanyScoped

**Soubory k přečtení:**
- `lib/core/data/repositories/base_company_scoped_repository.dart` (VZOR)
- Všechny soubory v `lib/core/data/repositories/` které DĚDÍ z `BaseCompanyScopedRepository`

**Identifikace:** Najdi všechny třídy s `extends BaseCompanyScopedRepository` (grep).

**Checklist pro KAŽDÝ dědící repozitář:**

- [ ] Implementuje `whereCompanyScope` — MUSÍ obsahovat `t.deletedAt.isNull()`?
- [ ] Implementuje `whereId` — je konzistentní s base třídou?
- [ ] Implementuje `defaultOrderBy` — existuje?
- [ ] Implementuje `entityName` — odpovídá názvu tabulky?
- [ ] Implementuje `supabaseTableName` — odpovídá skutečnému Supabase table name (snake_case)?
- [ ] Implementuje `toSupabaseJson` — volá správnou mapper funkci?
- [ ] Implementuje `fromEntity` — volá správnou mapper funkci?
- [ ] Implementuje `toCompanion` — volá správnou mapper funkci?
- [ ] Implementuje `toUpdateCompanion` — volá správnou mapper funkci?
- [ ] Implementuje `toDeleteCompanion` — je konzistentní s base třídou?
- [ ] Má `syncQueueRepo` v konstruktoru?
- [ ] Pokud má extra metody nad rámec CRUD — jsou konzistentní s base vzorem (Result<T>, try/catch, AppLogger)?
- [ ] Pokud přepisuje `create`/`update`/`delete` — je to zdokumentováno proč?

**Výstup:** Tabulka VŠECH dědících repozitářů + stav pro každý checklist bod → `/tmp/audit/phase1/C1_base_repos.md`

---

### Agent C2: Repository Pattern — Manuální repozitáře

**Soubory k přečtení:**
- `lib/core/data/repositories/bill_repository.dart`
- `lib/core/data/repositories/company_repository.dart`
- `lib/core/data/repositories/order_repository.dart`
- `lib/core/data/repositories/sync_queue_repository.dart`
- `lib/core/data/repositories/stock_document_repository.dart`
- Jakékoli další repozitáře které NEDĚDÍ z `BaseCompanyScopedRepository`

**Checklist pro KAŽDÝ manuální repozitář:**

- [ ] **Result<T>:** Vrací KAŽDÁ veřejná write metoda `Result<T>`? Vypiš metody které ne.
- [ ] **try/catch:** Má KAŽDÁ veřejná metoda try/catch s `AppLogger.error`? Vypiš metody které ne.
- [ ] **Transakce:** Jsou multi-step write operace (2+ DB operace) v `_db.transaction()`? Vypiš metody kde nejsou.
- [ ] **Outbox enqueue:** Má KAŽDÁ write metoda (create/update/delete) odpovídající `_enqueue*` volání? Vypiš metody které nemají.
- [ ] **Enqueue MIMO transakci:** Je `_enqueue*` voláno MIMO `_db.transaction()` blok (jako v base třídě)? Nebo uvnitř? Vypiš nekonzistence.
- [ ] **Company scope:** Filtrují read metody (watch/get) dle `companyId` a `deletedAt.isNull()`? Vypiš metody které ne.
- [ ] **Konstruktor pattern:** Je konzistentní s ostatními repozitáři (`_db`, `syncQueueRepo`, optional dependencies)?
- [ ] **Private helpers:** Existují `_enqueue*` metody pro KAŽDOU entitu kterou repozitář zapisuje?

**Výstup:** Per-method tabulka pro každý repozitář → `/tmp/audit/phase1/C2_manual_repos.md`

---

### Agent C3: Entity Mappers — Kompletnost

**Soubory k přečtení:**
- `lib/core/data/mappers/entity_mappers.dart`
- VŠECHNY soubory v `lib/core/data/models/*.dart` (ne `.freezed.dart`, ne `.g.dart`)
- VŠECHNY soubory v `lib/core/database/tables/*.dart`
- `lib/core/database/app_database.dart` (seznam tabulek z `@DriftDatabase`)

**Úkol:** Pro KAŽDOU entitu registrovanou v `@DriftDatabase(tables: [...])`:

1. Najdi odpovídající Drift tabulku (v `tables/`)
2. Najdi odpovídající Model (v `models/`)
3. Najdi odpovídající `*FromEntity()` a `*ToCompanion()` v `entity_mappers.dart`

**Checklist per entita:**

- [ ] Existuje `*FromEntity()` funkce?
- [ ] Existuje `*ToCompanion()` funkce?
- [ ] `*FromEntity()` mapuje VŠECHNY sloupce z Drift tabulky do modelu? (ignoruj sync sloupce z SyncColumnsMixin)
- [ ] `*ToCompanion()` mapuje VŠECHNY pole z modelu do Drift Companion?
- [ ] Jsou typy konzistentní? (int↔int, String↔String, DateTime↔DateTime, enum↔textEnum)
- [ ] Je nullable konzistentní? (Drift nullable → Model nullable, Drift required → Model required)

**Výstup:** Matice entit × checklist bodů → `/tmp/audit/phase1/C3_entity_mappers.md`

---

### Agent C4: Push + Pull Mappers — Kompletnost

**Soubory k přečtení:**
- `lib/core/data/mappers/supabase_mappers.dart`
- `lib/core/data/mappers/supabase_pull_mappers.dart`
- VŠECHNY soubory v `lib/core/data/models/*.dart` (ne `.freezed.dart`)
- VŠECHNY soubory v `lib/core/database/tables/*.dart`

**Push checklist per entita (`*ToSupabaseJson`):**

- [ ] Existuje `*ToSupabaseJson()` funkce?
- [ ] Mapuje VŠECHNA pole z modelu do JSON? Vypiš chybějící.
- [ ] Používá správné Supabase klíče (snake_case)?
- [ ] Odesílá `created_at`/`updated_at` jako `client_created_at`/`client_updated_at`? (NIKDY ne `created_at`/`updated_at` — ty nastavuje server trigger)
- [ ] Enum hodnoty — serializovány přes `.name`? Konzistentně?
- [ ] DateTime — `.toIso8601String()`? Konzistentně?
- [ ] Nullable pole — vynechána z JSON pokud null, nebo posílána jako null? Konzistentně?
- [ ] `id` pole — je vždy první v JSON mapu?

**Pull checklist per entita (`*FromSupabasePull`):**

- [ ] Existuje `*FromSupabasePull()` funkce?
- [ ] Mapuje VŠECHNY Drift sloupce (kromě `lastSyncedAt`, `version`)? Vypiš chybějící.
- [ ] Nastavuje `serverCreatedAt` z `json['created_at']`?
- [ ] Nastavuje `serverUpdatedAt` z `json['updated_at']`?
- [ ] Nastavuje `lastSyncedAt` na `DateTime.now()`?
- [ ] Nastavuje `deletedAt` z `json['deleted_at']`?
- [ ] Enum hodnoty — deserializuje přes `EnumType.values.byName()` s `orElse`/fallback? Nebo bez? Konzistentně?
- [ ] `as String` / `as int` casty — jsou null-safe? Používají `as String?` pro nullable?
- [ ] Pořadí polí v Companion — stejné jako pořadí sloupců v Drift tabulce?

**Výstup:** Per-mapper porovnávací tabulky → `/tmp/audit/phase1/C4_push_pull_mappers.md`

---

**Spuštění Fáze 1:**
```
Spusť C1, C2, C3, C4 paralelně (run_in_background: true).
Počkej na dokončení VŠECH 4.
Ověř: ls -la /tmp/audit/phase1/ — VŠECHNY 4 soubory existují a mají obsah.
Teprve pak pokračuj na FÁZI 2.
```

---

## FÁZE 2 — Data Layer (4 agenti paralelně)

### Agent C5: Model ↔ Drift tabulka — Field Match

**Soubory k přečtení:**
- VŠECHNY soubory v `lib/core/data/models/*.dart` (ne `.freezed.dart`)
- VŠECHNY soubory v `lib/core/database/tables/*.dart`

**Úkol:** Pro KAŽDÝ pár (Model, Drift tabulka) vytvoř srovnávací tabulku:

| Drift sloupec | Drift typ | Drift nullable | Model pole | Model typ | Model nullable | Shoda? |
|---------------|-----------|----------------|------------|-----------|----------------|--------|

**Checklist per pár:**

- [ ] Má model VŠECHNY sloupce z Drift tabulky? (ignoruj sync sloupce z SyncColumnsMixin)
- [ ] Má Drift tabulka VŠECHNY pole z modelu?
- [ ] Je nullable konzistentní? Pro KAŽDÉ pole:
  - Drift `nullable()` → Model `Type?` (nullable)
  - Drift bez `nullable()` → Model `required Type` (required)
- [ ] Jsou typy konzistentní?
  - Drift `text()` → Model `String`
  - Drift `integer()` → Model `int`
  - Drift `real()` → Model `double`
  - Drift `boolean()` → Model `bool`
  - Drift `dateTime()` → Model `DateTime`
  - Drift `textEnum<X>()` → Model `X` (enum typ)
- [ ] Je Freezed model definován se správnými `@Default` hodnotami odpovídajícími Drift `.withDefault()`?

**Výstup:** Per-entity srovnávací tabulka → `/tmp/audit/phase2/C5_model_drift.md`

---

### Agent C6: Drift tabulky — Vzory

**Soubory k přečtení:**
- VŠECHNY soubory v `lib/core/database/tables/*.dart`
- `lib/core/database/app_database.dart`

**Checklist per tabulka:**

- [ ] **SyncColumnsMixin:** Používá `with SyncColumnsMixin`? (VŠECHNY doménové tabulky MUSÍ, infrastrukturní ne)
- [ ] **@TableIndex:** Má `@TableIndex` pro `[#companyId, #updatedAt]`? (VŠECHNY company-scoped tabulky MUSÍ)
- [ ] **Další indexy:** Mají FK sloupce vlastní `@TableIndex`?
- [ ] **Enum sloupce:** Jsou definovány jako `textEnum<T>()`? (ne `text()` s manuální konverzí)
- [ ] **Monetární sloupce:** Jsou vždy `integer()` (haléře), NIKDY `real()`?
- [ ] **ID sloupec:** Je `text()` (UUID jako string)?
- [ ] **companyId sloupec:** Je `text()` (UUID)?
- [ ] **Naming konvence:** Jsou sloupce v camelCase? (Drift standard)
- [ ] **Registrace:** Je tabulka registrovaná v `@DriftDatabase(tables: [...])`?
- [ ] **Konzistence `.withDefault()`:** Jsou výchozí hodnoty konzistentní mezi tabulkami? (např. `0` pro monetary, `false` pro bool)

**Výstup:** Matice tabulek × checklist bodů → `/tmp/audit/phase2/C6_drift_tables.md`

---

### Agent C7: Sync Engine — Konzistence

**Soubory k přečtení:**
- `lib/core/sync/sync_service.dart`
- `lib/core/sync/outbox_processor.dart`
- `lib/core/sync/sync_lifecycle_manager.dart`
- `lib/core/sync/realtime_service.dart`

**Checklist:**

- [ ] **`_pullTables` seznam:** Vypiš VŠECHNY tabulky. Pro KAŽDOU ověř:
  - Existuje v Drift `@DriftDatabase(tables: [...])`?
  - Existuje odpovídající `fromSupabasePull` v pull mapperech?
  - Existuje odpovídající `_getDriftTable` case v sync_service?
  - Je FK pořadí správné? (parent před child)
- [ ] **`_globalTables` vs `_companyTables`:** Je rozdělení konzistentní s tím, které tabulky mají/nemají `companyId`?
- [ ] **`_realtimeTables`:** Které tabulky mají realtime a které ne?
- [ ] **Initial push (`_initialPush`):** Jsou VŠECHNY tabulky z `_pullTables` pokryty? Vypiš chybějící.
- [ ] **Initial push — FK pořadí:** Je pořadí pushování konzistentní s FK závislostmi?
- [ ] **`as dynamic` casty:** Vypiš VŠECHNY, pro každý uveď proč je nutný a zda je bezpečný.
- [ ] **Timer management:** Jsou VŠECHNY timery/subscriptions správně cancellované v `stop()`/`dispose()`?
- [ ] **Error handling konzistence:** Je try/catch + AppLogger vzor konzistentní napříč všemi metodami?
- [ ] **`_isProcessing` guard:** Existuje a je správně implementovaný v outbox processoru?
- [ ] **Outbox stuck entries:** Reset pro processing > 5 min?
- [ ] **Outbox cleanup:** Completed entries > 7 days?

**Výstup:** Pull tables matice + initial push coverage matice + seznam nekonzistencí → `/tmp/audit/phase2/C7_sync.md`

---

### Agent C8: Enum Konzistence — Dart ↔ Supabase ↔ Mappers

**Soubory k přečtení:**
- VŠECHNY soubory v `lib/core/data/enums/*.dart`
- `lib/core/data/mappers/supabase_mappers.dart` (enum serializace)
- `lib/core/data/mappers/supabase_pull_mappers.dart` (enum deserializace)
- `/tmp/audit/phase0/supabase_enums.txt` (Supabase enum hodnoty)

**Checklist per enum:**

- [ ] **Dart hodnoty:** Vypiš VŠECHNY hodnoty v pořadí.
- [ ] **Supabase hodnoty:** Vypiš VŠECHNY hodnoty v pořadí (z phase0 souboru).
- [ ] **1:1 shoda:** Jsou identické? Vypiš odchylky.
- [ ] **Serializace v push mapperu:** Jak se enum konvertuje na string? (`.name`? custom?)
- [ ] **Deserializace v pull mapperu:** Jak se string konvertuje na enum? (`byName`? `firstWhere`? switch?)
- [ ] **orElse/fallback:** Má deserializace fallback pro neznámou hodnotu?
- [ ] **Konzistence serializace:** Je STEJNÝ vzor použit pro VŠECHNY enumy?
- [ ] **Konzistence deserializace:** Je STEJNÝ vzor použit pro VŠECHNY enumy?

**Výstup:** Per-enum srovnávací tabulka Dart ↔ Supabase + seznam nekonzistencí → `/tmp/audit/phase2/C8_enums.md`

---

**Spuštění Fáze 2:**
```
Spusť C5, C6, C7, C8 paralelně (run_in_background: true).
Počkej na dokončení VŠECH 4.
Ověř: ls -la /tmp/audit/phase2/
Pokračuj na FÁZI 3.
```

---

## FÁZE 3 — Providers + Auth + UI/1 (4 agenti paralelně)

### Agent C9: Provider Pattern — Konzistence

**Soubory k přečtení:**
- VŠECHNY soubory v `lib/core/data/providers/*.dart`

**Checklist per provider soubor:**

- [ ] **Naming:** Má suffix `Provider`?
- [ ] **autoDispose:** Mají screen-scoped providery `autoDispose`?
- [ ] **keepAlive:** Je `ref.keepAlive()` použit pouze u globálních providerů?
- [ ] **ref.onDispose:** Mají providery s timery/streams cleanup?
- [ ] **Circular dependencies:** Vypiš VŠECHNY `ref.watch`/`ref.read` závislosti jako graf. Existuje cyklus?
- [ ] **Konzistence vzoru:** Je `@riverpod` / `@Riverpod(keepAlive: true)` použito konzistentně, nebo mix s `Provider()`/`StateProvider()`?
- [ ] **Repository providers:** Předávají konzistentně `syncQueueRepo`?
- [ ] **Error handling:** Mají `AsyncNotifierProvider` konzistentní error handling?
- [ ] **Invalidation:** Jsou providery invalidovány na správných místech?

**Výstup:** Provider dependency graf + seznam nekonzistencí → `/tmp/audit/phase3/C9_providers.md`

---

### Agent C10: Auth + Routing — Konzistence

**Soubory k přečtení:**
- `lib/core/auth/pin_helper.dart`
- `lib/core/auth/auth_service.dart`
- `lib/core/auth/session_manager.dart`
- `lib/core/auth/supabase_auth_service.dart`
- `lib/core/routing/app_router.dart`

**Checklist:**

- [ ] **Route guard completeness:** Pokrývá redirect VŠECHNY stavy? (no auth, no company, no user, no session)
- [ ] **Route guard konzistence:** Odpovídá použitý permission kód v routeru tomu, co je v `lib/core/data/enums/`?
- [ ] **Redirect loops:** Může nastat nekonečný redirect?
- [ ] **Auth flow konzistence:** Je login → PIN verify → session create flow konzistentní mezi auth_service, session_manager a UI?
- [ ] **PIN hash konzistence:** Je hash/verify round-trip konzistentní? (hash v pin_helper, verify v auth_service)
- [ ] **Brute-force timing:** Odpovídají lockout časy v auth_service dokumentaci v PROJECT.md?
- [ ] **Session volatilita:** Je session v RAM only? Záměr nebo bug?
- [ ] **Credentials:** Hledej JINÉ credentials než anon key (service_role key, DB heslo, API keys třetích stran — ty NESMÍ být v kódu)

**Výstup:** Route table + auth flow diagram + seznam nekonzistencí → `/tmp/audit/phase3/C10_auth_routing.md`

---

### Agent C11: UI — ScreenSell + ScreenBills

**Soubory k přečtení:**
- `lib/features/sell/screens/screen_sell.dart`
- `lib/features/bills/screens/screen_bills.dart`
- `lib/features/bills/widgets/*.dart` (VŠECHNY)
- `lib/features/bills/services/*.dart` (VŠECHNY)

**Checklist per soubor:**

- [ ] **Hardcoded stringy:** Existují stringy které NEJSOU přes `context.l10n`? Vypiš KAŽDÝ.
- [ ] **Business logika v UI:** Existují kalkulace, agregace nebo logika patřící do repositáře? Vypiš.
- [ ] **Mounted check:** Je po KAŽDÉM `await` ve StatefulWidget kontrola `if (!mounted) return` nebo `if (!context.mounted) return`?
- [ ] **Dispose:** Má KAŽDÝ StatefulWidget s controllery/timery/subscriptions `dispose()`?
- [ ] **Processing guard:** Mají tlačítka s async akcemi `_processing` flag?
- [ ] **ref.watch vs ref.read:** Je `ref.watch` v `build()` a `ref.read` v event handlerech? Vypiš porušení.
- [ ] **Direct DB access:** Volá UI přímo `_db` nebo `Supabase.instance`? Vše MUSÍ jít přes repository/provider.
- [ ] **StreamBuilder future:** Je `Future` v `FutureBuilder` vytvořeno v `initState` (ne v `build`)?
- [ ] **Theme barvy:** Jsou barvy přes `Theme.of(context)` / `ColorScheme`? Existují hardcoded `Color(0xFF...)`?
- [ ] **Touch targets:** Jsou VŠECHNA tlačítka >= 40px výška?
- [ ] **Padding/spacing konzistence:** Jsou mezery konzistentní (8, 12, 16, 24)?
- [ ] **Dialog šířka:** Je konzistentní vzor pro maxWidth dialogů?

**Výstup:** Per-soubor seznam nálezů → `/tmp/audit/phase3/C11_ui_sell_bills.md`

---

### Agent C12: UI — Auth + Onboarding + Settings

**Soubory k přečtení:**
- `lib/features/auth/screens/*.dart`
- `lib/features/onboarding/screens/*.dart`
- `lib/features/settings/screens/*.dart`
- `lib/features/settings/widgets/*.dart`

**Checklist:** Identický s agentem C11 (viz výše). Aplikuj na KAŽDÝ soubor.

**Výstup:** Per-soubor seznam nálezů → `/tmp/audit/phase3/C12_ui_auth_settings.md`

---

**Spuštění Fáze 3:**
```
Spusť C9, C10, C11, C12 paralelně (run_in_background: true).
Počkej na dokončení VŠECH 4.
Ověř: ls -la /tmp/audit/phase3/
Pokračuj na FÁZI 4.
```

---

## FÁZE 4 — UI/2 + Cross-cutting (4 agenti paralelně)

### Agent C13: UI — Zbývající features

**Soubory k přečtení:**
- `lib/features/orders/screens/*.dart`
- `lib/features/orders/widgets/*.dart`
- `lib/features/customers/screens/*.dart`
- `lib/features/customers/widgets/*.dart`
- Jakékoli další soubory v `lib/features/` nepokryté agenty C11 a C12

**Checklist:** Identický s agentem C11 (viz výše). Aplikuj na KAŽDÝ soubor.

**Výstup:** Per-soubor seznam nálezů → `/tmp/audit/phase4/C13_ui_remaining.md`

---

### Agent C14: Riverpod Patterns — Codebase-wide

**Soubory k přečtení:**
- VŠECHNY soubory v `lib/features/` (screeny a widgety)
- VŠECHNY soubory v `lib/core/data/providers/`

**Checklist:**

- [ ] **ref.watch v build():** Vypiš KAŽDÉ použití `ref.watch` MIMO `build()` metodu.
- [ ] **ref.read v build():** Vypiš KAŽDÉ použití `ref.read` V `build()` metodě (mělo by být watch).
- [ ] **ref.watch v callback:** Vypiš KAŽDÉ `ref.watch` uvnitř `onPressed`/`onChanged`/callback.
- [ ] **AsyncValue handling:** Grep `.when(`. Je konzistentně `data:`, `loading:`, `error:`? Jsou error stavy ošetřeny, nebo zobrazují spinner?
- [ ] **ConsumerWidget vs ConsumerStatefulWidget vs StatefulWidget:** Vypiš VŠECHNY widget třídy a jejich typ. Je volba konzistentní?
- [ ] **Provider granularita:** Existují providery vracející velké objekty, kde by stačil `.select()`?
- [ ] **FutureBuilder s inline future:** Grep `FutureBuilder(` a zkontroluj zda je `future:` definováno inline v build (špatně) nebo v initState (správně).
- [ ] **StreamBuilder nesting:** Existují vnořené StreamBuildery? Vypiš.
- [ ] **ref.watch/ref.read mimo build context:** Je `ref` použit uvnitř callback funkcí kde by měl být uložen do lokální proměnné předem?

**Výstup:** Per-pravidlo seznam porušení → `/tmp/audit/phase4/C14_riverpod.md`

---

### Agent C15: Error Handling Konzistence — Codebase-wide

**Soubory k přečtení:**
- VŠECHNY soubory v `lib/core/data/repositories/*.dart`
- VŠECHNY soubory v `lib/core/sync/*.dart`
- VŠECHNY soubory v `lib/core/auth/*.dart`

**Checklist:**

- [ ] **catch typ:** Grep `catch (e` vs `catch (e, s)`. Jsou stack traces vždy zachycovány? Vypiš kde ne.
- [ ] **AppLogger vzor:** Je vždy `AppLogger.error('message', error: e, stackTrace: s)`? Vypiš odchylky.
- [ ] **Error message jazyk:** Jsou VŠECHNY error messages anglicky? Vypiš výjimky.
- [ ] **Result.Failure messages:** Jsou konzistentní ve formátu? (např. `'Failed to X: $e'`)
- [ ] **Rethrow vs swallow:** Jsou chyby konzistentně zachyceny (swallow + log + return Failure)? Nebo existují místa kde se chyba rethrowuje?
- [ ] **Empty catch bloky:** Vypiš VŠECHNY.
- [ ] **Generic exception types:** Používá se `catch (e)` konzistentně, nebo existují specifické typy (`on DatabaseException`, `on AuthException`)?

**Výstup:** Error handling pattern tabulka + seznam nekonzistencí → `/tmp/audit/phase4/C15_error_handling.md`

---

### Agent C16: Naming Conventions — Codebase-wide

**Metoda:** Grep-based analýza celého `lib/` adresáře. NEČTI celé soubory — použij grep pro hledání vzorů.

**Checklist:**

- [ ] **Soubory:** Grep pro soubory které NEJSOU `snake_case.dart`. Vypiš odchylky.
- [ ] **Třídy — Screen:** Grep `class Screen`. Je prefix konzistentní? (`Screen*` vs `*Screen` vs `Page*`)
- [ ] **Třídy — Dialog:** Grep `class Dialog`. Je prefix konzistentní? (`Dialog*` vs `*Dialog`)
- [ ] **Třídy — Widget:** Grep `class _`. Jsou private widgety pojmenované konzistentně?
- [ ] **Provider naming:** Grep `Provider`. Mají VŠECHNY suffix `Provider`?
- [ ] **Repository naming:** Grep `Repository`. Mají VŠECHNY suffix `Repository`?
- [ ] **Boolean proměnné:** Grep `bool `. Mají prefix `is`/`has`/`can`/`should`? Vypiš které ne.
- [ ] **Callback naming:** Grep `Function\??\s+on`. Mají prefix `on*`?
- [ ] **DB field naming:** Grep v repositories pro `_db` vs `db` vs `database`. Je konzistentní?
- [ ] **Enum values:** Grep pro enum definice. Jsou VŠECHNY v `camelCase`?
- [ ] **Metody vracející Stream:** Grep `Stream<`. Mají prefix `watch`?
- [ ] **Metody vracející Future:** Grep `Future<`. Je naming konzistentní? (`get*`, `create*`, `update*`, `delete*`)
- [ ] **Privátní members:** Grep `final _` a `late _`. Je `_` prefix konzistentní?

**Výstup:** Per-pravidlo seznam výjimek → `/tmp/audit/phase4/C16_naming.md`

---

**Spuštění Fáze 4:**
```
Spusť C13, C14, C15, C16 paralelně (run_in_background: true).
Počkej na dokončení VŠECH 4.
Ověř: ls -la /tmp/audit/phase4/
Pokračuj na FÁZI 5.
```

---

## FÁZE 5 — Code Quality (4 agenti paralelně)

### Agent C17: UUID + DateTime + Const — Codebase-wide

**Metoda:** Grep-based analýza celého `lib/` adresáře.

**Checklist:**

- [ ] **UUID verze:** Grep `Uuid()` a `v4()` a `v7()`. Vypiš KAŽDÝ výskyt s cestou:řádek. Je v7 standard? Kde se používá v4?
- [ ] **UUID instantiation:** Grep `const Uuid()` vs `Uuid()` (bez const). Je `const` použito konzistentně?
- [ ] **DateTime.now():** Grep `DateTime.now()`. Je voláno na správných místech? (v repositories, ne v UI/mappers)
- [ ] **Const constructors:** Grep `Widget` třídy. Mají `const` konstruktor kde je to možné?
- [ ] **Const collections:** Grep `= []` a `= {}`. Jsou `const []` a `const {}` kde je to možné?
- [ ] **Magic numbers:** Grep pro číselné literály (mimo 0, 1, 2). Jsou pojmenované jako konstanty?
- [ ] **Hardcoded paths:** Grep `File('` a `'/Users/'`. Existují absolutní cesty?
- [ ] **print():** Grep `print(`. Existují mimo AppLogger?
- [ ] **Empty catch:** Grep `catch` + hledej prázdné catch bloky.
- [ ] **TODO/FIXME:** Grep `TODO|FIXME|HACK|XXX`. Vypiš VŠECHNY s kontextem.

**Výstup:** Per-pravidlo seznam výskytů → `/tmp/audit/phase5/C17_uuid_datetime_const.md`

---

### Agent C18: Import Ordering + Class Structure

**Soubory k přečtení:** Přečti PRVNÍCH 30 řádků z 20+ klíčových souborů (rozprostřených přes celý projekt — repositories, screens, providers, models, mappers, sync, auth).

**Checklist:**

- [ ] **Import pořadí:** Je konzistentní? Doporučené: `dart:` → `package:flutter/` → `package:třetí_strana/` → `package:epos/` → relativní. Vypiš soubory kde pořadí neodpovídá.
- [ ] **Relativní vs absolutní:** Je konzistentní styl? Mix `import '../...'` a `import 'package:epos/...'`? Vypiš.
- [ ] **Třídní struktura:** Přečti 5 StatefulWidget souborů a 5 Repository souborů. Je pořadí členů konzistentní?
  - Widgety: fields → constructor → initState → dispose → build → private methods
  - Repositories: fields → constructor → public methods → private methods
- [ ] **Trailing commas:** Jsou konzistentně přítomny?
- [ ] **`part`/`part of` direktivy:** Umístěny konzistentně?

**Výstup:** Import ordering tabulka + structural consistency report → `/tmp/audit/phase5/C18_imports_structure.md`

---

### Agent C19: Statická analýza + Code Quality

**Příkazy:**
```bash
dart analyze lib/ 2>&1
```

**Checklist:**

- [ ] **dart analyze:** Zaznamenej VŠECHNY warnings a errors. Kategorizuj:
  - `error` → VYSOKÉ
  - `warning` → STŘEDNÍ
  - `info` → NÍZKÉ
- [ ] **Force unwrap `!`:** Grep `\!\.` a `\!\[` a `\!)`. Vypiš KAŽDÝ force unwrap. Je bezpečný? Existuje null check předem?
- [ ] **`as dynamic`:** Grep `as dynamic`. Vypiš KAŽDÝ s kontextem. Je nutný (Drift limitation) nebo zbytečný?
- [ ] **`late` proměnné:** Grep `late `. Vypiš KAŽDOU. Je inicializační garance jistá?
- [ ] **Dlouhé metody:** Grep pro metody delší než 80 řádků. Vypiš s počtem řádků.
- [ ] **DRY violations:** Hledej duplicitní kód v repositories (stejný pattern opakovaný 3+×). Vypiš kandidáty na extrakci.

**Výstup:** dart analyze výstup + per-pravidlo seznam nálezů → `/tmp/audit/phase5/C19_static_quality.md`

---

### Agent C20: Best Practices — Idiomatický Dart/Flutter

**Soubory k přečtení:** Přečti klíčové soubory v `lib/core/` a `lib/features/` (vybírej reprezentativní vzorky — 5 repozitářů, 5 screenů, 3 providery, 3 sync soubory).

**Dart jazyk:**
- [ ] `final` vs `var` — jsou lokální proměnné `final` kde se nemění?
- [ ] Pattern matching — jsou `switch` výrazy na enumech/sealed třídách místo `if/else`?
- [ ] Extension methods — existuje boilerplate který by šel řešit extension method?
- [ ] Collection literals — `const []`, `const {}` místo `List.empty()`?
- [ ] Cascade notation (`..`) — využita kde je to vhodné?
- [ ] Null-aware operátory — konzistentní `?.`, `??`, `??=`?
- [ ] Spread operátor (`...`) — využit pro kompozici kolekcí?
- [ ] `dynamic` kde existuje konkrétní typ — přijímají metody `dynamic` parametr zbytečně?

**Flutter specifické:**
- [ ] `const` widgety — jsou widgety bez runtime závislostí `const`?
- [ ] `StatelessWidget` vs `StatefulWidget` — existují StatefulWidgety bez mutable state?
- [ ] `BuildContext` across async gaps — `context` po `await` bez mounted checku?
- [ ] Widget decomposition — `build()` metody delší než ~100 řádků?
- [ ] Theme/color reference — barvy přes `Theme.of(context)`, ne hardcoded `Color(0xFF...)`?

**Výkon:**
- [ ] Sequential `await` v loops — `for` cykly s `await` kde by šel `Future.wait()` nebo batch?
- [ ] N+1 queries — smyčky s DB query per iteration?

**Výstup:** Per-pravidlo seznam nálezů → `/tmp/audit/phase5/C20_best_practices.md`

---

**Spuštění Fáze 5:**
```
Spusť C17, C18, C19, C20 paralelně (run_in_background: true).
Počkej na dokončení VŠECH 4.
Ověř: ls -la /tmp/audit/phase5/
Pokračuj na FÁZI 6.
```

---

## FÁZE 6 — Drift↔Supabase Cross-validation (4 agenti paralelně)

### Agent C21: Drift ↔ Supabase — Tabulky A-I

**Vstupní soubory (z fáze 0):**
- `/tmp/audit/phase0/supabase_columns_A.txt`

**Drift soubory k přečtení:** Tabulky pro: bills, categories, cash_movements, companies, company_settings, currencies, customers, customer_transactions.

**Úkol:** Pro KAŽDOU tabulku vytvoř srovnávací tabulku:

| Sloupec | Drift typ | Drift null | Supabase typ | Supabase null | Shoda? |
|---------|-----------|------------|--------------|---------------|--------|

**Pravidla shody:**
- `text()` ↔ `text`/`uuid`/`varchar`/`jsonb` = SHODA
- `integer()` ↔ `integer`/`bigint`/`smallint` = SHODA
- `real()` ↔ `double precision`/`real` = SHODA
- `boolean()` ↔ `boolean` = SHODA
- `dateTime()` ↔ `timestamp with time zone` = SHODA
- `textEnum<T>()` ↔ `USER-DEFINED` = SHODA (ale ověř enum name)
- Ignoruj: `lastSyncedAt`, `version`, `serverCreatedAt`, `serverUpdatedAt` (Drift-only)
- Ignoruj: `created_at`, `updated_at`, `client_created_at`, `client_updated_at`, `deleted_at` (Supabase sync sloupce)

**Výstup:** Per-tabulka srovnávací tabulka + seznam neshod → `/tmp/audit/phase6/C21_drift_supabase_A_I.md`

---

### Agent C22: Drift ↔ Supabase — Tabulky I-O

**Vstupní soubory:** `/tmp/audit/phase0/supabase_columns_B.txt`

**Tabulky:** items, layout_items, manufacturers, map_elements, orders, order_items.

**Úkol:** Identický s C21.

**Výstup:** → `/tmp/audit/phase6/C22_drift_supabase_I_O.md`

---

### Agent C23: Drift ↔ Supabase — Tabulky P-Z

**Vstupní soubory:**
- `/tmp/audit/phase0/supabase_columns_C.txt`
- `/tmp/audit/phase0/supabase_columns_D.txt`
- `/tmp/audit/phase0/supabase_columns_E.txt`

**Tabulky:** payments, payment_methods, permissions, product_recipes, registers, register_sessions, reservations, roles, role_permissions, sections, shifts, stock_documents, stock_levels, stock_movements, suppliers, sync_queue, tables, tax_rates, users, user_permissions, vouchers, warehouses.

**Úkol:** Identický s C21.

**Výstup:** → `/tmp/audit/phase6/C23_drift_supabase_P_Z.md`

---

### Agent C24: Supabase — RLS + Triggers + Indexes

**Vstupní soubory (z fáze 0):**
- `/tmp/audit/phase0/supabase_rls_enabled.txt`
- `/tmp/audit/phase0/supabase_rls_policies.txt`
- `/tmp/audit/phase0/supabase_triggers.txt`
- `/tmp/audit/phase0/supabase_indexes.txt`
- `/tmp/audit/phase0/supabase_fk_no_index.txt`
- `/tmp/audit/phase0/advisors_security.txt`
- `/tmp/audit/phase0/advisors_performance.txt`

**Checklist per tabulka:**

- [ ] **RLS enabled?** Vypiš tabulky kde NE.
- [ ] **SELECT policy:** Existuje? Obsahuje `company_id IN (SELECT get_my_company_ids())`? (globální tabulky mají jiný vzor)
- [ ] **INSERT policy:** Existuje s WITH CHECK?
- [ ] **UPDATE policy:** Existuje s USING + WITH CHECK?
- [ ] **DELETE policy:** NESMÍ existovat (soft-delete). Vypiš kde existuje.
- [ ] **`set_server_timestamps` trigger:** Existuje na INSERT + UPDATE?
- [ ] **`enforce_lww` trigger:** Existuje na UPDATE? (VÝJIMKY: `sync_queue`, `audit_log`)
- [ ] **Trigger naming:** Je `trg_{table}_timestamps` a `trg_{table}_lww` konzistentní?
- [ ] **`idx_{table}_company_updated` index:** Existuje na VŠECH company-scoped tabulkách?
- [ ] **FK indexes:** Mají VŠECHNY FK sloupce index?
- [ ] **Nepoužívané indexy:** Vypiš z performance advisoru.
- [ ] **Security advisors:** Vypiš VŠECHNY nálezy.

**Výstup:** Matice tabulek × checklist bodů → `/tmp/audit/phase6/C24_rls_triggers.md`

---

**Spuštění Fáze 6:**
```
Spusť C21, C22, C23, C24 paralelně (run_in_background: true).
Počkej na dokončení VŠECH 4.
Ověř: ls -la /tmp/audit/phase6/
Pokračuj na FÁZI 7.
```

---

## FÁZE 7 — Sloučení (hlavní konverzace, BEZ agentů)

### 7.1 Sběr výstupů

Přečti VŠECHNY výstupní soubory:

**Phase 1:**
- `/tmp/audit/phase1/C1_base_repos.md`
- `/tmp/audit/phase1/C2_manual_repos.md`
- `/tmp/audit/phase1/C3_entity_mappers.md`
- `/tmp/audit/phase1/C4_push_pull_mappers.md`

**Phase 2:**
- `/tmp/audit/phase2/C5_model_drift.md`
- `/tmp/audit/phase2/C6_drift_tables.md`
- `/tmp/audit/phase2/C7_sync.md`
- `/tmp/audit/phase2/C8_enums.md`

**Phase 3:**
- `/tmp/audit/phase3/C9_providers.md`
- `/tmp/audit/phase3/C10_auth_routing.md`
- `/tmp/audit/phase3/C11_ui_sell_bills.md`
- `/tmp/audit/phase3/C12_ui_auth_settings.md`

**Phase 4:**
- `/tmp/audit/phase4/C13_ui_remaining.md`
- `/tmp/audit/phase4/C14_riverpod.md`
- `/tmp/audit/phase4/C15_error_handling.md`
- `/tmp/audit/phase4/C16_naming.md`

**Phase 5:**
- `/tmp/audit/phase5/C17_uuid_datetime_const.md`
- `/tmp/audit/phase5/C18_imports_structure.md`
- `/tmp/audit/phase5/C19_static_quality.md`
- `/tmp/audit/phase5/C20_best_practices.md`

**Phase 6:**
- `/tmp/audit/phase6/C21_drift_supabase_A_I.md`
- `/tmp/audit/phase6/C22_drift_supabase_I_O.md`
- `/tmp/audit/phase6/C23_drift_supabase_P_Z.md`
- `/tmp/audit/phase6/C24_rls_triggers.md`

### 7.2 Zpracování

1. **Deduplikuj** — stejný nález od více agentů = jeden nález
2. **Seřaď** dle závažnosti (VYSOKÉ → STŘEDNÍ → NÍZKÉ)
3. **Ověř sporné nálezy** — pokud agent reportuje něco co zní jako false positive, přečti zdrojový kód a ověř
4. **Zkontroluj proti "Známé vzory — NE nález"** — vyřaď false positives
5. **Seskup** dle kategorie (Architecture, Data, Sync, Supabase, UI, Naming, Quality)

### 7.3 Finální report

Zapiš do `/tmp/audit/FINAL_REPORT.md`:

```markdown
# Consistency Audit Report

## Souhrn
Celkem zkontrolováno: X souborů, ~Y řádků kódu
24 agentů, 6 fází
Nalezeno: VYSOKÉ: X | STŘEDNÍ: X | NÍZKÉ: X

## Nálezy dle kategorie

### Architektura (Repositories, Patterns)
[nálezy]

### Data Layer (Mappers, Models, Drift)
[nálezy]

### Sync Engine
[nálezy]

### Supabase Schema (RLS, Triggers, Indexes, Drift↔Supabase)
[nálezy]

### Enumy
[nálezy]

### Auth & Routing
[nálezy]

### UI Patterns
[nálezy]

### Riverpod Patterns
[nálezy]

### Error Handling
[nálezy]

### Naming & Formatting
[nálezy]

### Code Quality & Best Practices
[nálezy]

## Quick-Fix tabulka
| # | Závažnost | Soubor:řádek | Co změnit |
```

---

## Kontrolní checklisty

### Před spuštěním (ověř)
- [ ] `/tmp/audit/` adresářová struktura existuje (phase0-6)
- [ ] VŠECHNY Supabase dotazy z fáze 0 proběhly úspěšně
- [ ] VŠECHNY výsledky zapsány do `/tmp/audit/phase0/` (14 souborů)

### Po každé fázi (ověř)
- [ ] VŠECHNY 4 výstupní soubory fáze existují
- [ ] Každý soubor má nenulovou velikost (`ls -la`)
- [ ] Žádný agent neskončil s "Context limit reached"
- [ ] Pokud agent selhal → spusť ho ZNOVU jednotlivě (ne celou fázi)

### Po sloučení (ověř)
- [ ] `/tmp/audit/FINAL_REPORT.md` existuje a je kompletní
- [ ] Sporné nálezy byly re-verifikovány čtením zdrojového kódu
- [ ] False positives vyřazeny
- [ ] Nálezy seřazeny dle závažnosti

---

## Časový odhad

- Fáze 0: ~5-10 min (SQL dotazy, setup)
- Fáze 1-6: ~3-5 min per fáze = 18-30 min
- Fáze 7: ~5-10 min (merge, verifikace)
- **Celkem: ~30-50 min**

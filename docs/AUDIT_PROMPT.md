# Audit Prompt — Kompletní analýza EPOS projektu

> Tento prompt se předává Claude Code pro provedení důkladné read-only analýzy celého projektu.
> Spouštěj na čisté konverzaci (bez předchozího kontextu).

---

## Instrukce

Proveď **kompletní, důkladnou a podrobnou analýzu** celého EPOS projektu. Analýza je čistě **READ-ONLY** — žádný kód se nemodifikuje, žádné commity, žádné migrace.

### Pravidla analýzy

1. **Čti každý soubor**, na který odkazuješ. Necituj z paměti — vždy ověř aktuální stav.
2. **Uváděj přesné cesty a čísla řádků** (`soubor:řádek`) u každého nálezu.
3. **Rozlišuj závažnost**: KRITICKÉ > VYSOKÉ > STŘEDNÍ > NÍZKÉ > INFO.
4. **U každého nálezu uveď**: co je špatně, proč je to problém, konkrétní dopad, a navrhované řešení.
5. **Porovnávej kód s dokumentací** (`PROJECT.md`, `CLAUDE.md`). Pokud se liší, popiš nesoulad — neurčuj, kdo má pravdu.
6. **Analýzu Supabase** proveď přes MCP nástroje (execute_sql, list_tables, get_advisors) — nikdy nehádej stav serveru.
7. **Spouštěj analýzy paralelně** kde je to možné (Task tool s agenty pro různé oblasti).

---

## FÁZE 1 — Sběr kontextu

Před začátkem analýzy přečti:

1. `CLAUDE.md` — pravidla pro práci s projektem
2. `PROJECT.md` — autoritativní designový dokument (čti celý, po částech pokud je velký)
3. `docs/CHANGELOG.md` — historie změn
4. `pubspec.yaml` — závislosti a verze
5. `analysis_options.yaml` — linting konfigurace
6. `.gitignore` — co je vyloučeno z gitu
7. `lib/main.dart` a `lib/app.dart` — vstupní body aplikace

Strom všech `.dart` souborů v `lib/` (přes Glob `lib/**/*.dart`).

---

## FÁZE 2 — Analýza Supabase serveru (MCP)

Pomocí Supabase MCP nástrojů proveď kompletní audit server-side:

### 2.1 Schéma a struktura
```sql
-- Všechny tabulky se sloupci
SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- Všechny custom enumy
SELECT t.typname, e.enumlabel
FROM pg_type t JOIN pg_enum e ON t.oid = e.enumtypid
ORDER BY t.typname, e.enumsortorder;

-- Všechny foreign keys
SELECT tc.table_name, kcu.column_name,
       ccu.table_name AS foreign_table,
       ccu.column_name AS foreign_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public';
```

### 2.2 Indexy a výkon
```sql
-- Všechny indexy
SELECT tablename, indexname, indexdef
FROM pg_indexes WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Velikost tabulek a indexů
SELECT relname, pg_size_pretty(pg_total_relation_size(c.oid)) as total_size
FROM pg_class c LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' AND c.relkind = 'r'
ORDER BY pg_total_relation_size(c.oid) DESC;
```

### 2.3 RLS politiky
```sql
-- Všechny RLS politiky (kompletní)
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Je RLS povoleno na všech tabulkách?
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
```

### 2.4 Triggery a funkce
```sql
-- Všechny triggery
SELECT trigger_name, event_manipulation, event_object_table, action_timing, action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- Těla trigger funkcí
SELECT p.proname, pg_get_functiondef(p.oid)
FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname IN ('set_server_timestamps', 'enforce_lww', 'get_my_company_ids')
ORDER BY p.proname;
```

### 2.5 Migrace a advisors
- `list_migrations` — seznam všech migrací
- `get_advisors(type: "security")` — bezpečnostní doporučení
- `get_advisors(type: "performance")` — výkonnostní doporučení

### 2.6 Supabase audit checklist

Pro každou tabulku ověř:
- [ ] RLS je **enabled**
- [ ] Existuje SELECT policy s `company_id IN (SELECT get_my_company_ids())`
- [ ] Existuje INSERT policy s WITH CHECK
- [ ] Existuje UPDATE policy s USING + WITH CHECK
- [ ] **Neexistuje** DELETE policy (soft-delete only)
- [ ] Existuje `set_server_timestamps` trigger (INSERT + UPDATE)
- [ ] Existuje `enforce_lww` trigger (UPDATE)
- [ ] Trigger naming je konzistentní (`trg_{table}_timestamps`, `trg_{table}_lww`)
- [ ] Existuje index `idx_{table}_company_updated` (pro sync pull)
- [ ] FK sloupce mají indexy (pokud mají FK constraint)

---

## FÁZE 3 — Analýza klienta (Flutter/Dart)

### 3.1 Architektura a vzory

Přečti a analyzuj **každý** soubor v těchto adresářích:

**Repositáře** (`lib/core/data/repositories/*.dart`):
- [ ] Dodržuje se Repository pattern? Žádný přímý DB přístup mimo repositáře?
- [ ] `BaseCompanyScopedRepository` — je správně implementován? Dědí z něj správné entity?
- [ ] Manuální outbox — jsou `_enqueue*` volání po **každé** mutaci? Nechybí nějaké?
- [ ] Result pattern — vracejí všechny veřejné metody `Result<T>`? Jsou try/catch kompletní?
- [ ] Transakce — jsou atomické operace (`createOrderWithItems`, `cancelBill` cascade) v transaction bloku?
- [ ] N+1 queries — jsou někde smyčky s await uvnitř (query per iteration)?
- [ ] Stream management — jsou `watchAll`/`watchById` správně company-scoped a filtrují `deletedAt IS NULL`?

**Mappery** (`lib/core/data/mappers/*.dart`):
- [ ] `entity_mappers.dart` — existuje `fromEntity()` a `toCompanion()` pro **každou** entitu? Porovnej s tabulkou v PROJECT.md.
- [ ] `supabase_mappers.dart` — existuje `toSupabaseJson()` pro **každou** entitu? Jsou všechny sloupce pokryty? Odesílá se `client_created_at`/`client_updated_at` (ne `created_at`/`updated_at`)?
- [ ] `supabase_pull_mappers.dart` — existuje `fromSupabasePull()` pro **každou** entitu? Nastavuje se `lastSyncedAt`, `serverCreatedAt`, `serverUpdatedAt`?
- [ ] Konzistence: pokud Drift tabulka má sloupec X, má ho i model, mapper push i mapper pull?
- [ ] Typ safety: jsou `as String`, `as int` casty ošetřeny pro null/chybějící klíče?
- [ ] Enum konverze: odpovídají Dart enum hodnoty Supabase enum hodnotám (1:1 shoda)?

**Modely** (`lib/core/data/models/*.dart`):
- [ ] Odpovídají Freezed modely sloupcům v Drift tabulkách?
- [ ] Obsahují modely **všechny** sloupce z tabulky (kromě sync sloupců které nejsou v modelu)?
- [ ] Jsou nullable/required správně? Srovnej s Drift definicí.

**Drift tabulky** (`lib/core/database/tables/*.dart`):
- [ ] Odpovídají Drift tabulky Supabase tabulkám? (srovnej sloupce, typy, nullable)
- [ ] Používají všechny doménové tabulky `SyncColumnsMixin`?
- [ ] Mají všechny tabulky `@TableIndex` pro `company_id + updatedAt`?
- [ ] Jsou enum sloupce definované jako `textEnum<T>()`?
- [ ] Jsou monetární sloupce vždy `integer()` (haléře, ne double)?

**`app_database.dart`**:
- [ ] Jsou všechny tabulky registrované v `@DriftDatabase(tables: [...])`?
- [ ] `schemaVersion` — je aktuální?

### 3.2 Sync engine

Přečti a analyzuj:
- `lib/core/sync/sync_service.dart`
- `lib/core/sync/outbox_processor.dart`
- `lib/core/sync/sync_lifecycle_manager.dart`

Checklist:
- [ ] Pull tabulky — je pořadí v `_pullTables` správné podle FK závislostí? Srovnej s Supabase FK.
- [ ] Pull tabulky — jsou **všechny** tabulky v `_pullTables`? Žádná nechybí?
- [ ] LWW logika — je `enforce_lww` trigger konzistentní s pull-side LWW v `sync_service.dart`?
- [ ] Outbox — `_isProcessing` flag brání concurrent processing?
- [ ] Outbox — `_isPermanentError` detekuje správné chybové typy?
- [ ] Outbox — stuck entries reset (processing > 5 min)?
- [ ] Outbox — completed entries cleanup (> 7 days)?
- [ ] Initial push v `sync_lifecycle_manager.dart` — pushují se globální tabulky (currencies, roles, permissions, role_permissions)?
- [ ] `enqueueAll` — mají **všechny** BaseCompanyScopedRepository potomci implementaci?
- [ ] Timer cleanup — `_pullTimer?.cancel()` a `_timer?.cancel()` v dispose/stop?
- [ ] Dynamic casty — kolik je `as dynamic` v sync kódu? Jsou bezpečné?

### 3.3 Autentizace a bezpečnost

Přečti a analyzuj:
- `lib/core/auth/pin_helper.dart`
- `lib/core/auth/auth_service.dart`
- `lib/core/auth/session_manager.dart`
- `lib/core/auth/supabase_auth_service.dart`
- `lib/core/network/supabase_config.dart`

Checklist:
- [ ] PIN hashing — jaký algoritmus? Je dostatečně silný pro 4-6 místný PIN?
- [ ] Salt — jak se generuje? Random.secure()? Dostatečná délka?
- [ ] Brute-force — progresivní lockout odpovídá dokumentaci?
- [ ] Session — volatile (RAM only)? Je to záměr nebo bug?
- [ ] Credentials — jsou Supabase URL/key hardcoded v kódu? Jsou v .gitignore?
- [ ] PIN hash sync — posílají se PIN hashe na server? Pokud ano, proč?
- [ ] Password validation — jaká je minimální délka/komplexita pro Supabase auth?
- [ ] Token expiration — jaký je JWT expiration time?
- [ ] Leaked password protection — je zapnutá nebo vypnutá? Je to dokumentováno?

### 3.4 UI vrstva

Přečti a analyzuj **každý** screen a widget:
- `lib/features/auth/screens/screen_login.dart`
- `lib/features/bills/screens/screen_bills.dart`
- `lib/features/bills/widgets/*.dart` (všechny dialogy)
- `lib/features/sell/screens/screen_sell.dart`
- `lib/features/onboarding/screens/*.dart`
- `lib/features/settings/screens/*.dart`
- `lib/features/settings/widgets/*.dart`

Checklist:
- [ ] **Business logika v UI** — je v screen/widget souboru kalkulace, agregace, nebo logika, která patří do repositáře?
- [ ] **Hardcoded stringy** — jsou všechny UI texty přes `context.l10n`?
- [ ] **Error states** — rozlišuje se loading vs error v `AsyncValue.when()`? Nebo error zobrazuje spinner?
- [ ] **Mounted checks** — je před každým `setState()` po await kontrola `if (!mounted) return`?
- [ ] **Dispose** — má každý StatefulWidget s controllery/timery `dispose()` metodu?
- [ ] **Touch targets** — jsou všechny buttony >= 40px výška?
- [ ] **Chip/button bars** — dodržuje se pattern z CLAUDE.md (Expanded + SizedBox)?
- [ ] **N+1 v UI** — jsou ve widgetech smyčky s await (query per row)?
- [ ] **Permission checks** — jsou akce chráněné `hasPermissionProvider`?
- [ ] **Direct DB access** — volá UI přímo `appDatabaseProvider` místo repositáře?
- [ ] **Processing guard** — mají tlačítka s async akcemi ochranu proti double-tap?
- [ ] **Dialog width** — jsou šířky dialogů konzistentní?
- [ ] **Semantic labels** — mají IconButtony `semanticLabel` pro accessibility?

### 3.5 Providery a state management

Přečti: `lib/core/data/providers/*.dart`

- [ ] Circular dependencies — závisí providerA na providerB a naopak?
- [ ] `ref.onDispose()` — mají providery s timery/streams/subscriptions cleanup?
- [ ] `appInitProvider` — je inicializační logika kompletní a v správném pořadí?
- [ ] `activeRegisterProvider` / `activeRegisterSessionProvider` — jsou správně invalidovány při změně stavu?

### 3.6 Routing

Přečti: `lib/core/routing/app_router.dart`

- [ ] Auth guard — je redirect logika kompletní? Pokrývá všechny stavy (no company, no user, no session)?
- [ ] `/dev` route — je chráněná `kDebugMode` nebo permission checkem?
- [ ] Redirect loops — může nastat nekonečný redirect?

### 3.7 Kvalita kódu

- [ ] `print()` — existují volání `print()` mimo AppLogger? (Grep: `print(`)
- [ ] Empty catch — existují prázdné `catch` bloky? (Grep: `catch.*\{\s*\}`)
- [ ] TODO/FIXME — kolik jich je a jsou relevantní? (Grep: `TODO|FIXME|HACK|XXX`)
- [ ] Unused imports — detekuje linter nepoužité importy?
- [ ] `as dynamic` — kolik unsafe castů existuje? Kde jsou nejvíc koncentrované?
- [ ] `!` force unwrap — kolik force unwrapů existuje? Jsou bezpečné?
- [ ] Const constructors — jsou widgety bez parametrů označené `const`?
- [ ] Generated code — je `app_database.g.dart` a `*.freezed.dart` aktuální vůči zdrojům?

### 3.8 Testy

- [ ] Existují unit testy? Kolik jich je?
- [ ] Existují widget testy? Kolik jich je?
- [ ] Existují integration testy?
- [ ] Jaké je pokrytí kritických cest (sync, LWW, outbox, auth)?

---

## FÁZE 4 — Křížová validace (Drift ↔ Supabase ↔ Modely ↔ Mappery)

Pro **každou** z 22 tabulek vytvoř srovnávací tabulku:

| Sloupec | Drift typ | Drift nullable | Supabase typ | Supabase nullable | Model field | Push mapper | Pull mapper | Shoda? |
|---------|-----------|----------------|--------------|-------------------|-------------|-------------|-------------|--------|

Hledej:
- Sloupec existuje v Drift ale ne v Supabase (nebo naopak)
- Sloupec je nullable v jednom ale NOT NULL v druhém
- Typ mismatch (text vs integer, enum vs text)
- Sloupec chybí v modelu
- Sloupec chybí v push/pull mapperu
- Enum hodnoty se liší mezi Dart a Supabase

---

## FÁZE 5 — Dokumentace vs implementace

Porovnej `PROJECT.md` s aktuální implementací:

- [ ] Tabulky v PROJECT.md — existují všechny v Drift i Supabase?
- [ ] Sloupce v PROJECT.md — sedí typy, nullable, defaults?
- [ ] Workflows (createBill, cancelBill, recordPayment) — odpovídá implementace popisu?
- [ ] Enum hodnoty — sedí Dart enum, Supabase enum, a dokumentace?
- [ ] Route paths — sedí routes v `app_router.dart` s dokumentací?
- [ ] Permission kódy — sedí seed s dokumentací? Je jich přesně 14?
- [ ] Role šablony — sedí helper/operator/admin oprávnění s tabulkou v docs?
- [ ] Seed data — odpovídá SeedService dokumentaci (3 tax rates, 3 payment methods, 3 sections, 5 categories, 25 items)?

---

## FÁZE 6 — Výstupní zpráva

Strukturuj výsledky takto:

### A. Executive Summary
- 3-5 vět o celkovém stavu projektu
- Počet nálezů per závažnost
- Top 3 rizika

### B. Nálezy per oblast

Pro každou oblast (Supabase, Architektura, Bezpečnost, Sync, UI, Kvalita kódu):

```
### [ZÁVAŽNOST] Název nálezu
**Soubor:** `cesta/soubor.dart:řádek`
**Popis:** Co je špatně.
**Dopad:** Proč je to problém (konkrétní scénář).
**Řešení:** Jak to opravit (konkrétní kroky).
```

### C. Dokumentace vs kód — nesoulady
Tabulka nesouladů s odkazem na PROJECT.md a na konkrétní kód.

### D. Drift ↔ Supabase ↔ Model ↔ Mapper matice
Kompletní srovnávací tabulka (pouze řádky kde je nesoulad).

### E. Supabase RLS/Trigger audit
Tabulka per tabulka: co chybí, co je špatně, co je nekonzistentní.

### F. Pozitivní nálezy
Co je implementováno dobře a správně.

### G. Prioritizovaný akční plán
Seřazený seznam nálezů k opravě (KRITICKÉ → NÍZKÉ) s odhadem rozsahu (1 řádek / 1 soubor / více souborů / architekturální změna).

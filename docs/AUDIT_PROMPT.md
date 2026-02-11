# Audit Prompt — Kompletní analýza EPOS projektu (Triple Redundancy)

> Tento prompt se předává Claude Code pro provedení důkladné read-only analýzy celého projektu.
> Spouštěj na čisté konverzaci (bez předchozího kontextu).

---

## Architektura auditu — Trojitá redundance

Audit používá architekturu **Triple Modular Redundancy (TMR)** pro maximální spolehlivost:

```
┌─────────────────────────────────────────────────────┐
│                  FÁZE 0 — Prerekvizity              │
│         (hlavní konverzace, jednorázově)             │
│  Supabase project ID, git status, cesty k docs      │
└──────────────────────┬──────────────────────────────┘
                       │
        ┌──────────────┼──────────────────┐
        ▼              ▼                  ▼
┌──────────────┐┌──────────────┐┌──────────────┐
│   AGENT α    ││   AGENT β    ││   AGENT γ    │
│              ││              ││              │
│  IDENTICKÁ   ││  IDENTICKÁ   ││  IDENTICKÁ   │
│  kompletní   ││  kompletní   ││  kompletní   │
│  analýza     ││  analýza     ││  analýza     │
│              ││              ││              │
│ (může použít ││ (může použít ││ (může použít │
│  vlastní     ││  vlastní     ││  vlastní     │
│  podagenty)  ││  podagenty)  ││  podagenty)  │
└──────┬───────┘└──────┬───────┘└──────┬───────┘
       │               │               │
       ▼               ▼               ▼
┌─────────────────────────────────────────────────────┐
│              FÁZE SLOUČENÍ — Merge & Diff            │
│                 (hlavní konverzace)                   │
│                                                      │
│  1. Sloučit nálezy ze všech 3 agentů                │
│  2. Identifikovat shody (≥2/3 = potvrzený nález)   │
│  3. Identifikovat rozpory (nález jen u 1 agenta)    │
│  4. Re-verifikovat sporné nálezy                     │
│  5. Vyhodnotit kvalitu analýzy každého agenta        │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│           FINÁLNÍ REPORT + Confidence Score          │
└─────────────────────────────────────────────────────┘
```

### Klíčové principy TMR

1. **Identický scope** — Všichni 3 agenti provádějí **tutéž kompletní analýzu** (FÁZE 1–5). Žádné dělení práce mezi agenty.
2. **Nezávislost** — Agenti nevidí výsledky ostatních. Každý pracuje izolovaně.
3. **Vlastní podagenti** — Každý agent MŮŽE (a měl by) spouštět vlastní podagenty pro paralelizaci své práce (např. repos+sync, UI, auth, quality). Vnitřní organizace je na každém agentovi.
4. **Supabase MCP** — Každý agent má přístup k MCP nástrojům a provádí vlastní Supabase analýzu nezávisle.
5. **Sloučení až na konci** — Hlavní konverzace sloučí výsledky teprve po dokončení všech 3 agentů.

### Jak spustit 3 agenty

Spusť **v jednom kroku** 3 background agenty (Task tool, `run_in_background: true`). Každý dostane identický prompt obsahující:

- Kompletní instrukce (pravidla analýzy, verifikační protokol)
- Všechny fáze (FÁZE 1–5)
- Supabase project ID (zjištěné v FÁZI 0)
- Identifikátor agenta (α / β / γ) — pouze pro rozlišení ve výstupu

**Prompt pro každého agenta musí být shodný** (kromě identifikátoru). Agent si sám rozhodne, jak svou práci interně organizuje.

---

## FÁZE 0 — Prerekvizity (hlavní konverzace)

Před spuštěním agentů:

1. **Supabase project ID** — zjisti z `lib/core/network/supabase_config.dart`
2. **Git status** — `git status` a `git log --oneline -10`
3. **Cesta k PROJECT.md** — ověř skutečnou cestu (Glob `**/PROJECT.md`)
4. Tyto informace předej do promptu všem 3 agentům.

---

## Instrukce pro agenty (α, β, γ) — Kompletní analýza

> Následující instrukce tvoří prompt, který dostane každý z 3 agentů.
> Hlavní konverzace je zkopíruje do Task tool promptu pro každého agenta.

---

### Pravidla analýzy

Proveď **kompletní, důkladnou a podrobnou analýzu** celého EPOS projektu. Analýza je čistě **READ-ONLY** — žádný kód se nemodifikuje, žádné commity, žádné migrace.

1. **Čti každý soubor**, na který odkazuješ. Necituj z paměti — vždy ověř aktuální stav.
2. **Uváděj přesné cesty a čísla řádků** (`soubor:řádek`) u každého nálezu.
3. **Rozlišuj závažnost**: KRITICKÉ > VYSOKÉ > STŘEDNÍ > NÍZKÉ > INFO.
4. **U každého nálezu uveď**: co je špatně, proč je to problém, konkrétní dopad, a navrhované řešení.
5. **Porovnávej kód s dokumentací** (`PROJECT.md`, `CLAUDE.md`). Každý rozpor mezi kódem a dokumentací je **nález** — reportuj jako STŘEDNÍ+ závažnost. Neurčuj, kdo má pravdu (kód nebo docs), ale jasně popiš co se liší a kde.
6. **Analýzu Supabase** proveď přes MCP nástroje (execute_sql, list_tables, get_advisors) — nikdy nehádej stav serveru.
7. **Spouštěj podagenty** pro paralelizaci vlastní práce kde je to efektivní (viz doporučené rozdělení podagentů).

### Verifikační protokol (POVINNÝ)

Každý nález **MUSÍ** projít verifikací před zařazením do reportu. Cílem je eliminovat falešné nálezy.

**Postup pro každý potenciální nález:**

1. **Znovu přečti primární zdroj** — znovu otevři soubor a přečti konkrétní řádky. Nespoléhej na to, co sis přečetl dříve nebo co máš v paměti.
2. **Ověř protistranu** — pokud tvrdíš „sloupec X chybí v Supabase", spusť SQL dotaz a ověř, že sloupec skutečně neexistuje. Pokud tvrdíš „mapper neposílá pole Y", přečti mapper znovu a hledej pole pod všemi možnými názvy (camelCase, snake_case, aliasy).
3. **Zvaž kontext a záměr** — je to skutečně bug, nebo záměrné designové rozhodnutí? Příklady:
   - Drift `text()` pro UUID sloupec = standardní praxe v SQLite (ne bug)
   - Chybějící FK constraints = může být záměr pro offline-first sync
   - `public` role s `get_my_company_ids()` = funguje stejně jako `authenticated` pokud funkce volá `auth.uid()`
   - Sloupce `lastSyncedAt`, `version` pouze v Drift = local-only sync metadata (ne chybějící na serveru)
4. **Ověř kompletní řetězec** — pokud reportuješ problém v mapperu, ověř i Drift tabulku, model, Supabase schéma a druhý mapper. Problém může být na jiném místě než se zdá.
5. **Rozliš „nefunkční" vs „neoptimální"** — KRITICKÉ = crash nebo data loss. Neoptimální index ≠ KRITICKÉ.

**U každého nálezu v reportu uveď:**

```
### [ZÁVAŽNOST] Název nálezu
**Verifikace:** Jak jsem ověřil, že jde o skutečný problém (ne domněnku).
**Důkaz:** Přesná citace kódu/SQL výsledku, který problém potvrzuje.
**Soubor:** `cesta/soubor.dart:řádek`
**Popis:** Co je špatně.
**Dopad:** Proč je to problém (konkrétní scénář).
**Řešení:** Jak to opravit (konkrétní kroky).
```

**Pokud si nejsi 100% jistý**, zda jde o skutečný problém:
- Sniž závažnost o jeden stupeň
- Přidej poznámku „VYŽADUJE RUČNÍ OVĚŘENÍ" s popisem, co přesně ověřit
- Nikdy nehlásaj KRITICKÉ bez důkazu

### Doporučené rozdělení podagentů (interní pro každého agenta)

Každý agent (α/β/γ) si MŮŽE svou práci interně rozdělit na podagenty. Doporučené rozdělení:

1. **Podagent: Repositories + Sync + Mappers** — FÁZE 3.1, 3.2, mappers
2. **Podagent: Auth + Security + Routing + Providers** — FÁZE 3.3, 3.5, 3.6, seed service
3. **Podagent: UI (všechny screeny a widgety)** — FÁZE 3.4
4. **Podagent: Code quality + Drift tabulky** — FÁZE 3.7, 3.8, Drift table definitions

FÁZE 2 (Supabase MCP) a FÁZE 4 (křížová validace) by měl agent provádět přímo (ne v podagentech), protože vyžadují koordinaci dat.

### Priorita při nedostatku kontextu

Pokud hrozí vyčerpání kontextu, upřednostni:

1. FÁZE 4 (křížová validace Drift ↔ Supabase) — zde se nalézají nejkritičtější bugy
2. FÁZE 2 (Supabase server) — nelze ověřit z kódu
3. FÁZE 3.2 (sync engine) — nejkomplexnější logika
4. FÁZE 3.1 (repositories + mappers) — second most critical
5. Zbytek

---

### FÁZE 1 — Sběr kontextu

Přečti:

1. `CLAUDE.md` — pravidla pro práci s projektem
2. `PROJECT.md` — autoritativní designový dokument (čti celý, po částech pokud je velký)
3. `docs/CHANGELOG.md` — historie změn
4. `pubspec.yaml` — závislosti a verze
5. `analysis_options.yaml` — linting konfigurace
6. `.gitignore` — co je vyloučeno z gitu
7. `lib/main.dart` a `lib/app.dart` — vstupní body aplikace

Strom všech `.dart` souborů v `lib/` (přes Glob `lib/**/*.dart`).

---

### FÁZE 2 — Analýza Supabase serveru (MCP)

Pomocí Supabase MCP nástrojů proveď kompletní audit server-side:

#### 2.1 Schéma a struktura
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

#### 2.2 Indexy a výkon
```sql
-- Všechny indexy
SELECT tablename, indexname, indexdef
FROM pg_indexes WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- FK sloupce bez indexu (výkonnostní problém)
SELECT tc.table_name, kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public'
  AND NOT EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE tablename = tc.table_name
      AND indexdef LIKE '%' || kcu.column_name || '%'
  );
```

#### 2.3 RLS politiky
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

#### 2.4 Triggery a funkce
```sql
-- Všechny triggery
SELECT trigger_name, event_manipulation, event_object_table, action_timing, action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- Tabulky BEZ enforce_lww triggeru
SELECT t.tablename FROM pg_tables t
WHERE t.schemaname = 'public'
  AND t.tablename NOT IN (
    SELECT event_object_table FROM information_schema.triggers
    WHERE trigger_name LIKE '%lww%'
  );

-- Tabulky BEZ set_server_timestamps triggeru
SELECT t.tablename FROM pg_tables t
WHERE t.schemaname = 'public'
  AND t.tablename NOT IN (
    SELECT event_object_table FROM information_schema.triggers
    WHERE trigger_name LIKE '%timestamps%'
  );

-- Těla trigger funkcí
SELECT p.proname, pg_get_functiondef(p.oid)
FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname IN ('set_server_timestamps', 'enforce_lww', 'get_my_company_ids')
ORDER BY p.proname;
```

#### 2.5 Migrace a advisors
- `list_migrations` — seznam všech migrací
- `get_advisors(type: "security")` — bezpečnostní doporučení
- `get_advisors(type: "performance")` — výkonnostní doporučení

#### 2.6 Supabase audit checklist

Pro každou tabulku ověř (globální tabulky jako currencies, roles, permissions, role_permissions mají odlišná pravidla — typicky `true` pro authenticated):

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

### FÁZE 3 — Analýza klienta (Flutter/Dart)

#### 3.1 Architektura a vzory

Přečti a analyzuj **každý** soubor v těchto adresářích:

**Repositáře** (`lib/core/data/repositories/*.dart`):
- [ ] Dodržuje se Repository pattern? Žádný přímý DB přístup mimo repositáře?
- [ ] `BaseCompanyScopedRepository` — je správně implementován? Dědí z něj správné entity?
- [ ] `getById()` — validuje company_id scope, nebo vrací entitu jakékoli firmy bez ověření?
- [ ] Manuální outbox — jsou `_enqueue*` volání po **každé** mutaci? Nechybí nějaké?
- [ ] `Company.create()` — enqueueuje do outboxu? (zvláštní případ — není BaseCompanyScoped)
- [ ] Result pattern — vracejí všechny veřejné metody `Result<T>`? Jsou try/catch kompletní?
- [ ] Transakce — jsou atomické operace (`createOrderWithItems`, `cancelBill` cascade) v transaction bloku?
- [ ] N+1 queries — jsou někde smyčky s await uvnitř (query per iteration)?
- [ ] Stream management — jsou `watchAll`/`watchById` správně company-scoped a filtrují `deletedAt IS NULL`?

**Mappery** (`lib/core/data/mappers/*.dart`):
- [ ] `entity_mappers.dart` — existuje `fromEntity()` a `toCompanion()` pro **každou** entitu? Porovnej s tabulkou v PROJECT.md.
- [ ] `supabase_mappers.dart` — existuje `toSupabaseJson()` pro **každou** entitu? Jsou všechny sloupce pokryty? Odesílá se `client_created_at`/`client_updated_at` (ne `created_at`/`updated_at`)?
- [ ] `supabase_pull_mappers.dart` — existuje `fromSupabasePull()` pro **každou** entitu? Nastavuje se `lastSyncedAt`, `serverCreatedAt`, `serverUpdatedAt`?
- [ ] **Enum safety** — je `firstWhere` v enum konverzích volán s `orElse`? Bez něj crash na neznámém enum value ze serveru.
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
- [ ] Existují hardcoded absolutní cesty (např. `File('/Users/...')` v `_openConnection`)?

#### 3.2 Sync engine

Přečti a analyzuj:
- `lib/core/sync/sync_service.dart`
- `lib/core/sync/outbox_processor.dart`
- `lib/core/sync/sync_lifecycle_manager.dart`

Checklist:
- [ ] Pull tabulky — je pořadí v `_pullTables` správné podle FK závislostí? Srovnej s Supabase FK.
- [ ] Pull tabulky — jsou **všechny** tabulky v `_pullTables`? Žádná nechybí?
- [ ] Pull tabulky — jsou v `_pullTables` tabulky, které **neexistují** na Supabase? (crash risk)
- [ ] LWW logika — je `enforce_lww` trigger konzistentní s pull-side LWW v `sync_service.dart`?
- [ ] Outbox — `_isProcessing` flag brání concurrent processing?
- [ ] Outbox — `_isPermanentError` detekuje správné chybové typy?
- [ ] Outbox — stuck entries reset (processing > 5 min)?
- [ ] Outbox — completed entries cleanup (> 7 days)?
- [ ] Initial push v `sync_lifecycle_manager.dart` — pushují se globální tabulky (currencies, roles, permissions, role_permissions)?
- [ ] Initial push — pushují se tabulky, jejichž Supabase schéma se liší od Drift? (push fail risk)
- [ ] `enqueueAll` — mají **všechny** BaseCompanyScopedRepository potomci implementaci?
- [ ] Timer cleanup — `_pullTimer?.cancel()` a `_timer?.cancel()` v dispose/stop?
- [ ] Dynamic casty — kolik je `as dynamic` v sync kódu? Jsou bezpečné?

#### 3.3 Autentizace a bezpečnost

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

#### 3.4 UI vrstva

Přečti a analyzuj **každý** screen a widget:
- `lib/features/auth/screens/screen_login.dart`
- `lib/features/bills/screens/screen_bills.dart`
- `lib/features/bills/widgets/*.dart` (všechny dialogy)
- `lib/features/bills/services/*.dart` (services volané z UI)
- `lib/features/sell/screens/screen_sell.dart`
- `lib/features/onboarding/screens/*.dart`
- `lib/features/settings/screens/*.dart`
- `lib/features/settings/widgets/*.dart`

Checklist:
- [ ] **Business logika v UI** — je v screen/widget souboru kalkulace, agregace, nebo logika, která patří do repositáře/service?
- [ ] **Hardcoded stringy** — jsou všechny UI texty přes `context.l10n`?
- [ ] **Error states** — rozlišuje se loading vs error v `AsyncValue.when()`? Nebo error zobrazuje spinner?
- [ ] **Mounted checks** — je před každým `setState()` po await kontrola `if (!mounted) return`?
- [ ] **Dispose** — má každý StatefulWidget s controllery/timery `dispose()` metodu?
- [ ] **Touch targets** — jsou všechny buttony >= 40px výška?
- [ ] **Chip/button bars** — dodržuje se pattern z CLAUDE.md (Expanded + SizedBox)?
- [ ] **N+1 v UI** — jsou ve widgetech smyčky s await (query per row)?
- [ ] **Permission checks** — jsou akce chráněné `hasPermissionProvider`?
- [ ] **Direct DB/Supabase access** — volá UI přímo `appDatabaseProvider` nebo `Supabase.instance.client` místo repositáře?
- [ ] **Processing guard** — mají tlačítka s async akcemi ochranu proti double-tap?
- [ ] **FutureBuilder** — je future vytvořen v `initState`, nebo inline v `build()`? (Inline = recreated on every rebuild)
- [ ] **Dialog width** — jsou šířky dialogů konzistentní?

#### 3.5 Providery a state management

Přečti: `lib/core/data/providers/*.dart`

- [ ] Circular dependencies — závisí providerA na providerB a naopak?
- [ ] `ref.onDispose()` — mají providery s timery/streams/subscriptions cleanup?
- [ ] `appInitProvider` — je inicializační logika kompletní a v správném pořadí?
- [ ] `activeRegisterProvider` / `activeRegisterSessionProvider` — jsou správně invalidovány při změně stavu?

#### 3.6 Routing

Přečti: `lib/core/routing/app_router.dart`

- [ ] Auth guard — je redirect logika kompletní? Pokrývá všechny stavy (no company, no user, no session)?
- [ ] `/dev` route — je chráněná `kDebugMode` nebo permission checkem?
- [ ] Redirect loops — může nastat nekonečný redirect?

#### 3.7 Kvalita kódu

- [ ] `print()` — existují volání `print()` mimo AppLogger? (Grep: `print(`)
- [ ] Empty catch — existují prázdné `catch` bloky? (Grep: `catch.*\{\s*\}`)
- [ ] TODO/FIXME — kolik jich je a jsou relevantní? (Grep: `TODO|FIXME|HACK|XXX`)
- [ ] Unused imports — detekuje linter nepoužité importy?
- [ ] `as dynamic` — kolik unsafe castů existuje? Kde jsou nejvíc koncentrované?
- [ ] `!` force unwrap — kolik force unwrapů existuje? Jsou bezpečné?
- [ ] Const constructors — jsou widgety bez parametrů označené `const`?
- [ ] Generated code — je `app_database.g.dart` a `*.freezed.dart` aktuální vůči zdrojům?
- [ ] Hardcoded absolutní cesty — existují `File('/Users/...')` nebo podobné? (Grep: `File('`)

#### 3.8 Testy

- [ ] Existují unit testy? Kolik jich je?
- [ ] Existují widget testy? Kolik jich je?
- [ ] Existují integration testy?
- [ ] Jaké je pokrytí kritických cest (sync, LWW, outbox, auth)?
- [ ] Pokud testy neexistují: které oblasti jsou **nejkritičtější** pokrýt? (prioritizovaný seznam)

---

### FÁZE 4 — Křížová validace (Drift ↔ Supabase ↔ Modely ↔ Mappery)

#### Krok 1: Porovnej seznamy tabulek

Jako **první krok** než začneš per-column srovnání:

1. Vypiš **VŠECHNY** tabulky z Drift (`app_database.dart` — `@DriftDatabase(tables: [...])`)
2. Vypiš **VŠECHNY** tabulky ze Supabase (MCP `list_tables` nebo `information_schema.tables`)
3. Porovnej oba seznamy — hledej tabulky, které existují **POUZE na jedné straně**
4. Tabulky pouze v Drift = **KRITICKÉ** (sync pull/push crash)
5. Tabulky pouze v Supabase = **VYSOKÉ** (data se nesynchronizují)

Pozn: `sync_queue` a `sync_metadata` jsou infrastrukturní tabulky. Existují na obou stranách ale mají odlišné schéma — porovnej je zvlášť.

#### Krok 2: Per-column srovnání

Pro **každou sdílenou** tabulku:

1. Vypiš seznam sloupců z Drift (`.dart` soubor, bez sync sloupců z mixinu)
2. Vypiš seznam sloupců ze Supabase (`information_schema.columns`, bez server sync sloupců `created_at`, `updated_at`, `client_created_at`, `client_updated_at`, `deleted_at`)
3. Porovnej — hledej sloupce přítomné **POUZE na jedné straně** (KRITICKÉ)
4. Pro společné sloupce vytvoř srovnávací tabulku:

| Sloupec | Drift typ | Drift nullable | Supabase typ | Supabase nullable | Model field | Push mapper | Pull mapper | Shoda? |
|---------|-----------|----------------|--------------|-------------------|-------------|-------------|-------------|--------|

#### Krok 3: Hledej nesoulady

- Sloupec existuje v Drift ale ne v Supabase (nebo naopak) → **KRITICKÉ**
- Tabulka existuje v Drift ale ne v Supabase (nebo naopak) → **KRITICKÉ**
- Sloupec je nullable v jednom ale NOT NULL v druhém
- Typ mismatch (text vs uuid, text vs integer, real vs integer, enum vs text)
- Sloupec chybí v modelu
- Sloupec chybí v push/pull mapperu
- Enum hodnoty se liší mezi Dart a Supabase

---

### FÁZE 5 — Dokumentace vs implementace

**Každý rozpor je nález.** Pokud kód dělá něco jiného než říká dokumentace, nebo dokumentace popisuje něco co v kódu neexistuje (nebo naopak), reportuj jako nález se závažností dle dopadu.

#### 5.1 Analýza PROJECT.md

Přečti `PROJECT.md` **celý** (po částech). Pro každou sekci hledej:

**Schéma a tabulky:**
- [ ] Tabulky v PROJECT.md — existují všechny v Drift i Supabase?
- [ ] Existují tabulky v kódu, které **nejsou** v dokumentaci? (např. přidané v nedávných taskech ale docs neaktualizovány)
- [ ] Sloupce v PROJECT.md — sedí typy, nullable, defaults s Drift a Supabase?
- [ ] Počet tabulek — sedí číslo uvedené v docs s realitou?

**Enum definice:**
- [ ] Enum hodnoty v PROJECT.md — sedí s Dart enum definicemi v `lib/core/data/enums/`?
- [ ] Enum hodnoty v PROJECT.md — sedí se Supabase `pg_enum` hodnotami?
- [ ] Pořadí a pojmenování — je konzistentní napříč všemi třemi zdroji?

**Workflows a business logika:**
- [ ] Workflows (createBill, cancelBill, recordPayment, refundBill) — odpovídá implementace v repositories popisu v docs?
- [ ] Pořadí kroků ve workflow — sedí s kódem?
- [ ] Edge cases popsané v docs — jsou ošetřeny v kódu?

**Seed data a konfigurace:**
- [ ] Seed data — odpovídá `SeedService` dokumentaci (3 tax rates, 3 payment methods, 3 sections, 5 categories, 25 items)?
- [ ] Permission kódy — sedí seed s dokumentací? Je jich přesně 14?
- [ ] Role šablony — sedí helper/operator/admin oprávnění s tabulkou v docs?

**UI a routing:**
- [ ] Route paths — sedí routes v `app_router.dart` s dokumentací?
- [ ] Screen layouts popsané v docs — odpovídají implementaci?

**Architektura:**
- [ ] Popisuje docs patterny (Repository, Outbox, LWW), které kód nedodržuje?
- [ ] Odkazuje docs na soubory/třídy, které neexistují?
- [ ] Popisuje docs funkce/features, které nejsou implementované (bez označení jako "plánované")?

#### 5.2 Analýza CLAUDE.md

- [ ] Sedí pravidla v CLAUDE.md s realitou? (např. cesty k souborům, konvence)
- [ ] Odkazuje CLAUDE.md na `docs/PROJECT.md` ale soubor je jinde?
- [ ] Jsou v CLAUDE.md pravidla, která kód systematicky porušuje?

---

### Výstupní formát agenta

Každý agent vrátí svůj report ve strukturovaném formátu:

```
# REPORT AGENTA [α/β/γ]

## Souhrn
- Celkový počet nálezů: X
- KRITICKÉ: X | VYSOKÉ: X | STŘEDNÍ: X | NÍZKÉ: X | INFO: X

## Nálezy

### [ZÁVAŽNOST] Název nálezu
**ID:** [α/β/γ]-001 (unikátní ID pro pozdější křížové srovnání)
**Verifikace:** ...
**Důkaz:** ...
**Soubor:** `cesta/soubor.dart:řádek`
**Popis:** ...
**Dopad:** ...
**Řešení:** ...

(opakuj pro každý nález)

## Dokumentace vs kód — nesoulady
(tabulka)

## Drift ↔ Supabase matice
(tabulka, pouze řádky s nesouladem)

## Supabase RLS/Trigger audit
(tabulka per tabulka)

## Pozitivní nálezy
(co funguje správně)
```

---

## FÁZE SLOUČENÍ — Merge & Diff (hlavní konverzace)

Po dokončení všech 3 agentů hlavní konverzace provede:

### S1. Sběr výsledků

Přečti výstup všech 3 agentů. Pro každý nález zaznamenej:
- ID nálezu
- Závažnost
- Soubor a řádek
- Stručný popis

### S2. Klasifikace nálezů

Každý nález zařaď do jedné z kategorií:

| Kategorie | Definice | Akce |
|-----------|----------|------|
| **POTVRZENÝ (3/3)** | Všichni 3 agenti reportují totéž | Přijmout. Použít nejvyšší závažnost ze tří. |
| **VĚTŠINOVÝ (2/3)** | 2 agenti reportují, 1 ne | Přijmout, ale re-verifikovat detaily. Poznámka: „1 agent nereportoval". |
| **SPORNÝ (1/3)** | Pouze 1 agent reportuje | **POVINNÁ RE-VERIFIKACE** — hlavní konverzace musí nezávisle ověřit. |
| **KONFLIKTNÍ** | Agenti reportují protichůdné závěry | **POVINNÁ RE-VERIFIKACE** — hlavní konverzace rozhodne a zdůvodní. |

### S3. Re-verifikace sporných nálezů

Pro každý SPORNÝ nebo KONFLIKTNÍ nález:

1. Přečti primární zdroj (soubor, SQL dotaz)
2. Rozhodni: skutečný problém / falešný nález / nerozhodnutelné
3. Zaznamenej verdikt s odůvodněním

### S4. Vyhodnocení kvality agentů

Porovnej výkon jednotlivých agentů:

| Metrika | Agent α | Agent β | Agent γ |
|---------|---------|---------|---------|
| Celkový počet nálezů | | | |
| Falešné nálezy (false positives) | | | |
| Propuštěné nálezy (false negatives) | | | |
| Přesnost závažnosti | | | |
| Kvalita verifikace | | | |
| Kvalita řešení | | | |

### S5. Analýza rozporů

Pro každý případ kde se agenti neshodli, uveď:
- Co konkrétně se lišilo
- Proč se pravděpodobně lišilo (různá interpretace, přehlédnutí, odlišný kontext)
- Jaký je správný závěr

---

## FINÁLNÍ REPORT

Výsledný report kombinuje sloučené nálezy:

### A. Executive Summary
- 3-5 vět o celkovém stavu projektu
- Počet nálezů per závažnost
- Top 3 rizika
- **Confidence score** — % nálezů potvrzených ≥2/3 agenty

### B. Nálezy per oblast (sloučené)

Pro každou oblast (Supabase, Architektura, Bezpečnost, Sync, UI, Kvalita kódu):

```
### [ZÁVAŽNOST] Název nálezu
**Shoda agentů:** 3/3 | 2/3 | 1/3 (re-verifikováno)
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
Seřazený seznam nálezů k opravě (KRITICKÉ → NÍZKÉ) s odhadem rozsahu.

### H. Quick-Fix Reference
Tabulka 5 nejkritičtějších nálezů s přesnými soubory a řádky:

| # | Soubor:řádek | Co změnit | Rozsah | Shoda |
|---|-------------|-----------|--------|-------|

### I. Analýza rozporů mezi agenty
Tabulka všech případů kde se agenti neshodli, s finálním verdiktem.

### J. Vyhodnocení kvality agentů
Tabulka metrik pro každého agenta (viz S4).

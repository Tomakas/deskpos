PROVEĎ následující audit projektu.

### Architektura auditu — Trojitá redundance

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
│ (MUSÍ použít ││ (MUSÍ použít ││ (MUSÍ použít │
│  vlastní     ││  vlastní     ││  vlastní     │
│  podagenty)  ││  podagenty)  ││  podagenty)  │
└──────┬───────┘└──────┬───────┘└──────┬───────┘
       │               │               │
       ▼               ▼               ▼
┌─────────────────────────────────────────────────────┐
│          FÁZE SLOUČENÍ — Merge & Verify              │
│                 (hlavní konverzace)                   │
│                                                      │
│  1. Sloučit a deduplikovat nálezy ze všech 3 agentů │
│  2. KAŽDÝ nález (i od 1 agenta) nezávisle           │
│     re-verifikovat čtením zdrojového kódu / SQL     │
│  3. Potvrzené → do reportu                          │
│  4. Vyvrácené → do sekce zamítnutých                │
│  5. Vyhodnotit kvalitu analýzy každého agenta        │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│   FINÁLNÍ REPORT (pouze re-verifikované nálezy)     │
└─────────────────────────────────────────────────────┘
```

### Klíčové principy TMR

1. **Identický scope** — Všichni 3 agenti provádějí **tutéž kompletní analýzu** (FÁZE 1–5). Žádné dělení práce mezi agenty.
2. **Nezávislost** — Agenti nevidí výsledky ostatních. Každý pracuje izolovaně.
3. **Vlastní podagenti (POVINNÉ)** — Každý agent **MUSÍ** spouštět vlastní podagenty pro delegaci práce. Audit vyžaduje čtení 80+ souborů a spouštění SQL dotazů — bez podagentů kontext nestačí na dokončení všech fází. Agent sám provádí pouze koordinaci, FÁZI 2 (Supabase MCP) a FÁZI 4 (křížová validace). Vše ostatní deleguje na podagenty.
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
3. **Rozlišuj závažnost striktně dle definic** (viz Definice závažností níže). Nikdy neinfluj závažnost.
4. **U každého nálezu uveď**: co je špatně, proč je to problém, konkrétní dopad, a navrhované řešení.
5. **Porovnávej kód s dokumentací** (`PROJECT.md`, `CLAUDE.md`). Rozpor mezi kódem a dokumentací je nález — reportuj jako STŘEDNÍ+ závažnost. Neurčuj, kdo má pravdu (kód nebo docs), ale jasně popiš co se liší a kde. **VÝJIMKA:** Neimplementované plánované features z budoucích etap nejsou rozpory — viz "Známé vzory — NE BUG" bod 9.
6. **Analýzu Supabase** proveď přes MCP nástroje (execute_sql, list_tables, get_advisors) — nikdy nehádej stav serveru.
7. **Spouštěj podagenty** pro delegaci analytické práce — je to POVINNÉ (viz sekce "Povinné rozdělení podagentů"). Bez podagentů ti dojde kontext před dokončením analýzy.

### Verifikační protokol (POVINNÝ)

Každý nález **MUSÍ** projít verifikací před zařazením do reportu. Cílem je eliminovat falešné nálezy. Cílová false positive rate je **< 10%**. Pokud si nejsi jistý, NEREPORTUJ — je lepší minout NÍZKÝ nález než reportovat falešný STŘEDNÍ.

**Postup pro každý potenciální nález:**

1. **Znovu přečti primární zdroj** — znovu otevři soubor a přečti konkrétní řádky. Nespoléhej na to, co sis přečetl dříve nebo co máš v paměti.
2. **Ověř protistranu** — pokud tvrdíš „sloupec X chybí v Supabase", spusť SQL dotaz a ověř, že sloupec skutečně neexistuje. Pokud tvrdíš „mapper neposílá pole Y", přečti mapper znovu a hledej pole pod všemi možnými názvy (camelCase, snake_case, aliasy).
3. **Ověř KONKRÉTNÍ implementaci, ne jen base třídu** — pokud base třída nemá filtr (např. `deletedAt`), vždy zkontroluj, zda to nedělá abstraktní metoda implementovaná v subclass (např. `whereCompanyScope`). Čti ALESPOŇ 2 konkrétní subclassy.
4. **Zvaž kontext a záměr** — je to skutečně bug, nebo záměrné designové rozhodnutí? Viz sekce "Známé vzory — NE BUG" níže.
5. **Ověř kompletní řetězec** — pokud reportuješ problém v mapperu, ověř i Drift tabulku, model, Supabase schéma a druhý mapper. Problém může být na jiném místě než se zdá.
6. **Rozliš „nefunkční" vs „neoptimální"** — KRITICKÉ = crash nebo data loss V PRODUKCI. Neoptimální index ≠ KRITICKÉ. Typ mismatch, který PostgreSQL automaticky řeší ≠ KRITICKÉ.

### Známé vzory — NE BUG (POVINNÝ checklist)

Před reportováním nálezu ověř, že NEJDE o jeden z těchto známých vzorů. Pokud ano, NEREPORTUJ (nebo max jako INFO s poznámkou „known pattern"):

1. **Drift `text()` pro UUID sloupec** — SQLite nemá UUID typ. Drift `text()` pro Supabase `uuid` je standardní praxe. PostgreSQL automaticky castuje string↔uuid. Toto NIKDY nereportuj jako typ mismatch.
2. **Drift `text()` pro všechny stringové Supabase typy** (text, varchar, uuid, jsonb) — vše je `text()` v SQLite.
3. **Supabase anon key hardcoded v kódu** — Supabase anon key je DESIGNOVĚ VEŘEJNÝ. RLS ho chrání. Ve Flutter mobile/desktop app MUSÍ být v binárce (není server-side). NEREPORTUJ jako security issue.
4. **Sloupce `lastSyncedAt`, `version`, `serverCreatedAt`, `serverUpdatedAt` pouze v Drift** — local-only sync metadata, záměrně neexistují na Supabase.
5. **`sync_queue` bez `enforce_lww` triggeru** — sync_queue je jednosměrný outbox (klient→server), LWW na něm nemá smysl. NEREPORTUJ.
6. **Chybějící FK constraints na Supabase** — v offline-first architektuře je běžné vynechávat FK pro snazší sync (entity přicházejí v libovolném pořadí).
7. **`BaseCompanyScopedRepository.watchAll` bez explicitního `deletedAt` filtru** — filtrování je delegováno na abstraktní metodu `whereCompanyScope`, kterou KAŽDÝ konkrétní repozitář implementuje VČETNĚ `t.deletedAt.isNull()`. Před reportováním VŽDY přečti alespoň 2 konkrétní implementace.
8. **Globální tabulky (currencies, roles, permissions, role_permissions) s RLS `true`** — potřebné pro initial push při onboardingu. V single-company deploymentu akceptovatelné. Reportuj max jako STŘEDNÍ s kontextem.
9. **PROJECT.md popisuje budoucí plánované features (Etapa 4+, neoznačené tasky)** — PROJECT.md slouží jako DESIGN dokument, obsahuje i plánované funkce. Neimplementované tasky z budoucích etap NEJSOU bugy. NEREPORTUJ jako „chybějící implementace". Reportuj POUZE pokud je feature popsaná jako „hotová" ale není.
10. **Komentáře v kódu vysvětlující záměrné chování** — pokud kód má komentář typu „e.g. after schema fix" nebo „intentionally", respektuj záměr autora. Reportuj max jako INFO pokud máš pochybnosti o správnosti záměru.
11. **`as dynamic` v sync engine** — Drift neposkytuje společné rozhraní pro `.id`, `.companyId`, `.updatedAt` přes různé tabulky. Dynamic cast je nutný workaround pro generické operace. Reportuj max jako NÍZKÉ — known Drift limitation.

### Definice závažností (STRIKTNÍ)

| Závažnost | Definice | Příklady |
|-----------|----------|----------|
| **KRITICKÉ** | Crash v produkci NEBO potvrzená ztráta dat. Musí mít DŮKAZ (konkrétní scénář, ne hypotetický). | Tabulka v `_pullTables` neexistuje na Supabase → runtime exception. Mapper vynechává NOT NULL sloupec → INSERT fail. |
| **VYSOKÉ** | Bezpečnostní zranitelnost NEBO data se tiše ztrácejí/koruptují NEBO feature nefunguje. | RLS policy umožňuje cross-tenant access. Sloupec v Supabase ale ne v pull mapperu → data se nepropagují. |
| **STŘEDNÍ** | Nesoulad schema/docs/kód NEBO potenciální runtime problém za specifických podmínek. | Sloupec v Supabase chybí v Drift (nullable, nulový dopad teď). Dokumentace neodpovídá implementaci. |
| **NÍZKÉ** | Nekonzistence, neoptimální kód, kosmetické problémy. | UUID v4 místo v7. Nekonzistentní trigger naming. Nepoužívané indexy. |
| **INFO** | Pozitivní nález NEBO poznámka bez akce. | dart analyze clean. 100% RLS pokrytí. |

**KRITICKÉ vyžaduje důkaz.** Hypotetický scénář nestačí. Pokud nemůžeš demonstrovat konkrétní crash/data loss path, sniž na VYSOKÉ.

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

### Povinné rozdělení podagentů (interní pro každého agenta)

Každý agent (α/β/γ) **MUSÍ** svou práci rozdělit na podagenty. Audit vyžaduje čtení ~80+ souborů, spouštění SQL dotazů a křížovou validaci — to překračuje kontextové okno jednoho agenta. Bez podagentů analýza skončí neúplná.

**Strategie:** Agent sám slouží jako koordinátor — spouští podagenty, sbírá jejich výstupy a kompiluje finální report. Agent NEČTE zdrojové soubory přímo (kromě FÁZE 2 a 4), veškeré čtení a analýzu deleguje.

**Povinné podagenty (spouštěj paralelně kde je to možné):**

1. **Podagent: Sběr kontextu** — FÁZE 1 (přečte PROJECT.md, CLAUDE.md, CHANGELOG, pubspec, main.dart, app.dart, strom souborů). Vrátí souhrn klíčových informací, ne celý obsah.
2. **Podagent: Repositories + Sync + Mappers** — FÁZE 3.1, 3.2, mappers
3. **Podagent: Auth + Security + Routing + Providers** — FÁZE 3.3, 3.5, 3.6, seed service
4. **Podagent: UI (všechny screeny a widgety)** — FÁZE 3.4
5. **Podagent: Code quality + Drift tabulky + Testy** — FÁZE 3.7, 3.8, Drift table definitions
6. **Podagent: Best practices + Konzistence** — FÁZE 3.9, 3.10
7. **Podagent: Dokumentace vs implementace** — FÁZE 5

**Agent provádí PŘÍMO (ne v podagentech):**
- FÁZE 2 (Supabase MCP) — vyžaduje MCP nástroje a koordinaci dat
- FÁZE 4 (křížová validace Drift ↔ Supabase) — vyžaduje data z FÁZE 2 + výstupy podagentů

### Žádné vynechávání — kompletní audit je povinný

Agent NESMÍ vynechat žádnou fázi ani sekci z důvodu nedostatku kontextu. Pokud agent zjistí, že mu kontext nestačí, MUSÍ problém řešit dalším dělením práce na menší podagenty — nikdy ne vynecháním nebo zkrácením analýzy. Každá fáze a každý checklist bod musí být pokryt.

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
- [ ] Stream management — jsou `watchAll`/`watchById` správně company-scoped a filtrují `deletedAt IS NULL`? **POZOR:** Base class deleguje filtrování na `whereCompanyScope()` — vždy čti KONKRÉTNÍ subclass implementaci, ne jen base třídu.

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
- [ ] Credentials — Supabase anon key v kódu je OK (viz Známé vzory bod 3). Hledej JINÉ credentials: service_role key, databázové heslo, API keys třetích stran. Ty by v kódu být NEMĚLY.
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
- [ ] Debug/dev routes — existují routes přístupné bez autentizace nebo permission checku, které by neměly být?
- [ ] Redirect loops — může nastat nekonečný redirect?
- [ ] Permission guard konzistence — odpovídá použitý permission kód v routeru dokumentaci?

#### 3.7 Kvalita kódu

**3.7.0 Statická analýza (POVINNÝ PRVNÍ KROK)**

Spusť `dart analyze lib/` a zaznamenej VŠECHNY warnings a errors. Každý warning je automaticky nález:
- `error` → VYSOKÉ
- `warning` → STŘEDNÍ
- `info` → NÍZKÉ

Toto zachytí kategorie problémů, které manuální review nemůže efektivně odhalit: unnecessary null-aware operators, unused imports, type mismatches, dead code, missing overrides, deprecated API, null-safety porušení, atd.

**3.7.1 Manuální kontroly (grep-based)**

- [ ] `print()` — existují volání `print()` mimo AppLogger? (Grep: `print(`)
- [ ] Empty catch — existují prázdné `catch` bloky? (Grep: `catch.*\{\s*\}`)
- [ ] TODO/FIXME — kolik jich je a jsou relevantní? (Grep: `TODO|FIXME|HACK|XXX`)
- [ ] Unused imports — detekuje linter nepoužité importy?
- [ ] `as dynamic` — kolik unsafe castů existuje? Kde jsou nejvíc koncentrované?
- [ ] `!` force unwrap — kolik force unwrapů existuje? Jsou bezpečné?
- [ ] Const constructors — jsou widgety bez parametrů označené `const`?
- [ ] Generated code — je `app_database.g.dart` a `*.freezed.dart` aktuální vůči zdrojům?
- [ ] Hardcoded absolutní cesty — existují `File('/Users/...')` nebo podobné? (Grep: `File('`)
- [ ] DRY violations — existuje nově přidaný nebo existující kód, který duplikuje funkce z `lib/core/utils/`? Hledej duplicitní normalizace, formátování, validace, helpery rozstříkané po repositories/screens místo centralizace v utils. (Grep: klíčová slova jako `normalize`, `format`, `charMap`, `diacriticMap` mimo `utils/`)
- [ ] Utility reuse — jsou všechny helper funkce v repositories/screens/services skutečně doménově specifické, nebo patří do sdílených utils? Každá privátní funkce `_foo()` v repository, která nemá vazbu na konkrétní entitu, je kandidát na extrakci do utils.

#### 3.8 Testy

- [ ] Existují unit testy? Kolik jich je?
- [ ] Existují widget testy? Kolik jich je?
- [ ] Existují integration testy?
- [ ] Jaké je pokrytí kritických cest (sync, LWW, outbox, auth)?
- [ ] Pokud testy neexistují: které oblasti jsou **nejkritičtější** pokrýt? (prioritizovaný seznam)

#### 3.9 Best practices — idiomatický Dart/Flutter

Přečti klíčové soubory v `lib/core/` a `lib/features/` a hledej porušení idiomatických Dart/Flutter vzorů:

**Dart jazyk:**
- [ ] `final` vs `var` — jsou lokální proměnné, které se nemění, deklarované jako `final`? Hledej zbytečné `var` kde se hodnota nikdy nemění.
- [ ] Pattern matching — jsou `switch` výrazy na enumech/sealed třídách využity místo řetězce `if/else`? Jsou použity `switch expressions` (Dart 3) kde je to vhodné?
- [ ] Extension methods — existuje opakující se boilerplate (např. formátování, konverze), který by šel elegantně řešit extension method místo utility funkcí nebo inline kódu?
- [ ] Sealed classes — jsou discriminated unions modelovány jako sealed classes (Dart 3) kde je to vhodné, nebo se používají enum + nullable fields?
- [ ] Collection literals — jsou použity `const []`, `const {}` místo `List.empty()`, `Map.from()` kde je to možné?
- [ ] Cascade notation (`..`) — je využita kaskáda místo opakovaného přístupu k témuž objektu?
- [ ] `late` — jsou `late` proměnné použity pouze tam kde je to nutné? Existují `late` bez jasné inicializační garance (potenciální `LateInitializationError`)?
- [ ] Null-aware operátory — jsou konzistentně použity `?.`, `??`, `??=` místo explicitních null checků?
- [ ] Spread operátor (`...`) — je využit pro kompozici kolekcí místo `addAll`?
- [ ] `dynamic` kde existuje konkrétní typ — přijímají metody `dynamic` parametr, přestože konkrétní typ je dostupný? (např. `_processEntry(dynamic entry)` místo `_processEntry(SyncQueueData entry)`). `dynamic` je akceptovatelný pouze tam, kde Drift neumožňuje společné rozhraní (viz Známé vzory bod 11).
- [ ] `!` force unwrap vs pattern matching — jsou nullable proměnné opakovaně přistupované přes `_field!` místo bezpečného `if (x case final y)` nebo `final local = _field; if (local != null)`? Každý `!` je potenciální runtime exception.
- [ ] Typové aliasy — jsou složité generické typy (např. `Map<String, List<Map<String, dynamic>>>`) pojmenované přes `typedef` pro čitelnost?

**Výkon a efektivita:**
- [ ] **Sequential `await` v loops** — existují `for` cykly s `await` uvnitř těla, kde by šel použít `Future.wait()` nebo batch operace? Toto je typický N+1 problém — hledej vzory jako `for (final x in list) { await repo.method(x); }`. Ověř v repositories, sync engine, i seed service.
- [ ] **Metody delší než ~80 řádků** (nejen `build()`) — existují repository/service metody, které by šlo rozdělit na menší funkce? Hledej obzvlášť v: `_initialPush()`, `createBill()`, `refundBill()`, `seed()`.
- [ ] **Duplicitní helper metody ve stejném souboru** — existují varianty téhož vzoru (např. `_enqueueCompanyTable` vs `_enqueueGlobalTable` vs `_enqueueRegisters` vs `_enqueueUserPermissions`) které by šly sjednotit do jedné generické funkce?
- [ ] **Nested StreamBuilder/FutureBuilder** — existují vnořené `StreamBuilder`y nebo `FutureBuilder`y? Idiomatický přístup je kombinování streamů nebo použití Riverpod providerů.
- [ ] **FutureBuilder s inline future** — je `Future` vytvářen přímo v `build()` místo v `initState`? Inline future se znovu vytváří při každém rebuildu.

**Flutter specifické:**
- [ ] `const` widgety — jsou widgety bez runtime závislostí označeny `const`? (výkon)
- [ ] `StatelessWidget` vs `StatefulWidget` — existují `StatefulWidget`y, které by měly být `StatelessWidget` (nepoužívají `setState`, nemají mutable state)?
- [ ] `BuildContext` across async gaps — je `context` použit po `await` bez mounted checku?
- [ ] `Keys` — jsou `Key` parametry správně použity v listech/gridech pro zachování stavu?
- [ ] Widget decomposition — existují `build()` metody delší než ~100 řádků, které by šlo rozdělit na menší widgety?
- [ ] Theme/color reference — jsou barvy odkazovány přes `Theme.of(context)` a `ColorScheme`, nebo existují hardcoded `Color(0xFF...)` hodnoty?

**Riverpod patterns:**
- [ ] `ref.watch` vs `ref.read` — je `ref.watch` použit v `build()` metodách pro reaktivní UI a `ref.read` pro one-shot akce (event handlery, initState)? Existují případy `ref.read` v `build()` (chybějící reaktivita) nebo `ref.watch` v event handlerech (zbytečný rebuild)?
- [ ] `ref.watch` / `ref.read` mimo build context — je `ref` použit uvnitř callback funkcí (`StreamBuilder.builder`, `FutureBuilder.builder`, `onPressed`) kde by měl být uložen do lokální proměnné předem?
- [ ] `autoDispose` — mají providery, které jsou vázané na lifecycle konkrétní obrazovky, `autoDispose` modifikátor? Existují providery bez `autoDispose` které drží stav i po opuštění obrazovky (memory leak)?
- [ ] `keepAlive` — je `ref.keepAlive()` použit pouze u providerů, kde je cache žádoucí (např. globální konfigurace), ne plošně?
- [ ] Provider granularita — existují „mega-providery" vracející velký objekt, kde by stačil granulární provider pro konkrétní hodnotu (zbytečné rebuildy)?
- [ ] `select` — je `ref.watch(provider.select(...))` použit tam, kde widget potřebuje jen část stavu?
- [ ] `AsyncValue` handling — je `AsyncValue.when()` použit konzistentně pro loading/error/data stavy, nebo existují neošetřené stavy?
- [ ] Family providers — jsou `family` providery použity místo globálního stavu s parametrem tam, kde je to vhodné?
- [ ] Provider dependencies — jsou závislosti mezi providery explicitní (přes `ref.watch`), nebo existují skryté závislosti přes globální stav?

#### 3.10 Jednotnost zápisu (Consistency)

Analyzuj celý codebase na konzistenci zápisu. Nekonzistence **mezi soubory** je závažnější než nekonzistence **uvnitř souboru**. Hledej VZORY, ne jednotlivé výskyty — reportuj pouze systematické nekonzistence.

**Architekturní konzistence (nejvyšší priorita):**
- [ ] Repository architektura — kolik repozitářů dědí z `BaseCompanyScopedRepository` a kolik je psáno manuálně? Je dualita záměrná (komplex vs CRUD) nebo náhodná? Vypiš obě skupiny.
- [ ] Transaction boundaries — je `_enqueue()` / `_syncQueueRepo.enqueue()` voláno UVNITŘ nebo VNITŘKU transakcí konzistentně? Porovnej `BaseCompanyScopedRepository` (uvnitř) vs `BillRepository` (vně). Reportuj jako systematickou nekonzistenci.
- [ ] Result wrapping — vracejí všechny veřejné write metody `Result<T>`, nebo některé přímo throwují? Je vzor pro čtení (read) konzistentní se zápisem (write)?
- [ ] Dependency injection — jsou závislosti přijímány jako `required` v konstruktoru konzistentně, nebo existují mix `required` + optional/nullable pro stejnou závislost (např. `syncQueueRepo`) v různých repozitářích?

**Naming conventions:**
- [ ] Soubory — je konzistentní `snake_case` pojmenování? Existují výjimky?
- [ ] Třídy — je konzistentní `PascalCase`? Jsou prefixy konzistentní (např. `Screen*` vs `Page*`, `Dialog*` vs `*Dialog`)?
- [ ] Proměnné a metody — je konzistentní `camelCase`? Existují mixované konvence (např. `user_id` vs `userId`)?
- [ ] Privátní členy — je konzistentní použití `_` prefixu?
- [ ] Database field naming — je `AppDatabase` pole pojmenováno konzistentně? (hledej `db` vs `_db` vs `database` across repositories/services)
- [ ] Boolean proměnné — je konzistentní prefix (`is*`, `has*`, `can*`, `should*`) nebo existuje mix (např. `active` vs `isActive`)?
- [ ] Callback pojmenování — je konzistentní vzor (`on*` parametry pro callbacky, např. `onPressed`, `onChanged`)?
- [ ] Provider pojmenování — je konzistentní suffix (`*Provider`)?
- [ ] Screen class vs file — sedí název třídy s názvem souboru? (např. `ScreenSell` v `screen_sell.dart` vs odchylky)

**UUID a identifikátory:**
- [ ] UUID verze — je konzistentní verze UUID napříč codebase? (hledej `Uuid().v4()` vs `UuidV7().generate()` vs `const Uuid()` — vypiš kde se která varianta používá)
- [ ] UUID instantiation — je `Uuid` instancován jako `const Uuid()` (efektivní) nebo `Uuid()` (nová instance pokaždé)?

**Enum patterns:**
- [ ] Enum serialization — je konzistentní vzor pro konverzi enum→String? (`.name` vs custom extension vs switch expression)
- [ ] Enum deserialization — je konzistentní vzor pro String→enum? (`EnumType.values.byName()` vs `firstWhere` vs switch)
- [ ] Enum formatting — je konzistentní `camelCase` pro enum values, nebo existuje mix (`snake_case`, `UPPER_CASE`)?

**Import ordering:**
- [ ] Je pořadí importů konzistentní napříč soubory? (doporučené: dart:, package:flutter/, package:vlastní/, relativní importy, oddělené prázdnými řádky)
- [ ] Relativní vs absolutní importy — je konzistentní styl? Nebo mix `import '../...'` a `import 'package:epos/...'`?
- [ ] Jsou `part` / `part of` direktivy umístěny konzistentně?

**Strukturování tříd (method ordering):**
- [ ] Je pořadí členů ve třídách konzistentní? (doporučené: static fields → fields → constructors → lifecycle methods → public methods → private methods → build/overrides)
- [ ] Jsou `@override` metody konzistentně seskupeny?
- [ ] Je `dispose()` vždy na konci lifecycle bloku?
- [ ] Je `build()` vždy poslední metoda ve widgetu?

**Widget composition patterns:**
- [ ] Jsou padding/margin aplikovány konzistentně? (např. vždy `Padding` widget vs `EdgeInsets` v `Container`/`DecoratedBox`)
- [ ] Je spacing mezi widgety konzistentní? (např. `SizedBox(height: 8)` vs `SizedBox(height: 16)` vs custom hodnoty — existuje spacing systém?)
- [ ] Jsou dialogy vytvářeny konzistentním vzorem? Vypiš všechny varianty (např. `Dialog`, `AlertDialog`, `PosDialogShell`, custom) a kolikrát se která používá.
- [ ] Jsou listy/gridy konzistentně implementovány? (`ListView.builder` vs `Column` + `for`)
- [ ] Widget state management — existuje konzistentní vzor pro stateful widgety? (`StatefulWidget` + `setState` vs `ConsumerStatefulWidget` + `ref` vs `ConsumerWidget`)

**Error handling:**
- [ ] Je error handling konzistentní napříč repositories? (všude `Result<T>` + try/catch, nebo mix?)
- [ ] Jsou `catch` bloky konzistentní? (catch `Exception` vs `Object` vs specifické typy)
- [ ] Je logování chyb konzistentní? (`AppLogger.error` se stejným formátem?)
- [ ] Jsou chybové zprávy v konzistentním jazyce? (vše anglicky, nebo mix?)

**Const usage:**
- [ ] Jsou `const` konstruktory použity konzistentně? Existují widgety, které by mohly být `const` ale nejsou?
- [ ] Jsou `const` kolekce (`const []`, `const {}`) použity konzistentně?
- [ ] Jsou magic numbers nahrazeny pojmenovanými konstantami, nebo existují hardcoded hodnoty rozptýlené po kódu? (spacing, sizing, durations)

**Formátování parametrů:**
- [ ] Je konzistentní styl pro trailing commas? (trailing comma u posledního parametru pro lepší diff)
- [ ] Je konzistentní styl pro pojmenované vs pozicional parametry u vlastních widgetů?
- [ ] Je konzistentní styl pro `required` anotace?

---

### FÁZE 4 — Křížová validace (Drift ↔ Supabase ↔ Modely ↔ Mappery)

#### Krok 1: Porovnej seznamy tabulek

Jako **první krok** než začneš per-column srovnání:

1. Vypiš **VŠECHNY** tabulky z Drift (`app_database.dart` — `@DriftDatabase(tables: [...])`)
2. Vypiš **VŠECHNY** tabulky ze Supabase (MCP `list_tables` nebo `information_schema.tables`)
3. Porovnej oba seznamy — hledej tabulky, které existují **POUZE na jedné straně**
4. Tabulky pouze v Drift = **KRITICKÉ** (sync pull/push crash)
5. Tabulky pouze v Supabase = **VYSOKÉ** (data se nesynchronizují)

Pozn: Infrastrukturní tabulky:
- `sync_queue` — existuje na obou stranách, ale má odlišné schéma (porovnej zvlášť). Záměrně NEMÁ `enforce_lww` trigger (jednosměrný outbox).
- `sync_metadata` — existuje POUZE v Drift (local-only). Neexistuje v Supabase. NEREPORTUJ jako chybějící.
- `device_registrations` — existuje POUZE v Drift (local-only). Neexistuje v Supabase. NEREPORTUJ jako chybějící.

#### Krok 2: Per-column srovnání

Pro **každou sdílenou** tabulku:

1. Vypiš seznam sloupců z Drift (`.dart` soubor, bez sync sloupců z mixinu)
2. Vypiš seznam sloupců ze Supabase (`information_schema.columns`, bez server sync sloupců `created_at`, `updated_at`, `client_created_at`, `client_updated_at`, `deleted_at`)
3. Porovnej — hledej sloupce přítomné **POUZE na jedné straně** (KRITICKÉ)
4. Pro společné sloupce vytvoř srovnávací tabulku:

| Sloupec | Drift typ | Drift nullable | Supabase typ | Supabase nullable | Model field | Push mapper | Pull mapper | Shoda? |
|---------|-----------|----------------|--------------|-------------------|-------------|-------------|-------------|--------|

#### Krok 3: Hledej nesoulady

- Tabulka v Drift `_pullTables` ale ne v Supabase → **KRITICKÉ** (sync pull crash)
- Tabulka v Supabase ale ne v Drift `_pullTables` → **VYSOKÉ** (data se nesynchronizují)
- NOT NULL sloupec v Supabase bez defaultu chybí v push mapperu → **KRITICKÉ** (INSERT fail)
- Sloupec v Supabase ale ne v Drift (nullable) → **STŘEDNÍ** (no crash, just always NULL, schema drift)
- Sloupec v Drift ale ne v Supabase → **STŘEDNÍ** (push pošle extra field, Supabase ho ignoruje)
- Sloupec je nullable v jednom ale NOT NULL v druhém → závisí na kontextu
- Typ mismatch → **POZOR: `text` vs `uuid` NENÍ mismatch** (viz Známé vzory bod 1). Skutečný mismatch: `integer` vs `text`, `real` vs `integer`, nekompatibilní enum hodnoty
- Sloupec chybí v modelu ale je v Drift a mapperu → **STŘEDNÍ**
- Sloupec chybí v push/pull mapperu → **VYSOKÉ** (data se ztratí při sync)
- Enum hodnoty se liší mezi Dart a Supabase → **VYSOKÉ** (crash při neznámé hodnotě)

---

### FÁZE 5 — Dokumentace vs implementace

**Každý rozpor je nález** — s jednou klíčovou výjimkou: PROJECT.md obsahuje i **plánované budoucí features** (typicky vyšší Etapy/Milestones). Neimplementované plánované tasky z budoucích etap NEJSOU rozpory a NEREPORTUJ je jako nálezy. Reportuj POUZE:
- Kód dělá něco jiného než dokumentace popisuje pro HOTOVOU feature
- Dokumentace uvádí nesprávné cesty, názvy, hodnoty pro EXISTUJÍCÍ implementaci
- Sloupce/tabulky existují v kódu ale chybí v dokumentaci (docs neaktualizovány po implementaci)

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

### Kvalita analýzy — očekávání

- **False positive rate < 10%** — každý nález musí projít verifikačním protokolem A kontrolou proti "Známé vzory — NE BUG".
- **Raději méně nálezů s vyšší přesností** než více nálezů s falešnými pozitivy. 10 potvrzených nálezů > 20 nálezů s 5 falešnými.
- **Konzistentní závažnost** — používej definice ze sekce "Definice závažností". Nikdy KRITICKÉ bez důkazu.
- **Jeden nález = jeden problém** — neslučuj nesouvisející problémy. Nerozděluj jeden problém na více nálezů.

### Výstupní formát agenta

Každý agent vrátí **stručný** report — seznam nálezů, nic víc:

```
# REPORT AGENTA [α/β/γ]

Počet nálezů: KRITICKÉ: X | VYSOKÉ: X | STŘEDNÍ: X | NÍZKÉ: X

## Nálezy

### [ZÁVAŽNOST] Název nálezu
**Soubor:** `cesta/soubor.dart:řádek`
**Problém:** 1-2 věty — co je špatně a jaký je dopad.
**Řešení:** 1-2 věty — jak opravit.

(opakuj pro každý nález)
```

---

## FÁZE SLOUČENÍ — Merge & Verify (hlavní konverzace)

Po dokončení všech 3 agentů hlavní konverzace:

1. **Sloučí a deduplikuje** nálezy ze všech 3 agentů (totéž různě formulované = jeden nález)
2. **Re-verifikuje každý nález** — přečte zdrojový kód/spustí SQL a ověří, že problém skutečně existuje. Zkontroluje proti "Známé vzory — NE BUG". Falešné nálezy vyřadí.
3. **Sestaví finální report** z potvrzených nálezů

---

## FINÁLNÍ REPORT

Stručný, akční report. Žádné srovnávání agentů, žádné detailní tabulky zamítnutých nálezů.

### Souhrn
- 2-3 věty o celkovém stavu projektu
- Počet nálezů per závažnost

### Nálezy k řešení

Seřazené od nejkritičtějších. **Toto je primární výstup celého auditu.**

```
### [ZÁVAŽNOST] Název nálezu
**Soubor:** `cesta/soubor.dart:řádek`
**Problém:** Co je špatně a jaký je dopad.
**Řešení:** Jak opravit.
```

### Quick-Fix tabulka

| # | Závažnost | Soubor:řádek | Co změnit |
|---|-----------|-------------|-----------|

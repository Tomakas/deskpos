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
│  2. Klasifikovat shodu (3/3, 2/3, 1/3 agentů)      │
│  3. Re-verifikovat sporné nálezy (1/3 unikátní)     │
│  4. Potvrzené → do reportu                          │
│  5. Vyvrácené → do sekce zamítnutých                │
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

Proveď **kompletní, důkladnou a podrobnou analýzu** celého Maty projektu. Analýza je čistě **READ-ONLY** — žádný kód se nemodifikuje, žádné commity, žádné migrace.

1. **Čti každý soubor**, na který odkazuješ. Necituj z paměti — vždy ověř aktuální stav.
2. **Uváděj přesné cesty a čísla řádků** (`soubor:řádek`) u každého nálezu.
3. **Rozlišuj závažnost striktně dle definic** (viz Definice závažností níže). Nikdy neinfluj závažnost.
4. **U každého nálezu uveď**: co je špatně, proč je to problém, konkrétní dopad, a navrhované řešení.
5. **Porovnávej kód s dokumentací** (`PROJECT.md`, `CLAUDE.md`). Rozpor mezi kódem a dokumentací je nález — reportuj jako STŘEDNÍ+ závažnost. Neurčuj, kdo má pravdu (kód nebo docs), ale jasně popiš co se liší a kde. **VÝJIMKA:** Neimplementované plánované features z budoucích etap nejsou rozpory — viz "Známé vzory — NE BUG" bod 9.
6. **Analýzu Supabase** proveď přes MCP nástroje (execute_sql, list_tables, get_advisors) — nikdy nehádej stav serveru.
7. **Spouštěj podagenty** pro delegaci analytické práce — je to POVINNÉ (viz sekce "Povinné rozdělení podagentů"). Bez podagentů ti dojde kontext před dokončením analýzy.
8. **Generovaný kód VYLÚČ z analýzy** — soubory `*.g.dart` a `*.freezed.dart` jsou automaticky generované `build_runner`em. NEANALYZUJ je, NEHLÁŠEJ v nich nálezy, NEPOČÍTEJ je do code quality metrik. Jediná relevantní kontrola: je generovaný kód aktuální vůči zdrojovým definicím (viz 3.7.1).

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
12. **Server-side guard triggery (BEFORE triggers vyhazující exception)** — triggery typu `guard_last_admin` záměrně blokují nebezpečné operace přes `RAISE EXCEPTION`. Toto je standardní PostgreSQL pattern pro business rule enforcement — ne chybějící error handling. NEREPORTUJ samotnou existenci RAISE EXCEPTION jako problém. Reportuj POUZE pokud je guard logika neúplná nebo obejitelná.
13. **Tranzitivní permission dependency graf** — automatický grant prerequisites a revoke dependents při editaci uživatelských oprávnění je záměrný design. Graf v `permission_implications.dart` definuje 1:N vztahy (permission → required permissions). NEREPORTUJ automatické změny oprávnění jako „neočekávané side effects".
14. **Jednosměrné tabulky bez `enforce_lww`** — tabulky, které fungují jako append-only záznamy nebo jednosměrné logy (sync_queue, session_currency_cash, cash_movements apod.), záměrně nemají LWW trigger. NEREPORTUJ, pokud je absence LWW konzistentní s jednosměrným charakterem tabulky.
15. **Realtime broadcast nested payload** — Supabase Broadcast from Database posílá payload v nested struktuře `payload['payload']`. Dvojitý unwrap je konvence Supabase Realtime, ne chyba. NEREPORTUJ jako code smell.
16. **Duální repozitářový vzor** — V projektu existují dvě kategorie repozitářů: a) Jednoduché CRUD repozitáře dědící z `BaseCompanyScopedRepository` (~25 ks) s generickým create/update/delete/enqueueAll. b) Komplexní workflow repozitáře psané manuálně (~17 ks — BillRepository, OrderRepository, RegisterSessionRepository, PaymentRepository, ShiftRepository, atd.) — mají vlastní sync logiku a NEDĚDÍ z base třídy, protože jejich mutace zahrnují více tabulek. NEREPORTUJ absenci dědění z BaseCompanyScopedRepository u manuálních repozitářů. Reportuj POUZE pokud manuální repozitář CHYBÍ outbox enqueue u mutací.
17. **PaymentRepository je read-only** — Platby se vytvářejí prostřednictvím `BillRepository.recordPayment()` a `BillRepository.refundBill()`. PaymentRepository obsahuje pouze read metody (watchByBill, getByBill, getByBillIds). NEREPORTUJ absenci write metod nebo syncQueueRepo.
18. **SharedPreferences pro device-local konfiguraci** — SharedPreferences se používá pro device-specifická nastavení (device_id, display_code, display_type, login_mode), která se NESYNCHRONIZUJÍ. Toto NENÍ porušení pravidla „žádný přímý DB přístup mimo repozitáře" — pravidlo se týká Drift a Supabase.
19. **appDatabaseProvider v onboardingu** — Onboarding screen přistupuje k DB přímo pro: a) čtení default tax rate při demo seedu, b) insert do device_registrations (lokální tabulka). Toto jsou jednorázové operace před plným nastavením DI. Reportuj max jako NÍZKÉ s kontextem.
20. **Supabase edge function volání v UI** — Volání `Supabase.instance.client.functions.invoke()` v onboarding screenu je jednorázová serverová operace, ne běžný data access pattern. NEREPORTUJ jako „direct Supabase access".
21. **Globální tabulky se nepushují při initial push** — currencies, roles, permissions, role_permissions jsou server-authoritative. Initial push je pushuje jen pokud je firma nová (vlastní je). Jinak se stahují ze serveru při pull. NEREPORTUJ absenci v initial push jako bug.
22. **Platform-specifický kód** — `Platform.isMacOS`, `Platform.isWindows`, `kIsWeb` kontroly v `lib/core/platform/` a podmíněných importech jsou standardní Flutter multiplatformní vzor. NEREPORTUJ jako code smell. Reportuj POUZE pokud platform check chybí tam, kde by měl být.

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
**Confidence:** CONFIRMED / LIKELY / SUSPECTED
**Verifikace:** Jak jsem ověřil, že jde o skutečný problém (ne domněnku).
**Důkaz:** Přesná citace kódu/SQL výsledku, který problém potvrzuje.
**Soubor:** `cesta/soubor.dart:řádek`
**Popis:** Co je špatně.
**Dopad:** Proč je to problém (konkrétní scénář).
**Řešení:** Jak to opravit (konkrétní kroky).
```

**Confidence level (povinné u každého nálezu):**

| Level | Definice | Dopad na závažnost |
|-------|----------|--------------------|
| **CONFIRMED** | Ověřen čtením kódu + SQL, reprodukovatelný scénář | Plná závažnost |
| **LIKELY** | Silné indicie, ale ne 100% jistota | Závažnost −1 stupeň |
| **SUSPECTED** | Na základě vzoru/konvence, nepodařilo se reprodukovat | Max STŘEDNÍ, vždy s „VYŽADUJE RUČNÍ OVĚŘENÍ" |

Nikdy nehlásaj KRITICKÉ bez confidence level CONFIRMED.

### Povinné rozdělení podagentů (interní pro každého agenta)

Každý agent (α/β/γ) **MUSÍ** svou práci rozdělit na podagenty. Audit vyžaduje čtení ~80+ souborů, spouštění SQL dotazů a křížovou validaci — to překračuje kontextové okno jednoho agenta. Bez podagentů analýza skončí neúplná.

**Strategie:** Agent sám slouží jako koordinátor — spouští podagenty, sbírá jejich výstupy a kompiluje finální report. Agent NEČTE zdrojové soubory přímo (kromě FÁZE 2 a 4), veškeré čtení a analýzu deleguje.

**Strategie podagentů:**

Agent MUSÍ delegovat analytickou práci na podagenty. Konkrétní dělení je na agentovi, ale MUSÍ splnit:

1. Minimálně 4 paralelní podagenty pro FÁZI 3 (klient je příliš velký pro jednoho)
2. FÁZE 2 (Supabase MCP) provádí agent přímo
3. FÁZE 4 (křížová validace) provádí agent přímo (potřebuje data z FÁZE 2)
4. Každý podagent vrací strukturovaný výstup (viz formát níže)
5. Agent koordinuje a kompiluje finální report

Doporučené dělení (agent může upravit):

1. **Podagent: Sběr kontextu** — FÁZE 1 (přečte PROJECT.md, CLAUDE.md, CHANGELOG, pubspec, main.dart, app.dart, strom souborů). Vrátí souhrn klíčových informací, ne celý obsah.
2. **Podagent: Repositories + Business logika + Sync + Mappers** — FÁZE 3.1, 3.2, 3.11 (architektura repozitářů, sync engine, mappery, workflow integrita)
3. **Podagent: Auth + Security + Permissions + Routing + Providers** — FÁZE 3.3, 3.5, 3.6 (PIN, sessions, permission systém, dependency graf, route guards)
4. **Podagent: UI — screeny a widgety** — FÁZE 3.4 (rozděl na 2+ podagenty pokud > 30 screenů)
5. **Podagent: Code quality + Best practices + Konzistence** — FÁZE 3.7, 3.8, 3.9, 3.10, Drift table definitions
6. **Podagent: Dokumentace vs implementace** — FÁZE 5

**Agent provádí PŘÍMO (ne v podagentech):**
- FÁZE 2 (Supabase MCP) — vyžaduje MCP nástroje a koordinaci dat
- FÁZE 4 (křížová validace Drift ↔ Supabase) — vyžaduje data z FÁZE 2 + výstupy podagentů

### Kompletnost analýzy a prioritizace

Agent MUSÍ pokrýt všechny fáze. Pokud kontextové okno nestačí, řeš dalším dělením na menší podagenty. Pokud ani to nepomůže, dodržuj prioritní pořadí:

1. **Priorita 1 (NESMÍ chybět):** FÁZE 2, 4 (Supabase, křížová validace — nejvyšší hodnota)
2. **Priorita 2 (NEMĚLO BY chybět):** FÁZE 3.1–3.3 (repositories, sync, auth)
3. **Priorita 3 (MĚLO BY být):** FÁZE 3.4–3.6 (UI, providers, routing)
4. **Priorita 4 (NICE TO HAVE):** FÁZE 3.7–3.13, 5 (code quality, konzistence, docs)

Pokud agent nemůže dokončit nižší prioritu, MUSÍ:
- Explicitně uvést, které sekce nebyly pokryty
- Uvést důvod (kontextové okno, příliš mnoho souborů, MCP timeout)
- Pokrytí priority 1 a 2 je MINIMÁLNÍ akceptovatelný výstup

Pokud podagent při analýze jedné oblasti najde > 15 nálezů:
1. Zaznamenej prvních 15 seřazených dle závažnosti
2. Přidej poznámku „Oblast vyžaduje detailní dedikovaný audit"
3. Pokračuj na další oblast — nepokrývej jednu oblast na úkor ostatních

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

Analyzuj **všechny** triggery a funkce v `public` schema. Nekontroluj jen konkrétní jména — projekt průběžně přidává nové kategorie triggerů (sync, LWW, timestamps, broadcast, guard, apod.).

```sql
-- Všechny triggery (kompletní seznam)
SELECT trigger_name, event_manipulation, event_object_table, action_timing, action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- VŠECHNY custom funkce v public schema (ne jen trigger funkce)
SELECT p.proname, pg_get_functiondef(p.oid)
FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
ORDER BY p.proname;

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
```

**Kategorizuj triggery** a pro každou kategorii ověř pokrytí:

- **Sync timestamps** (`set_server_timestamps`) — mají ho všechny doménové tabulky?
- **LWW** (`enforce_lww`) — mají ho tabulky, které podporují UPDATE z klienta? (jednosměrné/append-only tabulky ho záměrně nemají — viz Známé vzory bod 14)
- **Broadcast/Realtime** — mají broadcast trigger všechny company-scoped tabulky, které se synchronizují? Chybí nějaká?
- **Guard/Constraint** — existují BEFORE triggery vynucující business pravidla? Je jejich logika kompletní a neobejitelná?
- **Jiné** — existují triggery mimo výše uvedené kategorie? Jsou zdokumentované?

#### 2.5 Migrace a advisors
- `list_migrations` — seznam všech migrací
- `get_advisors(type: "security")` — bezpečnostní doporučení
- `get_advisors(type: "performance")` — výkonnostní doporučení

#### 2.6 Edge Functions (TypeScript)

Přečti a analyzuj **KAŽDÝ** soubor v `supabase/functions/*/index.ts`:

**Ingest (`supabase/functions/ingest/index.ts`):**
- [ ] ALLOWED_TABLES — obsahuje všechny company-scoped tabulky? Žádná nechybí? Žádná navíc?
- [ ] Company ownership — ověřuje se `companies.auth_user_id = JWT uid`? Kontroluje se `deleted_at IS NULL`?
- [ ] FK violation handling — vrací `error_type: "transient"` při 23503? Loguje jako `fk_pending`?
- [ ] Idempotency — ověřuje se `idempotency_key`? Duplicitní requesty nevedou k duplikátním zápisům?
- [ ] Upsert — používá se `onConflict: "id"`? Jsou pokryty všechny sloupce payloadu?
- [ ] LWW conflict — zachytává `P0001` error a vrací `error_type: "lww_conflict"`?
- [ ] CORS — jsou headers nastaveny pro web platformu?

**Wipe (`supabase/functions/wipe/index.ts`):**
- [ ] Autorizace — JWT povinný? Firma odvozena z JWT (ne z client-supplied ID)?
- [ ] Pořadí mazání — FK dependency order (children first)?
- [ ] Kompletnost — jsou smazány VŠECHNY company-scoped tabulky? (porovnej se seznamem tabulek)
- [ ] Globální tabulky — NEJSOU mazány? (currencies, roles, permissions, role_permissions)

**Create-demo-data (`supabase/functions/create-demo-data/index.ts`):**
- [ ] Autorizace — JWT (anon nebo registered)?
- [ ] Abuse guard — kontrola, že user nemá existující firmu?
- [ ] RPC parametry — locale, mode, currency_code, company_name předávány správně?
- [ ] Demo flags — is_demo=true, demo_expires_at nastaveny?

**Reset-db (`supabase/functions/reset-db/index.ts`):**
- [ ] NENÍ přístupná v produkci — auth přes X-Reset-Secret header, ne JWT?
- [ ] Zachovává globální data?

#### 2.7 SQL funkce — bezpečnost

Pro KAŽDOU `SECURITY DEFINER` funkci (identifikované v 2.4):
- [ ] Má `SET search_path = 'public'` (ochrana proti search_path injection)?
- [ ] Přijímá pouze nezbytné parametry?
- [ ] Vrací pouze nezbytná data (ne `SELECT *`)?
- [ ] `create_demo_company` — race conditions? FK integrita generovaných dat?
- [ ] `guard_last_admin` — je logika neobejitelná (i přes service_role)?
- [ ] `lookup_display_device_by_code` — vrací jen omezená pole (ne celý záznam)?

#### 2.8 Supabase migrace — konzistence

- [ ] Jsou VŠECHNY migrace v `supabase/migrations/` aplikované na serveru? (porovnej `list_migrations` s lokálním adresářem)
- [ ] pg_cron job pro demo cleanup — je nastaven a aktivní?

#### 2.9 Supabase audit checklist

Pro každou tabulku ověř (globální tabulky jako currencies, roles, permissions, role_permissions mají odlišná pravidla — typicky `true` pro authenticated):

- [ ] RLS je **enabled**
- [ ] Existuje SELECT policy s `company_id IN (SELECT get_my_company_ids())`
- [ ] Existuje INSERT policy s WITH CHECK
- [ ] Existuje UPDATE policy s USING + WITH CHECK
- [ ] **Neexistuje** DELETE policy (soft-delete only)
- [ ] Existuje `set_server_timestamps` trigger (INSERT + UPDATE)
- [ ] Existuje `enforce_lww` trigger (UPDATE) — pokud tabulka podporuje UPDATE z klienta (jednosměrné tabulky záměrně ne, viz Známé vzory bod 14)
- [ ] Existuje broadcast/realtime trigger (AFTER INSERT OR UPDATE) — pro company-scoped tabulky, které se synchronizují
- [ ] Existují guard/constraint triggery tam, kde business pravidla vyžadují server-side enforcement (např. ochrana posledního admina, zamykání konfigurací apod.)
- [ ] Trigger naming je konzistentní (ověř naming pattern pro každou kategorii triggerů)
- [ ] Existuje index `idx_{table}_company_updated` (pro sync pull)
- [ ] FK sloupce mají indexy (pokud mají FK constraint)

---

### FÁZE 3 — Analýza klienta (Flutter/Dart)

#### 3.1 Architektura a vzory

Přečti a analyzuj **každý** soubor v těchto adresářích:

**Repositáře** (`lib/core/data/repositories/*.dart`):
- [ ] Dodržuje se Repository pattern? Žádný přímý DB přístup mimo repositáře?
- [ ] `BaseCompanyScopedRepository` — je správně implementován? Dědí z něj správné entity?
- [ ] **Registrace repozitářů** — jsou VŠECHNY repozitáře zaregistrované v příslušných provider setech (`companyRepos`, providery v `providers/`)? Chybějící registrace = tabulka se nesynchronizuje.
- [ ] **Dependency injection** — mají všechny repozitáře injektovaný `syncQueueRepo` kde ho potřebují? Nový repozitář bez `syncQueueRepo` = mutace se nepropagují do outboxu.
- [ ] `getById()` — validuje company_id scope, nebo vrací entitu jakékoli firmy bez ověření?
- [ ] Manuální outbox — jsou `_enqueue*` volání po **každé** mutaci? Nechybí nějaké?
- [ ] `Company.create()` — enqueueuje do outboxu? (zvláštní případ — není BaseCompanyScoped)
- [ ] Result pattern — vracejí všechny veřejné metody `Result<T>`? Jsou try/catch kompletní?
- [ ] Transakce — jsou atomické operace (`createOrderWithItems`, `cancelBill` cascade) v transaction bloku?
- [ ] N+1 queries — jsou někde smyčky s await uvnitř (query per iteration)?
- [ ] Stream management — jsou `watchAll`/`watchById` správně company-scoped a filtrují `deletedAt IS NULL`? **POZOR:** Base class deleguje filtrování na `whereCompanyScope()` — vždy čti KONKRÉTNÍ subclass implementaci, ne jen base třídu.
- [ ] **Server-side vs client-side validace** — pokud existují server-side guard triggery (business rule enforcement), má klient odpovídající validaci PŘED odesláním? Jsou obě strany konzistentní? (např. guard pro posledního admina — blokuje klient stejné operace jako server?)

**Mappery** (`lib/core/data/mappers/*.dart`):
- [ ] `entity_mappers.dart` — existuje `fromEntity()` a `toCompanion()` pro **každou** entitu? Porovnej s tabulkou v PROJECT.md.
- [ ] `supabase_mappers.dart` — existuje `toSupabaseJson()` pro **každou** entitu? Jsou všechny sloupce pokryty? Odesílá se `client_created_at`/`client_updated_at` (ne `created_at`/`updated_at`)?
- [ ] `supabase_pull_mappers.dart` — existuje `fromSupabasePull()` pro **každou** entitu? Nastavuje se `lastSyncedAt`, `serverCreatedAt`, `serverUpdatedAt`?
- [ ] **Enum safety** — je `firstWhere` v enum konverzích volán s `orElse`? Bez něj crash na neznámém enum value ze serveru.
- [ ] Konzistence: pokud Drift tabulka má sloupec X, má ho i model, mapper push i mapper pull?
- [ ] Typ safety: jsou `as String`, `as int` casty ošetřeny pro null/chybějící klíče?
- [ ] Enum konverze: odpovídají Dart enum hodnoty Supabase enum hodnotám (1:1 shoda)?

**Business logika mimo core repositories:**
- [ ] `ZReportService` (`lib/features/bills/services/z_report_service.dart`) — korektnost výpočtů (tržby, DPH breakdown, spropitné, slevy, cash reconciliation)? Per-register vs venue-wide agregace?
- [ ] `VoucherDiscountCalculator` (`lib/core/data/utils/voucher_discount_calculator.dart`) — korektnost algoritmu (scope filtering, effective unit price, greedy allocation, proportional split)? Edge cases (nulová cena, prázdné položky)?
- [ ] `session_helpers` (`lib/features/shared/session_helpers.dart`) — sdílená logika pro logout, session close — je kompletní a bezpečná?

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
- `lib/core/sync/` — **všechny** soubory v tomto adresáři (mohou existovat další, např. broadcast/realtime channel)

Checklist:
- [ ] Pull tabulky — je pořadí v seznamu tabulek (hledej konstantu s FK dependency order) správné podle FK závislostí? Srovnej s Supabase FK.
- [ ] Pull tabulky — jsou **všechny** synchronizované tabulky v seznamu? Žádná nechybí?
- [ ] Pull tabulky — jsou v seznamu tabulky, které **neexistují** na Supabase? (crash risk)
- [ ] Pull tabulky — rozlišuje se správně globální vs company-scoped pull? (globální tabulky nemají `company_id` filtr)
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
- [ ] **Realtime/Broadcast** — existuje realtime subscription (broadcast channel)? Pokrývá všechny synchronizované company-scoped tabulky? Je payload unpacking robustní (nested struktura)?
- [ ] **Realtime reconnect** — co se stane při výpadku realtime spojení? Existuje reconnect logika? Fallback na polling?
- [ ] **Merge konzistence** — je path pro realtime merge (single row) konzistentní s batch pull path? Používají totéž LWW rozhodování?
- [ ] **Pull watermark precision** — je watermark (`lastPulledAt`) ukládán s dostatečnou přesností (mikrosekundy)? Hrozí ztráta záznamů při zaokrouhlení?

#### 3.3 Autentizace, bezpečnost a oprávnění

Přečti a analyzuj:
- `lib/core/auth/pin_helper.dart`
- `lib/core/auth/auth_service.dart`
- `lib/core/auth/session_manager.dart`
- `lib/core/auth/supabase_auth_service.dart`
- `lib/core/network/supabase_config.dart`
- `lib/core/utils/` — hledej soubory související s permissions/implications

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

**Permission systém:**
- [ ] **Počet a struktura** — kolik permissions existuje? V kolika skupinách? Sedí seed/migrace s dokumentací a s kódem?
- [ ] **Role šablony** — kolik rolí existuje? Jaké permissions má každá role přiřazené? Sedí se seedem a dokumentací?
- [ ] **Dependency graf** — existuje soubor definující permission dependencies (které permissions vyžadují jiné)? Je graf acyklický? Jsou závislosti kompletní (nechybí očekávané prerequisites)? Jsou oboustranné (grant prerequisites + revoke dependents)?
- [ ] **Permission group guards** — jsou routes/screeny chráněné per-group permission checks? Pokrývají VŠECHNY chráněné routes? Sedí názvy skupin s reálnými permission kódy?
- [ ] **UI permission enforcement** — jsou akční tlačítka, menu položky a formulářové prvky konzistentně gated přes permission providery? Existují akce přístupné bez oprávnění, které by měly být chráněné?
- [ ] **Server-client konzistence** — odpovídají client-side permission checks server-side RLS policies? Může klient odeslat operaci, kterou server odmítne (nebo naopak)?

#### 3.4 UI vrstva

Přečti a analyzuj **každý** screen a widget. Projdi **všechny** `lib/features/*/screens/*.dart` a `lib/features/*/widgets/*.dart` — neomezuj se na konkrétní výčet, projekt se průběžně rozrůstá o nové features/screeny.

Checklist:
- [ ] **Business logika v UI** — je v screen/widget souboru kalkulace, agregace, nebo logika, která patří do repositáře/service? Obzvlášť hledej v komplexních agregačních screenech (statistiky, reporty, Z-reporty) — patří výpočty do UI nebo do service/repository vrstvy?
- [ ] **Hardcoded stringy** — jsou všechny UI texty přes `context.l10n`?
- [ ] **Error states** — rozlišuje se loading vs error v `AsyncValue.when()`? Nebo error zobrazuje spinner?
- [ ] **Mounted checks** — je před každým `setState()` po await kontrola `if (!mounted) return`?
- [ ] **Dispose** — má každý StatefulWidget s controllery/timery `dispose()` metodu?
- [ ] **Touch targets** — jsou všechny buttony >= 40px výška?
- [ ] **Chip/button bars** — dodržuje se pattern z CLAUDE.md (Expanded + SizedBox)?
- [ ] **N+1 v UI** — jsou ve widgetech smyčky s await (query per row)?
- [ ] **Permission checks** — jsou akce chráněné `hasPermissionProvider` nebo group-level permission providerem? Pokrývají VŠECHNY chráněné akce?
- [ ] **Direct DB/Supabase access** — volá UI přímo `appDatabaseProvider` nebo `Supabase.instance.client` místo repositáře?
- [ ] **Processing guard** — mají tlačítka s async akcemi ochranu proti double-tap?
- [ ] **FutureBuilder** — je future vytvořen v `initState`, nebo inline v `build()`? (Inline = recreated on every rebuild)
- [ ] **Dialog width** — jsou šířky dialogů konzistentní?
- [ ] **Agregační screeny** — pokud existují screeny s komplexní agregací dat (statistiky, sales breakdown, Z-reporty), jsou výpočty korektní? Ošetřují edge cases (storno položky, slevy, modifikátory, multi-currency)? Jsou dostatečně výkonné pro velké objemy dat?
- [ ] **Datový pipeline** — propagují se nové sloupce/fieldy (unit type, foreign currency, modifier metadata) kompletně celým UI řetězcem? (cart → order → KDS → bill → receipt → statistiky)

**Tisk a PDF** (`lib/core/printing/`):
- [ ] ReceiptPdfBuilder — jsou výpočty na účtence konzistentní s BillModel? (subtotal, slevy, DPH, total, zaokrouhlení, spropitné)
- [ ] ReceiptData — mapování z BillModel/OrderModel/PaymentModel — pokrývá všechny sloupce?
- [ ] ZReportPdfBuilder — kopíruje strukturu DialogZReport? Jsou výpočty identické?
- [ ] InventoryPdfBuilder — korektní zobrazení skladových dat?
- [ ] Multi-currency — jsou částky v cizí měně správně formátované na účtence?
- [ ] PrintingService — platformové chování (macOS: open, mobile: share)?

**Zákaznický displej a párování:**
- [ ] BroadcastChannel (`lib/core/sync/broadcast_channel.dart`) — join/leave lifecycle, error handling při odpojení?
- [ ] PairingConfirmationListener (`lib/core/widgets/pairing_confirmation_listener.dart`) — race conditions (více požadavků současně)?
- [ ] ScreenCustomerDisplay — korektnost zobrazení módů (idle, cart, active, thank-you)?
- [ ] ScreenDisplayCode — 6-digit kód, timeout, retry logika?
- [ ] DisplayDeviceRepository — manual sync pattern — je outbox správně zaregistrován?
- [ ] `display_devices` RLS — INSERT/UPDATE policies pro pairing flow?
- [ ] RPC `lookup_display_device_by_code` — SECURITY DEFINER, anon access, vrací jen omezená pole?

**Lokalizace** (`lib/l10n/`):
- [ ] Párování klíčů — mají `app_cs.arb` a `app_en.arb` identickou sadu klíčů?
- [ ] Plural formy — jsou plural/select ICU formáty správné pro oba jazyky?
- [ ] Parametrizované řetězce — jsou `{parametry}` konzistentní mezi jazyky?
- [ ] Kompletnost — jsou nově přidané features (demo, voucher, multi-currency, customer display, statistiky) pokryty v obou jazycích?

#### 3.5 Providery a state management

Přečti: `lib/core/data/providers/*.dart`

- [ ] Circular dependencies — závisí providerA na providerB a naopak?
- [ ] `ref.onDispose()` — mají providery s timery/streams/subscriptions cleanup?
- [ ] `appInitProvider` — je inicializační logika kompletní a v správném pořadí?
- [ ] `activeRegisterProvider` / `activeRegisterSessionProvider` — jsou správně invalidovány při změně stavu?
- [ ] **Permission providery** — existují providery pro single-permission check i group-level check? Jsou parametry (permission kód, group prefix) konzistentní s reálnými hodnotami v DB?
- [ ] **Family providery** — jsou `family` providery parametrizovány správným typem? Nehrozí memory leak při velkém počtu unikátních parametrů?
- [ ] **Kompletnost** — mají VŠECHNY nové repozitáře odpovídající provider? Nechybí provider pro žádnou doménovou oblast?

#### 3.6 Routing

Přečti: `lib/core/routing/app_router.dart`

- [ ] Auth guard — je redirect logika kompletní? Pokrývá všechny stavy (no company, no user, no session)?
- [ ] Debug/dev routes — existují routes přístupné bez autentizace nebo permission checku, které by neměly být?
- [ ] Redirect loops — může nastat nekonečný redirect?
- [ ] **Permission guard kompletnost** — mají VŠECHNY chráněné routes permission guard? Používají správný typ (single permission vs group-level check)? Sedí guard parametry s reálnými permission kódy/skupinami?
- [ ] **Deep link / direct navigation** — co se stane, když uživatel bez oprávnění přistoupí k route přímo (ne přes menu)? Je redirect korektní?

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
- [ ] `SnackBar` / `ScaffoldMessenger` — projekt záměrně NEPOUŽÍVÁ snackbary (viz CLAUDE.md). Existují výskyty? (Grep: `SnackBar|ScaffoldMessenger|showSnackBar`)
- [ ] `Supabase.instance.client` mimo datovou vrstvu — přímý přístup k Supabase mimo repositories/providers/services? (Grep: `Supabase.instance` v `lib/features/` — výjimky: onboarding edge function volání, viz Známé vzory bod 20)

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
- [ ] Transaction boundaries — je `_enqueue()` / `_syncQueueRepo.enqueue()` voláno UVNITŘ transakce u VŠECH repozitářů, které provádějí mutace? Zkontroluj SKUTEČNÝ kód (nespoléhej na předpoklady). Nález jen pokud existuje KONKRÉTNÍ repozitář, kde enqueue je MIMO transakci.
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
- [ ] Relativní vs absolutní importy — je konzistentní styl? Nebo mix `import '../...'` a `import 'package:maty/...'`?
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

#### 3.11 Business logika a workflow integrita

Pro každý netriviální business workflow (platba, storno, refund, stock movement, session lifecycle) ověř kompletní řetězec:

- [ ] **Multi-currency** — pokud systém podporuje více měn: je exchange rate aplikován konzistentně? Jsou částky v cizí měně ukládány spolu s kurzem a základní měnou? Jsou agregace (Z-report, statistiky, cash reconciliation) správně převáděny/součtovány?
- [ ] **Stock movements při modifikátorech** — pokud objednávka obsahuje modifikátory se stock-tracked položkami: vytváří se separátní stock movement per modifikátor? Je quantity správně násobena (modifier_qty × parent_item_qty)? Je směr pohybu (inbound/outbound) správný i pro speciální případy (záporné ceny, storno, refund)?
- [ ] **Storno/refund řetězec** — při stornování nebo refundování: jsou VŠECHNY navázané záznamy správně reversovány? (stock movements, cash movements, modifier stock, customer transactions, voucher usage)
- [ ] **Session lifecycle** — otevření/zavření registrové session: jsou všechny peněžní toky (opening cash, closing cash, expected cash, difference) správně počítány? Pokud existuje multi-currency cash tracking, jsou per-currency záznamy vytvářeny/uzavírány konzistentně?
- [ ] **Zamykání konfigurace** — existují business pravidla, která zamykají konfiguraci po prvním použití (např. default měna po prvním účtu, aktivní register po první session)? Je zamykání implementováno na klientu i serveru?

#### 3.12 Logging infrastruktura

Přečti `lib/core/logging/`:
- [ ] LogFileWriter — rotace logů? Maximální velikost souboru?
- [ ] Obsahují logy citlivé informace (PIN hashe, tokeny, hesla)? (Grep v AppLogger voláních)
- [ ] Web vs native implementace — je web stub dostatečný?
- [ ] LogTab v Settings — zobrazuje logy uživatelům, jsou filtrovány citlivé informace?

#### 3.13 Platformová kompatibilita

Přečti `lib/core/platform/`:
- [ ] Conditional export — fungují všechny implementace (native, web, stub)?
- [ ] `saveAndOpen` — platformově specifické chování (macOS: Process.run, mobile: SharePlus)?
- [ ] `deleteDatabaseFiles` — maže WAL/SHM/journal soubory?

---

### FÁZE 4 — Křížová validace (Drift ↔ Supabase ↔ Modely ↔ Mappery)

#### Krok 1: Porovnej seznamy tabulek

Jako **první krok** než začneš per-column srovnání:

1. Vypiš **VŠECHNY** tabulky z Drift (`app_database.dart` — `@DriftDatabase(tables: [...])`)
2. Vypiš **VŠECHNY** tabulky ze Supabase (MCP `list_tables` nebo `information_schema.tables`)
3. Porovnej oba seznamy — hledej tabulky, které existují **POUZE na jedné straně**
4. Tabulky pouze v Drift — NEJPRVE ověř, zda je tabulka v `tableDependencyOrder` (`sync_service.dart`). Pokud ANO a na Supabase neexistuje = **KRITICKÉ** (sync pull/push crash). Pokud NE (např. `device_registrations`, `sync_metadata`, `sync_queue`) = lokální tabulka, **NE NÁLEZ**.
5. Tabulky pouze v Supabase = **VYSOKÉ** (data se nesynchronizují) — pokud nejde o infrastrukturní tabulky (např. `audit_log`, `seed_demo_data`).

Pozn: Identifikuj **local-only tabulky** (existují pouze v Drift, záměrně se nesynchronizují — typicky sync metadata, device registrations apod.) a **infrastrukturní tabulky** (existují na obou stranách, ale mají odlišné schéma — typicky sync outbox). Tyto tabulky NEREPORTUJ jako „chybějící na Supabase". Porovnej je zvlášť s ohledem na jejich specifický účel.

#### Krok 2: Per-column srovnání

Pro **každou sdílenou** tabulku:

1. Vypiš seznam sloupců z Drift (`.dart` soubor, bez sync sloupců z mixinu)
2. Vypiš seznam sloupců ze Supabase (`information_schema.columns`, bez server sync sloupců `created_at`, `updated_at`, `client_created_at`, `client_updated_at`, `deleted_at`)
3. Porovnej — hledej sloupce přítomné **POUZE na jedné straně** (KRITICKÉ)
4. Pro společné sloupce vytvoř srovnávací tabulku:

| Sloupec | Drift typ | Drift nullable | Supabase typ | Supabase nullable | Model field | Push mapper | Pull mapper | Shoda? |
|---------|-----------|----------------|--------------|-------------------|-------------|-------------|-------------|--------|

#### Krok 3: Hledej nesoulady

- Tabulka v pull seznamu ale ne v Supabase → **KRITICKÉ** (sync pull crash)
- Tabulka v Supabase ale ne v pull seznamu → **VYSOKÉ** (data se nesynchronizují)
- NOT NULL sloupec v Supabase bez defaultu chybí v push mapperu → **KRITICKÉ** (INSERT fail)
- Sloupec v Supabase ale ne v Drift (nullable) → **STŘEDNÍ** (no crash, just always NULL, schema drift)
- Sloupec v Drift ale ne v Supabase → **STŘEDNÍ** (push pošle extra field, Supabase ho ignoruje)
- Sloupec je nullable v jednom ale NOT NULL v druhém → závisí na kontextu
- Typ mismatch → **POZOR: `text` vs `uuid` NENÍ mismatch** (viz Známé vzory bod 1). Skutečný mismatch: `integer` vs `text`, `real` vs `integer`, nekompatibilní enum hodnoty
- Sloupec chybí v modelu ale je v Drift a mapperu → **STŘEDNÍ**
- Sloupec chybí v push/pull mapperu → **VYSOKÉ** (data se ztratí při sync)
- Enum hodnoty se liší mezi Dart a Supabase → **VYSOKÉ** (crash při neznámé hodnotě)
- **Nové sloupce na existujících tabulkách** — pokud byla tabulka rozšířena o nové sloupce (FK na jinou tabulku, nullable metadata, apod.), ověř kompletní řetězec: Drift definice → Model → Entity mapper → Push mapper → Pull mapper → UI. Chybějící sloupec v JAKÉMKOLI článku řetězce = data se ztratí.

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
- [ ] Seed data — odpovídá `SeedService` dokumentaci? Porovnej skutečný počet seed záznamů (tax rates, payment methods, sections, categories, items) s docs.
- [ ] Permission kódy — kolik permissions skutečně existuje v DB/seedu/migraci? Sedí s dokumentací? Jsou organizovány ve skupinách — sedí skupiny s kódem?
- [ ] Role šablony — kolik rolí existuje? Jaké permissions má každá role přiřazené (spočítej z migrace/seedu)? Sedí s tabulkou v docs?
- [ ] Permission dependency pravidla — pokud existuje graf závislostí, sedí s reálným chováním UI při grant/revoke?

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
**Confidence:** CONFIRMED / LIKELY / SUSPECTED
**Soubor:** `cesta/soubor.dart:řádek`
**Problém:** 1-2 věty — co je špatně a jaký je dopad.
**Řešení:** 1-2 věty — jak opravit.

(opakuj pro každý nález)
```

---

## FÁZE SLOUČENÍ — Merge & Verify (hlavní konverzace)

Po dokončení všech 3 agentů hlavní konverzace (pokud agent nedokončil do 15 minut, pracuj s dostupnými výstupy — 2/3 stačí pro validní audit):

### Krok 1: Sběr a deduplikace
- Slouč všechny nálezy do jedné tabulky
- Identifikuj duplikáty (shodný soubor + řádek, nebo shodný koncept jinak formulovaný)
- Pro duplikáty: vezmi nejvyšší důvěryhodnost (confidence), ne nejvyšší závažnost

### Krok 2: Klasifikace shody

| Shoda | Akce |
|-------|------|
| 3/3 agentů shodně | → Přijat bez dalšího ověření |
| 2/3 shodně, 1 odlišně | → Přijat, přezkoumej závažnost |
| 1/3 unikátní nález | → POVINNÁ re-verifikace čtením kódu |
| 2/3+ říká NE BUG | → Zamítnut, uveď v sekci zamítnutých |

### Krok 3: Re-verifikace sporných nálezů
Pouze nálezy z kategorie „1/3 unikátní" podléhají re-verifikaci. Postup: přečti zdrojový kód → ověř proti „Známé vzory" → rozhodnutí Přijat/Zamítnut.

### Krok 4: Finální report
Pouze re-verifikované nálezy. Žádné nové nálezy z merge fáze.

---

## FINÁLNÍ REPORT

Stručný, akční report. Žádné srovnávání agentů, žádné detailní tabulky zamítnutých nálezů.

### Metadata
- Datum auditu, codebase stats (počet .dart souborů, řádků, tabulek)
- Stav agentů: α [KOMPLETNÍ/NEKOMPLETNÍ], β [...], γ [...]
- Pokrytí: X/Y fází plně pokryto

### Souhrn
- 2-3 věty o celkovém stavu projektu
- Počet nálezů per závažnost
- Top 3 rizikové oblasti

### Nálezy k řešení

Seřazené do kategorií. **Toto je primární výstup celého auditu.**

**Bezpečnost** (RLS, auth, permissions, tenant isolation)
**Korektnost & Sync** (bugy, chybějící mappery, broken workflows)
**Výkon** (N+1, chybějící indexy, zbytečné rebuildy)
**Kvalita kódu & Konzistence** (styl, best practices)
**Dokumentace** (PROJECT.md vs realita)

```
### [ZÁVAŽNOST] Název nálezu
**Confidence:** CONFIRMED / LIKELY / SUSPECTED
**Problém:** Co je špatně a jaký je dopad.
**Řešení:** Jak opravit.
**Rizika opravy:** Odhad rizikovosti opravy.
```

### Zamítnuté nálezy (stručně)

| Nález | Agenti | Důvod zamítnutí |
|-------|--------|-----------------|

### Nepokryté oblasti

Seznam sekcí, které žádný agent nedokončil (pokud existují).

---

## Časté false positive traps — PŘEČTI PŘED REPORTOVÁNÍM

1. **„Chybějící enqueueAll u repozitáře X"** — Ověř, zda X je BaseCompanyScopedRepository (má enqueueAll z base třídy) nebo manuální (enqueue se řeší v `sync_lifecycle_manager._initialPush` přes `_enqueueCompanyTable`).
2. **„Direct DB access v UI"** — Ověř, zda jde o: a) SharedPreferences (device-local, není DB), b) appDatabaseProvider v onboardingu (před DI), c) appDatabaseProvider pro lokální tabulku (device_registrations). Pouze skutečný Drift select/insert/update/delete doménových dat v screen/widget je nález.
3. **„Neshodný typ text vs uuid"** — NIKDY nereportuj. Známý vzor bod 1.
4. **„Transaction boundary nekonzistence"** — NEPŘEDPOKLÁDEJ, že BillRepository má enqueue mimo transakci. Přečti skutečný kód.
5. **„Chybějící globální tabulky v initial push"** — Globální tabulky jsou server-authoritative, client je nepushuje (kromě onboarding nové firmy, kde se seedují na serveru).
6. **„FutureBuilder s inline future"** — Ověř, jestli future není cachovaná v instanční proměnné (vzor `_cachedKey` + `_future` pattern v `dialog_bill_detail.dart`).
7. **„N+1 query v StreamBuilder"** — StreamBuilder s per-row streamem NENÍ N+1 problém (streamy jsou lazy a reaktivní). N+1 je POUZE: `for (final x in list) { await repo.method(x); }` v async kontextu.


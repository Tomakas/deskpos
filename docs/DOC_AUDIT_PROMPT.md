# Audit dokumentace — PROJECT.md vs. Realita

> **Cíl:** Ověřit, že PROJECT.md přesně popisuje skutečný stav codebase a Supabase.
> Najít: lži, zastaralé informace, chybějící popisy nových features, nesprávné hodnoty.
>
> **Scope:** Pouze správnost a úplnost dokumentace. Žádný code review, žádné best practices.

---

## Jak spustit

```
Spusť audit dokumentace podle docs/DOC_AUDIT_PROMPT.md
```

---

## Strategie: Extract → Scan → Report

```
FÁZE 1 — EXTRACT (hlavní agent)
  Cleanup /tmp/doc-audit → přečti PROJECT.md → zapiš blueprint + self-consistency check
  (Agenti v fázi 2 čtou JEN blueprint, ne celý PROJECT.md)

FÁZE 2 — SCAN (6 background agentů, paralelně)
  Každý agent čte blueprint + svůj výsek kódu/Supabase
  Každý agent zapíše findings do /tmp/doc-audit/NN_*.md
  Výstup se zapisuje do souboru — bez limitu na délku

FÁZE 3 — REPORT (hlavní agent)
  Validuj výstupy agentů (detekce selhání)
  Přečti 6 findings souborů → sestav finální report do konzole
  Deduplikuj dle matice autoritativních agentů
  Re-verifikuj CRITICAL/HIGH nálezy z JINÉHO úhlu než agent
  Volitelně: aplikuj opravy do PROJECT.md (selektivně dle severity)
```

**Proč blueprint:** PROJECT.md je rozsáhlý dokument. Bez blueprintu každý agent čte celý dokument
a plýtvá kontextem. Blueprint extrahuje jen ověřitelná tvrzení.

---

## FÁZE 1 — EXTRACT (hlavní agent)

### Krok 0: Cleanup

```bash
rm -rf /tmp/doc-audit && mkdir -p /tmp/doc-audit
```

Povinné — eliminuje stale soubory z předchozích běhů.

### Krok 1: Čtení PROJECT.md

Přečti PROJECT.md celý (po částech ~500 řádků). Extrahuj do `/tmp/doc-audit/blueprint.md`
**pouze ověřitelná tvrzení** — fakta, která jdou zkontrolovat proti kódu nebo Supabase.

### Krok 2: Self-consistency check

Před zápisem blueprintu projdi extrahovaná data a hledej:

**Numerické rozpory:**
- Stejná metrika s různými hodnotami na různých řádcích? (např. "40 doménových" na řádku X, "42 doménových" na řádku Y)
- Součet, který nesedí? (např. "42 doménových + 1 + 2 = 45" ale jinde text říká "43 aktivních")

**Strukturální rozpory:**
- Tabulka v sekci schema, ale CHYBÍ v sekci sync (tableDependencyOrder)?
- Tabulka v sekci sync, ale CHYBÍ v sekci schema?
- Enum použitý jako typ sloupce v sekci 2, ale NENÍ definován v sekci 3?
- Route v sekci 6, ale screen NENÍ zmíněn v sekci 9 (cesty)?
- Workflow v sekci 5 zmiňuje tabulku, která není v sekci 2?

**Srovnání explicitních seznamů:**
Pokud docs uvádí tentýž seznam na dvou místech (např. tableDependencyOrder
a pullAll entit), porovnej je položku po položce.

Zapiš rozpory přímo do blueprintu jako `⚠ POZOR: rozpor` poznámky — agenti je pak ověří
a určí, která varianta je správná.

### Krok 3: Tagování implementačního stavu

Při extrakci rozlišuj:
- **Task s ✅ checkmarkem** = implementováno → extrahuj do sekcí 1–9
- **Task bez checkmarku v Etapě ≤ 3** = pravděpodobně implementováno → extrahuj do sekcí 1–9
- **Task bez checkmarku v Etapě 4+** = plánováno → extrahuj do sekce 10
- **Schema sloupce/routes/enumy z plánovaných tasků** → sekce 10, NE do sekcí 2/3/6

### Struktura blueprintu

```markdown
# Blueprint — ověřitelná tvrzení z PROJECT.md

## 1. ČÍSLA A POČTY (PROJECT.md sekce X, cca řádky N–M)
Přesné numerické tvrzení z docs:
- "45 tabulek (42 doménových + 1 device_registrations + 2 sync)"
- "113 permissions"
- "287 role_permissions (19+63+92+113)"
- "3 tax rates, 5 payment methods"
- "38 broadcast triggerů"
- "23 PG enumů (21 doménových + 2 systémové)"
- (všechna další čísla)
⚠ POZOR: sekce X říká "40", sekce Y říká "42" — rozpor, ověřit.

## 2. TABULKY A SLOUPCE (PROJECT.md sekce X, cca řádky N–M)
Pro každou tabulku v docs:
### [table_name] — ✅ implementováno / ⏳ plánováno
| Sloupec | Typ (dle docs) | Nullable (dle docs) | Default (dle docs) | FK (dle docs) |
Poznámka: jen co docs explicitně uvádí. Pokud docs neuvádí typ, zapsat "neuveden".

## 3. ENUMY (PROJECT.md sekce X, cca řádky N–M)
Pro každý enum v docs:
### [EnumName] — ✅/⏳
- Hodnoty: [a, b, c]
- Explicitní "neobsahuje" tvrzení: "neobsahuje voucher, points" (pokud existuje)

## 4. SYNC TVRZENÍ (PROJECT.md sekce X, cca řádky N–M)
- Pull tabulky pořadí (dle docs) — kompletní seznam
- Outbox pravidla: konfigurační entity (BaseCompanyScopedRepository) + prodejní entity (vlastní _enqueue*)
- LWW popis (dle docs)
- Realtime popis (dle docs)
- Počet synchronizovaných tabulek
- companyRepos list + výjimky

## 5. WORKFLOW POPISY (PROJECT.md sekce X, cca řádky N–M)
Pro každý popsaný workflow:
### [workflow_name]
- Kroky: 1. ..., 2. ..., 3. ...
- Transakčnost: ano/ne (dle docs)
- Mermaid diagram: ano/ne (pokud ano, extrahuj klíčové přechody/stavy)

## 6. ROUTES A SCREENY (PROJECT.md sekce X, cca řádky N–M)
| Route (dle docs) | Screen (dle docs) | Guard (dle docs) | Taby (dle docs) |

## 7. SUPABASE TVRZENÍ (PROJECT.md sekce X, cca řádky N–M)
- RLS pravidla (co docs slibují)
- Triggery (co docs slibují) — počty, naming, scope
- Edge Functions (názvy + popis + cesta k souboru + klíčové chování)
- Databázové RPC funkce (názvy + SECURITY DEFINER/INVOKER)
- Seed data popis
- Server-only tabulky
- Migrace — zmíněné konvence

## 8. ARCHITEKTONICKÁ PRAVIDLA (PROJECT.md sekce X, cca řádky N–M)
Všechna "MUSÍ"/"NESMÍ"/"vždy"/"nikdy" tvrzení:
- "všechny doménové tabulky mají SyncColumnsMixin"
- "monetární sloupce jsou vždy integer (haléře)"
- (všechna další)

## 9. CESTY K SOUBORŮM A STRUKTURY (PROJECT.md sekce X, cca řádky N–M)
Všechny zmínky konkrétních cest, názvů tříd, názvů souborů, počtů souborů:
- "lib/core/data/repositories/ — 43 souborů"
- "lib/core/data/providers/ — 7 souborů"
- (všechny další)

## 10. PLÁNOVANÉ FEATURES (Etapa 4+)
Features explicitně označené jako budoucí nebo v nehotových etapách.
Včetně sloupců, routes, enumů z plánovaných tasků (viz Krok 3).

Pravidla pro agenty:
- Docs tvrdí "plánováno" a kód neexistuje → NE nález (docs správně)
- Docs tvrdí "plánováno" ale feature je PLNĚ implementována → HIGH
- Docs tvrdí "plánováno" ale existují částečné artefakty (soubory, stubs) → DOC DEBT
- Detailně specifikované tasky (Task4.18–4.31) — ověřit zda soubory EXISTUJÍ

## 11. UI BEHAVIOR CLAIMS (PROJECT.md sekce X, cca řádky N–M)
Specifické UI behavioral claims ověřitelné proti widget kódu:
- Počty tabů per screen + názvy tabů
- Widget usage counts (např. "PosTable: 35 použití ve 20 souborech")
- State machine chování (stavy CustomerDisplay, BillStatus přechody)
- Specifické interakce (triple-tap, long-press)
- Dialog dimensions, specifické widgety per screen
- Permission kódy použité v guardech

## 12. PERMISSION CATALOG (PROJECT.md sekce X, cca řádky N–M)
- Kompletní seznam permission kódů (113)
- Skupiny (17) s počty per skupina
- Role templates (helper: 19, operator: 63, manager: 92, admin: 113)
- Souhrnná matice per role per skupina
- Celkový součet 287 role_permissions
```

**Pravidla pro extrakci:**
- Extrahuj POUZE to, co docs říkají. Žádné vlastní interpretace.
- Řádkové reference uváděj PER SEKCI (rozsah řádků), ne per tvrzení.
- Pokud docs jsou nejednoznačné, zapiš obě interpretace.
- Blueprint musí být self-contained — agenti NEČTOU PROJECT.md.
- Taguj tvrzení jako ✅ (implementováno) nebo ⏳ (plánováno) dle Kroku 3.

---

## FÁZE 2 — SCAN (6 paralelních agentů)

Spusť všech 6 najednou přes Task tool s `run_in_background: true`.

Každý agent dostane:
1. Instrukci přečíst `/tmp/doc-audit/blueprint.md`
2. Svůj scope (které soubory/SQL zkontrolovat)
3. Instrukci zapsat findings do svého output souboru
4. Sdílená pravidla (viz konec dokumentu)

---

### Agent 1: SCHEMA + ENUMY + PROVIDERS — Tabulky, sloupce, enumy, počty souborů, providery

**Čte:** Blueprint sekce 1, 2, 3, 8, 9
**Kontroluje:** `lib/core/database/tables/*.dart`, `lib/core/database/app_database.dart`, `lib/core/data/enums/*.dart`, `lib/core/data/models/*.dart`, `lib/core/data/repositories/*.dart`, `lib/core/data/providers/*.dart`, `lib/core/printing/*.dart`, `lib/core/widgets/*.dart`
**Píše do:** `/tmp/doc-audit/01_schema_enums.md`
**Autoritativní pro:** počty tabulek, sloupce (Drift), enum hodnoty, počty souborů

**Úkoly:**
1. Pro každou ✅ tabulku v blueprintu najdi `.dart` soubor a porovnej sloupce:
   - Sloupec v docs ale NE v Drift? → MEDIUM (pokud ✅) nebo ignoruj (pokud ⏳)
   - Sloupec v Drift ale NE v docs? → DOC DEBT
   - Typ v docs nesedí s Drift? → MEDIUM
   - Default v docs nesedí s Drift? → MEDIUM
2. Ověř numerická tvrzení: počet tabulek, "všechny mají SyncColumnsMixin" (vzorkuj 5 tabulek), atd.
3. Ověř počty souborů v adresářích (viz **Počítací protokol** v sdílených pravidlech):
   - `lib/core/database/tables/*.dart`
   - `lib/core/data/models/*.dart`
   - `lib/core/data/repositories/*.dart`
   - `lib/core/data/enums/*.dart`
   - `lib/core/data/providers/*.dart`
   - `lib/core/printing/*.dart`
   - `lib/core/widgets/*.dart`
   - `lib/core/data/utils/*.dart`
4. Zkontroluj `@DriftDatabase(tables: [...])` — sedí počet a seznam s docs?
5. Pro každý ✅ enum v blueprintu porovnej hodnoty s Dart kódem:
   - Hodnota v docs ale NE v kódu? → MEDIUM
   - Hodnota v kódu ale NE v docs? → DOC DEBT
   - Docs tvrdí "neobsahuje X" ale kód X obsahuje? → CRITICAL (explicitní lež)
6. Najdi enumy v `lib/core/data/enums/` které NEJSOU v blueprintu → DOC DEBT
7. Pokud blueprint obsahuje ⚠ POZOR o rozporu, urči správnou hodnotu.
8. Ověř provider soubory v `lib/core/data/providers/`:
   a) Spočítej soubory — docs tvrdí 7
   b) Pro `repository_providers.dart` — spočítej provider definice (docs tvrdí 42)
   c) Pro každý provider soubor v blueprintu — existují uvedené providery?
   d) Provider v docs ale ne v kódu? → MEDIUM
   e) Provider v kódu ale ne v docs? → DOC DEBT
9. Ověř printing infrastrukturu:
   a) Glob `lib/core/printing/*.dart` — sedí seznam souborů s docs?
   b) Existují bundlované fonty v `assets/fonts/`?
10. Ověř core widget claims z blueprintu sekce 11:
    a) Glob `lib/core/widgets/*.dart` — sedí seznam s docs?
    b) Grep `PosTable` across codebase — ověř usage count pokud docs uvádí
    c) Grep `PosNumpad` — ověř usage count pokud docs uvádí
11. **Reverzní scan:** Glob každý kontrolovaný adresář a porovnej se seznamem v blueprintu.
    Soubory/entity v kódu ale ne v blueprintu → DOC DEBT (reportuj skupinově, ne per-soubor).

---

### Agent 2: SYNC + MAPPERS

**Čte:** Blueprint sekce 4, 8
**Kontroluje:** `lib/core/sync/*.dart`, `lib/core/data/mappers/*.dart`, `lib/core/data/providers/sync_providers.dart`
**Píše do:** `/tmp/doc-audit/02_sync.md`
**Autoritativní pro:** sync table list, outbox vzory, LWW, realtime

**Úkoly:**
1. Porovnej `tableDependencyOrder` pořadí v `sync_service.dart` s blueprintem sekce 4.
   - Tabulka v docs ale ne v kódu? → MEDIUM
   - Tabulka v kódu ale ne v docs? → DOC DEBT
2. Ověř outbox pravidla popsaná v docs — sedí s `outbox_processor.dart`?
3. Ověř LWW popis — sedí s implementací?
4. Ověř realtime popis — sedí s implementací?
5. Zkontroluj `sync_lifecycle_manager.dart` — initial push odpovídá docs?
6. Zkontroluj zda pro každou entitu existuje push mapper (`supabase_mappers.dart`)
   a pull mapper (`supabase_pull_mappers.dart`) — pokud docs tvrdí, že se synchronizuje.
7. Zkontroluj `companyRepos` list v `sync_providers.dart` — sedí s klasifikací v docs?
   Pokud docs klasifikuje entitu jako BaseCompanyScopedRepository ale není v `companyRepos`, je to nález.
8. Ověř dva vzory outbox zápisu:
   a) Konfigurační entity v docs — dědí skutečně z `BaseCompanyScopedRepository`?
      Grep `extends BaseCompanyScopedRepository` v repository souborech.
   b) Prodejní entity v docs — mají injektovaný `SyncQueueRepository`?
      Grep `SyncQueueRepository` v příslušných repository souborech.
   c) Ověř výjimky zmíněné v docs (např. `order_item_modifiers` ne v `companyRepos`).

---

### Agent 3: SUPABASE + MIGRACE — Server vs. docs

**Čte:** Blueprint sekce 7
**Kontroluje:** Supabase přes MCP (execute_sql, list_tables, list_edge_functions, list_migrations, get_advisors) + `supabase/functions/*/index.ts` + `supabase/migrations/*.sql`
**Píše do:** `/tmp/doc-audit/03_supabase.md`
**Autoritativní pro:** Supabase-specifické aspekty (RLS, triggery, EF, RPC, PG enum sort order, migrace)

**Úkoly:**
1. Spusť SQL dotazy pro získání reálného stavu:

```sql
-- Tabulky a sloupce
SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' ORDER BY table_name, ordinal_position;

-- Enumy (včetně sort order)
SELECT t.typname, e.enumlabel, e.enumsortorder
FROM pg_type t JOIN pg_enum e ON t.oid = e.enumtypid
ORDER BY t.typname, e.enumsortorder;

-- RLS stav
SELECT tablename, rowsecurity FROM pg_tables
WHERE schemaname = 'public' ORDER BY tablename;

-- RLS policies
SELECT tablename, policyname, cmd, roles, qual, with_check
FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename;

-- Triggery
SELECT event_object_table, trigger_name, event_manipulation, action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public' ORDER BY event_object_table;

-- Funkce (PG RPC) — pouze aplikační
SELECT proname, prosecdef, proconfig
FROM pg_proc WHERE pronamespace = 'public'::regnamespace
ORDER BY proname;

-- Počet broadcast triggerů
SELECT count(*) FROM information_schema.triggers
WHERE trigger_schema = 'public' AND trigger_name LIKE 'trg_%_broadcast';

-- Počet LWW triggerů
SELECT count(*) FROM information_schema.triggers
WHERE trigger_schema = 'public' AND trigger_name LIKE '%lww%';

-- Verify docs-mentioned RPC functions
SELECT proname, prosecdef FROM pg_proc
WHERE pronamespace = 'public'::regnamespace
AND proname IN ('lookup_display_device_by_code', 'create_demo_company', 'get_my_company_ids');

-- pg_cron jobs (demo cleanup)
SELECT jobname, schedule, command FROM cron.job;
```

2. Porovnej Supabase enum hodnoty s blueprintem — POUZE PG-specifické aspekty:
   - Počet PG enumů (docs tvrdí "23 PG enumů")
   - PG sort order odchylky (pouze pokud docs uvádí specifické pořadí)
   - Enumy existující v PG ale ne v Dartu (nebo naopak)
   - NEopakuj "hodnota X chybí v docs" — to patří Agent 1.
3. Porovnej Supabase sloupce s blueprintem — POUZE Supabase-specifické odchylky:
   - Supabase-only sloupce (neexistující v Drift)
   - Typy specifické pro Supabase (timestamptz vs datetime, uuid vs text)
   - NEopakuj obecné "column missing from docs" — to patří Agent 1.
4. Docs tvrdí RLS policies existují — existují skutečně? Jaké role mají přístup?
5. Docs tvrdí triggery existují — existují skutečně? Počty sedí?
6. Porovnej Edge Functions nasazené na serveru (`list_edge_functions`) se soubory v `supabase/functions/*/index.ts` a s docs:
   - EF v repo ale ne na serveru? → nález
   - EF na serveru ale ne v docs? → DOC DEBT
   - Docs tvrdí "kód není v repozitáři" ale soubor existuje? → nález
7. Porovnej PG RPC funkce (databázové funkce) s docs — chybí? špatně klasifikované?
8. Spusť `get_advisors(type: "security")` — jsou varování relevantní pro docs?
9. Spot-check Edge Function kód:
   a) `supabase/functions/ingest/index.ts` — ALLOWED_TABLES obsahuje počet tabulek dle docs?
   b) `supabase/functions/wipe/index.ts` — existuje? Maže v reverse FK order?
   c) `supabase/functions/create-demo-data/index.ts` — existuje? Abuse guard přítomen?
10. Migrace — porovnej repo vs. server:
    a) `list_migrations` přes MCP — získej applied migrace na serveru.
    b) Glob `supabase/migrations/*.sql` — migrační soubory v repo.
    c) Migrace v repo ale NE na serveru + docs popisují feature jako hotovou? → HIGH
    d) Migrace na serveru bez souboru v repo? → DOC DEBT
    e) Nestandardní naming migrací = DOC DEBT, ne CRITICAL.

---

### Agent 4: KŘÍŽOVÁ VALIDACE — Počty a konzistence

**Čte:** Blueprint sekce 1, 8, 12
**Kontroluje:** Klíčové soubory ze VŠECH agentových scopes (jen pro cross-check)
**Píše do:** `/tmp/doc-audit/04_cross_check.md`
**Autoritativní pro:** cross-cutting numerická tvrzení, architektonická pravidla

**Úkoly:**
1. Pro každé numerické tvrzení v blueprintu (sekce 1) ověř z VÍCE než jednoho zdroje:
   - "42 doménových tabulek" → `@DriftDatabase` count AND `tableDependencyOrder` count AND Supabase table count (Glob + Grep, ne SQL — to dělá Agent 3)
   - "38 company-scoped" → `ALLOWED_TABLES` v ingest EF AND broadcast trigger count v blueprintu AND `companyRepos` + výjimky
   - "113 permissions" → Dart seed_service AND blueprint sekce 12
   - "23 PG enumů" → count v `lib/core/data/enums/` (minus SellMode + barrel) AND PG enum count z blueprintu
2. Pro každý vnitřní rozpor (⚠ POZOR poznámky) urči správnou hodnotu
   ověřením v kódu (Glob/Grep, ne ruční počítání).
3. Ověř architektonická pravidla (sekce 8) VZORKOVÁNÍM:
   - Vyber 5 náhodných doménových tabulek a ověř, že mají `SyncColumnsMixin`
   - Vyber 3 náhodné repozitáře a ověř, že monetární sloupce jsou integer
   - Vyber 3 náhodné screen soubory a ověř, že neobsahují přímé DB dotazy
4. Ověř, že čísla v různých sekcích blueprintu jsou vzájemně konzistentní
   (42 domain tables v schema == 42 v sync == 42 v pull order atd.).
5. Ověř permission system (blueprint sekce 12):
   a) Spočítej permissions v `seed_service.dart` — sedí 113?
   b) Extrahuj seznam permission kódů a porovnej s blueprintem 1:1.
   c) Ověř skupinové počty (17 skupin) — sečti permissions dle prefixu.
   d) Ověř role template počty: helper 19, operator 63, manager 92, admin 113.
   e) Ověř celkový součet 287 role_permissions (19+63+92+113).
   f) Spot-check 5 permission kódů v `hasPermissionProvider`/`hasAnyPermissionInGroupProvider`
      usage ve widgetech — odpovídají kódy v kódu kódům v docs?

---

### Agent 5: ROUTES + SCREENY + TABY + L10N

**Čte:** Blueprint sekce 6, 9, 11
**Kontroluje:** `lib/core/routing/app_router.dart`, `lib/features/*/screens/*.dart`, `lib/features/*/widgets/dialog_*.dart`, `lib/l10n/*.arb`
**Píše do:** `/tmp/doc-audit/05_routes_screens.md`
**Autoritativní pro:** routes existence, screeny, taby, dialogy, lokalizace

**Úkoly:**
1. Porovnej routes v `app_router.dart` s blueprintem:
   - Route v docs ale ne v kódu? → nález
   - Route v kódu ale ne v docs? → DOC DEBT
   - Permission guard nesedí? → nález
2. Pro každý screen zmíněný v docs ověř:
   - Existuje? Má správný název třídy? Souhlasí soubor?
   - Tab struktura sedí s docs? (TabController length, tab labels/enum values)
   - Tab pořadí sedí?
3. Spočítej dialogy (`dialog_*.dart`) v každém feature adresáři — sedí s docs?
4. Existují screeny v kódu které NEJSOU v docs? → DOC DEBT.
   **File tree scope:** Docs file tree je kuratovaný přehled, NE exhaustivní listing.
   Reportuj jako DOC DEBT POUZE:
   - Celé nové feature adresáře (`lib/features/X/`) chybějící v docs
   - Nové screeny (`screen_*.dart`) chybějící v docs
   - Nové routes (`GoRoute`) chybějící v docs route tabulce
   NE-reportuj: jednotlivé widget/helper soubory uvnitř existujících feature adresářů.
5. Ověř cesty k souborům zmíněné v docs — existují? (`lib/features/` struktura)
6. Ověř lokalizaci:
   a) Spočítej klíče v `lib/l10n/app_cs.arb` a `lib/l10n/app_en.arb` — sedí počty?
   b) Pokud blueprint zmiňuje konkrétní l10n klíče, ověř že existují v ARB souborech.
   c) Spot-check 5 screen souborů pro hardcoded české/anglické stringy v UI
      (hledej přímé texty v `Text()` widgetech mimo `l10n`).
7. Ověř ScreenCustomerDisplay behavior claims z blueprintu sekce 11:
   a) Existují dokumentované stavy (idle, cart preview, active, thank you) v kódu?
   b) Triple-tap odpárování — existuje v kódu?
   c) 5s ThankYou timer — existuje v kódu?
8. Ověř specificky ScreenStatistics — docs tvrdí N tabů s konkrétními názvy.
   Glob `lib/features/statistics/**/*.dart` a ověř existenci widgetů zmíněných v docs.

---

### Agent 6: WORKFLOWS + SEED + AUTH + DIAGRAMS

**Čte:** Blueprint sekce 5, 7 (seed data), 10, 11, 12
**Kontroluje:** `lib/core/data/repositories/*.dart`, `lib/core/data/services/seed_service.dart`,
  `lib/core/auth/*.dart`, `lib/features/sell/screens/screen_sell.dart`, `lib/features/bills/`,
  `lib/core/printing/*.dart`
**Píše do:** `/tmp/doc-audit/06_workflows.md`
**Autoritativní pro:** workflow kroky, seed data, auth flow, Mermaid diagramy, printing obsah

**Úkoly:**
1. Pro každý workflow v blueprintu najdi implementaci a porovnej kroky:
   - Krok v docs ale ne v kódu? → nález (docs slibují víc než kód dělá)
   - Krok v kódu ale ne v docs? → DOC DEBT (docs neúplné)
   - Pořadí kroků jiné? → nález
   - Docs říkají "v transakci" ale kód nemá `transaction()`? → nález
   Pokud zjistíš, že screen/route neexistuje, NEHLÁSÍ to — to patří Agent 5.
   Hlásíš pouze: kroky workflow nesedí, chybí transakce, chybí větev.
2. Ověř seed data: `seed_service.dart` vs. blueprint sekce 7
   - Počty sedí? (tax rates, payment methods, permissions, roles, items...)
   - Defaultní hodnoty sedí? (názvy, typy, is_default flagy)
3. Zkontroluj plánované features (blueprint sekce 10):
   - Pokud na některé už začala práce (existují soubory, widgety, taby), reportuj DOC DEBT.
   - Pokud docs tvrdí "plánováno" ale feature je PLNĚ implementována → **HIGH**
   - Detailně specifikované tasky (Task4.18–4.31) — ověř zda soubory EXISTUJÍ.
4. Zkontroluj Quick Sale specificky: retail vs. gastro mode chování, cart separátory,
   customer display integrace — jsou v docs?
5. Ověř Mermaid diagramy v blueprintu (sekce 5):
   a) BillStatus state diagram — odpovídají přechody implementaci v `BillRepository`?
      - Přechod v diagramu ale ne v kódu? → MEDIUM
      - Přechod v kódu ale ne v diagramu? → DOC DEBT
   b) PrepStatus state diagram — odpovídají přechody implementaci v `OrderRepository`?
   c) Sync lifecycle diagram — odpovídá sekvence v `SyncLifecycleManager`?
   d) Quick Sale / Table Sale sequence diagrams — odpovídají volání repository metod?
6. Ověř autentizační flow:
   a) `auth_service.dart` — odpovídají lockout prahy v kódu dokumentaci?
   b) `pin_helper.dart` — formát hash je jak docs tvrdí?
   c) `session_manager.dart` — multi-session model (více přihlášených, jeden aktivní)?
7. Pro klíčové repozitáře v blueprintu (BillRepository, OrderRepository, RegisterRepository):
   - Existují business metody zmíněné v docs? Grep název metody v odpovídajícím `.dart` souboru.
8. Ověř printing content claims:
   a) `ReceiptPdfBuilder` — generuje hlavičku firmy, DPH rekapitulaci, spropitné?
   b) `ZReportPdfBuilder` — kopíruje strukturu `DialogZReport`?
   c) (Stačí Grep pro klíčové sekce v builder souborech)

---

## Sdílená pravidla pro všechny agenty

### Kategorie nálezů

| Kategorie | Definice | Rozhodovací kritérium | Příklad |
|-----------|----------|-----------------------|---------|
| **CRITICAL** | Docs explicitně tvrdí opak reality v **sémantickém** smyslu: funkce existuje/neexistuje, enum hodnota je/není přítomna, tabulka existuje/neexistuje. | "Docs říkají X, kód dělá NOT-X" | "neobsahuje voucher" ale kód voucher má |
| **HIGH** | Docs popisují neexistující feature jako hotovou, nebo zamlčují existující feature s dopadem na sync/data/security. | Feature chybí úplně, nebo chybějící popis má provozní dopad | Tabulka v docs neexistuje v kódu. Nenasazená migrace pro dokumentovanou feature. |
| **MEDIUM** | Kvantitativní nepřesnosti (počty, typy, defaulty) nebo neplatné cesty. | Informace je nepřesná ale čtenář by se nerozhodl špatně | Počet tabulek nesedí. Typ sloupce jiný. Cesta k souboru neplatná. |
| **LOW** | Kosmetické nepřesnosti bez dopadů na pochopení. | Čtenář by pochopil správně i bez opravy | camelCase vs snake_case. Překlep. |
| **DOC DEBT** | Realita se změnila, docs neaktualizovány. Není lež — jen zastaralé. | "Kód přidal X, docs o X neříkají nic" | Nový dialog v kódu není ve file tree. Nový sloupec bez docs. |

**Pravidlo konzistence:** Pokud 2 agenti najdou tentýž fakt s různou severity,
Fáze 3 použije VYŠŠÍ z nich a vysvětlí proč.

**Zakázané labely:** Agenti NESMÍ používat `[INFO]`, `[MINOR]`, `[NOTE]` nebo jiné
ad-hoc labely. Každý nález MUSÍ mít jednu z 5 oficiálních kategorií.

**Chybějící sloupec v docs — klasifikace DOC DEBT:**
- Sloupec je v `supabase_mappers` / `supabase_pull_mappers` → HIGH (sync-relevant)
- Sloupec je FK nebo mění business logiku → HIGH
- Sloupec je nullable s defaultem, není v mapperu → MEDIUM
- Sloupec je kosmetický (label, color, sort_order) → LOW

### Globální ignorované položky

Následující NEJSOU nálezy a agenti je MUSÍ ignorovat:

- **Sync/timestamp sloupce z mixinu:** `lastSyncedAt`, `version`, `serverCreatedAt`, `serverUpdatedAt`, `createdAt`, `updatedAt`, `deletedAt` — docs je neuvádí per-table (popsáno centrálně v SyncColumnsMixin)
- **Supabase sync/timestamp sloupce:** `created_at`, `updated_at`, `client_created_at`, `client_updated_at`, `deleted_at`, `version`, `last_synced_at`, `server_created_at`, `server_updated_at` — popsáno centrálně, ne per-table
- **`sync_metadata` a `device_registrations`** neexistují na Supabase — záměr
- **Drift `text()` pro UUID a FK reference:** Standardní. Docs notace `→companies` značí logický FK (enforced na Supabase), ne Drift FK constraint. FK ověřuj JEN na Supabase straně (Agent 3).
- **Generované soubory** (`*.freezed.dart`, `*.g.dart`) — nepočítej při ověřování počtů souborů
- **Barrel soubory** (soubory obsahující pouze `export` direktivy, např. `enums/enums.dart`) — nepočítej jako definice
- **`@DataClassName` anotace** — Drift entity name může být jiný než název tabulky, to je záměr
- **Plánované features** z blueprintu sekce 10 — viz pravidla v sekci 10
- **Enum ordering PG vs Dart:** Pořadí hodnot v Dart a PG enumu se OČEKÁVANĚ liší (PG závisí na `ALTER TYPE ADD VALUE`). Nesoulad v pořadí je nález POUZE pokud docs explicitně tvrdí konkrétní pořadí a to nesedí, NEBO aplikační logika závisí na `.index` / sort order.
- **`SellMode` v PG enum srovnání:** Záměrně TEXT, ne PG enum. Docs to explicitně říkají.
- **Globální tabulky bez `company_id`:** `roles`, `permissions`, `role_permissions`, `currencies` jsou globální (server-owned, seeded migrací). Nemají `company_id` ani `SyncColumnsMixin` — záměr.
- **PG funkce z extensions:** PostGIS, pg_stat, pg_trgm, Supabase internal. Reportuj POUZE aplikační funkce zmíněné v docs.
- **Supabase internal triggery:** `supabase_realtime`, `pg_net` atd. nejsou v scope auditu.
- **Indexy:** Docs popisují indexovací strategii a vybrané příklady, ne exhaustivní seznam. Nehlásit chybějící dokumentaci per-index.
- **Syntax default hodnot Drift vs Supabase:** `Constant(true)` vs `DEFAULT true`, `currentDateAndTime` vs `DEFAULT now()` — ověřuj pouze sémantickou shodu.
- **Počty souborů v `tables/`:** Docs uvádí souhrnný počet. Ověřuj celkový počet, ne jména souborů.

### Output formát (striktně dodržovat)

Každý output soubor MUSÍ začínat YAML frontmatter blokem:

```markdown
---
agent: 01_schema_enums
blueprint_sections: [1, 2, 3, 8, 9]
items_checked: 83
findings_count: 5
findings_by_severity:
  critical: 0
  high: 0
  medium: 2
  low: 1
  doc_debt: 2
---

# [NN] [NÁZEV OBLASTI]
> Ověřeno: X položek z blueprintu | Nálezů: Y

## Nálezy

### [CRITICAL/HIGH/MEDIUM/LOW/DOC DEBT] Stručný název
- **Docs:** přesná citace nebo parafráze z blueprintu (sekce + tvrzení)
- **Realita:** co kód/Supabase skutečně obsahuje (`soubor:řádek`)
- **Oprava docs:**
  1. **Kde:** Přesná sekce v PROJECT.md (název sekce)
  2. **Smazat/Změnit:** Přesný stávající text (citace)
  3. **Nahradit:** Přesný nový text
  POUZE docs oprava. Nikdy nenavrhuj změnu kódu.

(opakuj pro každý nález)

## Ověřeno bez nálezů (výběr klíčových kontrol)

Stručný seznam ověřených položek kde docs odpovídají realitě (tabulka/bullet points).
Slouží jako důkaz důkladnosti — hlavní agent ví co bylo zkontrolováno.
```

### Pravidla

1. **Jen delta.** Neopisuj detailně co sedí. Ale uveď stručný seznam ověřených položek
   na konci (viz output formát) — hlavní agent potřebuje vědět co bylo zkontrolováno.
2. **Buď důkladný.** Output jde do souboru, ne do hlavního kontextu — piš tolik detailů kolik potřebuješ.
   U každého nálezu uveď kompletní kontext, citace, a navrhovanou opravu.
3. **Vždy cituj docs** — sekce v blueprintu + co docs tvrdí.
4. **Vždy cituj realitu** — soubor:řádek + co kód/DB skutečně obsahuje.
5. **Navrhni opravu** ve formátu Kde/Smazat/Nahradit. Nikdy nenavrhuj změnu kódu — to je mimo scope.
6. **Plánované features (⏳)** — viz rozhodovací strom v blueprintu sekci 10.
7. **Nepřidávej code review nálezy.** Scope = documentation accuracy ONLY. Nereportuj:
   chybějící error handling, nepoužívané imports, suboptimální implementace, missing tests.
   Reportuj POUZE: docs říkají X, realita je Y.
8. **Drift `text()` pro UUID a FK** — viz Globální ignorované položky.
9. **Piš findings do souboru přes Write tool**, ne jako textový output.
10. **Ověřuj i vnitřní konzistenci.** Pokud blueprint obsahuje ⚠ POZOR poznámku o rozporu,
    ověř které číslo je správné a zahrň do findings.
11. **Při pochybnostech ověř.** Lepší 1 Read/Grep tool navíc než chybný nález.
    Nepočítej ručně — nech Glob spočítat soubory, nech Grep najít výskyty.
12. **Ověř PŘED zápisem.** Nepřidávej nález, dokud jsi ho neověřil čtením kódu.
    Nikdy nepiš "STORNO" — prostě nález nezapisuj. Pokud jsi na pochybách,
    přečti zdrojový soubor ještě jednou. Každý nález v output souboru MUSÍ být
    finální — hlavní agent na něj spoléhá bez dalšího filtrování.
13. **Počítací protokol:** Při ověřování počtů souborů v adresářích:
    - Použij Glob pro získání seznamu
    - ODFILTRUJ generované soubory: `*.freezed.dart`, `*.g.dart`
    - ODFILTRUJ barrel soubory (pouze `export` direktivy)
    - Výsledný počet porovnej s docs
    - V nálezech uveď: "Glob vrátil X souborů, po odfiltrování Y generovaných = Z"
14. **Bidirectional check:** Po ověření blueprintových tvrzení proveď reverzní scan:
    Glob příslušné adresáře a porovnej skutečný obsah se seznamem v blueprintu.
    Soubory/entity v kódu ale ne v blueprintu → DOC DEBT (reportuj skupinově).
15. **Křížová kontrola počtů:** Pokud blueprint uvádí stejné číslo v různých kontextech
    (např. "42 doménových tabulek" v sekci schema i v sekci sync), ověř obojí nezávisle.

---

## FÁZE 3 — REPORT (hlavní agent)

Po dokončení všech 6 agentů:

### Krok 0: Validace výstupů

Pro každý očekávaný soubor (`01_schema_enums.md` až `06_workflows.md`):
1. Existuje soubor? Pokud ne → agent selhal. Zaznamej a pokračuj.
2. Obsahuje soubor YAML frontmatter? Pokud ne → agent nedodržoval formát.
3. Má soubor `items_checked > 0`? Pokud `items_checked = 0` → agent pravděpodobně selhal.
4. Pokud agent měl zkontrolovat N položek a zkontroloval < 50%, označ jako INCOMPLETE.

Pokud některý agent selhal nebo je INCOMPLETE:
- Vypiš varování: "⚠ Agent NN selhal/neúplný — oblast XY nebyla plně auditována"
- Zeptej se uživatele, zda chce agenta spustit znovu (jednotlivě, ne celou fázi)

### Krok 1: Čtení a sloučení

Přečti soubory `/tmp/doc-audit/01_schema_enums.md` až `/tmp/doc-audit/06_workflows.md`.

### Krok 2: Deduplikace dle matice

**Deduplikační matice — autoritativní agent per oblast:**

| Oblast | Autoritativní agent | Ostatní agenti |
|--------|---------------------|----------------|
| Počet tabulek | Agent 1 (`@DriftDatabase`) | Agent 2 jen delta, Agent 4 cross-check |
| Sloupce tabulek | Agent 1 (Drift) | Agent 3 jen Supabase-specifické odchylky |
| Enum hodnoty | Agent 1 (Dart) | Agent 3 jen PG sort order |
| Sync table list | Agent 2 | Agent 1 jen total count |
| Routes/screeny existence | Agent 5 | Agent 6 jen chování |
| Trigger počty | Agent 3 | Agent 4 cross-check |
| Permission kódy | Agent 4 (cross-check) | Agent 6 jen seed counts |
| Workflow kroky | Agent 6 | Agent 2 jen sync-related kroky |

**Merge protokol pro duplicitní nálezy:**
a) **Identifikuj shodné nálezy** — dva nálezy jsou shodné pokud se týkají stejného faktu (stejná sekce, stejný typ rozporu).
b) **Severity: vezmi VYŠŠÍ** z duplicitních nálezů. Vysvětli proč v reportu.
c) **Kontext: sluč** — každý agent mohl ověřit z jiného úhlu. Finální nález obsahuje VŠECHNY citace reality ze všech agentů.
d) **Oprava: vezmi KONKRÉTNĚJŠÍ** — preferuj návrh s přesnou citací před vágním "doplnit do docs."
e) **Pokud agenti nesouhlasí na FAKTU** (např. jeden říká 36, druhý 38), re-verifikuj čtením kódu — toto je POVINNÉ.

### Krok 3: Re-verifikace

Pro CRITICAL a HIGH: re-verifikuj z JINÉHO úhlu než agent:
- Agent tvrdil počet? → Spočítej sám (Glob/Grep, ne ručně)
- Agent tvrdil neexistenci? → Vyhledej pomocí Grep s alternativními názvy
- Agent citoval soubor:řádek? → Přečti kontext (±20 řádků) pro ověření
- Agent použil SQL? → Ověř klientský kód, nebo naopak

Re-verifikace MUSÍ použít jiný zdroj než agent.

### Krok 4: Finální report

```markdown
# Audit dokumentace — PROJECT.md
> Datum: YYYY-MM-DD | PROJECT.md: ~RRRR řádků

## Souhrn
- X nálezů celkem (C critical, H high, M medium, L low, D doc debt)
- 1-2 věty o celkovém stavu dokumentace
- Agenti: všichni OK / Agent NN INCOMPLETE (oblast XY)

## CRITICAL — Docs explicitně lžou

### 1. Název
- **PROJECT.md sekce:** "citace"
- **Realita:** popis (`soubor:řádek`)
- **Oprava:** Kde → Smazat → Nahradit

## HIGH — Feature chybí nebo neexistuje

(stejný formát)

## MEDIUM — Nepřesnosti

(stejný formát)

## LOW — Kosmetické

| # | Sekce | Problém | Oprava |
|---|-------|---------|--------|

## DOC DEBT — Nedokumentované změny

| # | Oblast | Co chybí v docs | Dopad |
|---|--------|-----------------|-------|

## Akční plán oprav PROJECT.md

Seřazeno od nejdůležitějších. Pro každou opravu:
1. Sekce v PROJECT.md
2. Co smazat/změnit (přesná citace)
3. Čím nahradit (přesný nový text)
```

### Krok 5: Aplikace oprav

**Zeptej se uživatele:** "Mám aplikovat opravy do PROJECT.md?"
Nabídni možnosti:
a) Všechny opravy (CRITICAL → DOC DEBT)
b) Pouze CRITICAL + HIGH
c) Pouze CRITICAL
d) Žádné — pouze report

Pokud ano:
- Aplikuj vybrané opravy přes Edit tool (od CRITICAL po DOC DEBT).
- Aktualizuj datum `Poslední aktualizace` v PROJECT.md.
- Přidej záznam do `docs/CHANGELOG.md` s přehledem oprav.

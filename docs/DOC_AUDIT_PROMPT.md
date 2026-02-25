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
  Přečti 6 findings souborů → sestav finální report do konzole
  Re-verifikuj CRITICAL/HIGH nálezy přečtením kódu
  Volitelně: aplikuj opravy do PROJECT.md
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

Před zápisem blueprintu projdi extrahovaná čísla a hledej **vnitřní rozpory** v PROJECT.md:
- Stejná metrika s různými hodnotami na různých řádcích? (např. "40 doménových" na řádku X, "42 doménových" na řádku Y)
- Součet, který nesedí? (např. "42 doménových + 1 + 2 = 45" ale jinde text říká "43 aktivních")
- Tabulka zmíněná v jedné sekci ale chybí v jiné?

Zapiš rozpory přímo do blueprintu jako `⚠ POZOR: vnitřní rozpor` poznámky — agenti je pak ověří
a určí, která varianta je správná.

### Struktura blueprintu

```markdown
# Blueprint — ověřitelná tvrzení z PROJECT.md

## 1. ČÍSLA A POČTY
Přesné numerické tvrzení z docs (řádek v PROJECT.md → tvrzení):
- řádek ~44: "45 tabulek (42 doménových + 1 device_registrations + 2 sync)"
- řádek ~XX: "113 permissions"
- řádek ~XX: "3 tax rates, 5 payment methods"
- (všechna další čísla)
⚠ POZOR: řádek ~X říká "40", řádek ~Y říká "42" — vnitřní rozpor, ověřit.

## 2. TABULKY A SLOUPCE
Pro každou tabulku v docs:
### [table_name] (řádek ~N v PROJECT.md)
| Sloupec | Typ (dle docs) | Nullable (dle docs) | Default (dle docs) | FK (dle docs) |
Poznámka: jen co docs explicitně uvádí. Pokud docs neuvádí typ, zapsat "neuveden".

## 3. ENUMY
Pro každý enum v docs:
### [EnumName] (řádek ~N)
- Hodnoty: [a, b, c]
- Explicitní "neobsahuje" tvrzení: "neobsahuje voucher, points" (pokud existuje)

## 4. SYNC TVRZENÍ
- Pull tabulky pořadí (dle docs)
- Outbox pravidla (dle docs)
- LWW popis (dle docs)
- Realtime popis (dle docs)
- Počet synchronizovaných tabulek
- Klasifikace repozitářů (BaseCompanyScopedRepository vs. vlastní) + companyRepos list

## 5. WORKFLOW POPISY
Pro každý popsaný workflow:
### [workflow_name] (řádek ~N)
- Kroky: 1. ..., 2. ..., 3. ...
- Transakčnost: ano/ne (dle docs)
- Mermaid diagram: ano/ne (pokud ano, stručně co ukazuje)

## 6. ROUTES A SCREENY
| Route (dle docs) | Screen (dle docs) | Guard (dle docs) | Taby (dle docs) |

## 7. SUPABASE TVRZENÍ
- RLS pravidla (co docs slibují)
- Triggery (co docs slibují) — počty, naming, scope
- Edge Functions (názvy + popis + cesta k souboru)
- Databázové RPC funkce (názvy + SECURITY DEFINER/INVOKER)
- Seed data popis
- Server-only tabulky

## 8. ARCHITEKTONICKÁ PRAVIDLA
Všechna "MUSÍ"/"NESMÍ"/"vždy"/"nikdy" tvrzení:
- řádek ~N: "všechny doménové tabulky mají SyncColumnsMixin"
- řádek ~N: "monetární sloupce jsou vždy integer (haléře)"
- (všechna další)

## 9. CESTY K SOUBORŮM A STRUKTURY
Všechny zmínky konkrétních cest, názvů tříd, názvů souborů, počtů souborů v adresářích:
- řádek ~N: "lib/core/data/repositories/ — 43 souborů"
- řádek ~N: "BaseCompanyScopedRepository"
- (všechny další)

## 10. PLÁNOVANÉ FEATURES (Etapa 4+)
Features explicitně označené jako budoucí nebo v nehotových etapách.
Tyto NEJSOU chyby v docs — ale ověřit, zda na nich nezačala práce.
```

**Pravidla pro extrakci:**
- Extrahuj POUZE to, co docs říkají. Žádné vlastní interpretace.
- U každého tvrzení uveď přibližný řádek v PROJECT.md.
- Pokud docs jsou nejednoznačné, zapiš obě interpretace.
- Blueprint musí být self-contained — agenti NEČTOU PROJECT.md.

---

## FÁZE 2 — SCAN (6 paralelních agentů)

Spusť všech 6 najednou přes Task tool s `run_in_background: true`.

Každý agent dostane:
1. Instrukci přečíst `/tmp/doc-audit/blueprint.md`
2. Svůj scope (které soubory/SQL zkontrolovat)
3. Instrukci zapsat findings do svého output souboru
4. Sdílená pravidla (viz konec dokumentu)

---

### Agent 1: SCHEMA + ENUMY — Tabulky, sloupce, enumy, počty souborů

**Čte:** Blueprint sekce 1, 2, 3, 8, 9
**Kontroluje:** `lib/core/database/tables/*.dart`, `lib/core/database/app_database.dart`, `lib/core/data/enums/*.dart`, `lib/core/data/models/*.dart`, `lib/core/data/repositories/*.dart`
**Píše do:** `/tmp/doc-audit/01_schema_enums.md`

**Úkoly:**
1. Pro každou tabulku v blueprintu najdi `.dart` soubor a porovnej sloupce:
   - Sloupec v docs ale NE v Drift? → DOCS LŽE (sloupec neexistuje) nebo DOC DEBT (přejmenován)
   - Sloupec v Drift ale NE v docs? → DOC DEBT (docs neaktualizovány)
   - Typ v docs nesedí s Drift? → NEPŘESNOST
   - Default v docs nesedí s Drift? → NEPŘESNOST (chybějící default hodnota)
2. Ověř numerická tvrzení: počet tabulek, "všechny mají SyncColumnsMixin", atd.
3. Ověř cesty k souborům a počty souborů v adresářích (models/, repositories/, enums/, utils/, widgets/, providers/, printing/).
4. Zkontroluj `@DriftDatabase(tables: [...])` — sedí počet a seznam s docs?
5. Pro každý enum v blueprintu porovnej hodnoty s Dart kódem:
   - Hodnota v docs ale NE v kódu? → DOCS LŽE
   - Hodnota v kódu ale NE v docs? → DOC DEBT
   - Docs tvrdí "neobsahuje X" ale kód X obsahuje? → CRITICAL (explicitní lež)
6. Najdi enumy v `lib/core/data/enums/` které NEJSOU v blueprintu → DOC DEBT
7. Pokud blueprint obsahuje ⚠ POZOR o vnitřním rozporu v počtech, urči správnou hodnotu.

**Ignoruj:** sync sloupce z mixinu (docs je typicky neuvádí per-table).

---

### Agent 2: SYNC + MAPPERS

**Čte:** Blueprint sekce 4, 8
**Kontroluje:** `lib/core/sync/*.dart`, `lib/core/data/mappers/*.dart`, `lib/core/data/providers/sync_providers.dart`
**Píše do:** `/tmp/doc-audit/02_sync.md`

**Úkoly:**
1. Porovnej `tableDependencyOrder` pořadí v `sync_service.dart` s blueprintem sekce 4.
   - Tabulka v docs ale ne v kódu? → DOCS LŽE nebo DOC DEBT
   - Tabulka v kódu ale ne v docs? → DOC DEBT
2. Ověř outbox pravidla popsaná v docs — sedí s `outbox_processor.dart`?
3. Ověř LWW popis — sedí s implementací?
4. Ověř realtime popis — sedí s implementací?
5. Zkontroluj `sync_lifecycle_manager.dart` — initial push odpovídá docs?
6. Zkontroluj zda pro každou entitu existuje push mapper (`supabase_mappers.dart`)
   a pull mapper (`supabase_pull_mappers.dart`) — pokud docs tvrdí, že se synchronizuje.
7. Zkontroluj `companyRepos` list v `sync_providers.dart` — sedí s klasifikací v docs?
   Pokud docs klasifikuje entitu jako BaseCompanyScopedRepository ale není v `companyRepos`, je to nález.

---

### Agent 3: SUPABASE — Server vs. docs

**Čte:** Blueprint sekce 7
**Kontroluje:** Supabase přes MCP (execute_sql, list_tables, list_edge_functions, get_advisors) + `supabase/functions/*/index.ts`
**Píše do:** `/tmp/doc-audit/03_supabase.md`

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

-- Funkce (PG RPC)
SELECT proname, prosecdef, proconfig
FROM pg_proc WHERE pronamespace = 'public'::regnamespace
ORDER BY proname;
```

2. Porovnej Supabase enum hodnoty s blueprintem — nesedí pořadí nebo hodnoty? → nález
3. Porovnej Supabase sloupce s blueprintem per-table — nesedí typ, nullable, default? → nález
4. Docs tvrdí RLS policies existují — existují skutečně? Jaké role mají přístup?
5. Docs tvrdí triggery existují — existují skutečně? Počty?
6. Porovnej Edge Functions nasazené na serveru (`list_edge_functions`) se soubory v `supabase/functions/*/index.ts` a s docs:
   - EF v repo ale ne na serveru? → nález
   - EF na serveru ale ne v docs? → DOC DEBT
   - Docs tvrdí "kód není v repozitáři" ale soubor existuje? → nález
7. Porovnej PG RPC funkce (databázové funkce) s docs — chybí? špatně klasifikované (RPC vs EF)?
8. Spusť `get_advisors(type: "security")` — jsou varování relevantní pro docs?

**Ignoruj:** Drift-only sloupce (lastSyncedAt, version, serverCreatedAt, serverUpdatedAt).
`sync_metadata` a `device_registrations` neexistují na Supabase — to je záměr, ne chyba.

---

### Agent 4: MIGRACE — Repo vs. server

**Čte:** Blueprint sekce 7 (server-side tvrzení)
**Kontroluje:** `supabase/migrations/*.sql` soubory + Supabase MCP (`list_migrations`)
**Píše do:** `/tmp/doc-audit/04_migrations.md`

**Úkoly:**
1. Spusť `list_migrations` přes Supabase MCP — získej seznam applied migrací na serveru.
2. Glob `supabase/migrations/*.sql` — získej seznam migračních souborů v repozitáři.
3. Porovnej:
   - Migrace v repo ale NE na serveru? → **CRITICAL** pokud docs popisují feature z té migrace jako hotovou.
     Kontroluj zejména: naming konvence (Supabase CLI vyžaduje timestamp prefix), soubory které neprošly `supabase db push`.
   - Migrace na serveru bez odpovídajícího souboru v repo? → nález (undocumented server change)
4. Pro každou dokumentovanou serverovou feature v blueprintu (triggery, RPC funkce, RLS policies)
   najdi odpovídající migraci v repo — existuje? Byla nasazena?
5. Zkontroluj naming konvence migračních souborů — soubory s nestandardním naming
   (např. `_001_` místo timestamp) mohou být ignorovány Supabase CLI.

**Poznámka:** Tento agent zachytává situaci, kdy migrace existuje v kódu ale nebyla nasazena
na server — docs pak popisují feature jako hotovou, ale na serveru neexistuje.

---

### Agent 5: ROUTES + SCREENY + TABY

**Čte:** Blueprint sekce 6, 9
**Kontroluje:** `lib/core/routing/app_router.dart`, `lib/features/*/screens/*.dart`, `lib/features/*/widgets/dialog_*.dart`
**Píše do:** `/tmp/doc-audit/05_routes_screens.md`

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
4. Existují screeny/dialogy v kódu které NEJSOU v docs file tree? → DOC DEBT
5. Ověř cesty k souborům zmíněné v docs — existují? (lib/features/ struktura)

---

### Agent 6: WORKFLOWS + SEED + PLANNED

**Čte:** Blueprint sekce 5, 7 (seed data), 10
**Kontroluje:** `lib/core/data/repositories/*.dart`, `lib/core/data/services/seed_service.dart`,
  `lib/core/auth/*.dart`, `lib/features/sell/screens/screen_sell.dart`, `lib/features/bills/`
**Píše do:** `/tmp/doc-audit/06_workflows.md`

**Úkoly:**
1. Pro každý workflow v blueprintu najdi implementaci a porovnej kroky:
   - Krok v docs ale ne v kódu? → nález (docs slibují víc než kód dělá)
   - Krok v kódu ale ne v docs? → DOC DEBT (docs neúplné)
   - Pořadí kroků jiné? → nález
   - Docs říkají "v transakci" ale kód nemá `transaction()`? → nález
   - Mermaid diagram neodráží všechny cesty (chybí alternativní větev)? → nález
2. Ověř seed data: `seed_service.dart` vs. blueprint sekce 7
   - Počty sedí? (tax rates, payment methods, permissions, roles, items...)
   - Defaultní hodnoty sedí? (názvy, typy, is_default flagy)
3. Zkontroluj plánované features (blueprint sekce 10):
   - Pokud na některé už začala práce (existují soubory, widgety, taby), poznamenej "částečně implementováno".
   - Pokud docs tvrdí "neimplementováno" ale feature existuje → **HIGH** nález
4. Zkontroluj Quick Sale specificky: retail vs. gastro mode chování, cart separátory,
   customer display integrace — jsou v docs?

---

## Sdílená pravidla pro všechny agenty

### Kategorie nálezů

| Kategorie | Definice | Příklad |
|-----------|----------|---------|
| **CRITICAL** | Docs explicitně tvrdí opak reality (lež), nebo docs popisují feature jako hotovou ale na serveru neexistuje (nenasazená migrace). | "neobsahuje voucher" ale kód voucher má. Trigger dokumentován ale migrace nenasazena. |
| **HIGH** | Docs popisují neexistující feature jako hotovou, nebo zamlčují existující feature s dopadem na sync/data. | Tabulka v docs neexistuje v kódu. Nový sloupec v kódu chybí v docs a ovlivňuje sync. |
| **MEDIUM** | Docs neodpovídají realitě ale dopad je omezený. | Počet tabulek nesedí. Typ sloupce jiný. Cesta k souboru neplatná. Chybějící default. |
| **LOW** | Kosmetické nepřesnosti, překlepy, zastaralé názvy. | camelCase vs snake_case v docs. Překlep v názvu. Chybějící soubor ve file tree listingu. |

### Output formát (striktně dodržovat)

```markdown
# [NN] [NÁZEV OBLASTI]
> Ověřeno: X položek z blueprintu | Nálezů: Y

## Nálezy

### [CRITICAL/HIGH/MEDIUM/LOW] Stručný název
- **Docs (řádek ~N):** přesná citace nebo parafráze z blueprintu
- **Realita:** co kód/Supabase skutečně obsahuje (`soubor:řádek`)
- **Oprava docs:** navrhovaný nový text pro PROJECT.md (1-2 věty)

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
3. **Vždy cituj docs** — řádek v PROJECT.md (nebo blueprint) + co docs tvrdí.
4. **Vždy cituj realitu** — soubor:řádek + co kód/DB skutečně obsahuje.
5. **Navrhni opravu** — konkrétní text, kterým docs opravit.
6. **Plánované features (Etapa 4+) z blueprintu sekce 10 NEJSOU chyby.**
   Pokud docs popisují budoucí feature a ta neexistuje v kódu, to je OK.
   Reportuj JEN pokud docs tvrdí, že feature je HOTOVÁ, ale není.
   Pokud na plánované feature už začala práce, reportuj jako DOC DEBT (docs by měly říkat "partially implemented").
7. **Nepřidávej code review nálezy.** Pokud kód funguje jinak než docs popisují,
   to je docs nález. Ale nekritizuj kvalitu kódu — to není scope tohoto auditu.
8. **Drift `text()` pro UUID** je standardní a NENÍ nesoulad s docs `uuid` typem.
9. **Piš findings do souboru přes Write tool**, ne jako textový output.
10. **Ověřuj i vnitřní konzistenci.** Pokud blueprint obsahuje ⚠ POZOR poznámku o vnitřním rozporu,
    ověř které číslo je správné a zahrň do findings.
11. **Při pochybnostech ověř.** Lepší 1 Read/Grep tool navíc než chybný nález.
    Nepočítej ručně — nech Glob spočítat soubory, nech Grep najít výskyty.

---

## FÁZE 3 — REPORT (hlavní agent)

Po dokončení všech 6 agentů:

1. Přečti soubory `/tmp/doc-audit/01_schema_enums.md` až `/tmp/doc-audit/06_workflows.md`.
2. Slouč a deduplikuj (totéž z různých agentů = jeden nález).
   Pokud agenti nesouhlasí na faktu (např. jeden říká 36, druhý 38), re-verifikuj.
3. Pro CRITICAL a HIGH: re-verifikuj přečtením zdrojového kódu/SQL.
4. Vypiš finální report:

```markdown
# Audit dokumentace — PROJECT.md
> Datum: YYYY-MM-DD | PROJECT.md: ~RRRR řádků

## Souhrn
- X nálezů celkem (C critical, H high, M medium, L low)
- 1-2 věty o celkovém stavu dokumentace

## CRITICAL — Docs explicitně lžou

### 1. Název
- **PROJECT.md řádek ~N:** "citace"
- **Realita:** popis (`soubor:řádek`)
- **Oprava:** navrhovaný nový text

## HIGH — Zastaralé nebo chybějící popisy

(stejný formát)

## MEDIUM — Nepřesnosti

(stejný formát)

## LOW — Kosmetické

| # | Řádek | Problém | Oprava |
|---|-------|---------|--------|

## Akční plán oprav PROJECT.md

Seřazeno od nejdůležitějších. Pro každou opravu:
1. Sekce v PROJECT.md
2. Co smazat/změnit
3. Čím nahradit
```

5. **Zeptej se uživatele:** "Mám aplikovat opravy do PROJECT.md?"
   Pokud ano:
   - Aplikuj všechny navržené opravy přes Edit tool (od CRITICAL po LOW).
   - Aktualizuj datum `Poslední aktualizace` v PROJECT.md.
   - Přidej záznam do `docs/CHANGELOG.md` s přehledem oprav.

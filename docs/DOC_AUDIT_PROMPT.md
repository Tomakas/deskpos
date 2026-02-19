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
  Přečti PROJECT.md → zapiš strukturovaný blueprint do /tmp/doc-audit/blueprint.md
  (Agenti v fázi 2 čtou JEN blueprint, ne celý PROJECT.md)

FÁZE 2 — SCAN (5 background agentů, paralelně)
  Každý agent čte blueprint + svůj výsek kódu/Supabase
  Každý agent zapíše findings do /tmp/doc-audit/NN_*.md
  Výstup se zapisuje do souboru — bez limitu na délku

FÁZE 3 — REPORT (hlavní agent)
  Přečti 5 findings souborů → sestav finální report do konzole
  Re-verifikuj CRITICAL/HIGH nálezy přečtením kódu
```

**Proč:** PROJECT.md má ~2800 řádků. Bez blueprintu každý agent čte celý dokument
a plýtvá kontextem. Blueprint extrahuje jen ověřitelná tvrzení (~400 řádků).

---

## FÁZE 1 — EXTRACT (hlavní agent)

Přečti PROJECT.md celý (po částech ~500 řádků). Extrahuj do `/tmp/doc-audit/blueprint.md`
**pouze ověřitelná tvrzení** — fakta, která jdou zkontrolovat proti kódu nebo Supabase.

Před zápisem vytvoř adresář: `mkdir -p /tmp/doc-audit`

### Struktura blueprintu

```markdown
# Blueprint — ověřitelná tvrzení z PROJECT.md

## 1. ČÍSLA A POČTY
Přesné numerické tvrzení z docs (řádek v PROJECT.md → tvrzení):
- řádek ~44: "39 tabulek (36 doménových + 1 device_registrations + 2 sync)"
- řádek ~XX: "14 permissions"
- řádek ~XX: "3 tax rates, 3 payment methods, 3 sections, 5 categories, 25 items"
- (všechna další čísla)

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

## 5. WORKFLOW POPISY
Pro každý popsaný workflow:
### [workflow_name] (řádek ~N)
- Kroky: 1. ..., 2. ..., 3. ...
- Transakčnost: ano/ne (dle docs)

## 6. ROUTES A SCREENY
| Route (dle docs) | Screen (dle docs) | Guard (dle docs) | Taby (dle docs) |

## 7. SUPABASE TVRZENÍ
- RLS pravidla (co docs slibují)
- Triggery (co docs slibují)
- Edge Functions (názvy + popis)
- Seed data popis

## 8. ARCHITEKTONICKÁ PRAVIDLA
Všechna "MUSÍ"/"NESMÍ"/"vždy"/"nikdy" tvrzení:
- řádek ~N: "všechny doménové tabulky mají SyncColumnsMixin"
- řádek ~N: "monetární sloupce jsou vždy integer (haléře)"
- (všechna další)

## 9. CESTY K SOUBORŮM A STRUKTURY
Všechny zmínky konkrétních cest, názvů tříd, názvů souborů:
- řádek ~N: "lib/core/data/repositories/"
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

## FÁZE 2 — SCAN (5 paralelních agentů)

Spusť všech 5 najednou přes Task tool s `run_in_background: true`.

Každý agent dostane:
1. Instrukci přečíst `/tmp/doc-audit/blueprint.md`
2. Svůj scope (které soubory/SQL zkontrolovat)
3. Instrukci zapsat findings do svého output souboru
4. Sdílená pravidla (viz konec dokumentu)

---

### Agent 1: SCHEMA — Tabulky a sloupce

**Čte:** Blueprint sekce 1, 2, 8, 9
**Kontroluje:** `lib/core/database/tables/*.dart`, `lib/core/database/app_database.dart`
**Píše do:** `/tmp/doc-audit/01_schema.md`

**Úkoly:**
1. Pro každou tabulku v blueprintu najdi `.dart` soubor a porovnej sloupce:
   - Sloupec v docs ale NE v Drift? → DOCS LŽE (sloupec neexistuje) nebo DOC DEBT (sloupec přejmenován)
   - Sloupec v Drift ale NE v docs? → DOC DEBT (docs neaktualizovány)
   - Typ v docs nesedí s Drift? → NEPŘESNOST
   - Nullable v docs nesedí s Drift? → NEPŘESNOST
2. Ověř numerická tvrzení: počet tabulek, "všechny mají SyncColumnsMixin", atd.
3. Ověř cesty k souborům zmíněné v docs — existují?
4. Zkontroluj `@DriftDatabase(tables: [...])` — sedí s docs?

**Ignoruj:** sync sloupce z mixinu (docs je typicky neuvádí per-table).

---

### Agent 2: ENUMY + MODELY

**Čte:** Blueprint sekce 3
**Kontroluje:** `lib/core/data/enums/*.dart`, `lib/core/data/models/*.dart`
**Píše do:** `/tmp/doc-audit/02_enums_models.md`

**Úkoly:**
1. Pro každý enum v blueprintu porovnej hodnoty s Dart kódem:
   - Hodnota v docs ale NE v kódu? → DOCS LŽE
   - Hodnota v kódu ale NE v docs? → DOC DEBT
   - Docs tvrdí "neobsahuje X" ale kód X obsahuje? → CRITICAL (explicitní lež)
2. Najdi enumy v `lib/core/data/enums/` které NEJSOU v blueprintu → DOC DEBT
3. Pro Freezed modely: existují fieldy které jsou v Drift tabulce ale ne v modelu,
   nebo naopak? Docs o modelech typicky nemluví přímo, ale pokud ano, ověř.

---

### Agent 3: SYNC + MAPPERS

**Čte:** Blueprint sekce 4, 8
**Kontroluje:** `lib/core/sync/*.dart`, `lib/core/data/mappers/*.dart`
**Píše do:** `/tmp/doc-audit/03_sync.md`

**Úkoly:**
1. Porovnej `_pullTables` pořadí v `sync_service.dart` s blueprintem sekce 4.
   - Tabulka v docs ale ne v `_pullTables`? → DOCS LŽE nebo DOC DEBT
   - Tabulka v `_pullTables` ale ne v docs? → DOC DEBT
2. Ověř outbox pravidla popsaná v docs — sedí s `outbox_processor.dart`?
3. Ověř LWW popis — sedí s implementací?
4. Ověř realtime popis — sedí s implementací?
5. Zkontroluj `sync_lifecycle_manager.dart` — initial push odpovídá docs?
6. Zkontroluj zda pro každou entitu existuje push mapper (`supabase_mappers.dart`)
   a pull mapper (`supabase_pull_mappers.dart`) — pokud docs tvrdí, že se synchronizuje.

---

### Agent 4: SUPABASE — Server vs. docs

**Čte:** Blueprint sekce 7
**Kontroluje:** Supabase přes MCP (execute_sql, list_tables) + `supabase/migrations/*.sql` + `supabase/functions/`
**Píše do:** `/tmp/doc-audit/04_supabase.md`

**Úkoly:**
1. Spusť SQL dotazy pro získání reálného stavu:

```sql
-- Tabulky a sloupce
SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' ORDER BY table_name, ordinal_position;

-- Enumy
SELECT t.typname, e.enumlabel
FROM pg_type t JOIN pg_enum e ON t.oid = e.enumtypid
ORDER BY t.typname, e.enumsortorder;

-- RLS stav
SELECT tablename, rowsecurity FROM pg_tables
WHERE schemaname = 'public' ORDER BY tablename;

-- RLS policies
SELECT tablename, policyname, cmd, qual, with_check
FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename;

-- Triggery
SELECT event_object_table, trigger_name, event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public' ORDER BY event_object_table;
```

2. Porovnej Supabase enum hodnoty s blueprintem — nesedí? → nález
3. Porovnej Supabase sloupce s blueprintem per-table — nesedí? → nález
4. Docs tvrdí RLS policies existují — existují skutečně?
5. Docs tvrdí triggery existují — existují skutečně?
6. Přečti Edge Functions (`supabase/functions/`) — sedí s popisem v docs?
7. Spusť `get_advisors(type: "security")` — jsou varování relevantní pro docs?

**Ignoruj:** Drift-only sloupce (lastSyncedAt, version, serverCreatedAt, serverUpdatedAt).
`sync_metadata` a `device_registrations` neexistují na Supabase — to je záměr, ne chyba.

---

### Agent 5: WORKFLOWS + UI + ROUTING

**Čte:** Blueprint sekce 5, 6, 9, 10
**Kontroluje:** `lib/core/data/repositories/*.dart`, `lib/core/routing/app_router.dart`,
  `lib/features/*/screens/*.dart`, `lib/core/data/services/*.dart`, `lib/core/auth/*.dart`
**Píše do:** `/tmp/doc-audit/05_workflows_ui.md`

**Úkoly:**
1. Pro každý workflow v blueprintu najdi implementaci a porovnej kroky:
   - Krok v docs ale ne v kódu? → nález (docs slibují víc než kód dělá)
   - Krok v kódu ale ne v docs? → DOC DEBT (docs neúplné)
   - Pořadí kroků jiné? → nález
   - Docs říkají "v transakci" ale kód nemá `transaction()`? → nález
2. Porovnej routes v `app_router.dart` s blueprintem:
   - Route v docs ale ne v kódu? → nález
   - Route v kódu ale ne v docs? → DOC DEBT
3. Pro každý screen zmíněný v docs ověř:
   - Existuje? Má správný název třídy?
   - Tab struktura sedí s docs?
4. Ověř seed data: `seed_service.dart` vs. blueprint sekce 7
   - Počty sedí? (tax rates, payment methods, permissions, roles, items...)
5. Zkontroluj plánované features (blueprint sekce 10):
   - Pokud na některé už začala práce, poznamenej "částečně implementováno".

---

## Sdílená pravidla pro všechny agenty

### Kategorie nálezů

| Kategorie | Definice | Příklad |
|-----------|----------|---------|
| **CRITICAL** | Docs explicitně tvrdí opak reality (lež). | "neobsahuje voucher" ale kód voucher má |
| **HIGH** | Docs popisují neexistující feature jako hotovou, nebo zamlčují existující feature s dopadem na sync/data. | Tabulka v docs neexistuje v kódu. Nový sloupec v kódu chybí v docs a ovlivňuje sync. |
| **MEDIUM** | Docs neodpovídají realitě ale dopad je omezený. | Počet tabulek nesedí. Typ sloupce jiný. Cesta k souboru neplatná. |
| **LOW** | Kosmetické nepřesnosti, překlepy, zastaralé názvy. | camelCase vs snake_case v docs. Překlep v názvu. |

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
```

### Pravidla

1. **Jen delta.** Neopisuj co sedí. Pokud celá tabulka sedí, nezmiňuj ji.
2. **Buď důkladný.** Output jde do souboru, ne do hlavního kontextu — piš tolik detailů kolik potřebuješ.
   U každého nálezu uveď kompletní kontext, citace, a navrhovanou opravu.
3. **Vždy cituj docs** — řádek v PROJECT.md (nebo blueprint) + co docs tvrdí.
4. **Vždy cituj realitu** — soubor:řádek + co kód/DB skutečně obsahuje.
5. **Navrhni opravu** — konkrétní text, kterým docs opravit.
6. **Plánované features (Etapa 4+) z blueprintu sekce 10 NEJSOU chyby.**
   Pokud docs popisují budoucí feature a ta neexistuje v kódu, to je OK.
   Reportuj JEN pokud docs tvrdí, že feature je HOTOVÁ, ale není.
7. **Nepřidávej code review nálezy.** Pokud kód funguje jinak než docs popisují,
   to je docs nález. Ale nekritizuj kvalitu kódu — to není scope tohoto auditu.
8. **Drift `text()` pro UUID** je standardní a NENÍ nesoulad s docs `uuid` typem.
9. **Piš findings do souboru přes Write tool**, ne jako textový output.

---

## FÁZE 3 — REPORT (hlavní agent)

Po dokončení všech 5 agentů:

1. Přečti soubory `/tmp/doc-audit/01_schema.md` až `/tmp/doc-audit/05_workflows_ui.md`.
2. Slouč a deduplikuj (totéž z různých agentů = jeden nález).
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

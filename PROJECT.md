# Maty — Project Documentation

> Konsolidovaná dokumentace projektu Maty.
>
> **Poslední aktualizace:** 2026-03-02

---

## Obsah

1. [Přehled](#přehled)
2. [Roadmap](#roadmap)
3. [Technologický Stack](#technologický-stack)
4. [Architektura](#architektura)
5. [Struktura Projektu](#struktura-projektu)
6. [Databáze](#databáze)
7. [Synchronizace](#synchronizace)
8. [Obchodní model — Účty a objednávky](#obchodní-model--účty-a-objednávky)
9. [Autentizace](#autentizace)
10. [Oprávnění](#oprávnění)
11. [UI/UX Design](#uiux-design)
12. [Možná rozšíření v budoucnu](#možná-rozšíření-v-budoucnu)
13. [Development Guide](#development-guide)

---

## Přehled

**Maty** je moderní pokladní systém (Point of Sale) pro desktopová i mobilní prostředí (Windows, macOS, Linux, Android, iOS). Aplikace klade důraz na robustnost, rychlost a schopnost fungovat bez závislosti na stálém internetovém připojení.

### Klíčové vlastnosti

| Vlastnost | Popis |build 
|-----------|-------|
| **Offline-first** | Lokální databáze je zdroj pravdy. Plná funkčnost bez internetu. |
| **Hybridní architektura** | Centralizovaná datová vrstva (`core/`) + feature-first UI (`features/`). |
| **Reaktivita** | UI automaticky reaguje na změny stavu a databáze pomocí Riverpodu a Streams. |
| **Outbox Pattern + LWW** | Sync engine pro multi-device provoz (od Etapy 3). |

---

## Roadmap

4 etapy, každá s milníky a tasky. Schéma obsahuje **45 tabulek** (42 doménových + 1 lokální device_registrations + 2 sync). Sync se řeší až v Etapě 3 — do té doby funguje aplikace offline na jednom zařízení.

---

### Etapa 1 — Core (offline, single-device)

Admin vytvoří firmu, nastaví uživatele, stoly a produkty. Více uživatelů se může přihlásit a přepínat. Žádný prodej, žádný sync.

#### Milník 1.1 — Projekt a databáze

- **Task1.1** Flutter projekt — desktop + mobile targets, build funguje
- **Task1.2** Drift databáze — 20 tabulek, code generation
- **Task1.3** Lokalizace — i18n infrastruktura, ARB soubory, čeština
- **Výsledek:** Aplikace se spustí, zkompiluje na všech platformách, DB je připravena.

#### Milník 1.2 — Onboarding

- **Task1.4** ScreenOnboarding — výběr "Založit firmu" / "Připojit se k firmě"
- **Task1.5** ScreenOnboarding wizard — cloud účet (sign-up/sign-in) + vytvoření firmy + admin uživatele
- **Task1.6** Seed dat — výchozí měna, daňové sazby, platební metody (viz [Platební metody](#platební-metody)), permissions, role, výchozí registr
- **Výsledek:** Při prvním spuštění uživatel vytvoří firmu a admin účet. V DB jsou výchozí data.

#### Milník 1.3 — Autentizace (single-user)

- **Task1.7** ScreenLogin — výběr uživatele ze seznamu → zadání PINu → ověření proti lokální DB
- **Task1.8** Brute-force ochrana — progresivní lockout, countdown v UI
- **Task1.9** SessionManager — volatile session v RAM
- **Výsledek:** Uživatel vybere svůj účet ze seznamu a přihlásí se PINem. Nesprávné pokusy jsou blokovány progresivním lockoutem.

#### Milník 1.4 — Oprávnění (engine)

- **Task1.10** Permission engine — 105 permissions v 17 skupinách, O(1) check přes in-memory Set
- **Task1.11** Role šablony — helper (15), operator (55), manager (85), admin (105)
- **Výsledek:** Permission engine a role šablony jsou připraveny. Admin má všech 105 oprávnění.

#### Milník 1.5 — Hlavní obrazovka

- **Task1.12** ScreenBills — prázdný stav, layout, navigační shell
- **Task1.13** AppBar — odhlášení
- **Výsledek:** Po přihlášení admin vidí hlavní obrazovku s prázdným seznamem účtů a může se odhlásit.

#### Milník 1.6 — Settings

- **Task1.14** Správa uživatelů — CRUD pro users, přiřazení role (applyRoleToUser)
- **Task1.15** Správa stolů — CRUD pro tables
- **Task1.15b** Správa sekcí — CRUD pro sections
- **Task1.16** Správa produktů — CRUD pro items, categories
- **Task1.17** Správa daňových sazeb — CRUD pro tax_rates
- **Task1.18** Správa platebních metod — CRUD pro payment_methods (viz [Platební metody](#platební-metody))
- **Výsledek:** Admin může vytvořit další uživatele, stoly, produkty, daňové sazby a platební metody.

#### Milník 1.7 — Multi-user

- **Task1.19** Přepínání uživatelů — tlačítko PŘEPNOUT OBSLUHU → dialog se seznamem aktivních uživatelů → výběr → zadání PINu
- **Task1.20** UI enforcement — hasPermissionProvider, skrývání/blokování akcí podle oprávnění
- **Výsledek:** Více uživatelů se může přihlašovat a přepínat. Každý vidí pouze akce, na které má oprávnění.

---

### Etapa 2 — Základní prodej

Uživatel může vytvořit účet, přidat položky a zaplatit. Register session řídí kdy je prodej aktivní. Bez slev, tisku, pokročilých funkcí.

#### Milník 2.1 — Vytvoření účtu

- **Task2.1** DialogNewBill — vytvoření účtu (stůl / bez stolu), rychlý prodej jako samostatný flow
- **Task2.2** DialogBillDetail — detail účtu, informace, stav, prázdný stav
- **Task2.3** Bill CRUD v repository — createBill, updateStatus, cancelBill
- **Výsledek:** Obsluha může otevřít nový účet (přiřazení ke stolu nebo bez stolu), zobrazit jeho detail a stornovat ho. Rychlý prodej je samostatný flow bez předchozího vytvoření účtu.

#### Milník 2.2 — Objednávky

- **Task2.4** ScreenSell — produktový grid/seznam, výběr položek a množství
- **Task2.5** createOrderWithItems — INSERT order + order_items, batch operace
- **Task2.6** Seznam objednávek na účtu — zobrazení orders a items v DialogBillDetail
- **Task2.7** PrepStatus flow — created → ready → delivered (ruční změna)
- **Výsledek:** Obsluha může přidávat položky na účet a sledovat stav přípravy objednávek.

#### Milník 2.3 — Platba

- **Task2.8** DialogPayment — výběr platební metody, zadání částky
- **Task2.9** recordPayment — INSERT payment + UPDATE bill (paidAmount, status)
- **Task2.10** Plná platba — bill status → paid, closedAt se nastaví
- **Task2.11** ScreenBills filtry — filtrování podle stavu (opened, paid, cancelled)
- **Výsledek:** Obsluha může zaplatit účet, účet se uzavře. Na hlavní obrazovce lze filtrovat podle stavu.

#### Milník 2.4 — Grid editor

- **Task2.12** Grid editor — editační režim pro přiřazení položek/kategorií tlačítkům v ScreenSell gridu (layout_items CRUD)
- **Výsledek:** Obsluha může v editačním režimu nastavit, co každé tlačítko v prodejním gridu zobrazuje (produkt, kategorie, nebo prázdné).

#### Milník 2.5 — Register session (lightweight)

- **Task2.13** RegisterSession — otevření/zavření prodejní session
- **Task2.14** Dynamické tlačítko — "Zahájit prodej" (žádná aktivní session) / "Uzávěrka" (aktivní session)
- **Task2.15** Order numbering — O-0001 reset per session, counter v register_sessions
- **Výsledek:** Při přihlášení se kontroluje aktivní session. Bez session nelze prodávat. Uzávěrka session uzavře (nastaví closed_at). Order čísla se resetují s novou session.

---

### Etapa 3 — Pokročilé funkce

Funkce, které nejsou nezbytné pro základní prodej, ale rozšiřují možnosti systému.

#### Milník 3.1 — Sync + multi-device (rozpracováno)

- **Task3.1** Supabase backend — Auth, RLS policies, triggery ✅
- **Task3.2** Outbox pattern — sync_queue, auto-retry, status tracking ✅
- **Task3.3** LWW conflict resolution — updated_at porovnání, merge logika ✅
- **Task3.2b** Sync pro bills, orders, order_items, payments — mappers, outbox registrace, pull tables ✅
- **Task3.4** ConnectCompanyScreen — připojení k existující firmě, InitialSync, sync pro 42 tabulek ✅
- **Task3.5** SyncAuthScreen — admin credentials pro Supabase session ✅ (ScreenCloudAuth)
- **Výsledek:** Data se synchronizují mezi zařízeními. Nové zařízení se připojí k firmě a stáhne data.

#### Milník 3.2 — Pokročilý prodej

- **Task3.7** ✅ Slevy na položku — discount na OrderItem, UI pro zadání slevy
- **Task3.8** ✅ Slevy na účet — discount_amount na Bill, UI pro zadání slevy
- **Task3.9** ✅ Poznámky k objednávce — UI pro notes na Order a OrderItem (sloupce již ve schématu)
- **Task3.10** ✅ Split payment — rozdělení platby mezi více platebních metod (celá částka musí být vždy uhrazena)
- **Task3.11b** ✅ Refund — vrácení peněz po zaplacení, bill status → `refunded` (ve filtru se řadí pod "Zaplacené")
- **Task3.11c** ✅ Sloučení účtů (merge) — přesun všech objednávek ze zdrojového účtu na cílový, zdrojový účet se zruší (cancelled)
- **Task3.11d** ✅ Rozdělení účtu (split) — výběr položek k oddělení, dva režimy: "rozdělit a zaplatit" (nový účet + okamžitá platba) a "rozdělit na nový účet" (konfigurace přes DialogNewBill)
- **Výsledek:** Obsluha může aplikovat slevy, rozdělit platbu mezi metody, provést refund, sloučit a rozdělit účty.

... (a zbytek původního obsahu) ...

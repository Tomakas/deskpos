# Návrh systému oprávnění

> Konsolidovaný návrh nového systému práv pro EPOS Desktop POS.
> Vychází z analýzy současného kódu, PROJECT.md a konkurenčních systémů
> (Square, Toast, Lightspeed, Clover, Revel, TouchBistro, Shopify, Loyverse, Dotykačka, Poster, Storyous).

---

## Obsah

1. [Současný stav](#1-současný-stav)
2. [Přehled nového systému](#2-přehled-nového-systému)
3. [Skupiny a oprávnění](#3-skupiny-a-oprávnění)
4. [Přiřazení rolím](#4-přiřazení-rolím)
5. [Budoucí rozšíření](#5-budoucí-rozšíření)
6. [Architektonické poznámky](#6-architektonické-poznámky)
7. [Srovnání s konkurencí](#7-srovnání-s-konkurencí)

---

## 1. Současný stav

| Metrika | Hodnota |
|---------|---------|
| Role | 3 (`helper`, `operator`, `admin`) |
| Oprávnění | 16 v 7 kategoriích |
| Reálně enforced v kódu | **2** (`settings.manage`, `orders.view`) |

### Současná oprávnění (seed data)

| Kategorie | Kód | helper | operator | admin |
|-----------|-----|:------:|:--------:|:-----:|
| bills | `bills.create` | x | x | x |
| bills | `bills.view` | x | x | x |
| bills | `bills.void` | | x | x |
| bills | `bills.discount` | | x | x |
| orders | `orders.create` | x | x | x |
| orders | `orders.view` | x | x | x |
| orders | `orders.void` | | x | x |
| orders | `orders.discount` | | x | x |
| products | `products.view` | x | x | x |
| products | `products.manage` | | | x |
| tables | `tables.manage` | | x | x |
| users | `users.view` | | | x |
| users | `users.manage` | | | x |
| settings | `settings.manage` | | | x |
| customers | `customers.view` | x | x | x |
| customers | `customers.manage` | | | x |

**Problém:** Většina operací (storno, refundace, slevy, pokladní operace, sklad) nemá žádnou kontrolu oprávnění. Jakýkoli přihlášený uživatel může provést cokoli.

---

## 2. Přehled nového systému

| Metrika | Stav dnes | Nový návrh |
|---------|-----------|------------|
| Skupin | 7 | **13** |
| Oprávnění | 16 | **78** |
| Role | 3 | 3 (zachovány, rozšířeny) |
| Enforcement | 2 kódy | **78 kódů** |

### Skupiny

| # | Skupina | Kód | Počet oprávnění |
|---|---------|-----|:---------------:|
| 1 | Objednávky a účty | `orders.*` | 13 |
| 2 | Platby | `payments.*` | 7 |
| 3 | Slevy a ceny | `discounts.*` | 5 |
| 4 | Pokladna a směna | `register.*` | 7 |
| 5 | Produkty a katalog | `products.*` | 8 |
| 6 | Sklad | `stock.*` | 6 |
| 7 | Zákazníci a věrnost | `customers.*` | 4 |
| 8 | Vouchery | `vouchers.*` | 3 |
| 9 | Stoly, sekce, rezervace | `venue.*` | 6 |
| 10 | KDS a displej | `kds.*` | 5 |
| 11 | Reporty | `reports.*` | 5 |
| 12 | Uživatelé a role | `users.*` | 4 |
| 13 | Nastavení a hardware | `settings.*` | 9 |
| | | **Celkem** | **78** |

---

## 3. Skupiny a oprávnění

### 3.1 Objednávky a účty (`orders`)

| Kód | Název | Popis |
|-----|-------|-------|
| `orders.create` | Vytvořit objednávku | Přidávat položky na účet |
| `orders.view` | Zobrazit vlastní | Vidět objednávky přiřazené k sobě |
| `orders.view_all` | Zobrazit všechny | Vidět objednávky všech zaměstnanců |
| `orders.view_paid` | Zobrazit zaplacené | Vidět historii zaplacených účtů |
| `orders.view_cancelled` | Zobrazit stornované | Vidět stornované / zrušené účty |
| `orders.edit` | Upravit objednávku | Měnit položky na vlastní otevřené objednávce |
| `orders.edit_others` | Upravit cizí | Měnit položky na objednávce jiného zaměstnance |
| `orders.void_item` | Storno položky | Stornovat jednotlivou položku (vytvoří storno obj.) |
| `orders.void_bill` | Storno celého účtu | Zrušit / stornovat celý účet |
| `orders.reopen` | Znovu otevřít účet | Otevřít již zaplacený / zrušený účet |
| `orders.transfer` | Přesunout účet | Přesunout účet na jiný stůl / sekci |
| `orders.split` | Rozdělit účet | Rozdělit účet na více účtů |
| `orders.merge` | Sloučit účty | Spojit více účtů do jednoho |

### 3.2 Platby (`payments`)

| Kód | Název | Popis |
|-----|-------|-------|
| `payments.accept` | Přijímat platby | Zpracovat platbu |
| `payments.refund` | Vrátit platbu | Refundovat celý zaplacený účet |
| `payments.refund_item` | Vrátit položku | Refundovat jednu položku z účtu |
| `payments.method_cash` | Platba hotovostí | Přijímat hotovostní platby |
| `payments.method_card` | Platba kartou | Přijímat kartové platby |
| `payments.method_voucher` | Platba voucherem | Přijímat platby vouchery / stravenkami |
| `payments.method_credit` | Platba na kredit | Platba z kreditu zákazníka |

### 3.3 Slevy a ceny (`discounts`)

| Kód | Název | Popis |
|-----|-------|-------|
| `discounts.apply_item` | Sleva na položku | Aplikovat slevu na jednu položku |
| `discounts.apply_bill` | Sleva na účet | Aplikovat slevu na celý účet |
| `discounts.custom` | Vlastní sleva | Zadat libovolnou částku / procento slevy |
| `discounts.price_override` | Přepsat cenu | Ručně změnit prodejní cenu položky |
| `discounts.loyalty` | Uplatnit věrnostní body | Použít body zákazníka jako slevu |

### 3.4 Pokladna a směna (`register`)

| Kód | Název | Popis |
|-----|-------|-------|
| `register.open_session` | Otevřít směnu | Otevřít pokladní směnu (s počátečním stavem) |
| `register.close_session` | Uzavřít směnu | Provést uzávěrku / Z-report |
| `register.view_session` | Zobrazit stav směny | Vidět X-report / aktuální stav pokladny |
| `register.view_all_sessions` | Zobrazit historii směn | Vidět uzávěrky všech směn a uživatelů |
| `register.cash_in` | Vklad hotovosti | Zaznamenat vklad do pokladny |
| `register.cash_out` | Výběr hotovosti | Zaznamenat výběr z pokladny |
| `register.open_drawer` | Otevřít zásuvku | Otevřít pokladní zásuvku bez transakce |

### 3.5 Produkty a katalog (`products`)

| Kód | Název | Popis |
|-----|-------|-------|
| `products.view` | Zobrazit produkty | Vidět katalog a prodejní ceny |
| `products.view_cost` | Zobrazit nákupní ceny | Vidět nákupní cenu / marži |
| `products.manage` | Spravovat produkty | Vytvářet, upravovat, mazat produkty |
| `products.manage_categories` | Spravovat kategorie | CRUD kategorií |
| `products.manage_modifiers` | Spravovat modifikátory | CRUD skupin modifikátorů |
| `products.manage_recipes` | Spravovat receptury | CRUD receptur / BOM |
| `products.manage_pricing` | Spravovat ceny a daně | Měnit ceny, DPH, nákupní ceny |
| `products.set_availability` | Označit nedostupnost | Dočasně vyřadit položku z prodeje |

### 3.6 Sklad (`stock`)

| Kód | Název | Popis |
|-----|-------|-------|
| `stock.view` | Zobrazit stavy skladu | Vidět aktuální množství |
| `stock.receive` | Příjem zboží | Vytvořit příjemku |
| `stock.wastage` | Zaznamenat odpis | Vytvořit doklad odpisu / zmetku |
| `stock.adjust` | Korekce skladu | Ruční úprava množství |
| `stock.count` | Inventura | Provést inventurní sčítání |
| `stock.transfer` | Přesun mezi sklady | Přesun zboží mezi sklady |

### 3.7 Zákazníci a věrnost (`customers`)

| Kód | Název | Popis |
|-----|-------|-------|
| `customers.view` | Zobrazit zákazníky | Vidět seznam a detail zákazníků |
| `customers.manage` | Spravovat zákazníky | Vytvářet, upravovat, mazat zákazníky |
| `customers.manage_credit` | Spravovat kredit | Přidávat / odebírat kredit zákazníka |
| `customers.manage_loyalty` | Spravovat body | Ručně upravit věrnostní body |

### 3.8 Vouchery (`vouchers`)

| Kód | Název | Popis |
|-----|-------|-------|
| `vouchers.view` | Zobrazit vouchery | Vidět seznam voucherů |
| `vouchers.manage` | Spravovat vouchery | Vytvářet, upravovat, mazat vouchery |
| `vouchers.redeem` | Uplatnit voucher | Použít voucher na účet |

### 3.9 Stoly, sekce a rezervace (`venue`)

| Kód | Název | Popis |
|-----|-------|-------|
| `venue.view_map` | Zobrazit mapu | Vidět půdorys / mapu stolů |
| `venue.view_list` | Zobrazit seznam stolů | Vidět seznam stolů a jejich stav |
| `venue.manage_tables` | Spravovat stoly | CRUD stolů a sekcí |
| `venue.manage_layout` | Spravovat rozvržení | Editovat půdorys / floor map |
| `venue.reservations_view` | Zobrazit rezervace | Vidět seznam rezervací |
| `venue.reservations_manage` | Spravovat rezervace | Vytvářet, upravovat, rušit rezervace |

### 3.10 KDS a displej (`kds`)

| Kód | Název | Popis |
|-----|-------|-------|
| `kds.view` | Zobrazit KDS | Přístup na obrazovku kuchyně |
| `kds.bump` | Posunout stav | Potvrdit přípravu / expedici položky |
| `kds.bump_back` | Vrátit stav | Vrátit položku do předchozího stavu |
| `kds.manage` | Nastavení KDS | Konfigurovat KDS zařízení |
| `kds.view_detail` | Detail v info panelu | Zobrazit cenu, modifikátory, poznámky |

> **Poznámka k `kds.view_detail`:** Pomocník (helper) bez tohoto oprávnění vidí
> v info panelu pouze čas, stav a název položky. Operátor a admin vidí plný detail
> včetně cen, modifikátorů a poznámek.

### 3.11 Reporty (`reports`)

| Kód | Název | Popis |
|-----|-------|-------|
| `reports.view_own` | Vlastní přehled | Vidět jen vlastní tržby a aktivitu |
| `reports.view_sales` | Přehled prodejů | Přístup k souhrnným prodejním datům |
| `reports.view_financial` | Finanční reporty | Přístup k maržím, nákladům, daním |
| `reports.view_staff` | Reporty zaměstnanců | Přehledy výkonu zaměstnanců |
| `reports.export` | Export dat | Exportovat reporty do CSV / PDF |

### 3.12 Uživatelé a role (`users`)

| Kód | Název | Popis |
|-----|-------|-------|
| `users.view` | Zobrazit uživatele | Vidět seznam zaměstnanců |
| `users.manage` | Spravovat uživatele | Vytvářet, upravovat, deaktivovat |
| `users.assign_roles` | Přiřadit roli | Změnit roli zaměstnance |
| `users.manage_permissions` | Spravovat oprávnění | Přidělit / odebrat jednotlivá oprávnění |

### 3.13 Nastavení a hardware (`settings`)

| Kód | Název | Popis |
|-----|-------|-------|
| `settings.general` | Obecné nastavení | Info o firmě, jazyk, měna, prodejní mód |
| `settings.security` | Bezpečnost | PIN politika, auto-lock |
| `settings.payment_methods` | Platební metody | CRUD platebních metod |
| `settings.tax_rates` | Daňové sazby | CRUD daňových sazeb |
| `settings.fiscal` | Fiskální nastavení | EET / fiskalizace / tiskové povinnosti |
| `settings.hardware` | Hardware | Tiskárny, skenery, terminály, zásuvka |
| `settings.layout` | Rozvržení gridu | Editovat prodejní grid na pokladně |
| `settings.cloud` | Cloud a sync | Synchronizace, auth, migrace dat |
| `settings.data_wipe` | Smazat data | Factory reset / wipe dat |

---

## 4. Přiřazení rolím

### 4.1 Helper (Pomocník / Číšník)

> **24 oprávnění.** Základní provoz — vidí jen své věci, nemůže stornovat,
> refundovat ani měnit nastavení.

| Skupina | Oprávnění |
|---------|-----------|
| orders | `create`, `view`, `edit` |
| payments | `accept`, `method_cash`, `method_card` |
| discounts | *(žádné)* |
| register | `view_session` |
| products | `view` |
| stock | *(žádné)* |
| customers | `view` |
| vouchers | `view`, `redeem` |
| venue | `view_map`, `view_list`, `reservations_view` |
| kds | `view`, `bump` |
| reports | `view_own` |
| users | *(žádné)* |
| settings | *(žádné)* |

### 4.2 Operator (Směnový vedoucí)

> **50 oprávnění.** Vše od helpera + správa směny, storna, slevy, refundace,
> sklad (čtení + odpis), správa zákazníků.

| Skupina | Oprávnění navíc oproti helper |
|---------|-------------------------------|
| orders | + `view_all`, `view_paid`, `view_cancelled`, `edit_others`, `void_item`, `void_bill`, `transfer`, `split`, `merge` |
| payments | + `refund`, `refund_item`, `method_voucher`, `method_credit` |
| discounts | + `apply_item`, `apply_bill`, `custom`, `loyalty` |
| register | + `open_session`, `close_session`, `view_all_sessions`, `cash_in`, `cash_out`, `open_drawer` |
| products | + `set_availability` |
| stock | + `view`, `wastage` |
| customers | + `manage`, `manage_credit` |
| vouchers | + `manage` |
| venue | + `reservations_manage` |
| kds | + `bump_back`, `view_detail` |
| reports | + `view_sales`, `view_staff` |
| users | + `view` |
| settings | *(žádné)* |

### 4.3 Admin (Administrátor / Majitel)

> **78 oprávnění (vše).** Vše od operátora + správa produktů, skladu,
> uživatelů, nastavení, export, destruktivní akce.

| Skupina | Oprávnění navíc oproti operator |
|---------|--------------------------------|
| orders | + `reopen` |
| discounts | + `price_override` |
| products | + `view_cost`, `manage`, `manage_categories`, `manage_modifiers`, `manage_recipes`, `manage_pricing` |
| stock | + `receive`, `adjust`, `count`, `transfer` |
| customers | + `manage_loyalty` |
| venue | + `manage_tables`, `manage_layout` |
| kds | + `manage` |
| reports | + `view_financial`, `export` |
| users | + `manage`, `assign_roles`, `manage_permissions` |
| settings | + `general`, `security`, `payment_methods`, `tax_rates`, `fiscal`, `hardware`, `layout`, `cloud`, `data_wipe` |

### 4.4 Souhrnná matice

| Skupina | helper | operator | admin |
|---------|:------:|:--------:|:-----:|
| orders (13) | 3 | 12 | 13 |
| payments (7) | 3 | 7 | 7 |
| discounts (5) | 0 | 4 | 5 |
| register (7) | 1 | 7 | 7 |
| products (8) | 1 | 2 | 8 |
| stock (6) | 0 | 2 | 6 |
| customers (4) | 1 | 3 | 4 |
| vouchers (3) | 2 | 3 | 3 |
| venue (6) | 3 | 4 | 6 |
| kds (5) | 2 | 4 | 5 |
| reports (5) | 1 | 3 | 5 |
| users (4) | 0 | 1 | 4 |
| settings (9) | 0 | 0 | 9 |
| **Celkem** | **17** | **52** | **78** |

---

## 5. Budoucí rozšíření

Oprávnění připravená v architektuře, ale ne v prvním releasu:

| Kód | Popis | Kdy |
|-----|-------|-----|
| `payments.terminal` | Ovládání platebního terminálu | Integrace terminálu |
| `hardware.print_required` | Povinnost tisku účtenky | Fiskalizace |
| `hardware.scanner` | Použití čtečky čárových kódů | Integrace skeneru |
| `hardware.drawer` | Ovládání pokladní zásuvky | HW integrace |
| `fiscal.eet_manage` | Správa EET nastavení | EET implementace |
| `fiscal.eet_override` | Přepsat fiskální data | EET implementace |
| `settings.backup` | Záloha / obnova dat | Stage 4 |
| `settings.license` | Správa licence | Licencování |
| `reports.dashboard` | Přístup k dashboardu | Stage 4 |
| `stock.purchase_orders` | Objednávky od dodavatelů | Stage 4+ |
| `delivery.manage` | Správa rozvozů | Budoucí modul |
| `kiosk.manage` | Správa kiosku | Budoucí modul |

---

## 6. Architektonické poznámky

### 6.1 Co se nemění

- **DB tabulky** `permissions`, `role_permissions`, `user_permissions` — struktura zůstává
- **Provider** `hasPermissionProvider(code)` — zachován, O(1) lookup
- **Metoda** `applyRoleToUser()` — zachována, jen role dostanou víc oprávnění
- **Kódová konvence** `category.action` — zachována a rozšířena

### 6.2 Co se mění

- **Seed data:** 16 → 78 řádků v `permissions`, proporcionálně v `role_permissions`
- **Enforcement:** Přidání `hasPermissionProvider` kontrol do všech relevantních obrazovek, dialogů a repozitářů

### 6.3 Tří-stavový model (inspirace Shopify)

Zvážit rozšíření z binárního `granted` / `not granted` na tři stavy:

| Stav | Chování |
|------|---------|
| **Allowed** | Povoleno vždy |
| **Denied** | Zakázáno (výchozí pro negrantované) |
| **Approval Required** | Vyžaduje PIN nadřízeného |

Vyžaduje přidání sloupce `grant_type` do `user_permissions`. Není nutné pro MVP,
ale architektura by s tím měla počítat.

### 6.4 Elevated Permissions (inspirace Lightspeed)

Dočasné povýšení oprávnění:

1. Číšník (helper) chce provést storno
2. Systém požádá o PIN nadřízeného (operator/admin)
3. Nadřízený zadá svůj PIN
4. Akce se provede a zaloguje pod oba uživatele
5. Oprávnění se nezmění trvale

Vhodné pro: storna, refundace, ruční slevy, otevření zásuvky.

### 6.5 Kde kontrolovat oprávnění

| Vrstva | Kdy | Příklad |
|--------|-----|---------|
| **Router** | Přístup na celou obrazovku | `settings/*` → `settings.general` |
| **UI (widget)** | Skrytí / disable tlačítka | Storno button → `orders.void_item` |
| **Repository** | Vynucení při operaci | `billRepo.cancelBill()` → `orders.void_bill` |

Doporučení: Kontrolovat **vždy v UI** (UX — tlačítko se nezobrazí) **i v repozitáři**
(bezpečnost — nelze obejít).

---

## 7. Srovnání s konkurencí

| Metrika | EPOS (dnes) | EPOS (nový) | Square | Toast | Lightspeed | Dotykačka | Shopify |
|---------|:-----------:|:-----------:|:------:|:-----:|:----------:|:---------:|:-------:|
| Skupin | 7 | **13** | ~6 | 5 | 7 | 3 | ~8 |
| Oprávnění | 16 | **78** | ~19 | ~30 | ~25 | ~20+ | ~15 |
| Role | 3 | 3 | 3+C | job | 3+C | per-dom | 1+C |
| Tří-stav | - | Prepared | Yes | - | Yes | - | Yes |
| Elevated PIN | - | Prepared | Yes | Yes | Yes | - | Yes |
| Enforced | 2 | **78** | All | All | All | All | All |

> **Legenda:** C = custom roles, job = job-based, per-dom = per-domain accounts

---

## Zdroje

- Analýza codebase: `lib/core/data/`, `lib/features/`, `lib/core/database/tables/`
- Seed data: `supabase/migrations/20260218_001_seed_global_data.sql`
- Square: [Employee Permissions](https://squareup.com/help/us/en/article/5822-employee-permissions)
- Toast: [Access Permissions Reference](https://doc.toasttab.com/doc/platformguide/adminPermissions.html)
- Lightspeed: [Managing User Permissions](https://o-series-support.lightspeedhq.com/hc/en-us/articles/31329418175003)
- Clover: [Manage Roles](https://www.clover.com/en-US/help/manage-roles-and-access-permissions)
- Revel: [Role Permissions Guide](https://support.revelsystems.com/hc/en-us/articles/205153595)
- TouchBistro: [Staff Permissions](https://help.touchbistro.com/s/article/Staff-Permissions)
- Shopify: [POS Permissions](https://help.shopify.com/en/manual/your-account/users/roles/permissions/pos-permissions)
- Loyverse: [Access Rights](https://help.loyverse.com/help/how-manage-access-rights-employees)
- Dotykacka: [Uživatelská práva](https://manual.dotykacka.cz/prehleduzivatelskychprav.html)

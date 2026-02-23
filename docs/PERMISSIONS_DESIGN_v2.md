# Návrh systému oprávnění v2

> Konsolidovaný návrh práv pro EPOS Desktop POS.
> Vychází z analýzy kódu, PROJECT.md, konkurence (Square, Toast, Lightspeed,
> Clover, Revel, TouchBistro, Shopify, Loyverse, Dotykačka, Poster, Storyous)
> a zpětné vazby z revize v1 + gap analýzy.

---

## Obsah

1. [Současný stav](#1-současný-stav)
2. [Přehled nového systému](#2-přehled-nového-systému)
3. [Skupiny a oprávnění](#3-skupiny-a-oprávnění)
   - [3.1 Objednávky](#31-objednávky-orders)
   - [3.2 Platby](#32-platby-payments)
   - [3.3 Slevy a ceny](#33-slevy-a-ceny-discounts)
   - [3.4 Pokladna](#34-pokladna-register)
   - [3.5 Směny zaměstnanců](#35-směny-zaměstnanců-shifts)
   - [3.6 Produkty a katalog](#36-produkty-a-katalog-products)
   - [3.7 Sklad](#37-sklad-stock)
   - [3.8 Zákazníci a věrnost](#38-zákazníci-a-věrnost-customers)
   - [3.9 Vouchery](#39-vouchery-vouchers)
   - [3.10 Provoz — stoly a rezervace](#310-provoz--stoly-a-rezervace-venue)
   - [3.11 Reporty a analýzy](#311-reporty-a-analýzy-reports)
   - [3.12 Tisk](#312-tisk-printing)
   - [3.13 Data](#313-data-data)
   - [3.14 Uživatelé a role](#314-uživatelé-a-role-users)
   - [3.15 Nastavení — firma](#315-nastavení--firma-settings_company)
   - [3.16 Nastavení — provozovna](#316-nastavení--provozovna-settings_venue)
   - [3.17 Nastavení — pokladna](#317-nastavení--pokladna-settings_register)
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
| Reálně kontrolováno v kódu | **2** (`settings.manage`, `orders.view`) |

Většina operací (storno, refundace, slevy, pokladní operace, sklad) nemá
žádnou kontrolu oprávnění. Jakýkoli přihlášený uživatel může provést cokoli.

---

## 2. Přehled nového systému

| Metrika | Dnes | Nový návrh |
|---------|------|------------|
| Skupin | 7 | **17** |
| Oprávnění | 16 | **106** |
| Role | 3 | **4** (helper, operator, manager, admin) |
| Kontrolováno | 2 | **106** |

### Role

| Role | Český název | Popis |
|------|-------------|-------|
| `helper` | Pomocník / Číšník | Základní obsluha — přijímá objednávky, inkasuje, vidí jen své věci |
| `operator` | Směnový vedoucí | Řídí směnu — storna, refundace, slevy, pokladní operace, přehled směny |
| `manager` | Manažer | Řídí provoz — katalog, sklad, reporty, zaměstnanci, nastavení provozovny |
| `admin` | Administrátor / Majitel | Plný přístup — systémová nastavení, daně, data, role, destruktivní akce |

### Přehled skupin

| # | Skupina | Prefix | Počet |
|---|---------|--------|:-----:|
| 1 | Objednávky | `orders.*` | 17 |
| 2 | Platby | `payments.*` | 11 |
| 3 | Slevy a ceny | `discounts.*` | 5 |
| 4 | Pokladna | `register.*` | 7 |
| 5 | Směny zaměstnanců | `shifts.*` | 4 |
| 6 | Produkty a katalog | `products.*` | 11 |
| 7 | Sklad | `stock.*` | 8 |
| 8 | Zákazníci a věrnost | `customers.*` | 4 |
| 9 | Vouchery | `vouchers.*` | 3 |
| 10 | Provoz — stoly a rezervace | `venue.*` | 3 |
| 11 | Reporty a analýzy | `reports.*` | 5 |
| 12 | Tisk | `printing.*` | 4 |
| 13 | Data | `data.*` | 3 |
| 14 | Uživatelé a role | `users.*` | 4 |
| 15 | Nastavení — firma | `settings_company.*` | 7 |
| 16 | Nastavení — provozovna | `settings_venue.*` | 3 |
| 17 | Nastavení — pokladna | `settings_register.*` | 7 |
| | | **Celkem** | **106** |

---

## 3. Skupiny a oprávnění

### 3.1 Objednávky (`orders`)

Zahrnuje správu účtů, objednávek i KDS/obrazovku objednávek — jde o jedno
propojené workflow se sdílenými akcemi.

| Kód | Název | Popis |
|-----|-------|-------|
| `orders.create` | Vytvořit objednávku | Přidávat položky na účet |
| `orders.view` | Zobrazit vlastní | Vidět objednávky přiřazené k sobě |
| `orders.view_all` | Zobrazit všechny | Vidět objednávky všech zaměstnanců |
| `orders.view_paid` | Zobrazit zaplacené | Vidět historii zaplacených účtů |
| `orders.view_cancelled` | Zobrazit stornované | Vidět stornované a zrušené účty |
| `orders.view_detail` | Detail v info panelu | Zobrazit cenu, modifikátory a poznámky; bez tohoto oprávnění uživatel vidí jen čas, stav a název |
| `orders.edit` | Upravit objednávku | Měnit položky na vlastní otevřené objednávce |
| `orders.edit_others` | Upravit cizí | Měnit položky na objednávce jiného zaměstnance |
| `orders.void_item` | Storno položky | Stornovat jednotlivou položku (vytvoří storno objednávku) |
| `orders.void_bill` | Storno celého účtu | Zrušit nebo stornovat celý účet |
| `orders.reopen` | Znovu otevřít účet | Otevřít již zaplacený nebo zrušený účet |
| `orders.transfer` | Přesunout účet | Přesunout účet na jiný stůl nebo sekci |
| `orders.split` | Rozdělit účet | Rozdělit účet na více účtů |
| `orders.merge` | Sloučit účty | Spojit více účtů do jednoho |
| `orders.assign_customer` | Přiřadit zákazníka | Přiřadit zákazníka k účtu/objednávce |
| `orders.bump` | Posunout stav | Potvrdit přípravu nebo expedici položky |
| `orders.bump_back` | Vrátit stav | Vrátit položku do předchozího stavu přípravy |

---

### 3.2 Platby (`payments`)

| Kód | Název | Popis |
|-----|-------|-------|
| `payments.accept` | Přijímat platby | Zpracovat platbu na účtu |
| `payments.refund` | Vrátit platbu | Refundovat celý zaplacený účet |
| `payments.refund_item` | Vrátit položku | Refundovat jednu položku z účtu |
| `payments.method_cash` | Platba hotovostí | Přijímat hotovostní platby |
| `payments.method_card` | Platba kartou | Přijímat kartové platby |
| `payments.method_voucher` | Platba voucherem | Platba dárkovým nebo slevovým voucherem z aplikace |
| `payments.method_meal_ticket` | Platba stravenkami | Platba stravenkami (Sodexo, Up, Edenred apod.) |
| `payments.method_credit` | Platba na kredit | Platba z kreditu zákazníka |
| `payments.skip_cash_dialog` | Přeskočit dialog hotovosti | Dokončit hotovostní platbu bez zadání přijaté částky; bez tohoto oprávnění musí obsluha zadat kolik zákazník dal a systém zobrazí kolik vrátit |
| `payments.accept_tip` | Přijmout spropitné | Přijmout spropitné při platbě |
| `payments.adjust_tip` | Upravit spropitné | Upravit spropitné po zaplacení |

---

### 3.3 Slevy a ceny (`discounts`)

| Kód | Název | Popis |
|-----|-------|-------|
| `discounts.apply_item` | Sleva na položku | Aplikovat slevu na jednu položku |
| `discounts.apply_bill` | Sleva na účet | Aplikovat slevu na celý účet |
| `discounts.custom` | Vlastní sleva | Zadat libovolnou částku nebo procento slevy |
| `discounts.price_override` | Přepsat cenu | Ručně změnit prodejní cenu položky |
| `discounts.loyalty` | Uplatnit věrnostní body | Použít body zákazníka jako slevu |

---

### 3.4 Pokladna (`register`)

Správa pokladních sessions — otevření a uzavření pokladny, hotovostní operace.

> **Pozn.:** Směny zaměstnanců (příchod / odchod / docházka) jsou v samostatné
> skupině [3.5 Směny](#35-směny-zaměstnanců-shifts).

| Kód | Název | Popis |
|-----|-------|-------|
| `register.open_session` | Otevřít pokladnu | Zahájit pokladní session s počátečním stavem hotovosti |
| `register.close_session` | Uzavřít pokladnu | Provést uzávěrku (Z-report) |
| `register.view_session` | Zobrazit stav pokladny | Vidět X-report a aktuální stav hotovosti |
| `register.view_all_sessions` | Historie uzávěrek | Vidět uzávěrky všech pokladen a uživatelů |
| `register.cash_in` | Vklad hotovosti | Zaznamenat vklad do pokladny |
| `register.cash_out` | Výběr hotovosti | Zaznamenat výběr z pokladny |
| `register.open_drawer` | Otevřít zásuvku | Otevřít pokladní zásuvku bez transakce ("no sale") |

---

### 3.5 Směny zaměstnanců (`shifts`)

Evidence pracovních směn — příchod, odchod, docházka.

| Kód | Název | Popis |
|-----|-------|-------|
| `shifts.clock_in_out` | Přihlásit / odhlásit směnu | Zaznamenat vlastní příchod a odchod |
| `shifts.view_own` | Zobrazit vlastní směny | Vidět historii vlastních směn |
| `shifts.view_all` | Zobrazit všechny směny | Vidět směny všech zaměstnanců |
| `shifts.manage` | Spravovat směny | Vytvářet, upravovat a mazat směny zaměstnanců |

---

### 3.6 Produkty a katalog (`products`)

| Kód | Název | Popis |
|-----|-------|-------|
| `products.view` | Zobrazit produkty | Vidět katalog a prodejní ceny |
| `products.view_cost` | Zobrazit nákupní ceny | Vidět nákupní cenu a marži |
| `products.manage` | Spravovat produkty | Vytvářet, upravovat a mazat produkty |
| `products.manage_categories` | Spravovat kategorie | Vytvářet, upravovat a mazat kategorie |
| `products.manage_modifiers` | Spravovat modifikátory | Vytvářet, upravovat a mazat skupiny modifikátorů |
| `products.manage_recipes` | Spravovat receptury | Vytvářet, upravovat a mazat receptury (BOM) |
| `products.manage_purchase_price` | Měnit nákupní ceny | Upravit nákupní cenu produktu (i při naskladnění) |
| `products.manage_tax` | Měnit daňové sazby | Přiřazovat a měnit daňové sazby na položkách |
| `products.manage_suppliers` | Spravovat dodavatele | Vytvářet, upravovat a mazat dodavatele |
| `products.manage_manufacturers` | Spravovat výrobce | Vytvářet, upravovat a mazat výrobce |
| `products.set_availability` | Označit nedostupnost | Dočasně vyřadit položku z prodeje |

---

### 3.7 Sklad (`stock`)

| Kód | Název | Popis |
|-----|-------|-------|
| `stock.view` | Zobrazit stavy skladu | Vidět aktuální množství a stavy zásob |
| `stock.receive` | Příjem zboží | Vytvořit příjemku |
| `stock.wastage` | Zaznamenat odpis | Vytvořit doklad odpisu nebo zmetku |
| `stock.adjust` | Korekce skladu | Ručně upravit množství na skladě |
| `stock.count` | Inventura | Provést inventurní sčítání |
| `stock.transfer` | Přesun mezi sklady | Přesunout zboží mezi sklady |
| `stock.set_price_strategy` | Změnit strategii NC | Měnit strategii změny nákupní ceny při příjmu (přepsat / zachovat / průměr / vážený průměr) |
| `stock.manage_warehouses` | Spravovat sklady | Vytvořit, upravit a smazat sklady |

---

### 3.8 Zákazníci a věrnost (`customers`)

| Kód | Název | Popis |
|-----|-------|-------|
| `customers.view` | Zobrazit zákazníky | Vidět seznam a detail zákazníků |
| `customers.manage` | Spravovat zákazníky | Vytvářet, upravovat a mazat zákazníky |
| `customers.manage_credit` | Spravovat kredit | Přidávat a odebírat kredit zákazníka |
| `customers.manage_loyalty` | Spravovat body | Ručně upravit věrnostní body |

---

### 3.9 Vouchery (`vouchers`)

| Kód | Název | Popis |
|-----|-------|-------|
| `vouchers.view` | Zobrazit vouchery | Vidět seznam voucherů |
| `vouchers.manage` | Spravovat vouchery | Vytvářet, upravovat a mazat vouchery |
| `vouchers.redeem` | Uplatnit voucher | Použít voucher na účet |

---

### 3.10 Provoz — stoly a rezervace (`venue`)

Provozní pohled na stoly a rezervace během směny. Zobrazení formou mapy
nebo seznamu je uživatelská preference, ne oprávnění.

> **Pozn.:** Konfigurace stolů, sekcí a půdorysu je v
> [3.16 Nastavení — provozovna](#316-nastavení--provozovna-settings_venue).

| Kód | Název | Popis |
|-----|-------|-------|
| `venue.view` | Zobrazit stoly | Vidět stoly a jejich stav (mapa nebo seznam dle preferencí) |
| `venue.reservations_view` | Zobrazit rezervace | Vidět seznam rezervací |
| `venue.reservations_manage` | Spravovat rezervace | Vytvářet, upravovat a rušit rezervace |

---

### 3.11 Reporty a analýzy (`reports`)

| Kód | Název | Popis |
|-----|-------|-------|
| `reports.view_own` | Vlastní přehled | Vidět jen vlastní tržby a aktivitu |
| `reports.view_sales` | Přehled prodejů | Přístup k souhrnným prodejním datům |
| `reports.view_financial` | Finanční reporty | Přístup k maržím, nákladům a daním |
| `reports.view_staff` | Reporty zaměstnanců | Přehledy výkonu zaměstnanců |
| `reports.view_tips` | Přehledy spropitného | Zobrazit přehledy spropitného |

---

### 3.12 Tisk (`printing`)

| Kód | Název | Popis |
|-----|-------|-------|
| `printing.receipt` | Tisk účtenky | Vytisknout účtenku pro zákazníka |
| `printing.reprint` | Opakovaný tisk | Znovu vytisknout již vytištěnou účtenku |
| `printing.z_report` | Tisk Z-reportu | Vytisknout uzávěrkový report |
| `printing.inventory_report` | Tisk inventurního reportu | Vytisknout skladový nebo inventurní report |

---

### 3.13 Data (`data`)

Operace s daty — export, import, zálohy.

| Kód | Název | Popis |
|-----|-------|-------|
| `data.export` | Export dat | Exportovat reporty a seznamy do CSV nebo PDF |
| `data.import` | Import dat | Importovat produkty, zákazníky a další data z CSV |
| `data.backup` | Záloha a obnova | Vytvořit zálohu dat nebo obnovit ze zálohy |

---

### 3.14 Uživatelé a role (`users`)

| Kód | Název | Popis |
|-----|-------|-------|
| `users.view` | Zobrazit uživatele | Vidět seznam zaměstnanců |
| `users.manage` | Spravovat uživatele | Vytvářet, upravovat a deaktivovat zaměstnance |
| `users.assign_roles` | Přiřadit roli | Změnit roli zaměstnance |
| `users.manage_permissions` | Spravovat oprávnění | Přidělit nebo odebrat jednotlivá oprávnění |

---

### 3.15 Nastavení — firma (`settings_company`)

Odpovídá obrazovce **Nastavení firmy** (info, zabezpečení, cloud, fiskální).

| Kód | Název | Popis |
|-----|-------|-------|
| `settings_company.info` | Informace o firmě | Upravit název, IČO, adresu, měnu, jazyk, prodejní mód |
| `settings_company.security` | Zabezpečení | Nastavit PIN politiku a automatický zámek |
| `settings_company.fiscal` | Fiskální nastavení | Nastavit EET, fiskalizaci a tiskové povinnosti |
| `settings_company.cloud` | Cloud a synchronizace | Spravovat synchronizaci, přihlášení a migraci dat |
| `settings_company.data_wipe` | Smazat data | Provést factory reset nebo smazání všech dat |
| `settings_company.view_log` | Zobrazit systémový log | Zobrazit diagnostický a systémový log |
| `settings_company.clear_log` | Smazat log | Smazat / vyčistit systémový log |

---

### 3.16 Nastavení — provozovna (`settings_venue`)

Odpovídá obrazovce **Nastavení provozovny** (sekce, stoly, půdorys).

| Kód | Název | Popis |
|-----|-------|-------|
| `settings_venue.sections` | Spravovat sekce | Vytvářet, upravovat a mazat sekce restaurace |
| `settings_venue.tables` | Spravovat stoly | Vytvářet, upravovat a mazat stoly |
| `settings_venue.floor_plan` | Editovat půdorys | Upravovat rozvržení mapy a pozice prvků |

---

### 3.17 Nastavení — pokladna (`settings_register`)

Odpovídá obrazovce **Nastavení pokladny** (terminály, hardware, grid, displeje).

| Kód | Název | Popis |
|-----|-------|-------|
| `settings_register.manage` | Spravovat pokladny | Vytvářet, upravovat a mazat pokladní terminály |
| `settings_register.hardware` | Nastavit hardware | Konfigurovat tiskárny, skenery, platební terminály a zásuvku |
| `settings_register.grid` | Editovat prodejní grid | Upravovat rozvržení tlačítek na prodejní obrazovce |
| `settings_register.displays` | Spravovat displeje | Konfigurovat zákaznické a kuchyňské displeje |
| `settings_register.payment_methods` | Platební metody | Vytvářet, upravovat a mazat platební metody |
| `settings_register.tax_rates` | Daňové sazby | Vytvářet, upravovat a mazat daňové sazby |
| `settings_register.manage_devices` | Správa zobrazovacích zařízení | Spravovat KDS a zákaznické displeje jako zařízení |

---

## 4. Přiřazení rolím

### 4.1 Helper (Pomocník / Číšník)

> **20 oprávnění.** Základní provoz — přijímá objednávky, inkasuje platby,
> vidí jen své věci, nemůže stornovat, refundovat, dávat slevy ani měnit
> nastavení. V info panelu objednávek vidí pouze čas, stav a název
> (bez cen a modifikátorů).

| Skupina | Oprávnění | Počet |
|---------|-----------|:-----:|
| orders | `create`, `view`, `edit`, `assign_customer`, `bump` | 5 |
| payments | `accept`, `method_cash`, `method_card`, `accept_tip` | 4 |
| discounts | — | 0 |
| register | `view_session` | 1 |
| shifts | `clock_in_out`, `view_own` | 2 |
| products | `view` | 1 |
| stock | — | 0 |
| customers | `view` | 1 |
| vouchers | `view`, `redeem` | 2 |
| venue | `view`, `reservations_view` | 2 |
| reports | `view_own` | 1 |
| printing | `receipt` | 1 |
| data | — | 0 |
| users | — | 0 |
| settings_company | — | 0 |
| settings_venue | — | 0 |
| settings_register | — | 0 |
| | **Celkem** | **20** |

---

### 4.2 Operator (Směnový vedoucí)

> **62 oprávnění.** Vše od helpera + storna, refundace, slevy, pokladní
> operace, odpisy, správa zákazníků a rezervací. Plný detail v objednávkách.
> Řídí provoz během směny.

| Skupina | Navíc oproti helper | Celkem |
|---------|---------------------|:------:|
| orders | + `view_all`, `view_paid`, `view_cancelled`, `view_detail`, `edit_others`, `void_item`, `void_bill`, `transfer`, `split`, `merge`, `bump_back` | 16 |
| payments | + `refund`, `refund_item`, `method_voucher`, `method_meal_ticket`, `method_credit`, `skip_cash_dialog`, `adjust_tip` | 11 |
| discounts | + `apply_item`, `apply_bill`, `custom`, `loyalty` | 4 |
| register | + `open_session`, `close_session`, `view_all_sessions`, `cash_in`, `cash_out`, `open_drawer` | 7 |
| shifts | + `view_all` | 3 |
| products | + `set_availability` | 2 |
| stock | + `view`, `wastage` | 2 |
| customers | + `manage`, `manage_credit` | 3 |
| vouchers | + `manage` | 3 |
| venue | + `reservations_manage` | 3 |
| reports | + `view_sales`, `view_staff`, `view_tips` | 4 |
| printing | + `reprint`, `z_report` | 3 |
| data | — | 0 |
| users | + `view` | 1 |
| settings_company | — | 0 |
| settings_venue | — | 0 |
| settings_register | — | 0 |
| | **Celkem** | **62** |

---

### 4.3 Manager (Manažer)

> **85 oprávnění.** Vše od operátora + správa katalogu (produkty, kategorie,
> modifikátory, receptury, dodavatelé, výrobci), skladu (příjem, korekce,
> inventura, přesun), zaměstnanců, finanční reporty, nastavení provozovny
> a export dat. Řídí celý provoz na denní bázi.

| Skupina | Navíc oproti operator | Celkem |
|---------|----------------------|:------:|
| orders | + `reopen` | 17 |
| payments | — | 11 |
| discounts | — | 4 |
| register | — | 7 |
| shifts | + `manage` | 4 |
| products | + `view_cost`, `manage`, `manage_categories`, `manage_modifiers`, `manage_recipes`, `manage_suppliers`, `manage_manufacturers` | 9 |
| stock | + `receive`, `adjust`, `count`, `transfer` | 6 |
| customers | + `manage_loyalty` | 4 |
| vouchers | — | 3 |
| venue | — | 3 |
| reports | + `view_financial` | 5 |
| printing | + `inventory_report` | 4 |
| data | + `export` | 1 |
| users | + `manage` | 2 |
| settings_company | — | 0 |
| settings_venue | + `sections`, `tables`, `floor_plan` | 3 |
| settings_register | + `grid`, `displays` | 2 |
| | **Celkem** | **85** |

---

### 4.4 Admin (Administrátor / Majitel)

> **106 oprávnění (vše).** Vše od manažera + systémová nastavení firmy,
> správa daní a nákupních cen, cenová strategie, sklady, role a oprávnění
> uživatelů, import/záloha dat, registr a hardware, destruktivní akce.

| Skupina | Navíc oproti manager | Celkem |
|---------|---------------------|:------:|
| orders | — | 17 |
| payments | — | 11 |
| discounts | + `price_override` | 5 |
| register | — | 7 |
| shifts | — | 4 |
| products | + `manage_purchase_price`, `manage_tax` | 11 |
| stock | + `set_price_strategy`, `manage_warehouses` | 8 |
| customers | — | 4 |
| vouchers | — | 3 |
| venue | — | 3 |
| reports | — | 5 |
| printing | — | 4 |
| data | + `import`, `backup` | 3 |
| users | + `assign_roles`, `manage_permissions` | 4 |
| settings_company | + `info`, `security`, `fiscal`, `cloud`, `data_wipe`, `view_log`, `clear_log` | 7 |
| settings_venue | — | 3 |
| settings_register | + `manage`, `hardware`, `payment_methods`, `tax_rates`, `manage_devices` | 7 |
| | **Celkem** | **106** |

---

### 4.5 Souhrnná matice

| Skupina | Počet | helper | operator | manager | admin |
|---------|:-----:|:------:|:--------:|:-------:|:-----:|
| orders | 17 | 5 | 16 | 17 | 17 |
| payments | 11 | 4 | 11 | 11 | 11 |
| discounts | 5 | 0 | 4 | 4 | 5 |
| register | 7 | 1 | 7 | 7 | 7 |
| shifts | 4 | 2 | 3 | 4 | 4 |
| products | 11 | 1 | 2 | 9 | 11 |
| stock | 8 | 0 | 2 | 6 | 8 |
| customers | 4 | 1 | 3 | 4 | 4 |
| vouchers | 3 | 2 | 3 | 3 | 3 |
| venue | 3 | 2 | 3 | 3 | 3 |
| reports | 5 | 1 | 4 | 5 | 5 |
| printing | 4 | 1 | 3 | 4 | 4 |
| data | 3 | 0 | 0 | 1 | 3 |
| users | 4 | 0 | 1 | 2 | 4 |
| settings_company | 7 | 0 | 0 | 0 | 7 |
| settings_venue | 3 | 0 | 0 | 3 | 3 |
| settings_register | 7 | 0 | 0 | 2 | 7 |
| **Celkem** | **106** | **20** | **62** | **85** | **106** |

### 4.6 Progrese mezi rolemi

| Přechod | Nových oprávnění | Hlavní oblasti |
|---------|:----------------:|----------------|
| helper → operator | +42 | Storna, refundace, slevy, pokladní operace, přehled směny |
| operator → manager | +23 | Katalog, sklad, zaměstnanci, finanční reporty, nastavení provozovny |
| manager → admin | +21 | Systém, daně, ceny, data, role, hardware, destruktivní akce |

---

## 5. Budoucí rozšíření

Oprávnění připravená v architektuře, ale ne v prvním releasu.

| Kód | Popis | Kdy |
|-----|-------|-----|
| `payments.terminal` | Ovládání platebního terminálu | Integrace terminálu |
| `hardware.print_required` | Povinnost tisku účtenky | Fiskalizace |
| `hardware.scanner` | Použití čtečky čárových kódů | Integrace skeneru |
| `hardware.drawer` | Ovládání pokladní zásuvky | HW integrace |
| `fiscal.eet_manage` | Správa EET nastavení | EET implementace |
| `fiscal.eet_override` | Přepsat fiskální data | EET implementace |
| `reports.dashboard` | Přístup k dashboardu | Stage 4 |
| `stock.purchase_orders` | Objednávky od dodavatelů | Stage 4+ |
| `delivery.manage` | Správa rozvozů | Budoucí modul |
| `kiosk.manage` | Správa kiosku | Budoucí modul |

---

## 6. Architektonické poznámky

### 6.1 Co se nemění

- **DB tabulky** `permissions`, `role_permissions`, `user_permissions` — struktura zůstává
- **Provider** `hasPermissionProvider(code)` — zachován, O(1) lookup v `Set<String>`
- **Metoda** `applyRoleToUser()` — zachována, jen role dostanou víc oprávnění
- **Kódová konvence** `category.action` — zachována a rozšířena

### 6.2 Co se mění

- **Seed data:** 16 → 106 řádků v `permissions`, proporcionálně v `role_permissions`
- **Role:** Přidání nové role `manager` do tabulky `roles`
- **Enforcement:** Přidání `hasPermissionProvider` kontrol do obrazovek, dialogů
  a repozitářů

### 6.3 Kde kontrolovat oprávnění

| Vrstva | Kdy | Příklad |
|--------|-----|---------|
| **Router** | Přístup na celou obrazovku | `settings/*` → `settings_company.*` |
| **UI (widget)** | Skrytí nebo zašednutí tlačítka | Storno button → `orders.void_item` |
| **Repository** | Vynucení při operaci | `billRepo.cancelBill()` → `orders.void_bill` |

Doporučení: Kontrolovat **vždy v UI** (tlačítko se nezobrazí) **i v repozitáři**
(nelze obejít přímým voláním).

### 6.4 Tří-stavový model (inspirace Shopify)

Zvážit rozšíření z binárního `granted` / `not granted` na tři stavy:

| Stav | Chování |
|------|---------|
| **Allowed** | Povoleno vždy |
| **Denied** | Zakázáno (výchozí pro nepřidělené) |
| **Approval Required** | Vyžaduje PIN nadřízeného |

Vyžaduje přidání sloupce `grant_type` do `user_permissions`.
Není nutné pro MVP, ale architektura by s tím měla počítat.

### 6.5 Elevated Permissions (inspirace Lightspeed)

Dočasné povýšení oprávnění:

1. Číšník (helper) chce provést storno
2. Systém požádá o PIN nadřízeného (operator / manager / admin)
3. Nadřízený zadá svůj PIN
4. Akce se provede a zaloguje pod oba uživatele
5. Oprávnění se nezmění trvale

Vhodné pro: storna, refundace, ruční slevy, otevření zásuvky.

---

## 7. Srovnání s konkurencí

| Metrika | EPOS (dnes) | EPOS (v2) | Square | Toast | Lightspeed | Dotykačka | Shopify |
|---------|:-----------:|:---------:|:------:|:-----:|:----------:|:---------:|:-------:|
| Skupin | 7 | **17** | ~6 | 5 | 7 | 3 | ~8 |
| Oprávnění | 16 | **106** | ~19 | ~30 | ~25 | ~20+ | ~15 |
| Role | 3 | **4** | 3+C | job | 3+C | per-dom | 1+C |
| Tří-stav | — | Prepared | Yes | — | Yes | — | Yes |
| Elevated PIN | — | Prepared | Yes | Yes | Yes | — | Yes |
| Enforced | 2 | **106** | All | All | All | All | All |

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

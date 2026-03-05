# Maty — Permissions & Security

Tento dokument detailně popisuje systém oprávnění, role uživatelů a bezpečnostní mechanismy.

---

## 1. Architektura oprávnění
Systém funguje **offline-first**. Veškerá data jsou uložena lokálně v SQLite.
- **User Permissions:** Zdroj pravdy pro autorizaci (ne role).
- **Role Templates:** Šablony pro hromadné přiřazení (admin, manager, operator, helper).
- **Runtime Check:** O(1) lookup v in-memory `Set<String>`.
- **Dependency Implications:** Změna roleTemplate neovlivní stávající uživatele, dokud není znovu aplikována.

---

## 2. Katalog oprávnění (105)

Oprávnění jsou rozdělena do 17 skupin s konvencí `skupina.akce`.

### 1. Objednávky (`orders`) — 15 kódů
- `orders.create`: Vytvořit objednávku (přidávat položky na účet).
- `orders.view`: Zobrazit vlastní objednávky.
- `orders.view_paid`: Zobrazit historii zaplacených účtů.
- `orders.view_cancelled`: Zobrazit stornované a zrušené účty.
- `orders.view_detail`: Zobrazit detail (cenu, modifikátory, poznámky).
- `orders.edit`: Upravit položky na vlastní otevřené objednávce.
- `orders.void_item`: Stornovat jednotlivou položku.
- `orders.void_bill`: Stornovat celý účet.
- `orders.reopen`: Znovu otevřít zaplacený nebo zrušený účet.
- `orders.transfer`: Přesunout účet na jiný stůl nebo sekci.
- `orders.split`: Rozdělit účet na více účtů.
- `orders.merge`: Spojit více účtů do jednoho.
- `orders.assign_customer`: Přiřadit zákazníka k účtu.
- `orders.bump`: Potvrdit přípravu nebo expedici položky.
- `orders.bump_back`: Vrátit položku do předchozího stavu přípravy.

### 2. Platby (`payments`) — 11 kódů
- `payments.accept`: Zpracovat platbu na účtu.
- `payments.refund`: Refundovat celý zaplacený účet.
- `payments.refund_item`: Refundovat jednu položku z účtu.
- `payments.method_cash`: Platba hotovostí.
- `payments.method_card`: Platba kartou.
- `payments.method_voucher`: Platba voucherem.
- `payments.method_meal_ticket`: Platba stravenkami.
- `payments.method_bank`: Platba bankovním převodem.
- `payments.method_credit`: Platba z kreditu zákazníka.
- `payments.skip_cash_dialog`: Dokončit hotovostní platbu bez zadání přijaté částky.
- `payments.accept_tip`: Přijmout spropitné při platbě.

### 3. Slevy a ceny (`discounts`) — 5 kódů
- `discounts.apply_item_limited`: Sleva na položku omezená na firemní limit.
- `discounts.apply_item`: Sleva na položku bez omezení.
- `discounts.apply_bill_limited`: Sleva na celý účet omezená na firemní limit.
- `discounts.apply_bill`: Sleva na celý účet bez omezení.
- `discounts.loyalty`: Uplatnit věrnostní body.

### 4. Pokladna (`register`) — 4 kódy
- `register.open_close`: Otevřít nebo uzavřít pokladní session.
- `register.cash_in`: Zaznamenat vklad do pokladny.
- `register.cash_out`: Zaznamenat výběr z pokladny.
- `register.open_drawer`: Otevřít pokladní zásuvku bez transakce.

### 5. Směny zaměstnanců (`shifts`) — 1 kód
- `shifts.manage`: Vytvářet, upravovat a mazat směny zaměstnanců.

### 6. Produkty a katalog (`products`) — 11 kódů
- `products.view`: Vidět katalog a prodejní ceny.
- `products.view_cost`: Vidět nákupní ceny a marži.
- `products.manage`: Vytvářet, upravovat a mazat produkty.
- `products.manage_categories`: Vytvářet, upravovat a mazat kategorie.
- `products.manage_modifiers`: Vytvářet, upravovat a mazat skupiny modifikátorů.
- `products.manage_recipes`: Vytvářet, upravovat a mazat receptury (BOM).
- `products.manage_purchase_price`: Upravit nákupní cenu produktu.
- `products.manage_tax`: Přiřazovat a měnit daňové sazby na položkách.
- `products.manage_suppliers`: Správa dodavatelů.
- `products.manage_manufacturers`: Správa výrobců.
- `products.set_availability`: Dočasně vyřadit položku z prodeje.

### 7. Sklad (`stock`) — 10 kódů
- `stock.view_levels`: Vidět aktuální množství zásob.
- `stock.view_documents`: Vidět příjemky, odpisy a korekce.
- `stock.view_movements`: Vidět historii pohybů zásob.
- `stock.receive`: Vytvořit příjemku.
- `stock.wastage`: Zaznamenat odpis nebo zmetek.
- `stock.adjust`: Ručně upravit množství na skladě.
- `stock.count`: Provést inventurní sčítání.
- `stock.transfer`: Přesunout zboží mezi sklady.
- `stock.set_price_strategy`: Měnit strategii NC při příjmu.
- `stock.manage_warehouses`: Správa skladů.

### 8. Zákazníci a věrnost (`customers`) — 4 kódy
- `customers.view`: Seznam a detail zákazníků.
- `customers.manage`: CRUD zákazníků.
- `customers.manage_credit`: Přidávat a odebírat kredit.
- `customers.manage_loyalty`: Ručně upravit věrnostní body.

### 9. Vouchery (`vouchers`) — 3 kódy
- `vouchers.view`: Vidět seznam voucherů.
- `vouchers.manage`: Vytvářet a upravovat vouchery.
- `vouchers.redeem`: Použít voucher na účet.

### 10. Provoz — stoly a rezervace (`venue`) — 2 kódy
- `venue.reservations_view`: Vidět seznam rezervací.
- `venue.reservations_manage`: CRUD rezervací.

### 11. Statistiky a reporty (`stats`) — 12 kódů
- `stats.receipts`: Účtenky v aktuální session.
- `stats.receipts_all`: Účtenky za libovolné období.
- `stats.sales`: Prodeje v aktuální session.
- `stats.sales_all`: Prodeje za libovolné období.
- `stats.orders`: Objednávky v aktuální session.
- `stats.orders_all`: Objednávky za libovolné období.
- `stats.tips`: Spropitné v aktuální session.
- `stats.tips_all`: Spropitné za libovolné období.
- `stats.cash_journal`: Pohyby v aktuální session.
- `stats.cash_journal_all`: Pohyby za libovolné období.
- `stats.shifts`: Směny všech zaměstnanců.
- `stats.z_reports`: Uzávěrky (Z-reporty) všech sessions.

### 12. Tisk (`printing`) — 4 kódy
- `printing.receipt`: Vytisknout účtenku.
- `printing.reprint`: Znovu vytisknout účtenku.
- `printing.z_report`: Vytisknout uzávěrkový report.
- `printing.inventory_report`: Vytisknout skladový report.

### 13. Data (`data`) — 3 kódy
- `data.export`: Export reportů do CSV/PDF.
- `data.import`: Import produktů a zákazníků z CSV.
- `data.backup`: Záloha a obnova databáze.

### 14. Uživatelé a role (`users`) — 4 kódy
- `users.view`: Seznam zaměstnanců.
- `users.manage`: CRUD zaměstnanců.
- `users.assign_roles`: Změnit roli zaměstnance.
- `users.manage_permissions`: Přidělit jednotlivá oprávnění.

### 15. Nastavení — firma (`settings_company`) — 7 kódů
- `settings_company.info`: Upravit údaje o firmě.
- `settings_company.security`: Nastavit PIN politiku a zámek.
- `settings_company.fiscal`: Fiskalizace a tiskové povinnosti.
- `settings_company.cloud`: Cloud, synchronizace a migrace.
- `settings_company.data_wipe`: Smazání všech dat.
- `settings_company.view_log`: Zobrazit systémový log.
- `settings_company.clear_log`: Smazat systémový log.

### 16. Nastavení — provozovna (`settings_venue`) — 3 kódy
- `settings_venue.sections`: Správa sekcí.
- `settings_venue.tables`: Správa stolů.
- `settings_venue.floor_plan`: Editace půdorysu.

### 17. Nastavení — pokladna (`settings_register`) — 6 kódů
- `settings_register.manage`: Správa pokladen.
- `settings_register.hardware`: Konfigurace HW (tiskárny, skenery).
- `settings_register.grid`: Editace prodejního gridu.
- `settings_register.payment_methods`: CRUD platebních metod.
- `settings_register.tax_rates`: CRUD daňových sazeb.
- `settings_register.manage_devices`: Správa displejů (KDS, Zákaznický).

---

## 3. Role a Matice přiřazení (Template Matrix)

| Skupina | helper | operator | manager | admin |
|---------|:------:|:--------:|:-------:|:-----:|
| Celkem  | **15** | **55** | **85** | **105** |
| orders  | 6 | 14 | 15 | 15 |
| payments| 4 | 11 | 11 | 11 |
| discounts| 0 | 3 | 5 | 5 |
| products| 1 | 2 | 9 | 11 |
| stock   | 0 | 4 | 8 | 10 |
| stats   | 0 | 5 | 12 | 12 |
| settings| 0 | 0 | 4 | 16 |

---

## 4. Bezpečnostní mechanismy

### Last Admin Guard
Brání smazání nebo deaktivaci posledního admina ve firmě. Implementováno ve 3 vrstvách:
1. **UI Layer:** Disable ovládacích prvků v `users_tab.dart`.
2. **Repository Layer:** `UserRepository` vrací `Failure` při pokusu o odstranění.
3. **Database Layer:** Trigger `guard_last_admin` (BEFORE UPDATE/DELETE) vyhodí chybu ERRCODE 23514.

### Brute-Force ochrana
Progresivní lockout při chybném PINu: 1–3 pokusy (žádný), 4 (5s), 5 (30s), 6 (5min), 7+ (60min).

### PIN Hashing
Ukládáno jako Salted SHA-256 (`hex_salt:hex_hash`). Synchronizováno do Supabase.

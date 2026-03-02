# Testovací skript — Permission gates

## Fáze 1: Admin (všechna oprávnění)

Ověř že vše funguje a je viditelné.

**Bills:**
- [ ] ScreenBills — 3 filtry (Otevřené, Zaplacené, Stornované)
- [ ] Klik na řádek účtu — otevře se detail
- [ ] Detail účtu — tlačítko Voucher přítomné a funkční
- [ ] Detail účtu — tlačítka Zákazník, Přesun, Sloučit, Rozdělit, Sleva přítomná

**Rezervace:**
- [ ] Tlačítko "+ Nová rezervace" viditelné a funkční
- [ ] Klik na řádek v tabulce — otevře edit dialog
- [ ] Gantt chart — klik na blok otevře edit dialog

**Sklad:**
- [ ] Příjemka — dropdown strategie NC u dokumentu viditelný
- [ ] Příjemka — přidej položku, per-item strategy override viditelný
- [ ] Ulož příjemku — OK

**Katalog:**
- [ ] Edit produktu — pole nákupní ceny viditelné
- [ ] Edit produktu — dropdowny DPH prodejní + nákupní viditelné
- [ ] Edit produktu — switche Aktivní, V prodeji, Sledovat sklad viditelné

**Statistiky:**
- [ ] Tab Dashboard přítomný, comparison % na kartách funkční
- [ ] Tabs Účtenky, Prodeje, Objednávky, Spropitné — data za vybrané období, žádný info banner
- [ ] Tab Směny — vidí směny všech uživatelů (řízeno `stats.shifts`)

**Inventory:**
- [ ] Stock movements — klik na bill otevře detail

---

## Fáze 2: Helper (18 oprávnění)

Přepni na uživatele s rolí Helper.

**Bills:**
- [ ] Jen filtr Otevřené (Zaplacené a Stornované chybí)
- [ ] Klik na řádek účtu — nic se nestane (nemá `orders.view_detail`)
- [ ] Detail účtu nelze otevřít → nemůžeš testovat voucher tlačítko (OK, helper nemá přístup)

**Rezervace:**
- [ ] Helper nemá `venue.reservations_view` → nemá přístup na screen (ověř route guard)

**Sklad:**
- [ ] Helper nemá `stock.*` → nemá přístup na inventory screen (ověř route guard)

**Katalog:**
- [ ] Helper nemá `products.manage` → nemůže otevřít edit dialog
- [ ] Pokud má `products.view` → vidí seznam produktů, ale nemůže editovat

**Statistiky:**
- [ ] Helper nemá žádné `stats.*` → nemá přístup na statistiky (ověř route/menu guard)

**Inventory:**
- [ ] Nemá přístup → stock movements nedostupné

---

## Fáze 3: Custom role (cílené testy)

Pro otestování granulárních gatů vytvoř dočasnou roli nebo uprav helpera. Testuj po skupinách — po každém testu vrať oprávnění zpět.

### Test A — voucher gate

- Přidej: `orders.view`, `orders.view_detail`, `orders.create`, `payments.accept`, `payments.method_cash`
- Odeber: `vouchers.redeem`
- [ ] Otevři detail účtu — tlačítko Voucher chybí
- Přidej: `vouchers.redeem`
- [ ] Tlačítko Voucher se objeví

### Test B — rezervace gate

- Přidej: `venue.reservations_view`
- Odeber: `venue.reservations_manage`
- [ ] Vidí seznam rezervací
- [ ] Tlačítko "+ Nová" chybí
- [ ] Klik na řádek — nic se nestane
- [ ] Gantt chart — klik na blok — nic se nestane

### Test C — sklad strategy gate

- Přidej: `stock.view_levels`, `stock.view_documents`, `stock.receive`
- Odeber: `stock.set_price_strategy`
- [ ] Příjemka — dropdown strategie NC chybí (je Spacer)
- [ ] Přidej položku — per-item override chybí
- [ ] Ulož — uloží se s výchozí `overwrite`

### Test D — product edit gates

- Přidej: `products.view`, `products.manage`

**D1** — odeber `products.manage_purchase_price`:
- [ ] Edit produktu — pole nákupní ceny chybí, prodejní cena zabírá celou šířku

**D2** — odeber `products.manage_tax`:
- [ ] Edit produktu — řádek DPH prodejní + nákupní chybí celý

**D3** — odeber `products.set_availability`:
- [ ] Edit produktu — switche Aktivní a V prodeji chybí, Sledovat sklad zůstává

### Test E — statistiky session scope

- Přidej: `stats.receipts`, `stats.sales`, `stats.orders`, `stats.tips`
- Odeber: všechny `stats.*_all`
- [ ] Tab Dashboard chybí
- [ ] Tabs Účtenky/Prodeje/Objednávky/Spropitné — info banner "Pouze aktuální směna"
- [ ] Data omezena na aktuální session

Přidej `stats.receipts_all`:
- [ ] Tab Účtenky — banner zmizí, data za celé období
- [ ] Dashboard stále chybí (nemá všechny `*_all`)

Přidej zbylé `*_all`:
- [ ] Dashboard tab se objeví

### Test F — směny

- Přidej: `stats.shifts`
- [ ] Tab Směny — vidí směny všech uživatelů (přístup na tab je řízen `stats.shifts`)

### Test F2 — register open/close

- Přidej: `orders.create`, `payments.accept`, `payments.method_cash`
- Odeber: `register.open_close`
- [ ] Tlačítko otevření/uzavření pokladny chybí (ScreenBills i ScreenSell menu)
- Přidej: `register.open_close`
- [ ] Tlačítko se objeví

### Test F3 — accept_tip gate

- Přidej: `payments.accept`, `payments.method_cash`, `orders.create`
- Odeber: `payments.accept_tip`
- [ ] Otevři platební dialog, zadej vlastní částku vyšší než zůstatek
- [ ] Štítek "(Tip: X)" se nezobrazí
- [ ] Platba projde, tip = 0
- Přidej: `payments.accept_tip`
- [ ] Tip funguje normálně, štítek "(Tip: X)" se zobrazí

### Test G — bills filtry

- Přidej: `orders.view`

**G1** — přidej `orders.view_paid`, odeber `orders.view_cancelled`:
- [ ] Filtry: Otevřené + Zaplacené (Stornované chybí)

**G2** — odeber `orders.view_paid`, přidej `orders.view_cancelled`:
- [ ] Filtry: Otevřené + Stornované (Zaplacené chybí)

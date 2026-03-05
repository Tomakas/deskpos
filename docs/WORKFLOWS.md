# Maty — Workflows & Business Logic

Detailní popis obchodních procesů, životního cyklu entit, finanční logiky a API repozitářů.

---

## 1. Účty a Objednávky (Bill/Order)

POS systém striktně odděluje **platební jednotku** (Bill) od **produkční jednotky** (Order).

### Agregace Order.status z OrderItem.status
Status se nastavuje na úrovni položek. Status celého Orderu se automaticky odvozuje:
1. `activeItems` prázdné → `voided`.
2. Všechny `activeItems` delivered → `delivered`.
3. Všechny `activeItems` ∈ {ready, delivered} → `ready`.
4. Jinak → `created`.

### Přepočet Bill totalů
Výpočet probíhá reaktivně po každé změně:
1. `item_subtotal = sale_price_att × quantity`.
2. `item_discount = type == percent ? (subtotal * discount / 10000) : discount`.
3. `bill.subtotal_gross = Σ(item_subtotal - item_discount)` přes všechny aktivní orders.
4. `bill.total_gross = subtotal_gross - bill_discount - loyalty_discount - voucher_discount + rounding_amount`.

---

## 2. Přehled všech variant vytváření účtů (createBill)

Systém vytváří účty na 7 místech. Každá varianta nastavuje jiné parametry:

| # | Scénář | tableId | sectionId | isTakeaway | Zobrazení v ScreenBills |
|---|--------|---------|-----------|------------|------------------------|
| 1 | DialogNewBill | ANO | ANO | ne | název stolu |
| 2 | Gastro bez stolu | ne | ANO | ne | „Bez stolu“ |
| 3 | Rychlý prodej (retail) | ne | ANO | ANO | „Rychlý účet“ |
| 4 | Split (okamžitá platba) | ANO | ne | ne | název stolu |
| 5 | Split (odložená platba) | ANO | ne | ne | název stolu |
| 6 | Prodej voucheru | ne | ne | ANO | „Rychlý účet“ |
| 7 | Nabití kreditu | ne | ne | ANO | „Rychlý účet“ |

---

## 3. Voucher Systém (Algoritmus výpočtu)

Vouchery používají **freeze-on-apply** strategii:
1. **Filtr dle scope:** `bill` (vše), `product` (konkrétní ID), `category` (konkrétní kategorie).
2. **Effective Unit Price:** `(basePrice × qty + modifiers − itemDiscount) / qty`.
3. **Třídění:** Sestupně dle unit price (nejdražší první).
4. **Alokace maxUses:** Přidělení covered qty přes seřazené položky (každá jednotka = 1 use).
5. **Výpočet slevy:** Percent → `coveredValue × voucher.value / 10000`; Absolute → proporcionální rozdělení.
6. **Zápis:** Hodnota se zapíše do `order_items.voucher_discount`.

---

## 4. Hotovostní management (Register Session)

Každý prodej patří do aktivní session.
- **Otevírání:** Zadání `opening_cash` (DialogOpeningCash).
- **Uzávěrka:** Porovnání opening/expected/actual hotovosti (DialogClosingSession).
- **Multi-currency:** Evidence hotovosti pro každou měnu zvlášť v `session_currency_cash`.
- **Handover:** Předání hotovosti mobile→local (CashMovementType.handover).

---

## 5. Sklad a Negative Stock Policy

### Automatický odpis
- Odpis probíhá při vytvoření objednávky (`created`).
- Receptury se rozpadají na ingredience přes `product_recipes`.
- Modifikátory se odepisují společně s položkou (qty modif. × qty položky).

### Negative Stock Policy
1. **Allow:** Odpis do mínusu bez varování.
2. **Warn:** Vyhodí `InsufficientStockException(isWarningOnly: true)` → UI confirm dialog.
3. **Block:** Vyhodí exception → UI error dialog (zablokuje prodej).

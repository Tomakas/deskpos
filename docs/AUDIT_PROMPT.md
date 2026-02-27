# Audit: Nekomitnuté změny — hledání bugů a regresí

> **Cíl:** Důkladně zkontrolovat VŠECHNY nekomitnuté změny oproti HEAD. Najít bugy, regrese, nekonzistence, chybějící kusy a logické chyby.
>
> **Scope:** Pouze soubory změněné od posledního commitu (`git diff HEAD --name-only`). Pro kontext čti i okolní kód.
> **Audit je READ-ONLY** — žádné změny, žádné commity.

---

## Jak spustit

Spusť **5 paralelních agentů** (subagent_type=Explore), každý audituje svou oblast. Na konci shrň všechny nálezy do jedné tabulky.

---

## Agent 1: Datová vrstva (schéma, modely, mappery, repozitáře)

### Soubory
```
lib/core/database/tables/customer_transactions.dart
lib/core/database/tables/items.dart
lib/core/database/app_database.g.dart
lib/core/data/models/customer_transaction_model.dart
lib/core/data/models/customer_transaction_model.freezed.dart
lib/core/data/models/item_model.dart
lib/core/data/models/item_model.freezed.dart
lib/core/data/mappers/entity_mappers.dart
lib/core/data/mappers/supabase_mappers.dart
lib/core/data/mappers/supabase_pull_mappers.dart
lib/core/data/repositories/bill_repository.dart
lib/core/data/repositories/customer_repository.dart
lib/core/data/repositories/customer_transaction_repository.dart
supabase/migrations/20260227_008_add_note_to_customer_transactions.sql
supabase/migrations/20260227_009_add_reference_to_customer_transactions.sql
supabase/migrations/20260227_010_allow_null_unit_price_items.sql
```

### Checklist
1. **Konzistence `reference` sloupce** — je ve VŠECH vrstvách? (Drift tabulka, Freezed model, entity mapper oba směry, push mapper, pull mapper, repository CRUD, toUpdateCompanion)
2. **Konzistence `note` sloupce** — chyběl dříve v pull mapperu. Je teď správně všude?
3. **Nullable `unitPrice`** — je `int?` konzistentně v Drift tabulce, modelu, entity mapperu (oba směry), pull mapperu, push mapperu? Odpovídá generated kód?
4. **Bill repository: customer guard** — `paidAmount > 0` nepokrývá refundované účty (záporný paidAmount). Mělo by být `!= 0`?
5. **Bill repository: viditelnost účtů bez sekce/stolu** — nová logika `return true` pro účty bez sekce. Je to korektní pro všechny kontexty?
6. **Bill repository: předávání `reference`** — všechna volání `adjustPoints`/`adjustCredit` v bill_repository mají `reference: billNumber`?
7. **Customer repository: signatury** — obě metody `adjustPoints` a `adjustCredit` přijímají `reference`?
8. **Migrace** — odpovídají ALTER TABLE příkazy změnám v kódu?

---

## Agent 2: Prodejní obrazovka (screen_sell.dart)

### Soubory
```
lib/features/sell/screens/screen_sell.dart
```

### Checklist
1. **Open-price flow** — pořadí price → quantity → modifiers → cart je správné? Žádné přeskočení?
2. **`_PriceInputDialog`** — co vrací? Sedí návratový typ s `showDialog<int>`? Pokud vrací record `({int price, double quantity})`, je to type mismatch!
3. **`_PriceInputDialog`** — funguje `parseMoney` správně pro CZK i HUF? Je guard `price <= 0` korektní?
4. **Open-price varianty** — pokud varianta má `unitPrice == null`, projde správně celý flow?
5. **Cart merge** — `c.unitPrice == resolvedUnitPrice` správně rozlišuje různé zadané ceny?
6. **Modifier dialog s resolvedPrice** — `basePrice = widget.resolvedPrice ?? widget.item.unitPrice ?? 0` je správně?
7. **Modifier item nullable unitPrice** — `gi.item.unitPrice ?? 0` je konzistentní ve všech výskytech?
8. **Single-select deselect** — nový toggle funguje jen pro `minSelections == 0`?
9. **Session guard** — `requireActiveSession` je jen v `_submitQuickSale`. Měl by být i v `_onItemTapped` nebo `_addToCart`?
10. **Quantity stepper v _PriceInputDialog** — je tam redundantní? Ignoruje se výsledek?

---

## Agent 3: Účtenky, platby, uzavírání směny

### Soubory
```
lib/features/bills/screens/screen_bills.dart
lib/features/bills/widgets/dialog_bill_detail.dart
lib/features/bills/widgets/dialog_cash_journal.dart
lib/features/bills/widgets/dialog_closing_session.dart
lib/features/bills/widgets/dialog_customer_search.dart
lib/features/bills/widgets/dialog_payment.dart
lib/features/bills/widgets/dialog_z_report.dart
lib/features/shared/session_helpers.dart
```

### Checklist
1. **Z-report tisk po uzavření** — co když `buildZReport` vrátí null? Informuje se uživatel?
2. **Foreign currency opening** — vytváří se záznamy pro VŠECHNY aktivní měny, i s openingCash=0?
3. **Foreign currency closing** — pokud uživatel nevyplní closing pro měnu, chybí záznam? Asymetrie s opening?
4. **Currency conversion rounding** — `_remainingInForeign` používá `.ceil()`, `_foreignToBase` používá `.round()`. Je to konzistentní?
5. **`requireActiveSession`** — `showDialog` je fire-and-forget (bez await). Je to OK?
6. **`_showAllBills` toggle** — resetuje se při změně session? Co když není aktivní session?
7. **Bill detail: modifiers** — `mod.modifierItemName` může být prázdný string?
8. **Cash movement pro foreign currency change** — typ `withdrawal` je sémanticky správný?
9. **Dialog closing session** — nový layout. Jsou mounted checky po všech async operacích?
10. **Payment dialog** — foreign currency payment flow. Jsou všechny hraniční případy pokryté?

---

## Agent 4: Katalog, nastavení, statistiky, vouchery

### Soubory
```
lib/features/catalog/widgets/catalog_categories_tab.dart
lib/features/catalog/widgets/catalog_modifiers_tab.dart
lib/features/catalog/widgets/catalog_products_tab.dart
lib/features/catalog/widgets/customers_tab.dart
lib/features/catalog/widgets/dialog_customer_credit.dart
lib/features/catalog/widgets/dialog_customer_transactions.dart
lib/features/catalog/widgets/manufacturers_tab.dart
lib/features/catalog/widgets/recipes_tab.dart
lib/features/catalog/widgets/suppliers_tab.dart
lib/features/inventory/widgets/dialog_stock_document.dart
lib/features/inventory/widgets/dialog_stock_document_detail.dart
lib/features/settings/widgets/company_info_tab.dart
lib/features/settings/widgets/dialog_grid_editor.dart
lib/features/settings/widgets/log_tab.dart
lib/features/settings/widgets/payment_methods_tab.dart
lib/features/settings/widgets/registers_tab.dart
lib/features/settings/widgets/sections_tab.dart
lib/features/settings/widgets/tables_tab.dart
lib/features/settings/widgets/tax_rates_tab.dart
lib/features/settings/widgets/users_tab.dart
lib/features/statistics/screens/screen_statistics.dart
lib/features/vouchers/screens/screen_vouchers.dart
lib/features/vouchers/widgets/dialog_voucher_create.dart
```

### Checklist
1. **Long-press delete** — používá soft-delete přes repository (outbox)? Má `confirmDelete` + `mounted` check?
2. **dialog_customer_credit: deduct** — chybí `reference` a `orderId`? Je to záměr nebo bug?
3. **dialog_customer_transactions** — zobrazuje `reference` a `note` správně? Filtruje prázdné?
4. **catalog_products_tab: nullable unitPrice** — funguje vytváření/editace produktu bez ceny?
5. **Settings taby** — co se změnilo a proč? Nějaká regrese?
6. **Statistics** — filtrování a agregace. Nové filtry fungují?
7. **Vouchers** — session check před vytvořením voucheru?
8. **Inventory dialogy** — drobné změny, něco se rozbilo?

---

## Agent 5: Core widgety, utility, theme, lokalizace

### Soubory
```
lib/core/widgets/pos_dialog_shell.dart
lib/core/widgets/pos_dialog_theme.dart
lib/core/widgets/pos_table.dart
lib/core/utils/formatters.dart
lib/core/theme/app_colors.dart
lib/l10n/app_cs.arb
lib/l10n/app_en.arb
lib/l10n/app_localizations.dart
lib/l10n/app_localizations_cs.dart
lib/l10n/app_localizations_en.dart
```

### Checklist
1. **PosDialogShell: `onPrint`** — správně zarovnaný, nekonfliktuje s `showCloseButton`?
2. **PosDialogShell: `actionTopSpacing`** — nepřidává double-spacing u dialogů co mají vlastní padding?
3. **PosDialogShell: backward kompatibilita** — existující dialogy bez `onPrint` fungují stejně?
4. **PosTable: `onRowLongPress`** — implementace, backward kompatibilita?
5. **confirmDelete: destructive style** — `PosButtonStyles.destructiveFilled` existuje a funguje?
6. **formatters.dart: nové funkce** — `parseMoneyOrNull`, `formatForInput`, `parseInputDouble` mají správnou logiku?
7. **`minorUnitsToInputString` s locale** — backward kompatibilní (locale je optional)?
8. **L10n: nové klíče** — existují v OBOU jazycích (CS i EN)?
9. **L10n: změněné klíče** — `closingConfirm` změněn na "Potvrdit"/"Confirm". Není někde závislost na starém textu?
10. **L10n: konzistence** — `app_localizations.dart` (abstract) deklaruje všechny nové klíče?

---

## Výstupní formát

Každý agent vrátí:

```markdown
## Agent N: Oblast

### Bugy
| # | Závažnost | Soubor:řádek | Popis | Doporučení |
|---|-----------|--------------|-------|------------|

### Varování
| # | Závažnost | Soubor:řádek | Popis |
|---|-----------|--------------|-------|

### OK (ověřeno bez nálezu)
- [ ] Checklist bod X — OK
- [ ] Checklist bod Y — OK
```

Na konci shrň celkový počet nálezů: KRITICKÉ / VYSOKÉ / STŘEDNÍ / NÍZKÉ.

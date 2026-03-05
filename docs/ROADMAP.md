# Maty — Project Roadmap

> Doslovný export sekcí Roadmap a Rozšíření z hlavního dokumentu.

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

#### Milník 3.3 — Provoz (rozšíření register session)

- **Task3.11** ✅ Register session rozšíření — počáteční/koncový stav hotovosti (opening_cash, closing_cash, expected_cash, difference)
- **Task3.12** ✅ Cash movements — vklady, výběry, výdaje
- **Task3.13** ✅ Z-report — denní uzávěrka s detailním souhrnem (ZReportService, DialogZReport, DialogZReportList)
- **Výsledek:** Pokladna má plnou otevírací/zavírací proceduru s kontrolou hotovosti, evidenci hotovostních pohybů a denní uzávěrku.

#### Milník 3.4 — Rozšíření produktového katalogu

- **Task3.14** ✅ Dodavatelé a výrobci — tabulky `suppliers`, `manufacturers` (CRUD, sync, FK na items)
- **Task3.15** ✅ Rozšíření items — nákupní cena (`purchase_price`), alt SKU (`alt_sku`), FK na `supplier_id`, `manufacturer_id`, `parent_id`, `purchase_tax_rate_id`, flagy `is_on_sale`, `is_stock_tracked`
- **Task3.16** ✅ Receptury — tabulka `product_recipes` (parent_product_id → hotový produkt, component_product_id → surovina, quantity_required); item_type rozšíření o `recipe`, `ingredient`
- **Task3.17** ✅ Varianty produktů — `parent_id` ve items, item_type `variant`, `modifier` (velikost, barva apod.)
- **Task3.18** ✅ Hierarchické kategorie — `parent_id` v categories (stromová struktura, max 3 úrovně)
- **Task3.19** ✅ UI správa — nová route `/catalog` s 7 taby (Produkty, Kategorie, Skupiny modifikátorů, Dodavatelé, Výrobci, Receptury, Zákazníci); Sekce/Stoly/Mapa v ScreenVenueSettings, Daň. sazby/Plat. metody v ScreenCompanySettings
- **Výsledek:** Kompletní produktový katalog s dodavateli, výrobci, recepturami a variantami. Položky mají nákupní cenu, alt SKU a vazby na dodavatele/výrobce.

#### Milník 3.5 — Sklad a zásobování

##### Klíčová rozhodnutí

- **Jeden sklad** per firma (s přípravou na multi-warehouse — tabulka `warehouses` existuje, `warehouseId` na stock_levels/stock_documents)
- **Odpis při vytvoření objednávky** (`createOrderWithItems`), ne při delivered/paid
- **Receptury**: rozpad na ingredience přes `product_recipes`, samotná receptura nemá vlastní zásobu
- **Storno/void**: automatické vrácení zásob (reverzní stock_movement)
- **Odečítání**: vše s `isStockTracked=true` bez ohledu na `item_type`
- **Modifikátory**: stock-tracked modifikátory objednávkové položky se odečítají/vracejí společně s hlavní položkou (qty modifikátoru × qty hlavní položky)
- **Směr dle ceny**: záporná cena položky → inbound movement (přírůstek skladu, např. vratná láhev), kladná → outbound. Receptury vždy outbound/inbound bez ohledu na cenu.
- **Záporné zásoby povoleny** (běžné v gastronomii)
- **Nákupní cena při příjemce**: volba strategie per doklad s override per položka (přepsat / ponechat / průměr / vážený průměr)
- **Prodejní odpisy**: jen `stock_movements` bez `stock_document_id` (nullable FK). Doklady jen pro ruční operace (příjemka, výdejka, inventura, oprava).
- **Min. zásoby**: jen evidence (`min_quantity`), bez upozornění v první verzi
- **Inventura**: jednoduchá korekce — obsluha zadá skutečný stav, systém vypočítá rozdíl a vytvoří korekční movements

##### Tasky

- **Task3.20** ✅ Enumy + Drift tabulky — `StockDocumentType` (receipt, waste, inventory, correction), `PurchasePriceStrategy` (overwrite, keep, average, weightedAverage), `StockMovementDirection` (inbound, outbound). Tabulky: `warehouses` (id, company_id, name, is_default, is_active), `stock_levels` (id, company_id, warehouse_id, item_id, quantity real, min_quantity real), `stock_documents` (id, company_id, warehouse_id, supplier_id?, user_id, document_number, type, purchase_price_strategy, note?, total_amount, document_date), `stock_movements` (id, company_id, stock_document_id?, item_id, quantity real, purchase_price?, direction, purchase_price_strategy? override). Modely (freezed): WarehouseModel, StockLevelModel, StockDocumentModel, StockMovementModel.
- **Task3.21** ✅ Mappers + Sync — entity_mappers, supabase_mappers, supabase_pull_mappers pro všechny 4 tabulky. Outbox registrace v sync provideru. Supabase migrace: zatím nepřidány (klient-side hotový).
- **Task3.22** ✅ WarehouseRepository — getDefault (lazy init „Hlavní sklad" při prvním přístupu), watchAll. Extends BaseCompanyScopedRepository.
- **Task3.23** ✅ StockLevelRepository — getOrCreate (lazy init), watchByWarehouse (JOIN s items pro název/unit/purchasePrice), adjustQuantity (delta), setQuantity (absolutní), setMinQuantity. Injektovaný SyncQueueRepository.
- **Task3.24** ✅ StockDocumentRepository — createDocument (transakce: insert document + movements + adjust stock_levels + update purchase_price dle strategie per položka, enqueue všech dotčených entit). createInventoryDocument (difference-based movements). Logika nákupní ceny: per položka zjistí strategii (item override ?? document strategy), aplikuje dle typu (overwrite/keep/average/weightedAverage). watchByWarehouse, generateDocumentNumber (R-0001/W-0001/I-0001/C-0001).
- **Task3.25** ✅ Automatický odpis v OrderRepository — modifikace `createOrderWithItems`: po insertu pro každý isStockTracked item vytvořit stock_movement (bez stock_document_id). Receptury: rozpad přes product_recipes, odečtení ingrediencí. Modifikátory: po zpracování hlavní položky se iterují její modifikátory a pro stock-tracked modifikátory se vytvoří vlastní stock_movement (qty modifikátoru × qty hlavní položky). Směr dle ceny: záporná cena → inbound (přírůstek), kladná → outbound (odpis); receptury vždy outbound. Modifikace `updateStatus`: při cancelled/voided reverzní stock_movements (včetně modifikátorů, se správným směrem dle ceny). Modifikace `voidItem`: reversal jedné položky včetně jejích modifikátorů. Nové závislosti: StockLevelRepository, StockMovementRepository, OrderItemModifierRepository.
- **Task3.26** ✅ ScreenInventory — fullscreen route `/inventory`, 3 taby (Zásoby, Doklady, Pohyby). Tab Zásoby: DataTable se stock-tracked položkami (Položka, Jednotka, Množství, Min.množství, Nákupní cena, Celková hodnota) + footer s celkovou hodnotou skladu. Tab Doklady: DataTable se skladovými doklady (Číslo, Typ, Datum, Dodavatel, Poznámka, Celkem). Tab Pohyby: DataTable s historií skladových pohybů s vyhledáváním. Tlačítka: Příjemka, Výdejka, Inventura, Oprava. Přístup: tlačítko SKLAD na ScreenBills.
- **Task3.27** ✅ DialogStockDocument — znovupoužitelný dialog pro příjemku/výdejku/opravu. Pole: dodavatel (dropdown, jen receipt), strategie ceny (dropdown + per-item override, jen receipt), seznam položek (search + quantity + price). Validace: ≥1 položka.
- **Task3.28** ✅ Inventura — 3-krokový flow: (1) `DialogInventoryType` — výběr scope inventury (blind mode, filtr položek), (2) `DialogInventory` — zadání skutečných stavů, (3) `DialogInventoryResult` — zobrazení rozdílů a potvrzení. Výsledek vytvoří stock_movements a jeden stock_document typu `inventory`.
- **Výsledek:** Plné skladové hospodářství s evidencí zásob, příjemkami, výdejkami, automatickým odpisem při prodeji (s rozpadem receptur a odečtem stock-tracked modifikátorů), směrem pohybu dle ceny (záporná cena → inbound), inventurami a plnou synchronizací přes outbox.

#### Milník 3.6 — Tisk

- ✅ Účtenka — PDF 80mm šířka (thermal receipt styl), generováno lokálně přes `pdf` package, otevřeno v systémovém prohlížeči. Obsahuje: hlavička firmy (název, adresa, IČO, DIČ), info účtu, položky se slevami, DPH rekapitulace, platby se spropitným, patička.
- ✅ Z-report — PDF A4, kopíruje strukturu `DialogZReport` (session info, tržby, DPH, spropitné, slevy, počty účtů, cash reconciliation, směny).
- ✅ Fonty — bundled Inter Variable (UI) + Roboto TTF (PDF tisk, české diakritické znaky) v `assets/fonts/`.
- ✅ Voucher — PDF 80mm šířka (thermal receipt styl), tisk z `DialogVoucherDetail`. Obsahuje: název firmy, kód voucheru, typ, hodnota, scope (s názvem produktu/kategorie), max. použití, platnost, poznámka.
- ✅ Skladový doklad — PDF A4, hlavička (typ dokladu, číslo, datum, dodavatel, poznámka), tabulka položek (název, množství, jednotka, cena, celkem), celková hodnota.
- ✅ Infrastruktura — `lib/core/printing/` (PdfFontLoader, ReceiptData, ReceiptPdfBuilder, ZReportPdfBuilder, InventoryPdfBuilder, VoucherPdfBuilder, StockDocumentPdfBuilder, PrintingService), provider v `lib/core/data/providers/printing_providers.dart`.
- **Task3.30** Tisk reportů — tržby, prodeje dle kategorií/zaměstnanců (backlog)
- **Výsledek:** Lze tisknout účtenky, denní uzávěrky a vouchery do PDF. Kuchyňské tisky a tisk reportů mimo scope v1.

#### Milník 3.7 — Rezervace

- **Task3.31** ✅ Rezervace — tabulka `reservations` (customer_name, customer_phone, reservation_date, party_size, table_id, status, optional FK na customers). Drift table, Freezed model, BaseCompanyScopedRepository, entity/supabase/pull mappers, sync registrace, provider. Status enum: created, confirmed, seated, cancelled.
- **Task3.32** ✅ UI — DialogReservationsList (seznam s date range filtrem, 7 sloupců), DialogReservationEdit (create/edit formulář s propojením zákazníka, date/time picker, table dropdown, status segmented button). Přístup přes menu "Další" → "Rezervace" na ScreenBills.
- **Výsledek:** Uživatel může vytvářet, prohlížet, editovat a mazat rezervace. Volitelné propojení se zákazníkem z DB (pre-fill jméno + telefon). Plná offline podpora a sync přes outbox.

#### Milník 3.8 — Správa objednávek

- **Task3.33** ✅ Status timestamps — 3 nové nullable sloupce na `orders`: `prep_started_at`, `ready_at`, `delivered_at`. Drift tabulka, Freezed model, entity/supabase/pull mappers, Supabase migrace.
- **Task3.34** ✅ Storno order (void jednotlivé položky) — 2 nové sloupce na `orders`: `is_storno` (B, default false), `storno_source_order_id` (T? → orders). Nová metoda `OrderRepository.voidItem(orderId, orderItemId)`: validace → původní item status `voided` → stock reversal (vč. receptur) → nový storno order (`isStorno: true`, status `delivered`, `stornoSourceOrderId` = originál, order number `X{N}-{XXXX}` kde N=register_number) s kopií voidnuté položky → přepočet totals orderu (pokud všechny položky voided → auto-void celý order) → `updateTotals(billId)` (storno ordery se nepočítají) → enqueue sync. UI: tap na položku otevřeného účtu v DialogBillDetail → stávající dialog (poznámka + sleva) + tlačítko "Storno" → potvrzení → void. Storno ordery v historii červeně s prefixem "STORNO".
- **Task3.35** ✅ Oddělovač objednávek v košíku — nový toolbar chip "Oddělit" na ScreenSell. Vizuální čára v košíku oddělující skupiny položek. Oddělovač odebíratelný. Při submit: iterace přes skupiny → `createOrderWithItems()` pro každou → N po sobě jdoucích orderů (O-0001, O-0002...). Prázdné skupiny se ignorují.
- **Task3.36** ✅ ScreenOrders (přehled objednávek) — route `/orders`, přístup přes menu DALŠÍ → "Objednávky", permission `orders.view`. Kartový seznam (kuchyňský lístek): hlavička (číslo, stůl, čas, status barevně), položky přímo viditelné (název, qty, cena, poznámky). Storno ordery červeně s STORNO prefixem. Akce: status přechody (created→ready→delivered), void položek (→ storno order). Filtry (spodní lišta): Aktivní (default: created+ready) / Vytvořené / Hotové / Doručené / Stornované. Scope: default aktuální register session, přepínač na "vše".
- **Výsledek:** Obsluha může stornovat jednotlivé položky na otevřeném účtu (vznikne storno order pro audit/kuchyni). Objednávky mají timestamps pro měření doby přípravy. V košíku lze jedním odesláním vytvořit více oddělených objednávek (chody). Nová obrazovka ScreenOrders poskytuje přehled všech objednávek s filtry, akcemi a kartovým zobrazením.

#### Milník 3.9 — Multi-register architektura

- **Task3.37** ✅ Schéma + device binding — lokální tabulka `device_registrations` (nesync) pro vazbu zařízení↔pokladna. Rozšíření `registers` (name, register_number, parent_register_id), `register_sessions` (bill_counter), `orders` (register_id), `payments` (register_id). Provider `activeRegisterProvider` (vrací null pokud není device binding). `DeviceRegistrationRepository` (bind/unbind/getForCompany).
- **Task3.38** ✅ CRUD pokladen + payment enforcement — `RegistersTab` (PosTable s add/edit/delete, HardwareType, parent register, payment flags) přesunuto do `ScreenVenueSettings` (4. tab). `ScreenRegisterSettings` má 3 taby (Režim, Prodej, Periferie). `DialogPayment` filtruje platební metody dle `register.allowCash/Card/Transfer/Credit/Voucher/Other`. `DialogVoucherCreate` respektuje `allowRefunds`. Režim zařízení (POS/KDS/Customer Display) se volí v ScreenRegisterSettings nebo přímo na login obrazovce (KDS).
- **Task3.39** ✅ Z-report per register + cash handover — `CashMovementType.handover` pro mobile→local předání hotovosti. `ZReportService.buildVenueZReport` (agregace N sessions s per-register breakdowns). `RegisterSessionRepository` rozšíření: billCounter increment, getClosedSessions. `DialogZReport` zobrazuje per-register breakdown. `DialogZReportList` filtrování dle registeru.
- **Task3.40** ✅ Supabase Realtime <2s sync — `RealtimeService` subscribuje Broadcast from Database na kanálu `sync:{companyId}` (server-side triggers na 38 tabulkách volají `realtime.send()`). LWW merge přes `insertOnConflictUpdate` v `SyncService.mergeRow`. Reconnect → okamžitý `pullAll` (flag `_wasSubscribed`). Dual sync: Broadcast from Database (primární, ~1-2s) + polling 30s (fallback). Immediate outbox flush přes `SyncQueueRepository.onEnqueue` → `OutboxProcessor.nudge()`.
- **Task3.41** ✅ KDS (Kitchen Display System) — route `/kds`, volba režimu na login obrazovce (POS/KDS radio). Touch-optimized seznam karet s objednávkami, live clock v AppBar, Drawer s logout. Status filter chips (4 filtry vč. storno), per-item a full-order bump (created→ready→delivered), prev-status undo, item void (long press). `_isBumping` guard proti double-tap. Session scope popup menu. Funkčně téměř identický s ScreenOrders — sdílí ceny, modifikátory, poznámky, storno zobrazení, urgency timer.
- **Task3.42** ✅ Customer Display — route `/customer-display` (idle/active via `?code=` query param). Read-only zákaznická obrazovka pro sekundární monitor. Register-centric architektura: displej sleduje `activeBillId` a `displayCartJson` na registru (sync přes outbox). Idle mód (jméno firmy + konfigurovatelný uvítací text z `welcomeText`), cart preview mód (položky z `displayCartJson` před submitnutím objednávky), active mód (reálné objednávky + totaly), ThankYou mód (5s po zaplacení, pak návrat na idle). Discount výpočet z `subtotalGross - totalGross + roundingAmount`. Storno ordery a voided/cancelled položky filtrovány. Tlačítko „Zák. displej" v DialogBillDetail pro manuální odeslání účtu na displej (toggle s eye ikonou). Triple-tap na idle obrazovce pro odpárování displeje (skrytá akce).
- **Task3.43** ✅ Display Devices + Pairing — nová tabulka `display_devices` (id, company_id, parent_register_id, code, name, welcome_text, type, is_active) s `DisplayDeviceType` enum (customerDisplay, kds). `DisplayDeviceModel` (Freezed), `DisplayDeviceRepository` (manual sync pattern), entity/supabase/pull mappers, sync registrace. `ScreenDisplayCode` — 6-digit kód pro spárování displeje s pokladnou. `PairingConfirmationListener` — modální overlay na hlavní pokladně pro potvrzení/zamítnutí párovací žádosti. `BroadcastChannel` wrapper pro Supabase Realtime broadcast (join/send/leave). Párovací protokol: displej odešle `pairing_request` přes broadcast kanál `pairing:{companyId}`, hlavní pokladna zobrazí potvrzovací dialog, odpověď `pairing_confirmed`/`pairing_rejected` zpět přes broadcast. Retry každých 5s, timeout 60s. Vstup přes ScreenOnboarding → "Customer Display" → `/display-code?type=customer_display`.
- **Výsledek:** Plně multi-register POS: zařízení se bindují na pokladny, každá pokladna má konfiguraci platebních metod, Z-reporty per register i venue-wide, Broadcast from Database sync mezi zařízeními <2s, kuchyňský displej, zákaznický displej a bezpečné párování displejů přes broadcast protokol.

---

### Etapa 4 — Statistiky a reporty

Přehledy a reporty pro majitele a manažery.

#### Milník 4.1 — Dashboard (partially implemented)

- **Task4.1** Sales dashboard — denní/týdenní/měsíční tržby, graf — **IMPLEMENTOVÁNO** (Dashboard tab v ScreenStatistics: DashboardSummaryCards, DashboardRevenueChart, DashboardDonutCharts, DashboardTopProducts, DashboardHeatmap, porovnávání období)
- **Task4.2** Živý přehled — aktuální otevřené účty, obsazenost stolů — zatím neimplementováno
- **Výsledek:** Dashboard tab existuje s přehledovými kartami, grafy tržeb, donut charts, top produkty a heatmapou. Pokročilé reporty (Milníky 4.2-4.6) zůstávají neplánované.

#### Milník 4.2 — Reporty

- **Task4.3** Prodeje dle kategorií — tržby per kategorie, top produkty
- **Task4.4** Prodeje dle zaměstnanců — tržby per obsluha
- **Task4.5** Prodeje dle času — hodinový/denní breakdown, peak hours
- **Task4.6** Platební metody — rozložení plateb (hotovost vs karta vs ostatní)
- **Výsledek:** Manažer může analyzovat prodeje podle kategorií, zaměstnanců, času a platebních metod.

#### Milník 4.3 — Export

- **Task4.7** PDF export — generování PDF reportů
- **Task4.8** Excel export — tabulkový export dat
- **Task4.9** Účetní export — formát pro účetní software
- **Task4.10** CSV export — univerzální CSV export tabulek (produkty, zákazníci, účty, objednávky)
- **Task4.11** Fiskalizace — export dat ve formátu pro finanční správu (připravenost na budoucí legislativu)
- **Task4.12** API/webhook — REST API nebo webhook pro napojení na externí systémy (účetní SW, BI, e-shop)
- **Výsledek:** Reporty a data lze exportovat do PDF, Excelu, CSV a formátu pro účetní software. Připravena infrastruktura pro fiskalizaci a napojení externích systémů.

#### Milník 4.4 — Import

- **Task4.13** CSV import produktů — hromadný import položek z CSV (název, SKU, cena, kategorie, DPH sazba). Validace, náhled před importem, deduplikace dle SKU.
- **Task4.14** CSV import zákazníků — hromadný import zákazníků z CSV (jméno, email, telefon, IČO, DIČ).
- **Task4.15** Migrace z jiného POS — import dat z konkurenčních POS systémů (Storyous, Dotykačka, iKelp apod.). Mapování kategorií, produktů, zákazníků.
- **Výsledek:** Lze hromadně naimportovat produkty a zákazníky z CSV, případně migrovat data z jiného POS systému.

#### Milník 4.5 — Zálohy

- **Task4.16** Lokální záloha DB — export celé lokální SQLite databáze (šifrované) do souboru pro přenos na jiné zařízení nebo disaster recovery.
- **Task4.17** Obnova ze zálohy — import zálohy zpět do aplikace s validací integrity a verzí schématu.
- **Výsledek:** Uživatel může zálohovat a obnovit celou lokální databázi pro přenos dat nebo disaster recovery.

#### Milník 4.6 — Licencování a povinná registrace

Registrace (email+heslo) je povinná při vytvoření firmy — spouští 30denní trial. Po vypršení trialu je nutné prodloužení licence (v1: aktivační kód; budoucnost: Play/App Store, online nákup). Licence má lokální expiraci obnovenou ze serveru při sync pull. Sync je jednoduchý on/off toggle per zařízení (SharedPreferences, ne databáze). Supabase session zůstává aktivní vždy — toggle ovládá pouze sync engine. Bez limitu zařízení.

| Parametr | Hodnota |
|----------|---------|
| Délka trialu | 30 dní |
| Grace period (trial) | 3 dny |
| Grace period (placený) | 7 dní |
| Platba v1 | Aktivační kód |
| Platba budoucí | Play Store, App Store, online nákup |
| Potvrzení e-mailu | Vypnuto v Supabase |
| Sync default | Uživatel volí při onboardingu (per-device) |
| Limit zařízení | Žádný |

##### Architekturní rozhodnutí

1. **Licenční pole + status jsou server-autoritativní**: `trial_expires_at`, `license_expires_at`, `license_last_check_at` a `status` nastavuje server (triggery/Edge Functions). BEFORE UPDATE trigger na `companies` tiše zachovává tyto hodnoty z klientských pushů. Trigger používá `current_user NOT IN ('service_role', 'postgres', 'supabase_admin')` pro spolehlivou detekci role v Supabase.
2. **Supabase session zůstává aktivní permanentně** po registraci. Sync on/off používá per-device lokální preferenci (SharedPreferences), NE synchronizovaný DB sloupec. Tím se zabrání paradoxu synchronizace sync toggleu.
3. **signUp() probíhá atomicky se seedem** v `_finish()`, ne v samostatném kroku. Zabraňuje osiřelým Supabase účtům.
4. **`trialExpiresAt` nastavuje server** prostřednictvím PostgreSQL INSERT triggeru na `companies`. Klient nastaví lokálně pro okamžité zobrazení; server přepíše při prvním push; pull sync opraví klientskou hodnotu.
5. **`licenseLastCheckAt` se aktualizuje po každém pullu** jako monotónní kotva hodin pro detekci manipulace s časem.
6. **Aktivace licence přes CompanyRepository** — Edge Function volání jdou přes `CompanyRepository.activateLicense()`.
7. **`updateLicenseFromServer()` obchází outbox** — odůvodněná výjimka: data přišla ZE serveru, pushovat je zpět je redundantní. Server trigger by je ignoroval.
8. **Aktivace kódu je atomická** — `UPDATE ... WHERE used_by_company_id IS NULL RETURNING ...` zabraňuje race conditions.
9. **Edge Function odvozuje firmu z JWT** — lookup `companies.auth_user_id` odpovídající JWT `sub` claim. Nikdy nevěří client-supplied company ID.
10. **"Přihlásit se" flow kontroluje server PŘED kroky 1+2** — uživatelé s existujícím účtem nevyplňují zbytečně info o firmě.

##### Tasky
- **Task 4.6.1** ⬜ Schema: Licenční pole na companies (trialExpiresAt, licenseExpiresAt, licenseLastCheckAt)
- **Task 4.6.2** ⬜ CompanyModel, Entity mappers, Push/Pull mappers update
- **Task 4.6.3** ⬜ Supabase migrace: Licenční sloupce + Trigger aa_protect_license_fields
- **Task 4.6.4** ⬜ Supabase migrace: activation_codes + license_activation_attempts tabulky
- **Task 4.6.5** ⬜ LicenseService (lokální logika, clock suspicious check)
- **Task 4.6.6** ⬜ License providers + AppInitState enum rozšíření
- **Task 4.6.7** ⬜ Router: License redirect + ScreenLicenseExpired
- **Task 4.6.8** ⬜ Onboarding redesign: 3-krokový wizard + demo flow
- **Task 4.6.9** ⬜ Sync toggle (per-device SharedPreferences + syncEnabledProvider)
- **Task 4.6.10** ⬜ Cloud tab redesign (Account, Licence, Synchronizace sekce)
- **Task 4.6.11** ⬜ CompanyRepository: activateLicense + updateLicenseFromServer
- **Task 4.6.12** ⬜ Edge Function: activate-license (CORS, Rate limit, Atomic update)
- **Task 4.6.13** ⬜ SyncService: licenseLastCheckAt update po pullu
- **Task 4.6.14** ⬜ Grace period banner v app.dart + L10n klíče

---

## Možná rozšíření v budoucnu

- **Sklad:** Multi-warehouse, upozornění na nízké zásoby, inventurní předlohy.
- **CRM:** Zákaznický tier systém.
- **Gastro:** Elevated Permissions (PIN nadřízeného pro storno).
- **HW:** Barcode scanner, platební terminály, pokladní zásuvka.
- **Další:** Multi-currency operace, detailní auto_print/auto_logout konfigurace.

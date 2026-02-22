// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'EPOS';

  @override
  String get onboardingTitle => 'Vítejte v EPOS';

  @override
  String get onboardingCreateCompany => 'Založit novou firmu';

  @override
  String get onboardingJoinCompany => 'Připojit se k firmě';

  @override
  String get onboardingJoinCompanyDisabled => 'Dostupné od verze 3.0';

  @override
  String get wizardStepCompany => 'Firma';

  @override
  String get wizardStepAdmin => 'Administrátor';

  @override
  String get wizardCompanyName => 'Název firmy';

  @override
  String get wizardCompanyNameRequired => 'Název firmy je povinný';

  @override
  String get wizardBusinessId => 'IČO';

  @override
  String get wizardAddress => 'Adresa';

  @override
  String get wizardEmail => 'E-mail';

  @override
  String get wizardPhone => 'Telefon';

  @override
  String get wizardNext => 'Pokračovat';

  @override
  String get wizardBack => 'Zpět';

  @override
  String get wizardFinish => 'Dokončit';

  @override
  String get wizardFullName => 'Celé jméno';

  @override
  String get wizardFullNameRequired => 'Celé jméno je povinné';

  @override
  String get wizardUsername => 'Uživatelské jméno';

  @override
  String get wizardUsernameRequired => 'Uživatelské jméno je povinné';

  @override
  String get wizardPin => 'PIN (4–6 číslic)';

  @override
  String get wizardPinConfirm => 'Potvrzení PINu';

  @override
  String get wizardPinRequired => 'PIN je povinný';

  @override
  String get wizardPinLength => 'PIN musí mít 4–6 číslic';

  @override
  String get wizardPinMismatch => 'PINy se neshodují';

  @override
  String get wizardPinDigitsOnly => 'PIN smí obsahovat pouze číslice';

  @override
  String get loginTitle => 'Přihlášení';

  @override
  String get loginPinLabel => 'Zadejte PIN';

  @override
  String get loginButton => 'Přihlásit';

  @override
  String get loginFailed => 'Neplatný PIN';

  @override
  String loginLockedOut(int seconds) {
    return 'Příliš mnoho pokusů. Zkuste znovu za $seconds s.';
  }

  @override
  String get billsTitle => 'Účty';

  @override
  String get billsEmpty => 'Žádné účty';

  @override
  String get billsFilterOpened => 'Otevřené';

  @override
  String get billsFilterPaid => 'Zaplacené';

  @override
  String get billsFilterCancelled => 'Stornované';

  @override
  String get billsQuickBill => 'Rychlý účet';

  @override
  String get billsNewBill => 'Vytvořit účet';

  @override
  String get billsSectionAll => 'Vše';

  @override
  String get columnTable => 'Stůl';

  @override
  String get columnGuest => 'Host';

  @override
  String get columnGuests => 'Hostů';

  @override
  String get columnTotal => 'Celkem';

  @override
  String get columnLastOrder => 'Posl. obj.';

  @override
  String get columnStaff => 'Obsluha';

  @override
  String get billTimeJustNow => 'právě teď';

  @override
  String get infoPanelDate => 'Datum';

  @override
  String get infoPanelStatus => 'Stav pokladny';

  @override
  String get infoPanelStatusOffline => 'Offline';

  @override
  String get infoPanelActiveUser => 'Aktivní obsluha';

  @override
  String get infoPanelLoggedIn => 'Další přihlášení';

  @override
  String get actionSwitchUser => 'Zamknout / Přepnout';

  @override
  String get actionLogout => 'Odhlásit';

  @override
  String get switchUserTitle => 'Přepnout obsluhu';

  @override
  String get switchUserSelectUser => 'Vyberte uživatele';

  @override
  String switchUserEnterPin(String name) {
    return 'Zadejte PIN pro $name';
  }

  @override
  String get settingsTitle => 'Nastavení';

  @override
  String get settingsUsers => 'Uživatelé';

  @override
  String get settingsSections => 'Sekce';

  @override
  String get settingsTables => 'Stoly';

  @override
  String get settingsCategories => 'Kategorie';

  @override
  String get settingsProducts => 'Produkty';

  @override
  String get settingsTaxRates => 'Daň. sazby';

  @override
  String get settingsPaymentMethods => 'Plat. metody';

  @override
  String get actionAdd => 'Přidat';

  @override
  String get actionEdit => 'Upravit';

  @override
  String get actionSave => 'Uložit';

  @override
  String get actionCancel => 'Zrušit';

  @override
  String get actionDelete => 'Smazat';

  @override
  String get actionClose => 'Zavřít';

  @override
  String get actionConfirm => 'OK';

  @override
  String get unitPcs => 'ks';

  @override
  String get fieldName => 'Název';

  @override
  String get fieldUsername => 'Username';

  @override
  String get fieldRole => 'Role';

  @override
  String get fieldPin => 'PIN';

  @override
  String get fieldActive => 'Aktivní';

  @override
  String get fieldActions => 'Akce';

  @override
  String get fieldSection => 'Sekce';

  @override
  String get fieldCapacity => 'Kapacita';

  @override
  String get fieldColor => 'Barva';

  @override
  String get fieldCategory => 'Kategorie';

  @override
  String get fieldPrice => 'Cena';

  @override
  String get fieldTaxRate => 'Daň. sazba';

  @override
  String get fieldType => 'Typ';

  @override
  String get fieldRate => 'Sazba (%)';

  @override
  String get fieldDefault => 'Výchozí';

  @override
  String get roleHelper => 'Pomocník';

  @override
  String get roleOperator => 'Obsluha';

  @override
  String get roleAdmin => 'Administrátor';

  @override
  String get paymentTypeCash => 'Hotovost';

  @override
  String get paymentTypeCard => 'Karta';

  @override
  String get paymentTypeBank => 'Převod';

  @override
  String get paymentTypeOther => 'Ostatní';

  @override
  String get taxTypeRegular => 'Běžná';

  @override
  String get taxTypeNoTax => 'Bez DPH';

  @override
  String get taxTypeConstant => 'Konstantní';

  @override
  String get taxTypeMixed => 'Smíšená';

  @override
  String get confirmDelete => 'Opravdu chcete smazat tuto položku?';

  @override
  String get yes => 'Ano';

  @override
  String get no => 'Ne';

  @override
  String get noPermission => 'Nemáte oprávnění pro tuto akci';

  @override
  String get newBillTitle => 'Nový účet';

  @override
  String get newBillSelectTable => 'Stůl (volitelný)';

  @override
  String get newBillGuests => 'Počet hostů';

  @override
  String get newBillCreate => 'Vytvořit';

  @override
  String get billDetailTitle => 'Detail účtu';

  @override
  String billDetailTable(String name) {
    return 'Stůl: $name';
  }

  @override
  String get billDetailTakeaway => 'Jídlo s sebou';

  @override
  String get billDetailNoTable => 'Bez stolu';

  @override
  String billDetailCreated(String time) {
    return 'Vytvořen: $time';
  }

  @override
  String billDetailLastOrder(String time) {
    return 'Posl. obj.: $time';
  }

  @override
  String get billDetailNoOrders => 'Zatím žádné objednávky';

  @override
  String get billDetailOrder => 'Objednat';

  @override
  String get billDetailPay => 'Zaplatit';

  @override
  String get billDetailCancel => 'Storno účtu';

  @override
  String get billDetailConfirmCancel => 'Opravdu chcete stornovat tento účet?';

  @override
  String billDetailBillNumber(String number) {
    return 'Účet $number';
  }

  @override
  String get billStatusOpened => 'Otevřený';

  @override
  String get billStatusPaid => 'Zaplacený';

  @override
  String get billStatusCancelled => 'Stornovaný';

  @override
  String get sellTitle => 'Prodej';

  @override
  String get sellCart => 'Košík';

  @override
  String get sellCartEmpty => 'Košík je prázdný';

  @override
  String get sellTotal => 'Celkem';

  @override
  String get sellCancelOrder => 'Zrušit';

  @override
  String get sellClearCart => 'Vymazat košík';

  @override
  String get sellSaveToBill => 'Uložit';

  @override
  String get sellSubmitOrder => 'Objednat';

  @override
  String get sellSearch => 'Vyhledat';

  @override
  String get sellEditGrid => 'Upravit grid';

  @override
  String get sellExitEdit => 'Ukončit úpravy';

  @override
  String get sellEmptySlot => 'Prázdné';

  @override
  String get sellBackToCategories => 'Zpět';

  @override
  String sellQuantity(String count) {
    return '$count×';
  }

  @override
  String get prepStatusCreated => 'Vytvořeno';

  @override
  String get prepStatusReady => 'Připraveno';

  @override
  String get prepStatusDelivered => 'Doručeno';

  @override
  String get prepStatusCancelled => 'Zrušeno';

  @override
  String get prepStatusVoided => 'Stornováno';

  @override
  String get orderStatusChange => 'Změnit stav';

  @override
  String get orderCancel => 'Zrušit objednávku';

  @override
  String get orderVoid => 'Stornovat objednávku';

  @override
  String get orderConfirmCancel => 'Opravdu chcete zrušit tuto objednávku?';

  @override
  String get orderConfirmVoid => 'Opravdu chcete stornovat tuto objednávku?';

  @override
  String get paymentTitle => 'Platba';

  @override
  String get paymentMethod => 'Platební metoda';

  @override
  String get paymentAmount => 'Částka';

  @override
  String paymentTotalDue(String amount) {
    return 'K úhradě: $amount';
  }

  @override
  String get paymentConfirm => 'Zaplatit';

  @override
  String get gridEditorTitle => 'Editor gridu';

  @override
  String get gridEditorSelectType => 'Vyberte typ';

  @override
  String get gridEditorItem => 'Produkt';

  @override
  String get gridEditorCategory => 'Kategorie';

  @override
  String get gridEditorClear => 'Vymazat';

  @override
  String get gridEditorSelectItem => 'Vyberte produkt';

  @override
  String get gridEditorSelectCategory => 'Vyberte kategorii';

  @override
  String get registerSessionStart => 'Zahájit prodej';

  @override
  String get registerSessionClose => 'Uzávěrka';

  @override
  String get registerSessionNoSession => 'Žádná aktivní směna';

  @override
  String get registerSessionConfirmClose => 'Opravdu chcete uzavřít směnu?';

  @override
  String get registerSessionRequired =>
      'Pro prodej musíte nejdříve zahájit směnu';

  @override
  String get registerSessionActive => 'Směna aktivní';

  @override
  String get billsSorting => 'Řazení';

  @override
  String get sortByTable => 'Stůl';

  @override
  String get sortByTotal => 'Celkem';

  @override
  String get sortByLastOrder => 'Posl. objednávka';

  @override
  String get billsCashJournal => 'Pokladní deník';

  @override
  String get billsSalesOverview => 'Přehled prodeje';

  @override
  String get billsInventory => 'Sklad';

  @override
  String get billsMore => 'Další';

  @override
  String get billsTableMap => 'Mapa';

  @override
  String get infoPanelRegisterTotal => 'Pokladna';

  @override
  String get infoPanelRevenue => 'Tržba';

  @override
  String get infoPanelSalesCount => 'Počet prodejů';

  @override
  String get sellCartSummary => 'Souhrn položek';

  @override
  String get sellScan => 'Skenovat';

  @override
  String get sellCustomer => 'Zákazník';

  @override
  String get sellNote => 'Poznámka';

  @override
  String get sellActions => 'Akce';

  @override
  String get billDetailCustomer => 'Zákazník';

  @override
  String get billDetailMove => 'Stůl';

  @override
  String get billDetailMoveTitle => 'Přesunout účet';

  @override
  String get billDetailMerge => 'Sloučit';

  @override
  String get billDetailSplit => 'Rozdělit';

  @override
  String get billDetailSummary => 'Sumář';

  @override
  String get billDetailItemList => 'Historie';

  @override
  String get billDetailPrint => 'Tisk';

  @override
  String get billDetailOrderHistory => 'Historie objednávek';

  @override
  String billDetailTotalSpent(String amount) {
    return 'Celková útrata: $amount';
  }

  @override
  String billDetailCreatedAt(String date) {
    return 'Účet vytvořen: $date';
  }

  @override
  String billDetailLastOrderAt(String date) {
    return 'Poslední objednávka: $date';
  }

  @override
  String get billDetailNoOrderYet => 'Zatím žádná objednávka';

  @override
  String billDetailCustomerName(String name) {
    return 'Zákazník: $name';
  }

  @override
  String get billDetailNoCustomer => 'Zákazník nepřiřazen';

  @override
  String get itemTypeProduct => 'Produkt';

  @override
  String get itemTypeService => 'Služba';

  @override
  String get itemTypeCounter => 'Počítadlo';

  @override
  String get itemTypeRecipe => 'Receptura';

  @override
  String get itemTypeIngredient => 'Ingredience';

  @override
  String get itemTypeVariant => 'Varianta';

  @override
  String get itemTypeModifier => 'Modifikátor';

  @override
  String get moreReports => 'Reporty';

  @override
  String get moreStatistics => 'Statistiky';

  @override
  String get moreReservations => 'Rezervace';

  @override
  String get moreSettings => 'Nastavení';

  @override
  String get moreCompanySettings => 'Nastavení firmy';

  @override
  String get moreVenueSettings => 'Nastavení provozovny';

  @override
  String get moreRegisterSettings => 'Nastavení pokladny';

  @override
  String get settingsCompanyTitle => 'Nastavení firmy';

  @override
  String get settingsVenueTitle => 'Nastavení provozovny';

  @override
  String get settingsRegisterTitle => 'Nastavení pokladny';

  @override
  String get settingsTabCompany => 'Firma';

  @override
  String get settingsTabRegister => 'Pokladna';

  @override
  String get settingsTabUsers => 'Uživatelé';

  @override
  String get settingsTabLog => 'Log';

  @override
  String get settingsSectionCompanyInfo => 'Informace o firmě';

  @override
  String get settingsSectionSecurity => 'Zabezpečení';

  @override
  String get settingsSectionCloud => 'Cloud';

  @override
  String get settingsSectionSellOptions => 'Volby prodeje';

  @override
  String get settingsSellMode => 'Režim prodeje';

  @override
  String get sellModeGastro => 'Gastro';

  @override
  String get sellModeRetail => 'Retail';

  @override
  String get settingsSectionGrid => 'Zobrazení mřížky';

  @override
  String get companyFieldVatNumber => 'DIČ';

  @override
  String get settingsLanguage => 'Jazyk aplikace';

  @override
  String get settingsCurrency => 'Výchozí měna';

  @override
  String get languageCzech => 'Čeština';

  @override
  String get languageEnglish => 'English';

  @override
  String get cloudTitle => 'Cloudová synchronizace';

  @override
  String get cloudEmail => 'E-mail';

  @override
  String get cloudPassword => 'Heslo';

  @override
  String get cloudSignUp => 'Registrovat';

  @override
  String get cloudSignIn => 'Přihlásit';

  @override
  String get cloudSignOut => 'Odpojit';

  @override
  String get cloudConnected => 'Připojeno';

  @override
  String get cloudDisconnected => 'Nepřipojeno';

  @override
  String get cloudEmailRequired => 'E-mail je povinný';

  @override
  String get cloudPasswordRequired => 'Heslo je povinné';

  @override
  String get cloudPasswordLength => 'Heslo musí mít alespoň 6 znaků';

  @override
  String get cloudDiagnostics => 'Diagnostika';

  @override
  String get cloudExportLogs => 'Exportovat logy';

  @override
  String get cloudExportLogsDescription =>
      'Otevře soubor s logy aplikace pro řešení problémů.';

  @override
  String get cloudDangerZone => 'Nebezpečná zóna';

  @override
  String get cloudDeleteLocalData => 'Smazat lokální data';

  @override
  String get cloudDeleteLocalDataDescription =>
      'Smaže data z tohoto zařízení. Data na serveru zůstanou zachována a po přihlášení se znovu stáhnou.';

  @override
  String get cloudDeleteLocalDataConfirmTitle => 'Smazat lokální data?';

  @override
  String get cloudDeleteLocalDataConfirmMessage =>
      'Všechna lokální data budou smazána a aplikace se vrátí na úvodní obrazovku. Data na serveru zůstanou zachována.';

  @override
  String get cloudDeleteLocalDataConfirm => 'Smazat';

  @override
  String get cloudDeleteAllData => 'Smazat vše';

  @override
  String get cloudDeleteAllDataDescription =>
      'Smaže všechna data z tohoto zařízení i ze serveru. Tato akce je nevratná.';

  @override
  String get cloudDeleteAllDataConfirmTitle => 'Smazat všechna data?';

  @override
  String get cloudDeleteAllDataConfirmMessage =>
      'Všechna data budou nenávratně smazána z tohoto zařízení i ze serveru. Aplikace se vrátí na úvodní obrazovku.';

  @override
  String get cloudDeleteAllDataConfirm => 'Smazat vše';

  @override
  String get infoPanelSync => 'Synchronizace';

  @override
  String get infoPanelSyncConnected => 'Připojeno';

  @override
  String get infoPanelSyncDisconnected => 'Nepřipojeno';

  @override
  String get connectCompanyTitle => 'Připojit se k firmě';

  @override
  String get connectCompanySubtitle =>
      'Přihlaste se pomocí administrátorského účtu';

  @override
  String get connectCompanySearching => 'Hledání firmy...';

  @override
  String get connectCompanyFound => 'Nalezená firma';

  @override
  String get connectCompanyNotFound => 'Žádná firma nenalezena pro tento účet';

  @override
  String get connectCompanyConnect => 'Připojit';

  @override
  String get connectCompanySyncing => 'Synchronizace dat...';

  @override
  String get connectCompanySyncComplete => 'Synchronizace dokončena';

  @override
  String get connectCompanySyncFailed => 'Synchronizace selhala';

  @override
  String get cashJournalTitle => 'Pokladní deník';

  @override
  String get cashJournalBalance => 'Hotovost v pokladně:';

  @override
  String get cashJournalFilterDeposits => 'Vklady';

  @override
  String get cashJournalFilterWithdrawals => 'Výběry';

  @override
  String get cashJournalFilterSales => 'Prodeje';

  @override
  String get cashJournalAddMovement => 'Zapsat změnu';

  @override
  String get cashJournalColumnTime => 'Čas';

  @override
  String get cashJournalColumnType => 'Typ';

  @override
  String get cashJournalColumnAmount => 'Částka';

  @override
  String get cashJournalColumnNote => 'Poznámka';

  @override
  String get cashJournalEmpty => 'Žádné záznamy';

  @override
  String get cashMovementTitle => 'Změna stavu hotovosti';

  @override
  String get cashMovementAmount => 'Částka:';

  @override
  String get cashMovementDeposit => 'Vklad';

  @override
  String get cashMovementWithdrawal => 'Výběr';

  @override
  String get cashMovementSale => 'Prodej';

  @override
  String get cashMovementNote => 'Poznámka';

  @override
  String get cashMovementNoteTitle => 'Poznámka ke změně hotovosti';

  @override
  String get cashMovementNoteHint => 'Důvod pohybu...';

  @override
  String get openingCashTitle => 'Počáteční hotovost';

  @override
  String get openingCashSubtitle =>
      'Zadejte stav hotovosti v pokladně před zahájením prodeje.';

  @override
  String get openingCashConfirm => 'Potvrdit';

  @override
  String get closingTitle => 'Uzávěrka';

  @override
  String get closingSessionTitle => 'Přehled směny';

  @override
  String get closingOpenedAt => 'Začátek';

  @override
  String get closingOpenedBy => 'Otevřel';

  @override
  String get closingDuration => 'Trvání';

  @override
  String get closingBillsPaid => 'Zaplacené účty';

  @override
  String get closingBillsCancelled => 'Stornované účty';

  @override
  String get closingRevenueTitle => 'Tržba dle plateb';

  @override
  String get closingRevenueTotal => 'Celkem';

  @override
  String get closingTips => 'Spropitné';

  @override
  String get closingCashTitle => 'Stav hotovosti';

  @override
  String get closingOpeningCash => 'Počáteční hotovost';

  @override
  String get closingCashRevenue => 'Tržba hotovost';

  @override
  String get closingDeposits => 'Vklady';

  @override
  String get closingWithdrawals => 'Výběry';

  @override
  String get closingExpectedCash => 'Očekávaná hotovost';

  @override
  String get closingActualCash => 'Skutečný stav hotovosti';

  @override
  String get closingDifference => 'Rozdíl';

  @override
  String get closingPrint => 'Tisk';

  @override
  String get closingConfirm => 'Uzavřít směnu';

  @override
  String get closingNoteTitle => 'Poznámka k uzávěrce';

  @override
  String get closingNoteHint => 'Poznámky k uzávěrce...';

  @override
  String get paymentOtherCurrency => 'Jiná měna';

  @override
  String get paymentEet => 'EET';

  @override
  String get paymentEditAmount => 'Upravit částku';

  @override
  String get paymentMoreActions => 'Další akce';

  @override
  String get paymentMixPayments => 'Mix plateb';

  @override
  String get paymentOtherPayment => 'Jiná platba';

  @override
  String get paymentPrintReceipt => 'Tisk dokladu';

  @override
  String get paymentPrintYes => 'ANO';

  @override
  String get paymentPrintNo => 'NE';

  @override
  String paymentTip(String amount) {
    return 'Spropitné: $amount';
  }

  @override
  String paymentBillSubtitle(String billNumber, String tableName) {
    return 'Účet $billNumber - $tableName';
  }

  @override
  String get billDetailDiscount => 'Sleva';

  @override
  String get billStatusRefunded => 'Refundovaný';

  @override
  String get refundTitle => 'Refund';

  @override
  String get refundConfirmFull => 'Opravdu chcete refundovat celý účet?';

  @override
  String get refundConfirmItem => 'Opravdu chcete refundovat tuto položku?';

  @override
  String get refundButton => 'REFUND';

  @override
  String get refundFullBill => 'Celý účet';

  @override
  String get refundSelectItems => 'Vybrat položky';

  @override
  String get changeTotalTitle => 'Upravit částku';

  @override
  String get changeTotalOriginal => 'Původní';

  @override
  String get changeTotalEdited => 'Upravená';

  @override
  String get changeTotalDifference => 'Změna';

  @override
  String get newBillSave => 'Uložit';

  @override
  String get newBillOrder => 'Objednat';

  @override
  String get newBillSelectSection => 'Výběr sekce';

  @override
  String get newBillCustomer => 'Zákazník';

  @override
  String get newBillNoTable => 'Bez stolu';

  @override
  String get zReportListTitle => 'Přehled uzávěrek';

  @override
  String get zReportListEmpty => 'Žádné uzávěrky';

  @override
  String get zReportColumnDate => 'Datum';

  @override
  String get zReportColumnTime => 'Čas';

  @override
  String get zReportColumnUser => 'Uživatel';

  @override
  String get zReportColumnRevenue => 'Tržba';

  @override
  String get zReportColumnDifference => 'Rozdíl';

  @override
  String get zReportTitle => 'Z-Report';

  @override
  String get zReportSessionInfo => 'Informace o směně';

  @override
  String get zReportOpenedAt => 'Začátek';

  @override
  String get zReportClosedAt => 'Konec';

  @override
  String get zReportDuration => 'Trvání';

  @override
  String get zReportOpenedBy => 'Otevřel';

  @override
  String get zReportRevenueByPayment => 'Tržba dle plateb';

  @override
  String get zReportRevenueTotal => 'Celkem';

  @override
  String get zReportTaxTitle => 'DPH';

  @override
  String get zReportTaxRate => 'Sazba';

  @override
  String get zReportTaxNet => 'Základ';

  @override
  String get zReportTaxAmount => 'DPH';

  @override
  String get zReportTaxGross => 'Celkem';

  @override
  String get zReportTipsTotal => 'Spropitné celkem';

  @override
  String get zReportTipsByUser => 'Spropitné dle obsluhy';

  @override
  String get zReportDiscounts => 'Slevy celkem';

  @override
  String get zReportBillsPaid => 'Zaplacené účty';

  @override
  String get zReportBillsCancelled => 'Stornované účty';

  @override
  String get zReportBillsRefunded => 'Refundované účty';

  @override
  String get zReportCashTitle => 'Stav hotovosti';

  @override
  String get zReportCashOpening => 'Počáteční hotovost';

  @override
  String get zReportCashRevenue => 'Tržba hotovost';

  @override
  String get zReportCashDeposits => 'Vklady';

  @override
  String get zReportCashWithdrawals => 'Výběry';

  @override
  String get zReportCashExpected => 'Očekávaná hotovost';

  @override
  String get zReportCashClosing => 'Konečný stav';

  @override
  String get zReportCashDifference => 'Rozdíl';

  @override
  String get zReportShiftsTitle => 'Směny';

  @override
  String get zReportPrint => 'Tisk';

  @override
  String get zReportClose => 'Zavřít';

  @override
  String get moreShifts => 'Směny';

  @override
  String get shiftsListTitle => 'Přehled směn';

  @override
  String get shiftsListEmpty => 'Žádné směny v tomto období';

  @override
  String get shiftsColumnDate => 'Datum';

  @override
  String get shiftsColumnUser => 'Obsluha';

  @override
  String get shiftsColumnLogin => 'Přihlášení';

  @override
  String get shiftsColumnLogout => 'Odhlášení';

  @override
  String get shiftsColumnDuration => 'Trvání';

  @override
  String get shiftsOngoing => 'probíhá';

  @override
  String get closingOpenBillsWarningTitle => 'Otevřené účty';

  @override
  String closingOpenBillsWarningMessage(int count, String amount) {
    return 'Na konci prodeje je $count otevřených účtů v celkové hodnotě $amount.';
  }

  @override
  String get closingOpenBillsContinue => 'Pokračovat';

  @override
  String get closingOpenBills => 'Otevřené účty';

  @override
  String get zReportOpenBillsAtOpen => 'Otevřené účty (začátek)';

  @override
  String get zReportOpenBillsAtClose => 'Otevřené účty (konec)';

  @override
  String get settingsRequirePinOnSwitch =>
      'Vyžadovat PIN při přepínání obsluhy';

  @override
  String get settingsAutoLockTimeout => 'Automatické zamčení po nečinnosti';

  @override
  String get settingsAutoLockDisabled => 'Vypnuto';

  @override
  String settingsAutoLockMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get settingsGridRows => 'Řádky gridu';

  @override
  String get settingsGridCols => 'Sloupce gridu';

  @override
  String get lockScreenTitle => 'Zamčeno';

  @override
  String get lockScreenSubtitle => 'Vyberte uživatele pro odemčení';

  @override
  String get autoCorrection =>
      'Automatická korekce: počáteční hotovost se liší od předchozí uzávěrky';

  @override
  String get errorNoCompanyFound => 'Firma nenalezena';

  @override
  String get openingCashNote => 'Počáteční stav';

  @override
  String get catalogTitle => 'Katalog';

  @override
  String get catalogTabProducts => 'Produkty';

  @override
  String get catalogTabCategories => 'Kategorie';

  @override
  String get catalogTabSuppliers => 'Dodavatelé';

  @override
  String get catalogTabManufacturers => 'Výrobci';

  @override
  String get catalogTabRecipes => 'Receptury';

  @override
  String get fieldSupplierName => 'Název dodavatele';

  @override
  String get fieldContactPerson => 'Kontaktní osoba';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldPhone => 'Telefon';

  @override
  String get fieldManufacturer => 'Výrobce';

  @override
  String get fieldSupplier => 'Dodavatel';

  @override
  String get fieldParentCategory => 'Nadřazená kategorie';

  @override
  String get fieldAltSku => 'Alternativní SKU';

  @override
  String get fieldPurchasePrice => 'Nákupní cena';

  @override
  String get fieldPurchaseTaxRate => 'Nákupní DPH';

  @override
  String get fieldOnSale => 'V prodeji';

  @override
  String get fieldStockTracked => 'Sledování skladu';

  @override
  String get fieldParentProduct => 'Nadřazený produkt';

  @override
  String get fieldComponent => 'Složka';

  @override
  String get fieldQuantityRequired => 'Požadované množství';

  @override
  String get moreCatalog => 'Katalog';

  @override
  String get mergeBillTitle => 'Sloučit účet';

  @override
  String get mergeBillDescription =>
      'Objednávky z tohoto účtu budou přesunuty na vybraný účet. Aktuální účet bude zrušen.';

  @override
  String get mergeBillNoBills => 'Žádné otevřené účty k sloučení';

  @override
  String get splitBillTitle => 'Rozdělit účet';

  @override
  String get splitBillSelectItems => 'Vyberte položky k rozdělení';

  @override
  String get splitBillPayButton => 'Rozdělit a zaplatit';

  @override
  String get splitBillNewBillButton => 'Rozdělit na nový účet';

  @override
  String get catalogTabCustomers => 'Zákazníci';

  @override
  String get customerFirstName => 'Jméno';

  @override
  String get customerLastName => 'Příjmení';

  @override
  String get customerEmail => 'E-mail';

  @override
  String get customerPhone => 'Telefon';

  @override
  String get customerAddress => 'Adresa';

  @override
  String get customerPoints => 'Body';

  @override
  String get customerCredit => 'Kredit';

  @override
  String get customerTotalSpent => 'Celkem utraceno';

  @override
  String get customerBirthdate => 'Datum narození';

  @override
  String get customerLastVisit => 'Poslední návštěva';

  @override
  String get customerSearch => 'Hledat zákazníka';

  @override
  String get customerRemove => 'Odebrat zákazníka';

  @override
  String get customerNone => 'Žádný zákazník';

  @override
  String get inventoryTitle => 'Sklad';

  @override
  String get inventoryColumnItem => 'Položka';

  @override
  String get inventoryColumnUnit => 'Jednotka';

  @override
  String get inventoryColumnQuantity => 'Množství';

  @override
  String get inventoryColumnMinQuantity => 'Min. množství';

  @override
  String get inventoryColumnPurchasePrice => 'Nákupní cena';

  @override
  String get inventoryColumnTotalValue => 'Celková hodnota';

  @override
  String get inventoryTotalValue => 'Celková hodnota skladu';

  @override
  String get inventoryReceipt => 'Příjemka';

  @override
  String get inventoryWaste => 'Výdejka';

  @override
  String get inventoryCorrection => 'Oprava';

  @override
  String get inventoryInventory => 'Inventura';

  @override
  String get inventoryNoItems => 'Žádné sledované položky';

  @override
  String get stockDocumentTitle => 'Skladový doklad';

  @override
  String get stockDocumentSupplier => 'Dodavatel';

  @override
  String get stockDocumentPriceStrategy => 'Strategie nákupní ceny';

  @override
  String get stockDocumentNote => 'Poznámka';

  @override
  String get stockDocumentAddItem => 'Přidat položku';

  @override
  String get stockDocumentQuantity => 'Množství';

  @override
  String get stockDocumentPrice => 'Nákupní cena';

  @override
  String get stockDocumentSave => 'Uložit doklad';

  @override
  String get stockDocumentNoItems => 'Přidejte alespoň jednu položku';

  @override
  String get stockDocumentSearchItem => 'Hledat položku';

  @override
  String get stockDocumentItemOverrideStrategy => 'Override strategie';

  @override
  String get stockStrategyOverwrite => 'Přepsat';

  @override
  String get stockStrategyKeep => 'Ponechat';

  @override
  String get stockStrategyAverage => 'Průměr';

  @override
  String get stockStrategyWeightedAverage => 'Vážený průměr';

  @override
  String get inventoryDialogTitle => 'Inventura';

  @override
  String get inventoryDialogActualQuantity => 'Skutečný stav';

  @override
  String get inventoryDialogDifference => 'Rozdíl';

  @override
  String get inventoryDialogSave => 'Uložit inventuru';

  @override
  String get inventoryDialogNoDifferences => 'Žádné rozdíly';

  @override
  String get inventoryTabLevels => 'Zásoby';

  @override
  String get inventoryTabDocuments => 'Doklady';

  @override
  String get inventoryTabMovements => 'Pohyby';

  @override
  String get documentColumnNumber => 'Číslo';

  @override
  String get documentColumnType => 'Typ';

  @override
  String get documentColumnDate => 'Datum';

  @override
  String get documentColumnSupplier => 'Dodavatel';

  @override
  String get documentColumnNote => 'Poznámka';

  @override
  String get documentColumnTotal => 'Celkem';

  @override
  String get documentNoDocuments => 'Žádné skladové doklady';

  @override
  String get documentTypeReceipt => 'Příjemka';

  @override
  String get documentTypeWaste => 'Výdejka';

  @override
  String get documentTypeInventory => 'Inventura';

  @override
  String get documentTypeCorrection => 'Oprava';

  @override
  String get movementColumnDate => 'Datum';

  @override
  String get movementColumnItem => 'Položka';

  @override
  String get movementColumnQuantity => 'Množství';

  @override
  String get movementColumnType => 'Typ';

  @override
  String get movementColumnDocument => 'Doklad';

  @override
  String get movementNoMovements => 'Žádné skladové pohyby';

  @override
  String get movementFilterItem => 'Filtrovat dle položky';

  @override
  String get movementTypeSale => 'Prodej';

  @override
  String get movementTypeReversal => 'Storno';

  @override
  String get recipeComponents => 'Složky';

  @override
  String recipeComponentCount(int count) {
    return '$count složek';
  }

  @override
  String get recipeAddComponent => 'Přidat složku';

  @override
  String get recipeNoComponents => 'Žádné složky. Přidejte alespoň jednu.';

  @override
  String get searchHint => 'Hledat...';

  @override
  String get filterTitle => 'Filtr';

  @override
  String get filterAll => 'Vše';

  @override
  String get filterReset => 'Resetovat';

  @override
  String get receiptSubtotal => 'Mezisoučet';

  @override
  String get receiptDiscount => 'Sleva';

  @override
  String get receiptTotal => 'Celkem';

  @override
  String get receiptRounding => 'Zaokrouhlení';

  @override
  String get receiptTaxTitle => 'Rekapitulace DPH';

  @override
  String get receiptTaxRate => 'Sazba';

  @override
  String get receiptTaxNet => 'Základ';

  @override
  String get receiptTaxAmount => 'DPH';

  @override
  String get receiptTaxGross => 'Celkem';

  @override
  String get receiptPayment => 'Platba';

  @override
  String get receiptTip => 'Spropitné';

  @override
  String get receiptBillNumber => 'Účtenka č.';

  @override
  String get receiptTable => 'Stůl';

  @override
  String get receiptTakeaway => 'S sebou';

  @override
  String get receiptCashier => 'Obsluha';

  @override
  String get receiptDate => 'Datum';

  @override
  String get receiptThankYou => 'Děkujeme za návštěvu';

  @override
  String get receiptIco => 'IČO';

  @override
  String get receiptDic => 'DIČ';

  @override
  String get receiptPreviewTitle => 'Náhled účtenky';

  @override
  String get zReportReportTitle => 'Z-Report';

  @override
  String get zReportSession => 'Směna';

  @override
  String get zReportOpenedAtLabel => 'Začátek';

  @override
  String get zReportClosedAtLabel => 'Konec';

  @override
  String get zReportDurationLabel => 'Trvání';

  @override
  String get zReportOpenedByLabel => 'Otevřel';

  @override
  String get zReportRevenueTitle => 'Tržba dle plateb';

  @override
  String get zReportTaxReportTitle => 'DPH';

  @override
  String get zReportTipsTitle => 'Spropitné';

  @override
  String get zReportDiscountsTitle => 'Slevy';

  @override
  String get zReportBillCountsTitle => 'Počty účtů';

  @override
  String get zReportCashReportTitle => 'Stav hotovosti';

  @override
  String get zReportShiftsReportTitle => 'Směny';

  @override
  String get zReportRegisterBreakdown => 'Rozpad dle pokladen';

  @override
  String get zReportRegisterColumn => 'Pokladna';

  @override
  String get zReportVenueReport => 'Report provozovny';

  @override
  String get zReportVenueReportTitle => 'Report provozovny';

  @override
  String zReportRegisterName(String name) {
    return 'Pokladna: $name';
  }

  @override
  String cashHandoverReason(String registerName) {
    return 'Předání hotovosti z $registerName';
  }

  @override
  String get reservationsTitle => 'Rezervace';

  @override
  String get reservationNew => 'Nová rezervace';

  @override
  String get reservationEdit => 'Upravit rezervaci';

  @override
  String get reservationDate => 'Datum';

  @override
  String get reservationTime => 'Čas';

  @override
  String get reservationCustomerName => 'Jméno';

  @override
  String get reservationCustomerPhone => 'Telefon';

  @override
  String get reservationPartySize => 'Počet osob';

  @override
  String get reservationTable => 'Stůl';

  @override
  String get reservationNotes => 'Poznámka';

  @override
  String get reservationStatus => 'Stav';

  @override
  String get reservationStatusCreated => 'Vytvořena';

  @override
  String get reservationStatusConfirmed => 'Potvrzena';

  @override
  String get reservationStatusSeated => 'Usazeni';

  @override
  String get reservationStatusCancelled => 'Zrušena';

  @override
  String get reservationLinkCustomer => 'Propojit zákazníka';

  @override
  String get reservationLinkedCustomer => 'Zákazník';

  @override
  String get reservationsEmpty => 'Žádné rezervace';

  @override
  String get reservationSave => 'Uložit';

  @override
  String get reservationDelete => 'Smazat';

  @override
  String get reservationColumnDate => 'Datum';

  @override
  String get reservationColumnTime => 'Čas';

  @override
  String get reservationColumnName => 'Jméno';

  @override
  String get reservationColumnPhone => 'Telefon';

  @override
  String get reservationColumnPartySize => 'Počet';

  @override
  String get reservationColumnTable => 'Stůl';

  @override
  String get reservationColumnStatus => 'Stav';

  @override
  String get paymentTypeCredit => 'Kredit';

  @override
  String get paymentTypeVoucher => 'Stravenky';

  @override
  String get loyaltySectionTitle => 'Věrnostní program';

  @override
  String loyaltyEarnRate(String unit) {
    return 'Bodů za $unit';
  }

  @override
  String get loyaltyPointValue => 'Hodnota 1 bodu (minor units)';

  @override
  String loyaltyDescription(int earn, String unit, String value) {
    return 'Zákazník získá $earn bodů za každých $unit. 1 bod = $value.';
  }

  @override
  String get loyaltyDisabled =>
      'Věrnostní program je vypnutý (nastavte hodnoty > 0)';

  @override
  String get loyaltyRedeem => 'Uplatnit body';

  @override
  String get loyaltyAvailablePoints => 'Dostupné body';

  @override
  String get loyaltyPointsValue => 'Hodnota';

  @override
  String loyaltyPerPoint(String value) {
    return '$value/bod';
  }

  @override
  String get loyaltyPointsToUse => 'Bodů k uplatnění';

  @override
  String loyaltyDiscountPreview(int points, String amount) {
    return '$points bodů = sleva $amount';
  }

  @override
  String get loyaltyEarned => 'Získáno bodů';

  @override
  String loyaltyCustomerInfo(int points, String credit) {
    return 'Body: $points | Kredit: $credit';
  }

  @override
  String get loyaltyCredit => 'Zákaznický kredit';

  @override
  String get loyaltyCreditTopUp => 'Nabít kredit';

  @override
  String get loyaltyCreditDeduct => 'Odečíst kredit';

  @override
  String get loyaltyCreditBalance => 'Zůstatek';

  @override
  String get loyaltyTransactionHistory => 'Historie transakcí';

  @override
  String get loyaltyNoCustomer => 'K účtu není přiřazen zákazník';

  @override
  String get settingsSectionGridManagement => 'Správa rozložení mřížky';

  @override
  String get settingsAutoArrange => 'Automatické rozmístění';

  @override
  String get settingsAutoArrangeDescription =>
      'Rozmístí kategorie a produkty do mřížky';

  @override
  String get settingsManualEditor => 'Ruční editor mřížky';

  @override
  String get settingsManualEditorDescription =>
      'Otevře editor pro přiřazení položek';

  @override
  String get autoArrangeTitle => 'Automatické rozmístění';

  @override
  String get autoArrangeHorizontal => 'Horizontální';

  @override
  String get autoArrangeHorizontalDesc => 'Řádek = kategorie + její produkty';

  @override
  String get autoArrangeVertical => 'Vertikální';

  @override
  String get autoArrangeVerticalDesc =>
      'Sloupec = kategorie + její produkty pod ní';

  @override
  String get autoArrangeWarning => 'Stávající rozmístění bude nahrazeno';

  @override
  String get autoArrangeConfirm => 'Rozmístit';

  @override
  String autoArrangeSummary(int categories, int products) {
    return '$categories kategorií, $products produktů';
  }

  @override
  String autoArrangeOverflow(int fit, int total) {
    return 'Na hlavní stránku se vejde jen $fit z $total kategorií. Zbylé budou dostupné pouze na sub-stránkách.';
  }

  @override
  String get gridEditorTitle2 => 'Editor mřížky';

  @override
  String get gridEditorBack => 'Zpět';

  @override
  String get gridEditorRootPage => 'Hlavní stránka';

  @override
  String gridEditorPage(int page) {
    return 'Stránka $page';
  }

  @override
  String get gridEditorColor => 'Barva tlačítka';

  @override
  String get settingsFloorMap => 'Mapa';

  @override
  String get billsTableList => 'Seznam';

  @override
  String get floorMapEditorTitle => 'Editor mapy';

  @override
  String get floorMapAddTable => 'Přidat stůl na mapu';

  @override
  String get floorMapEditTable => 'Upravit pozici stolu';

  @override
  String get floorMapRemoveTable => 'Odebrat z mapy';

  @override
  String get floorMapWidth => 'Šířka (buňky)';

  @override
  String get floorMapHeight => 'Výška (buňky)';

  @override
  String get floorMapSelectSection => 'Sekce';

  @override
  String get floorMapSelectTable => 'Stůl';

  @override
  String get floorMapNewTable => 'Nový stůl';

  @override
  String get floorMapNoTables =>
      'Žádné stoly na mapě. Přidejte je v editoru mapy v Nastavení.';

  @override
  String get floorMapEmptySlot => 'Prázdné';

  @override
  String get floorMapShapeRectangle => 'Obdélník';

  @override
  String get floorMapShapeRound => 'Ovál';

  @override
  String get floorMapShapeTriangle => 'Trojúhelník';

  @override
  String get floorMapShapeDiamond => 'Kosočtverec';

  @override
  String get floorMapSegmentTable => 'Stůl';

  @override
  String get floorMapSegmentElement => 'Prvek';

  @override
  String get floorMapAddElement => 'Přidat prvek na mapu';

  @override
  String get floorMapEditElement => 'Upravit prvek';

  @override
  String get floorMapRemoveElement => 'Odebrat z mapy';

  @override
  String get floorMapElementLabel => 'Popisek';

  @override
  String get floorMapElementColor => 'Barva';

  @override
  String get floorMapColorNone => 'Žádná';

  @override
  String get floorMapElementFontSize => 'Velikost textu';

  @override
  String get floorMapElementFillStyle => 'Výplň';

  @override
  String get floorMapElementBorderStyle => 'Obrys';

  @override
  String get floorMapStyleNone => 'Žádný';

  @override
  String get floorMapStyleTranslucent => 'Průsvitný';

  @override
  String get floorMapStyleSolid => 'Plný';

  @override
  String get vouchersTitle => 'Vouchery';

  @override
  String get voucherCreate => 'Vytvořit voucher';

  @override
  String get voucherTypeGift => 'Dárkový';

  @override
  String get voucherTypeDeposit => 'Zálohový';

  @override
  String get voucherTypeDiscount => 'Slevový';

  @override
  String get voucherStatusActive => 'Aktivní';

  @override
  String get voucherStatusRedeemed => 'Uplatněný';

  @override
  String get voucherStatusExpired => 'Expirovaný';

  @override
  String get voucherStatusCancelled => 'Zrušený';

  @override
  String get voucherCode => 'Kód';

  @override
  String get voucherValue => 'Hodnota';

  @override
  String get voucherDiscount => 'Sleva';

  @override
  String get voucherExpires => 'Platnost do';

  @override
  String get voucherCustomer => 'Zákazník';

  @override
  String get voucherNote => 'Poznámka';

  @override
  String get voucherScopeBill => 'Celý účet';

  @override
  String get voucherScopeProduct => 'Produkt';

  @override
  String get voucherScopeCategory => 'Kategorie';

  @override
  String get voucherMaxUses => 'Max. použití';

  @override
  String get voucherUsedCount => 'Použito';

  @override
  String get voucherMinOrderValue => 'Min. hodnota účtu';

  @override
  String get voucherSell => 'Prodat';

  @override
  String get voucherCancel => 'Zrušit voucher';

  @override
  String get voucherRedeem => 'Uplatnit';

  @override
  String get voucherEnterCode => 'Zadejte kód voucheru';

  @override
  String get voucherInvalid => 'Neplatný kód voucheru';

  @override
  String get voucherExpiredError => 'Voucher expiroval';

  @override
  String get voucherAlreadyUsed => 'Voucher byl již uplatněn';

  @override
  String get voucherMinOrderNotMet => 'Minimální hodnota účtu nesplněna';

  @override
  String get voucherCustomerMismatch => 'Voucher je vázán na jiného zákazníka';

  @override
  String get voucherDepositReturn => 'Vrácení přeplatku zálohy';

  @override
  String get voucherFilterAll => 'Všechny';

  @override
  String get voucherRedeemedAt => 'Uplatněno';

  @override
  String get voucherIdLabel => 'ID';

  @override
  String get billDetailVoucher => 'Voucher';

  @override
  String get wizardLanguage => 'Jazyk';

  @override
  String get wizardCurrency => 'Výchozí měna';

  @override
  String get wizardWithTestData => 'Vytvořit s testovacími daty';

  @override
  String get orderItemStorno => 'Storno';

  @override
  String get orderItemStornoConfirm => 'Opravdu chcete stornovat tuto položku?';

  @override
  String get ordersTitle => 'Objednávky';

  @override
  String get ordersFilterActive => 'Aktivní';

  @override
  String get ordersFilterCreated => 'Vytvořené';

  @override
  String get ordersFilterReady => 'Hotové';

  @override
  String get ordersFilterDelivered => 'Doručené';

  @override
  String get ordersFilterStorno => 'Stornované';

  @override
  String get ordersScopeSession => 'Session';

  @override
  String get ordersScopeAll => 'Vše';

  @override
  String get ordersNoOrders => 'Žádné objednávky';

  @override
  String get ordersTimeCreated => 'Vytvořeno';

  @override
  String get ordersTimeUpdated => 'Změněno';

  @override
  String get ordersTableLabel => 'Stůl';

  @override
  String get ordersCustomerLabel => 'Zákazník';

  @override
  String get ordersStornoPrefix => 'STORNO';

  @override
  String ordersStornoRef(String orderNumber) {
    return '→ $orderNumber';
  }

  @override
  String get customerDisplayTitle => 'Zákaznický displej';

  @override
  String get customerDisplayWelcome => 'Vítejte';

  @override
  String get customerDisplayHeader => 'Váš účet';

  @override
  String get customerDisplaySubtotal => 'Mezisoučet';

  @override
  String get customerDisplayDiscount => 'Sleva';

  @override
  String get customerDisplayTotal => 'Celkem';

  @override
  String get kdsTitle => 'Kuchyně';

  @override
  String get kdsNoOrders => 'Žádné objednávky k přípravě';

  @override
  String get kdsBump => 'Další';

  @override
  String kdsMinAgo(String minutes) {
    return '$minutes min';
  }

  @override
  String get sellSeparator => 'Oddělit';

  @override
  String get sellSeparatorLabel => '--- Další objednávka ---';

  @override
  String get customerEnterName => 'Zadat jméno';

  @override
  String get customerNameHint => 'Jméno hosta';

  @override
  String get settingsRegisters => 'Pokladny';

  @override
  String get registerName => 'Název';

  @override
  String get registerType => 'Typ';

  @override
  String get registerNumber => 'Číslo';

  @override
  String get registerParent => 'Nadřazená pokladna';

  @override
  String get registerAllowCash => 'Hotovost';

  @override
  String get registerAllowCard => 'Karta';

  @override
  String get registerAllowTransfer => 'Převod';

  @override
  String get registerAllowCredit => 'Kredit';

  @override
  String get registerAllowVoucher => 'Stravenky';

  @override
  String get registerAllowOther => 'Ostatní';

  @override
  String get registerAllowRefunds => 'Refundy';

  @override
  String get registerPaymentFlags => 'Povolené platby';

  @override
  String get registerTypeLocal => 'Stacionární';

  @override
  String get registerTypeMobile => 'Mobilní';

  @override
  String get registerTypeVirtual => 'Virtuální';

  @override
  String get registerDeviceBinding => 'Svázání zařízení';

  @override
  String registerBound(String name) {
    return 'Svázáno s: $name';
  }

  @override
  String get registerNotBound => 'Nesvázáno';

  @override
  String get registerBind => 'Vybrat pokladnu';

  @override
  String get registerUnbind => 'Odpojit';

  @override
  String get registerSelectTitle => 'Vyberte pokladnu';

  @override
  String get registerNone => 'Žádná';

  @override
  String get registerIsMain => 'Hlavní';

  @override
  String get registerSetMain => 'Nastavit jako hlavní';

  @override
  String get registerBoundHere => 'Toto zařízení';

  @override
  String get registerBindAction => 'Svázat';

  @override
  String get registerSessionActiveCannotChange =>
      'Nelze změnit svázání během aktivní směny.';

  @override
  String get registerBoundOnOtherDevice => 'Používá jiné zařízení';

  @override
  String get infoPanelRegisterName => 'Název pokladny';

  @override
  String get connectCompanySelectRegister => 'Vyberte pokladnu';

  @override
  String get connectCompanySelectRegisterSubtitle =>
      'Vyberte pokladnu pro toto zařízení';

  @override
  String get connectCompanyNoRegisters => 'Žádné pokladny k dispozici';

  @override
  String get connectCompanyCreateRegister => 'Vytvořit novou pokladnu';

  @override
  String get registerNotBoundMessage =>
      'Pokladna není přiřazena k tomuto zařízení. Přiřaďte pokladnu v Nastavení.';

  @override
  String get modeTitle => 'Režim';

  @override
  String get modePOS => 'Pokladna';

  @override
  String get modeKDS => 'Objednávkový displej';

  @override
  String get modeCustomerDisplay => 'Zákaznický displej';

  @override
  String get customerDisplayThankYou => 'Děkujeme!';

  @override
  String get customerDisplayPaid => 'Zaplaceno';

  @override
  String get billDetailShowOnDisplay => 'Zák. displej';

  @override
  String get onboardingSectionPos => 'Pokladna';

  @override
  String get onboardingSectionDisplays => 'Displeje';

  @override
  String get onboardingCustomerDisplay => 'Zákaznický displej';

  @override
  String get onboardingKdsDisplay => 'Objednávkový displej (KDS)';

  @override
  String get displayCodeTitle => 'Zadejte kód';

  @override
  String get displayCodeSubtitle =>
      'Zadejte 6-místný kód zobrazený na pokladně';

  @override
  String get displayCodeConnect => 'Připojit';

  @override
  String get displayCodeBack => 'Zpět';

  @override
  String get displayCodeNotFound => 'Kód nenalezen';

  @override
  String get displayCodeError => 'Chyba při hledání kódu';

  @override
  String get displayCodeWaitingForConfirmation =>
      'Čeká se na potvrzení obsluhou…';

  @override
  String get displayCodeRejected => 'Připojení bylo zamítnuto';

  @override
  String get displayCodeTimeout => 'Obsluha neodpověděla. Zkuste to znovu.';

  @override
  String get pairingRequestTitle => 'Žádost o připojení';

  @override
  String get pairingRequestMessage =>
      'Zařízení se chce připojit k této pokladně:';

  @override
  String get pairingRequestCode => 'Kód';

  @override
  String get pairingConfirm => 'Potvrdit';

  @override
  String get pairingReject => 'Zamítnout';

  @override
  String get displayDevicesTitle => 'Displeje';

  @override
  String get displayDevicesEmpty => 'Žádné displeje';

  @override
  String get displayDeviceAddCustomer => 'Zákaznický';

  @override
  String get displayDeviceAddKds => 'KDS';

  @override
  String get displayWelcomeText => 'Uvítací text';

  @override
  String get displayDefaultNameKds => 'Objednávkový systém';

  @override
  String get displayDefaultWelcomeText => 'Vítejte u nás!';

  @override
  String get wizardStepAccount => 'Cloudový účet';

  @override
  String get wizardAccountEmail => 'E-mail';

  @override
  String get wizardAccountPassword => 'Heslo';

  @override
  String get wizardAccountPasswordConfirm => 'Potvrzení hesla';

  @override
  String get wizardAccountPasswordMismatch => 'Hesla se neshodují';

  @override
  String get wizardAccountSignUp => 'Vytvořit účet';

  @override
  String get wizardAccountSignIn => 'Přihlásit se';

  @override
  String get wizardAccountSwitchToSignIn => 'Máte účet? Přihlaste se';

  @override
  String get wizardAccountSwitchToSignUp => 'Nemáte účet? Vytvořte si ho';

  @override
  String cloudConnectedAs(String email) {
    return 'Připojeno jako $email';
  }

  @override
  String get actionExitApp => 'Ukončit aplikaci';

  @override
  String get actionOk => 'OK';

  @override
  String errorGeneric(Object error) {
    return 'Chyba: $error';
  }

  @override
  String loyaltyMaxPoints(Object points) {
    return 'Max: $points';
  }

  @override
  String durationHoursMinutes(int h, int m) {
    return '$h h $m min';
  }

  @override
  String durationHoursOnly(int h) {
    return '$h h';
  }

  @override
  String durationMinutesOnly(int m) {
    return '$m min';
  }

  @override
  String get variantPickerTitle => 'Vyberte variantu';

  @override
  String get addVariant => 'Přidat variantu';

  @override
  String get editVariant => 'Upravit variantu';

  @override
  String get variants => 'Varianty';

  @override
  String get noVariants => 'Žádné varianty';

  @override
  String get modifiers => 'Modifikátory';

  @override
  String get modifierGroups => 'Skupiny modifikátorů';

  @override
  String get modifierGroupName => 'Název skupiny';

  @override
  String get addModifierGroup => 'Přidat skupinu';

  @override
  String get editModifierGroup => 'Upravit skupinu';

  @override
  String get deleteModifierGroup => 'Smazat skupinu';

  @override
  String get minSelections => 'Min. výběr';

  @override
  String get maxSelections => 'Max. výběr';

  @override
  String get required => 'Povinné';

  @override
  String get optional => 'Volitelné';

  @override
  String get unlimited => 'Neomezeno';

  @override
  String get addModifier => 'Přidat modifikátor';

  @override
  String get selectModifiers => 'Vybrat modifikátory';

  @override
  String get editModifiers => 'Upravit modifikátory';

  @override
  String get noModifierGroups => 'Žádné skupiny modifikátorů';

  @override
  String get modifierTotal => 'Celkem s modifikátory';

  @override
  String get modifierGroupRequired => 'Povinná skupina';

  @override
  String get assignModifierGroup => 'Přiřadit skupinu';

  @override
  String get removeModifierGroup => 'Odebrat skupinu';

  @override
  String get inventoryTypeTitle => 'Typ inventury';

  @override
  String get inventoryTypeComplete => 'Kompletní';

  @override
  String get inventoryTypeCompleteDesc => 'Všechny sledované položky';

  @override
  String get inventoryTypeByCategory => 'Dle kategorií';

  @override
  String get inventoryTypeByCategoryDesc => 'Položky vybraných kategorií';

  @override
  String get inventoryTypeBySupplier => 'Dle dodavatele';

  @override
  String get inventoryTypeBySupplierDesc => 'Položky vybraných dodavatelů';

  @override
  String get inventoryTypeByManufacturer => 'Dle výrobce';

  @override
  String get inventoryTypeByManufacturerDesc => 'Položky vybraných výrobců';

  @override
  String get inventoryTypeSelective => 'Selektivní';

  @override
  String get inventoryTypeSelectiveDesc => 'Ruční výběr položek';

  @override
  String get inventoryTypeContinue => 'Pokračovat';

  @override
  String get inventoryTypeNoItems => 'Žádné položky k výběru';
}

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
  String get actionSwitchUser => 'Přepnout obsluhu';

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
  String get prepStatusInPrep => 'Připravuje se';

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
  String get billDetailMove => 'Přesunout';

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
  String get moreRegisterSettings => 'Nastavení pokladny';

  @override
  String get settingsCompanyTitle => 'Nastavení firmy';

  @override
  String get settingsRegisterTitle => 'Nastavení pokladny';

  @override
  String get settingsTabCompany => 'Firma';

  @override
  String get settingsTabRegister => 'Pokladna';

  @override
  String get settingsTabUsers => 'Uživatelé';

  @override
  String get settingsSectionCompanyInfo => 'Informace o firmě';

  @override
  String get settingsSectionSecurity => 'Zabezpečení';

  @override
  String get settingsSectionCloud => 'Cloud';

  @override
  String get settingsSectionGrid => 'Zobrazení mřížky';

  @override
  String get companyFieldVatNumber => 'DIČ';

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
  String get paymentMixPayments => 'Mix plateb';

  @override
  String get paymentOtherPayment => 'Jiná platba';

  @override
  String get paymentPrintReceipt => 'Tisk dokladu';

  @override
  String get paymentPrintYes => 'ANO';

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
  String get changeTotalOriginal => 'Původní částka';

  @override
  String get changeTotalEdited => 'Upravená částka';

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
}

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
  String get infoPanelDate => 'Datum';

  @override
  String get infoPanelStatus => 'Stav pokladny';

  @override
  String get infoPanelStatusOffline => 'Offline';

  @override
  String get infoPanelActiveUser => 'Aktivní obsluha';

  @override
  String get infoPanelLoggedIn => 'Přihlášení';

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
}

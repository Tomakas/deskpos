import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In cs, this message translates to:
  /// **'EPOS'**
  String get appTitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In cs, this message translates to:
  /// **'Vítejte v EPOS'**
  String get onboardingTitle;

  /// No description provided for @onboardingCreateCompany.
  ///
  /// In cs, this message translates to:
  /// **'Založit novou firmu'**
  String get onboardingCreateCompany;

  /// No description provided for @onboardingJoinCompany.
  ///
  /// In cs, this message translates to:
  /// **'Připojit se k firmě'**
  String get onboardingJoinCompany;

  /// No description provided for @onboardingJoinCompanyDisabled.
  ///
  /// In cs, this message translates to:
  /// **'Dostupné od verze 3.0'**
  String get onboardingJoinCompanyDisabled;

  /// No description provided for @wizardStepCompany.
  ///
  /// In cs, this message translates to:
  /// **'Firma'**
  String get wizardStepCompany;

  /// No description provided for @wizardStepAdmin.
  ///
  /// In cs, this message translates to:
  /// **'Administrátor'**
  String get wizardStepAdmin;

  /// No description provided for @wizardCompanyName.
  ///
  /// In cs, this message translates to:
  /// **'Název firmy'**
  String get wizardCompanyName;

  /// No description provided for @wizardCompanyNameRequired.
  ///
  /// In cs, this message translates to:
  /// **'Název firmy je povinný'**
  String get wizardCompanyNameRequired;

  /// No description provided for @wizardBusinessId.
  ///
  /// In cs, this message translates to:
  /// **'IČO'**
  String get wizardBusinessId;

  /// No description provided for @wizardAddress.
  ///
  /// In cs, this message translates to:
  /// **'Adresa'**
  String get wizardAddress;

  /// No description provided for @wizardEmail.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get wizardEmail;

  /// No description provided for @wizardPhone.
  ///
  /// In cs, this message translates to:
  /// **'Telefon'**
  String get wizardPhone;

  /// No description provided for @wizardNext.
  ///
  /// In cs, this message translates to:
  /// **'Pokračovat'**
  String get wizardNext;

  /// No description provided for @wizardBack.
  ///
  /// In cs, this message translates to:
  /// **'Zpět'**
  String get wizardBack;

  /// No description provided for @wizardFinish.
  ///
  /// In cs, this message translates to:
  /// **'Dokončit'**
  String get wizardFinish;

  /// No description provided for @wizardFullName.
  ///
  /// In cs, this message translates to:
  /// **'Celé jméno'**
  String get wizardFullName;

  /// No description provided for @wizardFullNameRequired.
  ///
  /// In cs, this message translates to:
  /// **'Celé jméno je povinné'**
  String get wizardFullNameRequired;

  /// No description provided for @wizardUsername.
  ///
  /// In cs, this message translates to:
  /// **'Uživatelské jméno'**
  String get wizardUsername;

  /// No description provided for @wizardUsernameRequired.
  ///
  /// In cs, this message translates to:
  /// **'Uživatelské jméno je povinné'**
  String get wizardUsernameRequired;

  /// No description provided for @wizardPin.
  ///
  /// In cs, this message translates to:
  /// **'PIN (4–6 číslic)'**
  String get wizardPin;

  /// No description provided for @wizardPinConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Potvrzení PINu'**
  String get wizardPinConfirm;

  /// No description provided for @wizardPinRequired.
  ///
  /// In cs, this message translates to:
  /// **'PIN je povinný'**
  String get wizardPinRequired;

  /// No description provided for @wizardPinLength.
  ///
  /// In cs, this message translates to:
  /// **'PIN musí mít 4–6 číslic'**
  String get wizardPinLength;

  /// No description provided for @wizardPinMismatch.
  ///
  /// In cs, this message translates to:
  /// **'PINy se neshodují'**
  String get wizardPinMismatch;

  /// No description provided for @wizardPinDigitsOnly.
  ///
  /// In cs, this message translates to:
  /// **'PIN smí obsahovat pouze číslice'**
  String get wizardPinDigitsOnly;

  /// No description provided for @loginTitle.
  ///
  /// In cs, this message translates to:
  /// **'Přihlášení'**
  String get loginTitle;

  /// No description provided for @loginPinLabel.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte PIN'**
  String get loginPinLabel;

  /// No description provided for @loginButton.
  ///
  /// In cs, this message translates to:
  /// **'Přihlásit'**
  String get loginButton;

  /// No description provided for @loginFailed.
  ///
  /// In cs, this message translates to:
  /// **'Neplatný PIN'**
  String get loginFailed;

  /// No description provided for @loginLockedOut.
  ///
  /// In cs, this message translates to:
  /// **'Příliš mnoho pokusů. Zkuste znovu za {seconds} s.'**
  String loginLockedOut(int seconds);

  /// No description provided for @billsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Účty'**
  String get billsTitle;

  /// No description provided for @billsEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Žádné účty'**
  String get billsEmpty;

  /// No description provided for @billsFilterOpened.
  ///
  /// In cs, this message translates to:
  /// **'Otevřené'**
  String get billsFilterOpened;

  /// No description provided for @billsFilterPaid.
  ///
  /// In cs, this message translates to:
  /// **'Zaplacené'**
  String get billsFilterPaid;

  /// No description provided for @billsFilterCancelled.
  ///
  /// In cs, this message translates to:
  /// **'Stornované'**
  String get billsFilterCancelled;

  /// No description provided for @billsQuickBill.
  ///
  /// In cs, this message translates to:
  /// **'Rychlý účet'**
  String get billsQuickBill;

  /// No description provided for @billsNewBill.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořit účet'**
  String get billsNewBill;

  /// No description provided for @billsSectionAll.
  ///
  /// In cs, this message translates to:
  /// **'Vše'**
  String get billsSectionAll;

  /// No description provided for @columnTable.
  ///
  /// In cs, this message translates to:
  /// **'Stůl'**
  String get columnTable;

  /// No description provided for @columnGuest.
  ///
  /// In cs, this message translates to:
  /// **'Host'**
  String get columnGuest;

  /// No description provided for @columnGuests.
  ///
  /// In cs, this message translates to:
  /// **'Hostů'**
  String get columnGuests;

  /// No description provided for @columnTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celkem'**
  String get columnTotal;

  /// No description provided for @columnLastOrder.
  ///
  /// In cs, this message translates to:
  /// **'Posl. obj.'**
  String get columnLastOrder;

  /// No description provided for @columnStaff.
  ///
  /// In cs, this message translates to:
  /// **'Obsluha'**
  String get columnStaff;

  /// No description provided for @billTimeJustNow.
  ///
  /// In cs, this message translates to:
  /// **'právě teď'**
  String get billTimeJustNow;

  /// No description provided for @infoPanelDate.
  ///
  /// In cs, this message translates to:
  /// **'Datum'**
  String get infoPanelDate;

  /// No description provided for @infoPanelStatus.
  ///
  /// In cs, this message translates to:
  /// **'Stav pokladny'**
  String get infoPanelStatus;

  /// No description provided for @infoPanelStatusOffline.
  ///
  /// In cs, this message translates to:
  /// **'Offline'**
  String get infoPanelStatusOffline;

  /// No description provided for @infoPanelActiveUser.
  ///
  /// In cs, this message translates to:
  /// **'Aktivní obsluha'**
  String get infoPanelActiveUser;

  /// No description provided for @infoPanelLoggedIn.
  ///
  /// In cs, this message translates to:
  /// **'Další přihlášení'**
  String get infoPanelLoggedIn;

  /// No description provided for @actionSwitchUser.
  ///
  /// In cs, this message translates to:
  /// **'Zamknout / Přepnout'**
  String get actionSwitchUser;

  /// No description provided for @actionLogout.
  ///
  /// In cs, this message translates to:
  /// **'Odhlásit'**
  String get actionLogout;

  /// No description provided for @switchUserTitle.
  ///
  /// In cs, this message translates to:
  /// **'Přepnout obsluhu'**
  String get switchUserTitle;

  /// No description provided for @switchUserSelectUser.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte uživatele'**
  String get switchUserSelectUser;

  /// No description provided for @switchUserEnterPin.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte PIN pro {name}'**
  String switchUserEnterPin(String name);

  /// No description provided for @settingsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení'**
  String get settingsTitle;

  /// No description provided for @settingsUsers.
  ///
  /// In cs, this message translates to:
  /// **'Uživatelé'**
  String get settingsUsers;

  /// No description provided for @settingsSections.
  ///
  /// In cs, this message translates to:
  /// **'Sekce'**
  String get settingsSections;

  /// No description provided for @settingsTables.
  ///
  /// In cs, this message translates to:
  /// **'Stoly'**
  String get settingsTables;

  /// No description provided for @settingsCategories.
  ///
  /// In cs, this message translates to:
  /// **'Kategorie'**
  String get settingsCategories;

  /// No description provided for @settingsProducts.
  ///
  /// In cs, this message translates to:
  /// **'Produkty'**
  String get settingsProducts;

  /// No description provided for @settingsTaxRates.
  ///
  /// In cs, this message translates to:
  /// **'Daň. sazby'**
  String get settingsTaxRates;

  /// No description provided for @settingsPaymentMethods.
  ///
  /// In cs, this message translates to:
  /// **'Plat. metody'**
  String get settingsPaymentMethods;

  /// No description provided for @actionAdd.
  ///
  /// In cs, this message translates to:
  /// **'Přidat'**
  String get actionAdd;

  /// No description provided for @actionEdit.
  ///
  /// In cs, this message translates to:
  /// **'Upravit'**
  String get actionEdit;

  /// No description provided for @actionSave.
  ///
  /// In cs, this message translates to:
  /// **'Uložit'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In cs, this message translates to:
  /// **'Smazat'**
  String get actionDelete;

  /// No description provided for @actionClose.
  ///
  /// In cs, this message translates to:
  /// **'Zavřít'**
  String get actionClose;

  /// No description provided for @actionConfirm.
  ///
  /// In cs, this message translates to:
  /// **'OK'**
  String get actionConfirm;

  /// No description provided for @fieldName.
  ///
  /// In cs, this message translates to:
  /// **'Název'**
  String get fieldName;

  /// No description provided for @fieldUsername.
  ///
  /// In cs, this message translates to:
  /// **'Username'**
  String get fieldUsername;

  /// No description provided for @fieldRole.
  ///
  /// In cs, this message translates to:
  /// **'Role'**
  String get fieldRole;

  /// No description provided for @fieldPin.
  ///
  /// In cs, this message translates to:
  /// **'PIN'**
  String get fieldPin;

  /// No description provided for @fieldActive.
  ///
  /// In cs, this message translates to:
  /// **'Aktivní'**
  String get fieldActive;

  /// No description provided for @fieldActions.
  ///
  /// In cs, this message translates to:
  /// **'Akce'**
  String get fieldActions;

  /// No description provided for @fieldSection.
  ///
  /// In cs, this message translates to:
  /// **'Sekce'**
  String get fieldSection;

  /// No description provided for @fieldCapacity.
  ///
  /// In cs, this message translates to:
  /// **'Kapacita'**
  String get fieldCapacity;

  /// No description provided for @fieldColor.
  ///
  /// In cs, this message translates to:
  /// **'Barva'**
  String get fieldColor;

  /// No description provided for @fieldCategory.
  ///
  /// In cs, this message translates to:
  /// **'Kategorie'**
  String get fieldCategory;

  /// No description provided for @fieldPrice.
  ///
  /// In cs, this message translates to:
  /// **'Prodejní cena'**
  String get fieldPrice;

  /// No description provided for @fieldTaxRate.
  ///
  /// In cs, this message translates to:
  /// **'Prodejní daň'**
  String get fieldTaxRate;

  /// No description provided for @fieldType.
  ///
  /// In cs, this message translates to:
  /// **'Typ'**
  String get fieldType;

  /// No description provided for @fieldRate.
  ///
  /// In cs, this message translates to:
  /// **'Sazba (%)'**
  String get fieldRate;

  /// No description provided for @fieldDefault.
  ///
  /// In cs, this message translates to:
  /// **'Výchozí'**
  String get fieldDefault;

  /// No description provided for @roleHelper.
  ///
  /// In cs, this message translates to:
  /// **'Pomocník'**
  String get roleHelper;

  /// No description provided for @roleOperator.
  ///
  /// In cs, this message translates to:
  /// **'Obsluha'**
  String get roleOperator;

  /// No description provided for @roleManager.
  ///
  /// In cs, this message translates to:
  /// **'Manažer'**
  String get roleManager;

  /// No description provided for @roleAdmin.
  ///
  /// In cs, this message translates to:
  /// **'Administrátor'**
  String get roleAdmin;

  /// No description provided for @paymentTypeCash.
  ///
  /// In cs, this message translates to:
  /// **'Hotovost'**
  String get paymentTypeCash;

  /// No description provided for @paymentTypeCard.
  ///
  /// In cs, this message translates to:
  /// **'Karta'**
  String get paymentTypeCard;

  /// No description provided for @paymentTypeBank.
  ///
  /// In cs, this message translates to:
  /// **'Převod'**
  String get paymentTypeBank;

  /// No description provided for @paymentTypeOther.
  ///
  /// In cs, this message translates to:
  /// **'Ostatní'**
  String get paymentTypeOther;

  /// No description provided for @taxTypeRegular.
  ///
  /// In cs, this message translates to:
  /// **'Běžná'**
  String get taxTypeRegular;

  /// No description provided for @taxTypeNoTax.
  ///
  /// In cs, this message translates to:
  /// **'Bez DPH'**
  String get taxTypeNoTax;

  /// No description provided for @taxTypeConstant.
  ///
  /// In cs, this message translates to:
  /// **'Konstantní'**
  String get taxTypeConstant;

  /// No description provided for @taxTypeMixed.
  ///
  /// In cs, this message translates to:
  /// **'Smíšená'**
  String get taxTypeMixed;

  /// No description provided for @confirmDelete.
  ///
  /// In cs, this message translates to:
  /// **'Opravdu chcete smazat tuto položku?'**
  String get confirmDelete;

  /// No description provided for @sellRemoveFromCart.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat tuto položku z košíku?'**
  String get sellRemoveFromCart;

  /// No description provided for @yes.
  ///
  /// In cs, this message translates to:
  /// **'Ano'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In cs, this message translates to:
  /// **'Ne'**
  String get no;

  /// No description provided for @noPermission.
  ///
  /// In cs, this message translates to:
  /// **'Nemáte oprávnění pro tuto akci'**
  String get noPermission;

  /// No description provided for @newBillTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nový účet'**
  String get newBillTitle;

  /// No description provided for @newBillSelectTable.
  ///
  /// In cs, this message translates to:
  /// **'Stůl (volitelný)'**
  String get newBillSelectTable;

  /// No description provided for @newBillGuests.
  ///
  /// In cs, this message translates to:
  /// **'Počet hostů'**
  String get newBillGuests;

  /// No description provided for @newBillCreate.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořit'**
  String get newBillCreate;

  /// No description provided for @billDetailTitle.
  ///
  /// In cs, this message translates to:
  /// **'Detail účtu'**
  String get billDetailTitle;

  /// No description provided for @billDetailTable.
  ///
  /// In cs, this message translates to:
  /// **'Stůl: {name}'**
  String billDetailTable(String name);

  /// No description provided for @billDetailTakeaway.
  ///
  /// In cs, this message translates to:
  /// **'Jídlo s sebou'**
  String get billDetailTakeaway;

  /// No description provided for @billDetailNoTable.
  ///
  /// In cs, this message translates to:
  /// **'Bez stolu'**
  String get billDetailNoTable;

  /// No description provided for @billDetailCreated.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořen: {time}'**
  String billDetailCreated(String time);

  /// No description provided for @billDetailLastOrder.
  ///
  /// In cs, this message translates to:
  /// **'Posl. obj.: {time}'**
  String billDetailLastOrder(String time);

  /// No description provided for @billDetailNoOrders.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné objednávky'**
  String get billDetailNoOrders;

  /// No description provided for @billDetailOrder.
  ///
  /// In cs, this message translates to:
  /// **'Objednat'**
  String get billDetailOrder;

  /// No description provided for @billDetailPay.
  ///
  /// In cs, this message translates to:
  /// **'Zaplatit'**
  String get billDetailPay;

  /// No description provided for @billDetailCancel.
  ///
  /// In cs, this message translates to:
  /// **'Storno účtu'**
  String get billDetailCancel;

  /// No description provided for @billDetailConfirmCancel.
  ///
  /// In cs, this message translates to:
  /// **'Opravdu chcete stornovat tento účet?'**
  String get billDetailConfirmCancel;

  /// No description provided for @billDetailBillNumber.
  ///
  /// In cs, this message translates to:
  /// **'Účet {number}'**
  String billDetailBillNumber(String number);

  /// No description provided for @billStatusOpened.
  ///
  /// In cs, this message translates to:
  /// **'Otevřený'**
  String get billStatusOpened;

  /// No description provided for @billStatusPaid.
  ///
  /// In cs, this message translates to:
  /// **'Zaplacený'**
  String get billStatusPaid;

  /// No description provided for @billStatusCancelled.
  ///
  /// In cs, this message translates to:
  /// **'Stornovaný'**
  String get billStatusCancelled;

  /// No description provided for @sellTitle.
  ///
  /// In cs, this message translates to:
  /// **'Prodej'**
  String get sellTitle;

  /// No description provided for @sellCart.
  ///
  /// In cs, this message translates to:
  /// **'Košík'**
  String get sellCart;

  /// No description provided for @sellCartEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Košík je prázdný'**
  String get sellCartEmpty;

  /// No description provided for @sellTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celkem'**
  String get sellTotal;

  /// No description provided for @sellCancelOrder.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get sellCancelOrder;

  /// No description provided for @sellClearCart.
  ///
  /// In cs, this message translates to:
  /// **'Vymazat košík'**
  String get sellClearCart;

  /// No description provided for @sellSaveToBill.
  ///
  /// In cs, this message translates to:
  /// **'Uložit'**
  String get sellSaveToBill;

  /// No description provided for @sellSubmitOrder.
  ///
  /// In cs, this message translates to:
  /// **'Objednat'**
  String get sellSubmitOrder;

  /// No description provided for @sellSearch.
  ///
  /// In cs, this message translates to:
  /// **'Vyhledat'**
  String get sellSearch;

  /// No description provided for @sellEditGrid.
  ///
  /// In cs, this message translates to:
  /// **'Upravit grid'**
  String get sellEditGrid;

  /// No description provided for @sellExitEdit.
  ///
  /// In cs, this message translates to:
  /// **'Ukončit úpravy'**
  String get sellExitEdit;

  /// No description provided for @sellEmptySlot.
  ///
  /// In cs, this message translates to:
  /// **'Prázdné'**
  String get sellEmptySlot;

  /// No description provided for @sellBackToCategories.
  ///
  /// In cs, this message translates to:
  /// **'Zpět'**
  String get sellBackToCategories;

  /// No description provided for @sellQuantity.
  ///
  /// In cs, this message translates to:
  /// **'{count}×'**
  String sellQuantity(String count);

  /// No description provided for @prepStatusCreated.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořeno'**
  String get prepStatusCreated;

  /// No description provided for @prepStatusReady.
  ///
  /// In cs, this message translates to:
  /// **'Připraveno'**
  String get prepStatusReady;

  /// No description provided for @prepStatusDelivered.
  ///
  /// In cs, this message translates to:
  /// **'Doručeno'**
  String get prepStatusDelivered;

  /// No description provided for @prepStatusCancelled.
  ///
  /// In cs, this message translates to:
  /// **'Zrušeno'**
  String get prepStatusCancelled;

  /// No description provided for @prepStatusVoided.
  ///
  /// In cs, this message translates to:
  /// **'Stornováno'**
  String get prepStatusVoided;

  /// No description provided for @orderStatusChange.
  ///
  /// In cs, this message translates to:
  /// **'Změnit stav'**
  String get orderStatusChange;

  /// No description provided for @orderCancel.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit objednávku'**
  String get orderCancel;

  /// No description provided for @orderVoid.
  ///
  /// In cs, this message translates to:
  /// **'Stornovat objednávku'**
  String get orderVoid;

  /// No description provided for @orderConfirmCancel.
  ///
  /// In cs, this message translates to:
  /// **'Opravdu chcete zrušit tuto objednávku?'**
  String get orderConfirmCancel;

  /// No description provided for @orderConfirmVoid.
  ///
  /// In cs, this message translates to:
  /// **'Opravdu chcete stornovat tuto objednávku?'**
  String get orderConfirmVoid;

  /// No description provided for @paymentTitle.
  ///
  /// In cs, this message translates to:
  /// **'Platba'**
  String get paymentTitle;

  /// No description provided for @paymentMethod.
  ///
  /// In cs, this message translates to:
  /// **'Platební metoda'**
  String get paymentMethod;

  /// No description provided for @paymentAmount.
  ///
  /// In cs, this message translates to:
  /// **'Částka'**
  String get paymentAmount;

  /// No description provided for @paymentTotalDue.
  ///
  /// In cs, this message translates to:
  /// **'K úhradě: {amount}'**
  String paymentTotalDue(String amount);

  /// No description provided for @paymentConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Zaplatit'**
  String get paymentConfirm;

  /// No description provided for @gridEditorTitle.
  ///
  /// In cs, this message translates to:
  /// **'Editor gridu'**
  String get gridEditorTitle;

  /// No description provided for @gridEditorSelectType.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte typ'**
  String get gridEditorSelectType;

  /// No description provided for @gridEditorItem.
  ///
  /// In cs, this message translates to:
  /// **'Produkt'**
  String get gridEditorItem;

  /// No description provided for @gridEditorCategory.
  ///
  /// In cs, this message translates to:
  /// **'Kategorie'**
  String get gridEditorCategory;

  /// No description provided for @gridEditorClear.
  ///
  /// In cs, this message translates to:
  /// **'Vymazat'**
  String get gridEditorClear;

  /// No description provided for @gridEditorSelectItem.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte produkt'**
  String get gridEditorSelectItem;

  /// No description provided for @gridEditorSelectCategory.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte kategorii'**
  String get gridEditorSelectCategory;

  /// No description provided for @registerSessionStart.
  ///
  /// In cs, this message translates to:
  /// **'Zahájit prodej'**
  String get registerSessionStart;

  /// No description provided for @registerSessionClose.
  ///
  /// In cs, this message translates to:
  /// **'Uzávěrka'**
  String get registerSessionClose;

  /// No description provided for @registerSessionNoSession.
  ///
  /// In cs, this message translates to:
  /// **'Žádná aktivní směna'**
  String get registerSessionNoSession;

  /// No description provided for @registerSessionConfirmClose.
  ///
  /// In cs, this message translates to:
  /// **'Opravdu chcete uzavřít směnu?'**
  String get registerSessionConfirmClose;

  /// No description provided for @registerSessionRequired.
  ///
  /// In cs, this message translates to:
  /// **'Pro prodej musíte nejdříve zahájit směnu'**
  String get registerSessionRequired;

  /// No description provided for @registerSessionActive.
  ///
  /// In cs, this message translates to:
  /// **'Směna aktivní'**
  String get registerSessionActive;

  /// No description provided for @billsSorting.
  ///
  /// In cs, this message translates to:
  /// **'Řazení'**
  String get billsSorting;

  /// No description provided for @sortByTable.
  ///
  /// In cs, this message translates to:
  /// **'Stůl'**
  String get sortByTable;

  /// No description provided for @sortByTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celkem'**
  String get sortByTotal;

  /// No description provided for @sortByLastOrder.
  ///
  /// In cs, this message translates to:
  /// **'Posl. objednávka'**
  String get sortByLastOrder;

  /// No description provided for @billsCashJournal.
  ///
  /// In cs, this message translates to:
  /// **'Pokladní deník'**
  String get billsCashJournal;

  /// No description provided for @billsSalesOverview.
  ///
  /// In cs, this message translates to:
  /// **'Přehled prodeje'**
  String get billsSalesOverview;

  /// No description provided for @billsInventory.
  ///
  /// In cs, this message translates to:
  /// **'Sklad'**
  String get billsInventory;

  /// No description provided for @billsMore.
  ///
  /// In cs, this message translates to:
  /// **'Další'**
  String get billsMore;

  /// No description provided for @billsTableMap.
  ///
  /// In cs, this message translates to:
  /// **'Mapa'**
  String get billsTableMap;

  /// No description provided for @infoPanelRegisterTotal.
  ///
  /// In cs, this message translates to:
  /// **'Pokladna'**
  String get infoPanelRegisterTotal;

  /// No description provided for @infoPanelRevenue.
  ///
  /// In cs, this message translates to:
  /// **'Tržba'**
  String get infoPanelRevenue;

  /// No description provided for @infoPanelSalesCount.
  ///
  /// In cs, this message translates to:
  /// **'Počet prodejů'**
  String get infoPanelSalesCount;

  /// No description provided for @sellCartSummary.
  ///
  /// In cs, this message translates to:
  /// **'Souhrn položek'**
  String get sellCartSummary;

  /// No description provided for @sellScan.
  ///
  /// In cs, this message translates to:
  /// **'Skenovat'**
  String get sellScan;

  /// No description provided for @sellCustomer.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník'**
  String get sellCustomer;

  /// No description provided for @sellNote.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka'**
  String get sellNote;

  /// No description provided for @sellActions.
  ///
  /// In cs, this message translates to:
  /// **'Akce'**
  String get sellActions;

  /// No description provided for @billDetailCustomer.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník'**
  String get billDetailCustomer;

  /// No description provided for @billDetailMove.
  ///
  /// In cs, this message translates to:
  /// **'Stůl'**
  String get billDetailMove;

  /// No description provided for @billDetailMoveTitle.
  ///
  /// In cs, this message translates to:
  /// **'Přesunout účet'**
  String get billDetailMoveTitle;

  /// No description provided for @billDetailMerge.
  ///
  /// In cs, this message translates to:
  /// **'Sloučit'**
  String get billDetailMerge;

  /// No description provided for @billDetailSplit.
  ///
  /// In cs, this message translates to:
  /// **'Rozdělit'**
  String get billDetailSplit;

  /// No description provided for @billDetailSummary.
  ///
  /// In cs, this message translates to:
  /// **'Sumář'**
  String get billDetailSummary;

  /// No description provided for @billDetailItemList.
  ///
  /// In cs, this message translates to:
  /// **'Historie'**
  String get billDetailItemList;

  /// No description provided for @billDetailPrint.
  ///
  /// In cs, this message translates to:
  /// **'Tisk'**
  String get billDetailPrint;

  /// No description provided for @billDetailOrderHistory.
  ///
  /// In cs, this message translates to:
  /// **'Historie objednávek'**
  String get billDetailOrderHistory;

  /// No description provided for @billDetailTotalSpent.
  ///
  /// In cs, this message translates to:
  /// **'Celková útrata: {amount}'**
  String billDetailTotalSpent(String amount);

  /// No description provided for @billDetailCreatedAt.
  ///
  /// In cs, this message translates to:
  /// **'Účet vytvořen: {date}'**
  String billDetailCreatedAt(String date);

  /// No description provided for @billDetailLastOrderAt.
  ///
  /// In cs, this message translates to:
  /// **'Poslední objednávka: {date}'**
  String billDetailLastOrderAt(String date);

  /// No description provided for @billDetailNoOrderYet.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádná objednávka'**
  String get billDetailNoOrderYet;

  /// No description provided for @billDetailCustomerName.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník: {name}'**
  String billDetailCustomerName(String name);

  /// No description provided for @billDetailNoCustomer.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník nepřiřazen'**
  String get billDetailNoCustomer;

  /// No description provided for @itemTypeProduct.
  ///
  /// In cs, this message translates to:
  /// **'Produkt'**
  String get itemTypeProduct;

  /// No description provided for @itemTypeService.
  ///
  /// In cs, this message translates to:
  /// **'Služba'**
  String get itemTypeService;

  /// No description provided for @itemTypeCounter.
  ///
  /// In cs, this message translates to:
  /// **'Počítadlo'**
  String get itemTypeCounter;

  /// No description provided for @itemTypeRecipe.
  ///
  /// In cs, this message translates to:
  /// **'Receptura'**
  String get itemTypeRecipe;

  /// No description provided for @itemTypeIngredient.
  ///
  /// In cs, this message translates to:
  /// **'Ingredience'**
  String get itemTypeIngredient;

  /// No description provided for @itemTypeVariant.
  ///
  /// In cs, this message translates to:
  /// **'Varianta'**
  String get itemTypeVariant;

  /// No description provided for @itemTypeModifier.
  ///
  /// In cs, this message translates to:
  /// **'Modifikátor'**
  String get itemTypeModifier;

  /// No description provided for @moreReports.
  ///
  /// In cs, this message translates to:
  /// **'Reporty'**
  String get moreReports;

  /// No description provided for @moreStatistics.
  ///
  /// In cs, this message translates to:
  /// **'Statistiky'**
  String get moreStatistics;

  /// No description provided for @moreReservations.
  ///
  /// In cs, this message translates to:
  /// **'Rezervace'**
  String get moreReservations;

  /// No description provided for @moreSettings.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení'**
  String get moreSettings;

  /// No description provided for @moreCompanySettings.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení firmy'**
  String get moreCompanySettings;

  /// No description provided for @moreVenueSettings.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení provozovny'**
  String get moreVenueSettings;

  /// No description provided for @moreRegisterSettings.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení pokladny'**
  String get moreRegisterSettings;

  /// No description provided for @settingsCompanyTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení firmy'**
  String get settingsCompanyTitle;

  /// No description provided for @settingsVenueTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení provozovny'**
  String get settingsVenueTitle;

  /// No description provided for @settingsRegisterTitle.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení pokladny'**
  String get settingsRegisterTitle;

  /// No description provided for @settingsTabCompany.
  ///
  /// In cs, this message translates to:
  /// **'Firma'**
  String get settingsTabCompany;

  /// No description provided for @settingsTabRegister.
  ///
  /// In cs, this message translates to:
  /// **'Pokladna'**
  String get settingsTabRegister;

  /// No description provided for @settingsTabUsers.
  ///
  /// In cs, this message translates to:
  /// **'Uživatelé'**
  String get settingsTabUsers;

  /// No description provided for @settingsTabLog.
  ///
  /// In cs, this message translates to:
  /// **'Log'**
  String get settingsTabLog;

  /// No description provided for @settingsSectionCompanyInfo.
  ///
  /// In cs, this message translates to:
  /// **'Informace o firmě'**
  String get settingsSectionCompanyInfo;

  /// No description provided for @settingsSectionSecurity.
  ///
  /// In cs, this message translates to:
  /// **'Zabezpečení'**
  String get settingsSectionSecurity;

  /// No description provided for @settingsSectionCloud.
  ///
  /// In cs, this message translates to:
  /// **'Cloud'**
  String get settingsSectionCloud;

  /// No description provided for @settingsSectionSellOptions.
  ///
  /// In cs, this message translates to:
  /// **'Volby prodeje'**
  String get settingsSectionSellOptions;

  /// No description provided for @settingsSellMode.
  ///
  /// In cs, this message translates to:
  /// **'Režim prodeje'**
  String get settingsSellMode;

  /// No description provided for @sellModeGastro.
  ///
  /// In cs, this message translates to:
  /// **'Gastro'**
  String get sellModeGastro;

  /// No description provided for @sellModeRetail.
  ///
  /// In cs, this message translates to:
  /// **'Retail'**
  String get sellModeRetail;

  /// No description provided for @settingsSectionGrid.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazení mřížky'**
  String get settingsSectionGrid;

  /// No description provided for @companyFieldVatNumber.
  ///
  /// In cs, this message translates to:
  /// **'DIČ'**
  String get companyFieldVatNumber;

  /// No description provided for @settingsLanguage.
  ///
  /// In cs, this message translates to:
  /// **'Jazyk aplikace'**
  String get settingsLanguage;

  /// No description provided for @settingsCurrency.
  ///
  /// In cs, this message translates to:
  /// **'Výchozí měna'**
  String get settingsCurrency;

  /// No description provided for @languageCzech.
  ///
  /// In cs, this message translates to:
  /// **'Čeština'**
  String get languageCzech;

  /// No description provided for @languageEnglish.
  ///
  /// In cs, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @cloudTitle.
  ///
  /// In cs, this message translates to:
  /// **'Cloudová synchronizace'**
  String get cloudTitle;

  /// No description provided for @cloudEmail.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get cloudEmail;

  /// No description provided for @cloudPassword.
  ///
  /// In cs, this message translates to:
  /// **'Heslo'**
  String get cloudPassword;

  /// No description provided for @cloudSignUp.
  ///
  /// In cs, this message translates to:
  /// **'Registrovat'**
  String get cloudSignUp;

  /// No description provided for @cloudSignIn.
  ///
  /// In cs, this message translates to:
  /// **'Přihlásit'**
  String get cloudSignIn;

  /// No description provided for @cloudSignOut.
  ///
  /// In cs, this message translates to:
  /// **'Odpojit'**
  String get cloudSignOut;

  /// No description provided for @cloudConnected.
  ///
  /// In cs, this message translates to:
  /// **'Připojeno'**
  String get cloudConnected;

  /// No description provided for @cloudDisconnected.
  ///
  /// In cs, this message translates to:
  /// **'Nepřipojeno'**
  String get cloudDisconnected;

  /// No description provided for @cloudEmailRequired.
  ///
  /// In cs, this message translates to:
  /// **'E-mail je povinný'**
  String get cloudEmailRequired;

  /// No description provided for @cloudPasswordRequired.
  ///
  /// In cs, this message translates to:
  /// **'Heslo je povinné'**
  String get cloudPasswordRequired;

  /// No description provided for @cloudPasswordLength.
  ///
  /// In cs, this message translates to:
  /// **'Heslo musí mít alespoň 6 znaků'**
  String get cloudPasswordLength;

  /// No description provided for @cloudDiagnostics.
  ///
  /// In cs, this message translates to:
  /// **'Diagnostika'**
  String get cloudDiagnostics;

  /// No description provided for @cloudExportLogs.
  ///
  /// In cs, this message translates to:
  /// **'Exportovat logy'**
  String get cloudExportLogs;

  /// No description provided for @cloudExportLogsDescription.
  ///
  /// In cs, this message translates to:
  /// **'Otevře soubor s logy aplikace pro řešení problémů.'**
  String get cloudExportLogsDescription;

  /// No description provided for @cloudDangerZone.
  ///
  /// In cs, this message translates to:
  /// **'Nebezpečná zóna'**
  String get cloudDangerZone;

  /// No description provided for @cloudDeleteLocalData.
  ///
  /// In cs, this message translates to:
  /// **'Smazat lokální data'**
  String get cloudDeleteLocalData;

  /// No description provided for @cloudDeleteLocalDataDescription.
  ///
  /// In cs, this message translates to:
  /// **'Smaže data z tohoto zařízení. Data na serveru zůstanou zachována a po přihlášení se znovu stáhnou.'**
  String get cloudDeleteLocalDataDescription;

  /// No description provided for @cloudDeleteLocalDataConfirmTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat lokální data?'**
  String get cloudDeleteLocalDataConfirmTitle;

  /// No description provided for @cloudDeleteLocalDataConfirmMessage.
  ///
  /// In cs, this message translates to:
  /// **'Všechna lokální data budou smazána a aplikace se vrátí na úvodní obrazovku. Data na serveru zůstanou zachována.'**
  String get cloudDeleteLocalDataConfirmMessage;

  /// No description provided for @cloudDeleteLocalDataConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Smazat'**
  String get cloudDeleteLocalDataConfirm;

  /// No description provided for @cloudDeleteAllData.
  ///
  /// In cs, this message translates to:
  /// **'Smazat vše'**
  String get cloudDeleteAllData;

  /// No description provided for @cloudDeleteAllDataDescription.
  ///
  /// In cs, this message translates to:
  /// **'Smaže všechna data z tohoto zařízení i ze serveru. Tato akce je nevratná.'**
  String get cloudDeleteAllDataDescription;

  /// No description provided for @cloudDeleteAllDataConfirmTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat všechna data?'**
  String get cloudDeleteAllDataConfirmTitle;

  /// No description provided for @cloudDeleteAllDataConfirmMessage.
  ///
  /// In cs, this message translates to:
  /// **'Všechna data budou nenávratně smazána z tohoto zařízení i ze serveru. Aplikace se vrátí na úvodní obrazovku.'**
  String get cloudDeleteAllDataConfirmMessage;

  /// No description provided for @cloudDeleteAllDataConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Smazat vše'**
  String get cloudDeleteAllDataConfirm;

  /// No description provided for @infoPanelSync.
  ///
  /// In cs, this message translates to:
  /// **'Synchronizace'**
  String get infoPanelSync;

  /// No description provided for @infoPanelSyncConnected.
  ///
  /// In cs, this message translates to:
  /// **'Připojeno'**
  String get infoPanelSyncConnected;

  /// No description provided for @infoPanelSyncDisconnected.
  ///
  /// In cs, this message translates to:
  /// **'Nepřipojeno'**
  String get infoPanelSyncDisconnected;

  /// No description provided for @connectCompanyTitle.
  ///
  /// In cs, this message translates to:
  /// **'Připojit se k firmě'**
  String get connectCompanyTitle;

  /// No description provided for @connectCompanySubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Přihlaste se pomocí administrátorského účtu'**
  String get connectCompanySubtitle;

  /// No description provided for @connectCompanySearching.
  ///
  /// In cs, this message translates to:
  /// **'Hledání firmy...'**
  String get connectCompanySearching;

  /// No description provided for @connectCompanyFound.
  ///
  /// In cs, this message translates to:
  /// **'Nalezená firma'**
  String get connectCompanyFound;

  /// No description provided for @connectCompanyNotFound.
  ///
  /// In cs, this message translates to:
  /// **'Žádná firma nenalezena pro tento účet'**
  String get connectCompanyNotFound;

  /// No description provided for @connectCompanyConnect.
  ///
  /// In cs, this message translates to:
  /// **'Připojit'**
  String get connectCompanyConnect;

  /// No description provided for @connectCompanySyncing.
  ///
  /// In cs, this message translates to:
  /// **'Synchronizace dat...'**
  String get connectCompanySyncing;

  /// No description provided for @connectCompanySyncComplete.
  ///
  /// In cs, this message translates to:
  /// **'Synchronizace dokončena'**
  String get connectCompanySyncComplete;

  /// No description provided for @connectCompanySyncFailed.
  ///
  /// In cs, this message translates to:
  /// **'Synchronizace selhala'**
  String get connectCompanySyncFailed;

  /// No description provided for @cashJournalTitle.
  ///
  /// In cs, this message translates to:
  /// **'Pokladní deník'**
  String get cashJournalTitle;

  /// No description provided for @cashJournalBalance.
  ///
  /// In cs, this message translates to:
  /// **'Hotovost v pokladně:'**
  String get cashJournalBalance;

  /// No description provided for @cashJournalFilterDeposits.
  ///
  /// In cs, this message translates to:
  /// **'Vklady'**
  String get cashJournalFilterDeposits;

  /// No description provided for @cashJournalFilterWithdrawals.
  ///
  /// In cs, this message translates to:
  /// **'Výběry'**
  String get cashJournalFilterWithdrawals;

  /// No description provided for @cashJournalFilterSales.
  ///
  /// In cs, this message translates to:
  /// **'Prodeje'**
  String get cashJournalFilterSales;

  /// No description provided for @cashJournalAddMovement.
  ///
  /// In cs, this message translates to:
  /// **'Zapsat změnu'**
  String get cashJournalAddMovement;

  /// No description provided for @cashJournalColumnTime.
  ///
  /// In cs, this message translates to:
  /// **'Čas'**
  String get cashJournalColumnTime;

  /// No description provided for @cashJournalColumnType.
  ///
  /// In cs, this message translates to:
  /// **'Typ'**
  String get cashJournalColumnType;

  /// No description provided for @cashJournalColumnAmount.
  ///
  /// In cs, this message translates to:
  /// **'Částka'**
  String get cashJournalColumnAmount;

  /// No description provided for @cashJournalColumnNote.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka'**
  String get cashJournalColumnNote;

  /// No description provided for @cashJournalEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Žádné záznamy'**
  String get cashJournalEmpty;

  /// No description provided for @cashMovementTitle.
  ///
  /// In cs, this message translates to:
  /// **'Změna stavu hotovosti'**
  String get cashMovementTitle;

  /// No description provided for @cashMovementAmount.
  ///
  /// In cs, this message translates to:
  /// **'Částka:'**
  String get cashMovementAmount;

  /// No description provided for @cashMovementDeposit.
  ///
  /// In cs, this message translates to:
  /// **'Vklad'**
  String get cashMovementDeposit;

  /// No description provided for @cashMovementWithdrawal.
  ///
  /// In cs, this message translates to:
  /// **'Výběr'**
  String get cashMovementWithdrawal;

  /// No description provided for @cashMovementSale.
  ///
  /// In cs, this message translates to:
  /// **'Prodej'**
  String get cashMovementSale;

  /// No description provided for @cashMovementNote.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka'**
  String get cashMovementNote;

  /// No description provided for @cashMovementNoteTitle.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka ke změně hotovosti'**
  String get cashMovementNoteTitle;

  /// No description provided for @cashMovementNoteHint.
  ///
  /// In cs, this message translates to:
  /// **'Důvod pohybu...'**
  String get cashMovementNoteHint;

  /// No description provided for @openingCashTitle.
  ///
  /// In cs, this message translates to:
  /// **'Počáteční hotovost'**
  String get openingCashTitle;

  /// No description provided for @openingCashSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte stav hotovosti v pokladně před zahájením prodeje.'**
  String get openingCashSubtitle;

  /// No description provided for @openingCashConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Potvrdit'**
  String get openingCashConfirm;

  /// No description provided for @closingTitle.
  ///
  /// In cs, this message translates to:
  /// **'Uzávěrka'**
  String get closingTitle;

  /// No description provided for @closingSessionTitle.
  ///
  /// In cs, this message translates to:
  /// **'Přehled směny'**
  String get closingSessionTitle;

  /// No description provided for @closingOpenedAt.
  ///
  /// In cs, this message translates to:
  /// **'Začátek'**
  String get closingOpenedAt;

  /// No description provided for @closingOpenedBy.
  ///
  /// In cs, this message translates to:
  /// **'Otevřel'**
  String get closingOpenedBy;

  /// No description provided for @closingDuration.
  ///
  /// In cs, this message translates to:
  /// **'Trvání'**
  String get closingDuration;

  /// No description provided for @closingBillsPaid.
  ///
  /// In cs, this message translates to:
  /// **'Zaplacené účty'**
  String get closingBillsPaid;

  /// No description provided for @closingBillsCancelled.
  ///
  /// In cs, this message translates to:
  /// **'Stornované účty'**
  String get closingBillsCancelled;

  /// No description provided for @closingRevenueTitle.
  ///
  /// In cs, this message translates to:
  /// **'Tržba dle plateb'**
  String get closingRevenueTitle;

  /// No description provided for @closingRevenueTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celkem'**
  String get closingRevenueTotal;

  /// No description provided for @closingTips.
  ///
  /// In cs, this message translates to:
  /// **'Spropitné'**
  String get closingTips;

  /// No description provided for @closingCashTitle.
  ///
  /// In cs, this message translates to:
  /// **'Stav hotovosti'**
  String get closingCashTitle;

  /// No description provided for @closingOpeningCash.
  ///
  /// In cs, this message translates to:
  /// **'Počáteční hotovost'**
  String get closingOpeningCash;

  /// No description provided for @closingCashRevenue.
  ///
  /// In cs, this message translates to:
  /// **'Tržba hotovost'**
  String get closingCashRevenue;

  /// No description provided for @closingDeposits.
  ///
  /// In cs, this message translates to:
  /// **'Vklady'**
  String get closingDeposits;

  /// No description provided for @closingWithdrawals.
  ///
  /// In cs, this message translates to:
  /// **'Výběry'**
  String get closingWithdrawals;

  /// No description provided for @closingExpectedCash.
  ///
  /// In cs, this message translates to:
  /// **'Očekávaná hotovost'**
  String get closingExpectedCash;

  /// No description provided for @closingActualCash.
  ///
  /// In cs, this message translates to:
  /// **'Skutečný stav hotovosti'**
  String get closingActualCash;

  /// No description provided for @closingDifference.
  ///
  /// In cs, this message translates to:
  /// **'Rozdíl'**
  String get closingDifference;

  /// No description provided for @closingPrint.
  ///
  /// In cs, this message translates to:
  /// **'Tisk'**
  String get closingPrint;

  /// No description provided for @closingConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Uzavřít směnu'**
  String get closingConfirm;

  /// No description provided for @closingNoteTitle.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka k uzávěrce'**
  String get closingNoteTitle;

  /// No description provided for @closingNoteHint.
  ///
  /// In cs, this message translates to:
  /// **'Poznámky k uzávěrce...'**
  String get closingNoteHint;

  /// No description provided for @paymentOtherCurrency.
  ///
  /// In cs, this message translates to:
  /// **'Jiná měna'**
  String get paymentOtherCurrency;

  /// No description provided for @paymentEet.
  ///
  /// In cs, this message translates to:
  /// **'EET'**
  String get paymentEet;

  /// No description provided for @paymentEditAmount.
  ///
  /// In cs, this message translates to:
  /// **'Upravit částku'**
  String get paymentEditAmount;

  /// No description provided for @paymentMoreActions.
  ///
  /// In cs, this message translates to:
  /// **'Další akce'**
  String get paymentMoreActions;

  /// No description provided for @paymentMixPayments.
  ///
  /// In cs, this message translates to:
  /// **'Mix plateb'**
  String get paymentMixPayments;

  /// No description provided for @paymentOtherPayment.
  ///
  /// In cs, this message translates to:
  /// **'Jiná platba'**
  String get paymentOtherPayment;

  /// No description provided for @paymentPrintReceipt.
  ///
  /// In cs, this message translates to:
  /// **'Tisk dokladu'**
  String get paymentPrintReceipt;

  /// No description provided for @paymentPrintYes.
  ///
  /// In cs, this message translates to:
  /// **'ANO'**
  String get paymentPrintYes;

  /// No description provided for @paymentPrintNo.
  ///
  /// In cs, this message translates to:
  /// **'NE'**
  String get paymentPrintNo;

  /// No description provided for @paymentTip.
  ///
  /// In cs, this message translates to:
  /// **'+{amount} spropitné'**
  String paymentTip(String amount);

  /// No description provided for @paymentRemaining.
  ///
  /// In cs, this message translates to:
  /// **'Zbývá {amount}'**
  String paymentRemaining(String amount);

  /// No description provided for @paymentBillSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Účet {billNumber} - {tableName}'**
  String paymentBillSubtitle(String billNumber, String tableName);

  /// No description provided for @billDetailDiscount.
  ///
  /// In cs, this message translates to:
  /// **'Sleva'**
  String get billDetailDiscount;

  /// No description provided for @billDetailRemoveDiscount.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit slevu'**
  String get billDetailRemoveDiscount;

  /// No description provided for @billDetailRemoveDiscountConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat slevu z tohoto účtu?'**
  String get billDetailRemoveDiscountConfirm;

  /// No description provided for @billStatusRefunded.
  ///
  /// In cs, this message translates to:
  /// **'Refundovaný'**
  String get billStatusRefunded;

  /// No description provided for @refundTitle.
  ///
  /// In cs, this message translates to:
  /// **'Refund'**
  String get refundTitle;

  /// No description provided for @refundConfirmFull.
  ///
  /// In cs, this message translates to:
  /// **'Opravdu chcete refundovat celý účet?'**
  String get refundConfirmFull;

  /// No description provided for @refundConfirmItem.
  ///
  /// In cs, this message translates to:
  /// **'Opravdu chcete refundovat tuto položku?'**
  String get refundConfirmItem;

  /// No description provided for @refundButton.
  ///
  /// In cs, this message translates to:
  /// **'REFUND'**
  String get refundButton;

  /// No description provided for @refundFullBill.
  ///
  /// In cs, this message translates to:
  /// **'Celý účet'**
  String get refundFullBill;

  /// No description provided for @refundSelectItems.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat položky'**
  String get refundSelectItems;

  /// No description provided for @changeTotalTitle.
  ///
  /// In cs, this message translates to:
  /// **'Upravit částku'**
  String get changeTotalTitle;

  /// No description provided for @changeTotalOriginal.
  ///
  /// In cs, this message translates to:
  /// **'Původní'**
  String get changeTotalOriginal;

  /// No description provided for @changeTotalEdited.
  ///
  /// In cs, this message translates to:
  /// **'Upravená'**
  String get changeTotalEdited;

  /// No description provided for @changeTotalDifference.
  ///
  /// In cs, this message translates to:
  /// **'Změna'**
  String get changeTotalDifference;

  /// No description provided for @newBillSave.
  ///
  /// In cs, this message translates to:
  /// **'Uložit'**
  String get newBillSave;

  /// No description provided for @newBillOrder.
  ///
  /// In cs, this message translates to:
  /// **'Objednat'**
  String get newBillOrder;

  /// No description provided for @newBillSelectSection.
  ///
  /// In cs, this message translates to:
  /// **'Výběr sekce'**
  String get newBillSelectSection;

  /// No description provided for @newBillCustomer.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník'**
  String get newBillCustomer;

  /// No description provided for @newBillNoTable.
  ///
  /// In cs, this message translates to:
  /// **'Bez stolu'**
  String get newBillNoTable;

  /// No description provided for @zReportListTitle.
  ///
  /// In cs, this message translates to:
  /// **'Přehled uzávěrek'**
  String get zReportListTitle;

  /// No description provided for @zReportListEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Žádné uzávěrky'**
  String get zReportListEmpty;

  /// No description provided for @zReportColumnDate.
  ///
  /// In cs, this message translates to:
  /// **'Datum'**
  String get zReportColumnDate;

  /// No description provided for @zReportColumnTime.
  ///
  /// In cs, this message translates to:
  /// **'Čas'**
  String get zReportColumnTime;

  /// No description provided for @zReportColumnUser.
  ///
  /// In cs, this message translates to:
  /// **'Uživatel'**
  String get zReportColumnUser;

  /// No description provided for @zReportColumnRevenue.
  ///
  /// In cs, this message translates to:
  /// **'Tržba'**
  String get zReportColumnRevenue;

  /// No description provided for @zReportColumnDifference.
  ///
  /// In cs, this message translates to:
  /// **'Rozdíl'**
  String get zReportColumnDifference;

  /// No description provided for @zReportTitle.
  ///
  /// In cs, this message translates to:
  /// **'Z-Report'**
  String get zReportTitle;

  /// No description provided for @zReportSessionInfo.
  ///
  /// In cs, this message translates to:
  /// **'Informace o směně'**
  String get zReportSessionInfo;

  /// No description provided for @zReportOpenedAt.
  ///
  /// In cs, this message translates to:
  /// **'Začátek'**
  String get zReportOpenedAt;

  /// No description provided for @zReportClosedAt.
  ///
  /// In cs, this message translates to:
  /// **'Konec'**
  String get zReportClosedAt;

  /// No description provided for @zReportDuration.
  ///
  /// In cs, this message translates to:
  /// **'Trvání'**
  String get zReportDuration;

  /// No description provided for @zReportOpenedBy.
  ///
  /// In cs, this message translates to:
  /// **'Otevřel'**
  String get zReportOpenedBy;

  /// No description provided for @zReportRevenueByPayment.
  ///
  /// In cs, this message translates to:
  /// **'Tržba dle plateb'**
  String get zReportRevenueByPayment;

  /// No description provided for @zReportRevenueTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celkem'**
  String get zReportRevenueTotal;

  /// No description provided for @zReportTaxTitle.
  ///
  /// In cs, this message translates to:
  /// **'DPH'**
  String get zReportTaxTitle;

  /// No description provided for @zReportTaxRate.
  ///
  /// In cs, this message translates to:
  /// **'Sazba'**
  String get zReportTaxRate;

  /// No description provided for @zReportTaxNet.
  ///
  /// In cs, this message translates to:
  /// **'Základ'**
  String get zReportTaxNet;

  /// No description provided for @zReportTaxAmount.
  ///
  /// In cs, this message translates to:
  /// **'DPH'**
  String get zReportTaxAmount;

  /// No description provided for @zReportTaxGross.
  ///
  /// In cs, this message translates to:
  /// **'Celkem'**
  String get zReportTaxGross;

  /// No description provided for @zReportTipsTotal.
  ///
  /// In cs, this message translates to:
  /// **'Spropitné celkem'**
  String get zReportTipsTotal;

  /// No description provided for @zReportTipsByUser.
  ///
  /// In cs, this message translates to:
  /// **'Spropitné dle obsluhy'**
  String get zReportTipsByUser;

  /// No description provided for @zReportDiscounts.
  ///
  /// In cs, this message translates to:
  /// **'Slevy celkem'**
  String get zReportDiscounts;

  /// No description provided for @zReportBillsPaid.
  ///
  /// In cs, this message translates to:
  /// **'Zaplacené účty'**
  String get zReportBillsPaid;

  /// No description provided for @zReportBillsCancelled.
  ///
  /// In cs, this message translates to:
  /// **'Stornované účty'**
  String get zReportBillsCancelled;

  /// No description provided for @zReportBillsRefunded.
  ///
  /// In cs, this message translates to:
  /// **'Refundované účty'**
  String get zReportBillsRefunded;

  /// No description provided for @zReportCashTitle.
  ///
  /// In cs, this message translates to:
  /// **'Stav hotovosti'**
  String get zReportCashTitle;

  /// No description provided for @zReportCashOpening.
  ///
  /// In cs, this message translates to:
  /// **'Počáteční hotovost'**
  String get zReportCashOpening;

  /// No description provided for @zReportCashRevenue.
  ///
  /// In cs, this message translates to:
  /// **'Tržba hotovost'**
  String get zReportCashRevenue;

  /// No description provided for @zReportCashDeposits.
  ///
  /// In cs, this message translates to:
  /// **'Vklady'**
  String get zReportCashDeposits;

  /// No description provided for @zReportCashWithdrawals.
  ///
  /// In cs, this message translates to:
  /// **'Výběry'**
  String get zReportCashWithdrawals;

  /// No description provided for @zReportCashExpected.
  ///
  /// In cs, this message translates to:
  /// **'Očekávaná hotovost'**
  String get zReportCashExpected;

  /// No description provided for @zReportCashClosing.
  ///
  /// In cs, this message translates to:
  /// **'Konečný stav'**
  String get zReportCashClosing;

  /// No description provided for @zReportCashDifference.
  ///
  /// In cs, this message translates to:
  /// **'Rozdíl'**
  String get zReportCashDifference;

  /// No description provided for @zReportShiftsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Směny'**
  String get zReportShiftsTitle;

  /// No description provided for @zReportPrint.
  ///
  /// In cs, this message translates to:
  /// **'Tisk'**
  String get zReportPrint;

  /// No description provided for @zReportClose.
  ///
  /// In cs, this message translates to:
  /// **'Zavřít'**
  String get zReportClose;

  /// No description provided for @moreShifts.
  ///
  /// In cs, this message translates to:
  /// **'Směny'**
  String get moreShifts;

  /// No description provided for @shiftsListTitle.
  ///
  /// In cs, this message translates to:
  /// **'Přehled směn'**
  String get shiftsListTitle;

  /// No description provided for @shiftsListEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Žádné směny v tomto období'**
  String get shiftsListEmpty;

  /// No description provided for @shiftsColumnDate.
  ///
  /// In cs, this message translates to:
  /// **'Datum'**
  String get shiftsColumnDate;

  /// No description provided for @shiftsColumnUser.
  ///
  /// In cs, this message translates to:
  /// **'Obsluha'**
  String get shiftsColumnUser;

  /// No description provided for @shiftsColumnLogin.
  ///
  /// In cs, this message translates to:
  /// **'Přihlášení'**
  String get shiftsColumnLogin;

  /// No description provided for @shiftsColumnLogout.
  ///
  /// In cs, this message translates to:
  /// **'Odhlášení'**
  String get shiftsColumnLogout;

  /// No description provided for @shiftsColumnDuration.
  ///
  /// In cs, this message translates to:
  /// **'Trvání'**
  String get shiftsColumnDuration;

  /// No description provided for @shiftsOngoing.
  ///
  /// In cs, this message translates to:
  /// **'probíhá'**
  String get shiftsOngoing;

  /// No description provided for @closingOpenBillsWarningTitle.
  ///
  /// In cs, this message translates to:
  /// **'Otevřené účty'**
  String get closingOpenBillsWarningTitle;

  /// No description provided for @closingOpenBillsWarningMessage.
  ///
  /// In cs, this message translates to:
  /// **'Na konci prodeje je {count} otevřených účtů v celkové hodnotě {amount}.'**
  String closingOpenBillsWarningMessage(int count, String amount);

  /// No description provided for @closingOpenBillsContinue.
  ///
  /// In cs, this message translates to:
  /// **'Pokračovat'**
  String get closingOpenBillsContinue;

  /// No description provided for @closingOpenBills.
  ///
  /// In cs, this message translates to:
  /// **'Otevřené účty'**
  String get closingOpenBills;

  /// No description provided for @zReportOpenBillsAtOpen.
  ///
  /// In cs, this message translates to:
  /// **'Otevřené účty (začátek)'**
  String get zReportOpenBillsAtOpen;

  /// No description provided for @zReportOpenBillsAtClose.
  ///
  /// In cs, this message translates to:
  /// **'Otevřené účty (konec)'**
  String get zReportOpenBillsAtClose;

  /// No description provided for @settingsRequirePinOnSwitch.
  ///
  /// In cs, this message translates to:
  /// **'Vyžadovat PIN při přepínání obsluhy'**
  String get settingsRequirePinOnSwitch;

  /// No description provided for @settingsAutoLockTimeout.
  ///
  /// In cs, this message translates to:
  /// **'Automatické zamčení po nečinnosti'**
  String get settingsAutoLockTimeout;

  /// No description provided for @settingsAutoLockDisabled.
  ///
  /// In cs, this message translates to:
  /// **'Vypnuto'**
  String get settingsAutoLockDisabled;

  /// No description provided for @settingsAutoLockMinutes.
  ///
  /// In cs, this message translates to:
  /// **'{minutes} min'**
  String settingsAutoLockMinutes(int minutes);

  /// No description provided for @settingsGridRows.
  ///
  /// In cs, this message translates to:
  /// **'Řádky gridu'**
  String get settingsGridRows;

  /// No description provided for @settingsGridCols.
  ///
  /// In cs, this message translates to:
  /// **'Sloupce gridu'**
  String get settingsGridCols;

  /// No description provided for @lockScreenTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zamčeno'**
  String get lockScreenTitle;

  /// No description provided for @lockScreenSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte uživatele pro odemčení'**
  String get lockScreenSubtitle;

  /// No description provided for @autoCorrection.
  ///
  /// In cs, this message translates to:
  /// **'Automatická korekce: počáteční hotovost se liší od předchozí uzávěrky'**
  String get autoCorrection;

  /// No description provided for @errorNoCompanyFound.
  ///
  /// In cs, this message translates to:
  /// **'Firma nenalezena'**
  String get errorNoCompanyFound;

  /// No description provided for @openingCashNote.
  ///
  /// In cs, this message translates to:
  /// **'Počáteční stav'**
  String get openingCashNote;

  /// No description provided for @catalogTitle.
  ///
  /// In cs, this message translates to:
  /// **'Katalog'**
  String get catalogTitle;

  /// No description provided for @catalogTabProducts.
  ///
  /// In cs, this message translates to:
  /// **'Produkty'**
  String get catalogTabProducts;

  /// No description provided for @catalogTabCategories.
  ///
  /// In cs, this message translates to:
  /// **'Kategorie'**
  String get catalogTabCategories;

  /// No description provided for @catalogTabSuppliers.
  ///
  /// In cs, this message translates to:
  /// **'Dodavatelé'**
  String get catalogTabSuppliers;

  /// No description provided for @catalogTabManufacturers.
  ///
  /// In cs, this message translates to:
  /// **'Výrobci'**
  String get catalogTabManufacturers;

  /// No description provided for @catalogTabRecipes.
  ///
  /// In cs, this message translates to:
  /// **'Receptury'**
  String get catalogTabRecipes;

  /// No description provided for @fieldSupplierName.
  ///
  /// In cs, this message translates to:
  /// **'Název dodavatele'**
  String get fieldSupplierName;

  /// No description provided for @fieldContactPerson.
  ///
  /// In cs, this message translates to:
  /// **'Kontaktní osoba'**
  String get fieldContactPerson;

  /// No description provided for @fieldEmail.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get fieldEmail;

  /// No description provided for @fieldPhone.
  ///
  /// In cs, this message translates to:
  /// **'Telefon'**
  String get fieldPhone;

  /// No description provided for @fieldManufacturer.
  ///
  /// In cs, this message translates to:
  /// **'Výrobce'**
  String get fieldManufacturer;

  /// No description provided for @fieldSupplier.
  ///
  /// In cs, this message translates to:
  /// **'Dodavatel'**
  String get fieldSupplier;

  /// No description provided for @fieldParentCategory.
  ///
  /// In cs, this message translates to:
  /// **'Nadřazená kategorie'**
  String get fieldParentCategory;

  /// No description provided for @fieldAltSku.
  ///
  /// In cs, this message translates to:
  /// **'Alternativní SKU'**
  String get fieldAltSku;

  /// No description provided for @fieldPurchasePrice.
  ///
  /// In cs, this message translates to:
  /// **'Nákupní cena'**
  String get fieldPurchasePrice;

  /// No description provided for @fieldPurchaseTaxRate.
  ///
  /// In cs, this message translates to:
  /// **'Nákupní DPH'**
  String get fieldPurchaseTaxRate;

  /// No description provided for @fieldOnSale.
  ///
  /// In cs, this message translates to:
  /// **'V prodeji'**
  String get fieldOnSale;

  /// No description provided for @fieldStockTracked.
  ///
  /// In cs, this message translates to:
  /// **'Sledování skladu'**
  String get fieldStockTracked;

  /// No description provided for @fieldDescription.
  ///
  /// In cs, this message translates to:
  /// **'Popis'**
  String get fieldDescription;

  /// No description provided for @fieldSku.
  ///
  /// In cs, this message translates to:
  /// **'SKU'**
  String get fieldSku;

  /// No description provided for @fieldUnit.
  ///
  /// In cs, this message translates to:
  /// **'Jednotka'**
  String get fieldUnit;

  /// No description provided for @unitTypeKs.
  ///
  /// In cs, this message translates to:
  /// **'ks'**
  String get unitTypeKs;

  /// No description provided for @unitTypeG.
  ///
  /// In cs, this message translates to:
  /// **'g'**
  String get unitTypeG;

  /// No description provided for @unitTypeKg.
  ///
  /// In cs, this message translates to:
  /// **'kg'**
  String get unitTypeKg;

  /// No description provided for @unitTypeMl.
  ///
  /// In cs, this message translates to:
  /// **'ml'**
  String get unitTypeMl;

  /// No description provided for @unitTypeCl.
  ///
  /// In cs, this message translates to:
  /// **'cl'**
  String get unitTypeCl;

  /// No description provided for @unitTypeL.
  ///
  /// In cs, this message translates to:
  /// **'l'**
  String get unitTypeL;

  /// No description provided for @unitTypeMm.
  ///
  /// In cs, this message translates to:
  /// **'mm'**
  String get unitTypeMm;

  /// No description provided for @unitTypeCm.
  ///
  /// In cs, this message translates to:
  /// **'cm'**
  String get unitTypeCm;

  /// No description provided for @unitTypeM.
  ///
  /// In cs, this message translates to:
  /// **'m'**
  String get unitTypeM;

  /// No description provided for @unitTypeMin.
  ///
  /// In cs, this message translates to:
  /// **'min'**
  String get unitTypeMin;

  /// No description provided for @unitTypeH.
  ///
  /// In cs, this message translates to:
  /// **'h'**
  String get unitTypeH;

  /// No description provided for @fieldParentProduct.
  ///
  /// In cs, this message translates to:
  /// **'Nadřazený produkt'**
  String get fieldParentProduct;

  /// No description provided for @fieldComponent.
  ///
  /// In cs, this message translates to:
  /// **'Složka'**
  String get fieldComponent;

  /// No description provided for @fieldQuantityRequired.
  ///
  /// In cs, this message translates to:
  /// **'Požadované množství'**
  String get fieldQuantityRequired;

  /// No description provided for @moreCatalog.
  ///
  /// In cs, this message translates to:
  /// **'Katalog'**
  String get moreCatalog;

  /// No description provided for @mergeBillTitle.
  ///
  /// In cs, this message translates to:
  /// **'Sloučit účet'**
  String get mergeBillTitle;

  /// No description provided for @mergeBillDescription.
  ///
  /// In cs, this message translates to:
  /// **'Objednávky z tohoto účtu budou přesunuty na vybraný účet. Aktuální účet bude zrušen.'**
  String get mergeBillDescription;

  /// No description provided for @mergeBillNoBills.
  ///
  /// In cs, this message translates to:
  /// **'Žádné otevřené účty k sloučení'**
  String get mergeBillNoBills;

  /// No description provided for @splitBillTitle.
  ///
  /// In cs, this message translates to:
  /// **'Rozdělit účet'**
  String get splitBillTitle;

  /// No description provided for @splitBillPayButton.
  ///
  /// In cs, this message translates to:
  /// **'Rozdělit a zaplatit'**
  String get splitBillPayButton;

  /// No description provided for @splitBillNewBillButton.
  ///
  /// In cs, this message translates to:
  /// **'Rozdělit na nový účet'**
  String get splitBillNewBillButton;

  /// No description provided for @splitBillSourceLabel.
  ///
  /// In cs, this message translates to:
  /// **'Účet #{billNumber}'**
  String splitBillSourceLabel(String billNumber);

  /// No description provided for @splitBillTargetLabel.
  ///
  /// In cs, this message translates to:
  /// **'Nový účet'**
  String get splitBillTargetLabel;

  /// No description provided for @splitBillTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celkem'**
  String get splitBillTotal;

  /// No description provided for @catalogTabCustomers.
  ///
  /// In cs, this message translates to:
  /// **'Zákazníci'**
  String get catalogTabCustomers;

  /// No description provided for @customerFirstName.
  ///
  /// In cs, this message translates to:
  /// **'Jméno'**
  String get customerFirstName;

  /// No description provided for @customerLastName.
  ///
  /// In cs, this message translates to:
  /// **'Příjmení'**
  String get customerLastName;

  /// No description provided for @customerEmail.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get customerEmail;

  /// No description provided for @customerPhone.
  ///
  /// In cs, this message translates to:
  /// **'Telefon'**
  String get customerPhone;

  /// No description provided for @customerAddress.
  ///
  /// In cs, this message translates to:
  /// **'Adresa'**
  String get customerAddress;

  /// No description provided for @customerPoints.
  ///
  /// In cs, this message translates to:
  /// **'Body'**
  String get customerPoints;

  /// No description provided for @customerCredit.
  ///
  /// In cs, this message translates to:
  /// **'Kredit'**
  String get customerCredit;

  /// No description provided for @customerTotalSpent.
  ///
  /// In cs, this message translates to:
  /// **'Celkem utraceno'**
  String get customerTotalSpent;

  /// No description provided for @customerBirthdate.
  ///
  /// In cs, this message translates to:
  /// **'Datum narození'**
  String get customerBirthdate;

  /// No description provided for @customerLastVisit.
  ///
  /// In cs, this message translates to:
  /// **'Poslední návštěva'**
  String get customerLastVisit;

  /// No description provided for @customerSearch.
  ///
  /// In cs, this message translates to:
  /// **'Hledat zákazníka'**
  String get customerSearch;

  /// No description provided for @customerRemove.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat zákazníka'**
  String get customerRemove;

  /// No description provided for @customerNone.
  ///
  /// In cs, this message translates to:
  /// **'Žádný zákazník'**
  String get customerNone;

  /// No description provided for @inventoryTitle.
  ///
  /// In cs, this message translates to:
  /// **'Sklad'**
  String get inventoryTitle;

  /// No description provided for @inventoryColumnItem.
  ///
  /// In cs, this message translates to:
  /// **'Položka'**
  String get inventoryColumnItem;

  /// No description provided for @inventoryColumnUnit.
  ///
  /// In cs, this message translates to:
  /// **'Jednotka'**
  String get inventoryColumnUnit;

  /// No description provided for @inventoryColumnQuantity.
  ///
  /// In cs, this message translates to:
  /// **'Množství'**
  String get inventoryColumnQuantity;

  /// No description provided for @inventoryColumnMinQuantity.
  ///
  /// In cs, this message translates to:
  /// **'Min. množství'**
  String get inventoryColumnMinQuantity;

  /// No description provided for @inventoryColumnPurchasePrice.
  ///
  /// In cs, this message translates to:
  /// **'Nákupní cena'**
  String get inventoryColumnPurchasePrice;

  /// No description provided for @inventoryColumnTotalValue.
  ///
  /// In cs, this message translates to:
  /// **'Celková hodnota'**
  String get inventoryColumnTotalValue;

  /// No description provided for @inventoryTotalValue.
  ///
  /// In cs, this message translates to:
  /// **'Celková hodnota skladu'**
  String get inventoryTotalValue;

  /// No description provided for @inventoryReceipt.
  ///
  /// In cs, this message translates to:
  /// **'Příjemka'**
  String get inventoryReceipt;

  /// No description provided for @inventoryWaste.
  ///
  /// In cs, this message translates to:
  /// **'Výdejka'**
  String get inventoryWaste;

  /// No description provided for @inventoryCorrection.
  ///
  /// In cs, this message translates to:
  /// **'Oprava'**
  String get inventoryCorrection;

  /// No description provided for @inventoryInventory.
  ///
  /// In cs, this message translates to:
  /// **'Inventura'**
  String get inventoryInventory;

  /// No description provided for @inventoryNoItems.
  ///
  /// In cs, this message translates to:
  /// **'Žádné sledované položky'**
  String get inventoryNoItems;

  /// No description provided for @stockDocumentTitle.
  ///
  /// In cs, this message translates to:
  /// **'Skladový doklad'**
  String get stockDocumentTitle;

  /// No description provided for @stockDocumentSupplier.
  ///
  /// In cs, this message translates to:
  /// **'Dodavatel'**
  String get stockDocumentSupplier;

  /// No description provided for @stockDocumentPriceStrategy.
  ///
  /// In cs, this message translates to:
  /// **'Strategie nákupní ceny'**
  String get stockDocumentPriceStrategy;

  /// No description provided for @stockDocumentNote.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka'**
  String get stockDocumentNote;

  /// No description provided for @stockDocumentAddItem.
  ///
  /// In cs, this message translates to:
  /// **'Přidat položku'**
  String get stockDocumentAddItem;

  /// No description provided for @stockDocumentQuantity.
  ///
  /// In cs, this message translates to:
  /// **'Množství'**
  String get stockDocumentQuantity;

  /// No description provided for @stockDocumentPrice.
  ///
  /// In cs, this message translates to:
  /// **'Nákupní cena'**
  String get stockDocumentPrice;

  /// No description provided for @stockDocumentSave.
  ///
  /// In cs, this message translates to:
  /// **'Uložit doklad'**
  String get stockDocumentSave;

  /// No description provided for @stockDocumentNoItems.
  ///
  /// In cs, this message translates to:
  /// **'Přidejte alespoň jednu položku'**
  String get stockDocumentNoItems;

  /// No description provided for @stockDocumentSearchItem.
  ///
  /// In cs, this message translates to:
  /// **'Hledat položku'**
  String get stockDocumentSearchItem;

  /// No description provided for @stockDocumentItemOverrideStrategy.
  ///
  /// In cs, this message translates to:
  /// **'Override strategie'**
  String get stockDocumentItemOverrideStrategy;

  /// No description provided for @stockStrategyOverwrite.
  ///
  /// In cs, this message translates to:
  /// **'Přepsat'**
  String get stockStrategyOverwrite;

  /// No description provided for @stockStrategyKeep.
  ///
  /// In cs, this message translates to:
  /// **'Ponechat'**
  String get stockStrategyKeep;

  /// No description provided for @stockStrategyAverage.
  ///
  /// In cs, this message translates to:
  /// **'Průměr'**
  String get stockStrategyAverage;

  /// No description provided for @stockStrategyWeightedAverage.
  ///
  /// In cs, this message translates to:
  /// **'Vážený průměr'**
  String get stockStrategyWeightedAverage;

  /// No description provided for @inventoryDialogTitle.
  ///
  /// In cs, this message translates to:
  /// **'Inventura'**
  String get inventoryDialogTitle;

  /// No description provided for @inventoryDialogActualQuantity.
  ///
  /// In cs, this message translates to:
  /// **'Skutečný stav'**
  String get inventoryDialogActualQuantity;

  /// No description provided for @inventoryDialogDifference.
  ///
  /// In cs, this message translates to:
  /// **'Rozdíl'**
  String get inventoryDialogDifference;

  /// No description provided for @inventoryDialogSave.
  ///
  /// In cs, this message translates to:
  /// **'Uložit inventuru'**
  String get inventoryDialogSave;

  /// No description provided for @inventoryDialogNoDifferences.
  ///
  /// In cs, this message translates to:
  /// **'Žádné rozdíly'**
  String get inventoryDialogNoDifferences;

  /// No description provided for @inventoryTabLevels.
  ///
  /// In cs, this message translates to:
  /// **'Zásoby'**
  String get inventoryTabLevels;

  /// No description provided for @inventoryTabDocuments.
  ///
  /// In cs, this message translates to:
  /// **'Doklady'**
  String get inventoryTabDocuments;

  /// No description provided for @inventoryTabMovements.
  ///
  /// In cs, this message translates to:
  /// **'Pohyby'**
  String get inventoryTabMovements;

  /// No description provided for @documentColumnNumber.
  ///
  /// In cs, this message translates to:
  /// **'Číslo'**
  String get documentColumnNumber;

  /// No description provided for @documentColumnType.
  ///
  /// In cs, this message translates to:
  /// **'Typ'**
  String get documentColumnType;

  /// No description provided for @documentColumnDate.
  ///
  /// In cs, this message translates to:
  /// **'Datum'**
  String get documentColumnDate;

  /// No description provided for @documentColumnSupplier.
  ///
  /// In cs, this message translates to:
  /// **'Dodavatel'**
  String get documentColumnSupplier;

  /// No description provided for @documentColumnNote.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka'**
  String get documentColumnNote;

  /// No description provided for @documentColumnTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celkem'**
  String get documentColumnTotal;

  /// No description provided for @documentNoDocuments.
  ///
  /// In cs, this message translates to:
  /// **'Žádné skladové doklady'**
  String get documentNoDocuments;

  /// No description provided for @documentTypeReceipt.
  ///
  /// In cs, this message translates to:
  /// **'Příjemka'**
  String get documentTypeReceipt;

  /// No description provided for @documentTypeWaste.
  ///
  /// In cs, this message translates to:
  /// **'Výdejka'**
  String get documentTypeWaste;

  /// No description provided for @documentTypeInventory.
  ///
  /// In cs, this message translates to:
  /// **'Inventura'**
  String get documentTypeInventory;

  /// No description provided for @documentTypeCorrection.
  ///
  /// In cs, this message translates to:
  /// **'Oprava'**
  String get documentTypeCorrection;

  /// No description provided for @movementColumnDate.
  ///
  /// In cs, this message translates to:
  /// **'Datum'**
  String get movementColumnDate;

  /// No description provided for @movementColumnItem.
  ///
  /// In cs, this message translates to:
  /// **'Položka'**
  String get movementColumnItem;

  /// No description provided for @movementColumnQuantity.
  ///
  /// In cs, this message translates to:
  /// **'Množství'**
  String get movementColumnQuantity;

  /// No description provided for @movementColumnType.
  ///
  /// In cs, this message translates to:
  /// **'Typ'**
  String get movementColumnType;

  /// No description provided for @movementColumnDocument.
  ///
  /// In cs, this message translates to:
  /// **'Doklad'**
  String get movementColumnDocument;

  /// No description provided for @movementNoMovements.
  ///
  /// In cs, this message translates to:
  /// **'Žádné skladové pohyby'**
  String get movementNoMovements;

  /// No description provided for @movementFilterItem.
  ///
  /// In cs, this message translates to:
  /// **'Filtrovat dle položky'**
  String get movementFilterItem;

  /// No description provided for @movementTypeSale.
  ///
  /// In cs, this message translates to:
  /// **'Prodej'**
  String get movementTypeSale;

  /// No description provided for @movementTypeReversal.
  ///
  /// In cs, this message translates to:
  /// **'Storno'**
  String get movementTypeReversal;

  /// No description provided for @recipeComponents.
  ///
  /// In cs, this message translates to:
  /// **'Složky'**
  String get recipeComponents;

  /// No description provided for @recipeComponentCount.
  ///
  /// In cs, this message translates to:
  /// **'{count} složek'**
  String recipeComponentCount(int count);

  /// No description provided for @recipeAddComponent.
  ///
  /// In cs, this message translates to:
  /// **'Přidat složku'**
  String get recipeAddComponent;

  /// No description provided for @recipeNoComponents.
  ///
  /// In cs, this message translates to:
  /// **'Žádné složky. Přidejte alespoň jednu.'**
  String get recipeNoComponents;

  /// No description provided for @searchHint.
  ///
  /// In cs, this message translates to:
  /// **'Hledat...'**
  String get searchHint;

  /// No description provided for @filterTitle.
  ///
  /// In cs, this message translates to:
  /// **'Filtr'**
  String get filterTitle;

  /// No description provided for @filterAll.
  ///
  /// In cs, this message translates to:
  /// **'Vše'**
  String get filterAll;

  /// No description provided for @filterReset.
  ///
  /// In cs, this message translates to:
  /// **'Resetovat'**
  String get filterReset;

  /// No description provided for @receiptSubtotal.
  ///
  /// In cs, this message translates to:
  /// **'Mezisoučet'**
  String get receiptSubtotal;

  /// No description provided for @receiptDiscount.
  ///
  /// In cs, this message translates to:
  /// **'Sleva'**
  String get receiptDiscount;

  /// No description provided for @receiptVoucherDiscount.
  ///
  /// In cs, this message translates to:
  /// **'Voucher'**
  String get receiptVoucherDiscount;

  /// No description provided for @receiptTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celkem'**
  String get receiptTotal;

  /// No description provided for @receiptRounding.
  ///
  /// In cs, this message translates to:
  /// **'Zaokrouhlení'**
  String get receiptRounding;

  /// No description provided for @receiptTaxTitle.
  ///
  /// In cs, this message translates to:
  /// **'Rekapitulace DPH'**
  String get receiptTaxTitle;

  /// No description provided for @receiptTaxRate.
  ///
  /// In cs, this message translates to:
  /// **'Sazba'**
  String get receiptTaxRate;

  /// No description provided for @receiptTaxNet.
  ///
  /// In cs, this message translates to:
  /// **'Základ'**
  String get receiptTaxNet;

  /// No description provided for @receiptTaxAmount.
  ///
  /// In cs, this message translates to:
  /// **'DPH'**
  String get receiptTaxAmount;

  /// No description provided for @receiptTaxGross.
  ///
  /// In cs, this message translates to:
  /// **'Celkem'**
  String get receiptTaxGross;

  /// No description provided for @receiptPayment.
  ///
  /// In cs, this message translates to:
  /// **'Platba'**
  String get receiptPayment;

  /// No description provided for @receiptTip.
  ///
  /// In cs, this message translates to:
  /// **'Spropitné'**
  String get receiptTip;

  /// No description provided for @receiptBillNumber.
  ///
  /// In cs, this message translates to:
  /// **'Účtenka č.'**
  String get receiptBillNumber;

  /// No description provided for @receiptTable.
  ///
  /// In cs, this message translates to:
  /// **'Stůl'**
  String get receiptTable;

  /// No description provided for @receiptTakeaway.
  ///
  /// In cs, this message translates to:
  /// **'S sebou'**
  String get receiptTakeaway;

  /// No description provided for @receiptCashier.
  ///
  /// In cs, this message translates to:
  /// **'Obsluha'**
  String get receiptCashier;

  /// No description provided for @receiptDate.
  ///
  /// In cs, this message translates to:
  /// **'Datum'**
  String get receiptDate;

  /// No description provided for @receiptThankYou.
  ///
  /// In cs, this message translates to:
  /// **'Děkujeme za návštěvu'**
  String get receiptThankYou;

  /// No description provided for @receiptIco.
  ///
  /// In cs, this message translates to:
  /// **'IČO'**
  String get receiptIco;

  /// No description provided for @receiptDic.
  ///
  /// In cs, this message translates to:
  /// **'DIČ'**
  String get receiptDic;

  /// No description provided for @receiptPreviewTitle.
  ///
  /// In cs, this message translates to:
  /// **'Náhled účtenky'**
  String get receiptPreviewTitle;

  /// No description provided for @zReportReportTitle.
  ///
  /// In cs, this message translates to:
  /// **'Z-Report'**
  String get zReportReportTitle;

  /// No description provided for @zReportSession.
  ///
  /// In cs, this message translates to:
  /// **'Směna'**
  String get zReportSession;

  /// No description provided for @zReportOpenedAtLabel.
  ///
  /// In cs, this message translates to:
  /// **'Začátek'**
  String get zReportOpenedAtLabel;

  /// No description provided for @zReportClosedAtLabel.
  ///
  /// In cs, this message translates to:
  /// **'Konec'**
  String get zReportClosedAtLabel;

  /// No description provided for @zReportDurationLabel.
  ///
  /// In cs, this message translates to:
  /// **'Trvání'**
  String get zReportDurationLabel;

  /// No description provided for @zReportOpenedByLabel.
  ///
  /// In cs, this message translates to:
  /// **'Otevřel'**
  String get zReportOpenedByLabel;

  /// No description provided for @zReportRevenueTitle.
  ///
  /// In cs, this message translates to:
  /// **'Tržba dle plateb'**
  String get zReportRevenueTitle;

  /// No description provided for @zReportTaxReportTitle.
  ///
  /// In cs, this message translates to:
  /// **'DPH'**
  String get zReportTaxReportTitle;

  /// No description provided for @zReportTipsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Spropitné'**
  String get zReportTipsTitle;

  /// No description provided for @zReportDiscountsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Slevy'**
  String get zReportDiscountsTitle;

  /// No description provided for @zReportBillCountsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Počty účtů'**
  String get zReportBillCountsTitle;

  /// No description provided for @zReportCashReportTitle.
  ///
  /// In cs, this message translates to:
  /// **'Stav hotovosti'**
  String get zReportCashReportTitle;

  /// No description provided for @zReportShiftsReportTitle.
  ///
  /// In cs, this message translates to:
  /// **'Směny'**
  String get zReportShiftsReportTitle;

  /// No description provided for @zReportRegisterBreakdown.
  ///
  /// In cs, this message translates to:
  /// **'Rozpad dle pokladen'**
  String get zReportRegisterBreakdown;

  /// No description provided for @zReportRegisterColumn.
  ///
  /// In cs, this message translates to:
  /// **'Pokladna'**
  String get zReportRegisterColumn;

  /// No description provided for @zReportVenueReport.
  ///
  /// In cs, this message translates to:
  /// **'Report provozovny'**
  String get zReportVenueReport;

  /// No description provided for @zReportVenueReportTitle.
  ///
  /// In cs, this message translates to:
  /// **'Report provozovny'**
  String get zReportVenueReportTitle;

  /// No description provided for @zReportRegisterName.
  ///
  /// In cs, this message translates to:
  /// **'Pokladna: {name}'**
  String zReportRegisterName(String name);

  /// No description provided for @cashHandoverReason.
  ///
  /// In cs, this message translates to:
  /// **'Předání hotovosti z {registerName}'**
  String cashHandoverReason(String registerName);

  /// No description provided for @reservationsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Rezervace'**
  String get reservationsTitle;

  /// No description provided for @reservationNew.
  ///
  /// In cs, this message translates to:
  /// **'Nová rezervace'**
  String get reservationNew;

  /// No description provided for @reservationEdit.
  ///
  /// In cs, this message translates to:
  /// **'Upravit rezervaci'**
  String get reservationEdit;

  /// No description provided for @reservationDate.
  ///
  /// In cs, this message translates to:
  /// **'Datum'**
  String get reservationDate;

  /// No description provided for @reservationTime.
  ///
  /// In cs, this message translates to:
  /// **'Čas'**
  String get reservationTime;

  /// No description provided for @reservationCustomerName.
  ///
  /// In cs, this message translates to:
  /// **'Jméno'**
  String get reservationCustomerName;

  /// No description provided for @reservationCustomerPhone.
  ///
  /// In cs, this message translates to:
  /// **'Telefon'**
  String get reservationCustomerPhone;

  /// No description provided for @reservationPartySize.
  ///
  /// In cs, this message translates to:
  /// **'Počet osob'**
  String get reservationPartySize;

  /// No description provided for @reservationTable.
  ///
  /// In cs, this message translates to:
  /// **'Stůl'**
  String get reservationTable;

  /// No description provided for @reservationNotes.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka'**
  String get reservationNotes;

  /// No description provided for @reservationStatus.
  ///
  /// In cs, this message translates to:
  /// **'Stav'**
  String get reservationStatus;

  /// No description provided for @reservationStatusCreated.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořena'**
  String get reservationStatusCreated;

  /// No description provided for @reservationStatusConfirmed.
  ///
  /// In cs, this message translates to:
  /// **'Potvrzena'**
  String get reservationStatusConfirmed;

  /// No description provided for @reservationStatusSeated.
  ///
  /// In cs, this message translates to:
  /// **'Usazeni'**
  String get reservationStatusSeated;

  /// No description provided for @reservationStatusCancelled.
  ///
  /// In cs, this message translates to:
  /// **'Zrušena'**
  String get reservationStatusCancelled;

  /// No description provided for @reservationLinkCustomer.
  ///
  /// In cs, this message translates to:
  /// **'Propojit zákazníka'**
  String get reservationLinkCustomer;

  /// No description provided for @reservationLinkedCustomer.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník'**
  String get reservationLinkedCustomer;

  /// No description provided for @reservationsEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Žádné rezervace'**
  String get reservationsEmpty;

  /// No description provided for @reservationSave.
  ///
  /// In cs, this message translates to:
  /// **'Uložit'**
  String get reservationSave;

  /// No description provided for @reservationDelete.
  ///
  /// In cs, this message translates to:
  /// **'Smazat'**
  String get reservationDelete;

  /// No description provided for @reservationColumnDate.
  ///
  /// In cs, this message translates to:
  /// **'Datum'**
  String get reservationColumnDate;

  /// No description provided for @reservationColumnTime.
  ///
  /// In cs, this message translates to:
  /// **'Čas'**
  String get reservationColumnTime;

  /// No description provided for @reservationColumnName.
  ///
  /// In cs, this message translates to:
  /// **'Jméno'**
  String get reservationColumnName;

  /// No description provided for @reservationColumnPhone.
  ///
  /// In cs, this message translates to:
  /// **'Telefon'**
  String get reservationColumnPhone;

  /// No description provided for @reservationColumnPartySize.
  ///
  /// In cs, this message translates to:
  /// **'Počet'**
  String get reservationColumnPartySize;

  /// No description provided for @reservationColumnTable.
  ///
  /// In cs, this message translates to:
  /// **'Stůl'**
  String get reservationColumnTable;

  /// No description provided for @reservationColumnStatus.
  ///
  /// In cs, this message translates to:
  /// **'Stav'**
  String get reservationColumnStatus;

  /// No description provided for @paymentTypeCredit.
  ///
  /// In cs, this message translates to:
  /// **'Kredit'**
  String get paymentTypeCredit;

  /// No description provided for @paymentTypeVoucher.
  ///
  /// In cs, this message translates to:
  /// **'Stravenky'**
  String get paymentTypeVoucher;

  /// No description provided for @loyaltySectionTitle.
  ///
  /// In cs, this message translates to:
  /// **'Věrnostní program'**
  String get loyaltySectionTitle;

  /// No description provided for @loyaltyEarnRate.
  ///
  /// In cs, this message translates to:
  /// **'Bodů za {unit}'**
  String loyaltyEarnRate(String unit);

  /// No description provided for @loyaltyPointValue.
  ///
  /// In cs, this message translates to:
  /// **'Hodnota 1 bodu (minor units)'**
  String get loyaltyPointValue;

  /// No description provided for @loyaltyDescription.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník získá {earn} bodů za každých {unit}. 1 bod = {value}.'**
  String loyaltyDescription(int earn, String unit, String value);

  /// No description provided for @loyaltyDisabled.
  ///
  /// In cs, this message translates to:
  /// **'Věrnostní program je vypnutý (nastavte hodnoty > 0)'**
  String get loyaltyDisabled;

  /// No description provided for @loyaltyRedeem.
  ///
  /// In cs, this message translates to:
  /// **'Uplatnit body'**
  String get loyaltyRedeem;

  /// No description provided for @loyaltyAvailablePoints.
  ///
  /// In cs, this message translates to:
  /// **'Dostupné body'**
  String get loyaltyAvailablePoints;

  /// No description provided for @loyaltyPointsValue.
  ///
  /// In cs, this message translates to:
  /// **'Hodnota'**
  String get loyaltyPointsValue;

  /// No description provided for @loyaltyPerPoint.
  ///
  /// In cs, this message translates to:
  /// **'{value}/bod'**
  String loyaltyPerPoint(String value);

  /// No description provided for @loyaltyPointsToUse.
  ///
  /// In cs, this message translates to:
  /// **'Bodů k uplatnění'**
  String get loyaltyPointsToUse;

  /// No description provided for @loyaltyDiscountPreview.
  ///
  /// In cs, this message translates to:
  /// **'{points} bodů = sleva {amount}'**
  String loyaltyDiscountPreview(int points, String amount);

  /// No description provided for @loyaltyEarned.
  ///
  /// In cs, this message translates to:
  /// **'Získáno bodů'**
  String get loyaltyEarned;

  /// No description provided for @loyaltyCustomerInfo.
  ///
  /// In cs, this message translates to:
  /// **'Body: {points} | Kredit: {credit}'**
  String loyaltyCustomerInfo(int points, String credit);

  /// No description provided for @loyaltyCredit.
  ///
  /// In cs, this message translates to:
  /// **'Zákaznický kredit'**
  String get loyaltyCredit;

  /// No description provided for @loyaltyCreditTopUp.
  ///
  /// In cs, this message translates to:
  /// **'Nabít kredit'**
  String get loyaltyCreditTopUp;

  /// No description provided for @loyaltyCreditDeduct.
  ///
  /// In cs, this message translates to:
  /// **'Odečíst kredit'**
  String get loyaltyCreditDeduct;

  /// No description provided for @loyaltyCreditBalance.
  ///
  /// In cs, this message translates to:
  /// **'Zůstatek'**
  String get loyaltyCreditBalance;

  /// No description provided for @loyaltyTransactionHistory.
  ///
  /// In cs, this message translates to:
  /// **'Historie transakcí'**
  String get loyaltyTransactionHistory;

  /// No description provided for @loyaltyNoCustomer.
  ///
  /// In cs, this message translates to:
  /// **'K účtu není přiřazen zákazník'**
  String get loyaltyNoCustomer;

  /// No description provided for @settingsSectionGridManagement.
  ///
  /// In cs, this message translates to:
  /// **'Správa rozložení mřížky'**
  String get settingsSectionGridManagement;

  /// No description provided for @settingsAutoArrange.
  ///
  /// In cs, this message translates to:
  /// **'Automatické rozmístění'**
  String get settingsAutoArrange;

  /// No description provided for @settingsAutoArrangeDescription.
  ///
  /// In cs, this message translates to:
  /// **'Rozmístí kategorie a produkty do mřížky'**
  String get settingsAutoArrangeDescription;

  /// No description provided for @settingsManualEditor.
  ///
  /// In cs, this message translates to:
  /// **'Ruční editor mřížky'**
  String get settingsManualEditor;

  /// No description provided for @settingsManualEditorDescription.
  ///
  /// In cs, this message translates to:
  /// **'Otevře editor pro přiřazení položek'**
  String get settingsManualEditorDescription;

  /// No description provided for @autoArrangeTitle.
  ///
  /// In cs, this message translates to:
  /// **'Automatické rozmístění'**
  String get autoArrangeTitle;

  /// No description provided for @autoArrangeHorizontal.
  ///
  /// In cs, this message translates to:
  /// **'Horizontální'**
  String get autoArrangeHorizontal;

  /// No description provided for @autoArrangeHorizontalDesc.
  ///
  /// In cs, this message translates to:
  /// **'Řádek = kategorie + její produkty'**
  String get autoArrangeHorizontalDesc;

  /// No description provided for @autoArrangeVertical.
  ///
  /// In cs, this message translates to:
  /// **'Vertikální'**
  String get autoArrangeVertical;

  /// No description provided for @autoArrangeVerticalDesc.
  ///
  /// In cs, this message translates to:
  /// **'Sloupec = kategorie + její produkty pod ní'**
  String get autoArrangeVerticalDesc;

  /// No description provided for @autoArrangeWarning.
  ///
  /// In cs, this message translates to:
  /// **'Stávající rozmístění bude nahrazeno'**
  String get autoArrangeWarning;

  /// No description provided for @autoArrangeConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Rozmístit'**
  String get autoArrangeConfirm;

  /// No description provided for @autoArrangeSummary.
  ///
  /// In cs, this message translates to:
  /// **'{categories} kategorií, {products} produktů'**
  String autoArrangeSummary(int categories, int products);

  /// No description provided for @autoArrangeOverflow.
  ///
  /// In cs, this message translates to:
  /// **'Na hlavní stránku se vejde jen {fit} z {total} kategorií. Zbylé budou dostupné pouze na sub-stránkách.'**
  String autoArrangeOverflow(int fit, int total);

  /// No description provided for @gridEditorTitle2.
  ///
  /// In cs, this message translates to:
  /// **'Editor mřížky'**
  String get gridEditorTitle2;

  /// No description provided for @gridEditorBack.
  ///
  /// In cs, this message translates to:
  /// **'Zpět'**
  String get gridEditorBack;

  /// No description provided for @gridEditorRootPage.
  ///
  /// In cs, this message translates to:
  /// **'Hlavní stránka'**
  String get gridEditorRootPage;

  /// No description provided for @gridEditorPage.
  ///
  /// In cs, this message translates to:
  /// **'Stránka {page}'**
  String gridEditorPage(int page);

  /// No description provided for @gridEditorColor.
  ///
  /// In cs, this message translates to:
  /// **'Barva tlačítka'**
  String get gridEditorColor;

  /// No description provided for @settingsFloorMap.
  ///
  /// In cs, this message translates to:
  /// **'Mapa'**
  String get settingsFloorMap;

  /// No description provided for @billsTableList.
  ///
  /// In cs, this message translates to:
  /// **'Seznam'**
  String get billsTableList;

  /// No description provided for @floorMapEditorTitle.
  ///
  /// In cs, this message translates to:
  /// **'Editor mapy'**
  String get floorMapEditorTitle;

  /// No description provided for @floorMapAddTable.
  ///
  /// In cs, this message translates to:
  /// **'Přidat stůl na mapu'**
  String get floorMapAddTable;

  /// No description provided for @floorMapEditTable.
  ///
  /// In cs, this message translates to:
  /// **'Upravit pozici stolu'**
  String get floorMapEditTable;

  /// No description provided for @floorMapRemoveTable.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat z mapy'**
  String get floorMapRemoveTable;

  /// No description provided for @floorMapWidth.
  ///
  /// In cs, this message translates to:
  /// **'Šířka (buňky)'**
  String get floorMapWidth;

  /// No description provided for @floorMapHeight.
  ///
  /// In cs, this message translates to:
  /// **'Výška (buňky)'**
  String get floorMapHeight;

  /// No description provided for @floorMapSelectSection.
  ///
  /// In cs, this message translates to:
  /// **'Sekce'**
  String get floorMapSelectSection;

  /// No description provided for @floorMapSelectTable.
  ///
  /// In cs, this message translates to:
  /// **'Stůl'**
  String get floorMapSelectTable;

  /// No description provided for @floorMapNewTable.
  ///
  /// In cs, this message translates to:
  /// **'Nový stůl'**
  String get floorMapNewTable;

  /// No description provided for @floorMapNoTables.
  ///
  /// In cs, this message translates to:
  /// **'Žádné stoly na mapě. Přidejte je v editoru mapy v Nastavení.'**
  String get floorMapNoTables;

  /// No description provided for @floorMapEmptySlot.
  ///
  /// In cs, this message translates to:
  /// **'Prázdné'**
  String get floorMapEmptySlot;

  /// No description provided for @floorMapShapeRectangle.
  ///
  /// In cs, this message translates to:
  /// **'Obdélník'**
  String get floorMapShapeRectangle;

  /// No description provided for @floorMapShapeRound.
  ///
  /// In cs, this message translates to:
  /// **'Ovál'**
  String get floorMapShapeRound;

  /// No description provided for @floorMapShapeTriangle.
  ///
  /// In cs, this message translates to:
  /// **'Trojúhelník'**
  String get floorMapShapeTriangle;

  /// No description provided for @floorMapShapeDiamond.
  ///
  /// In cs, this message translates to:
  /// **'Kosočtverec'**
  String get floorMapShapeDiamond;

  /// No description provided for @floorMapSegmentTable.
  ///
  /// In cs, this message translates to:
  /// **'Stůl'**
  String get floorMapSegmentTable;

  /// No description provided for @floorMapSegmentElement.
  ///
  /// In cs, this message translates to:
  /// **'Prvek'**
  String get floorMapSegmentElement;

  /// No description provided for @floorMapAddElement.
  ///
  /// In cs, this message translates to:
  /// **'Přidat prvek na mapu'**
  String get floorMapAddElement;

  /// No description provided for @floorMapEditElement.
  ///
  /// In cs, this message translates to:
  /// **'Upravit prvek'**
  String get floorMapEditElement;

  /// No description provided for @floorMapRemoveElement.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat z mapy'**
  String get floorMapRemoveElement;

  /// No description provided for @floorMapElementLabel.
  ///
  /// In cs, this message translates to:
  /// **'Popisek'**
  String get floorMapElementLabel;

  /// No description provided for @floorMapElementColor.
  ///
  /// In cs, this message translates to:
  /// **'Barva'**
  String get floorMapElementColor;

  /// No description provided for @floorMapColorNone.
  ///
  /// In cs, this message translates to:
  /// **'Žádná'**
  String get floorMapColorNone;

  /// No description provided for @floorMapElementFontSize.
  ///
  /// In cs, this message translates to:
  /// **'Velikost textu'**
  String get floorMapElementFontSize;

  /// No description provided for @floorMapElementFillStyle.
  ///
  /// In cs, this message translates to:
  /// **'Výplň'**
  String get floorMapElementFillStyle;

  /// No description provided for @floorMapElementBorderStyle.
  ///
  /// In cs, this message translates to:
  /// **'Obrys'**
  String get floorMapElementBorderStyle;

  /// No description provided for @floorMapStyleNone.
  ///
  /// In cs, this message translates to:
  /// **'Žádný'**
  String get floorMapStyleNone;

  /// No description provided for @floorMapStyleTranslucent.
  ///
  /// In cs, this message translates to:
  /// **'Průsvitný'**
  String get floorMapStyleTranslucent;

  /// No description provided for @floorMapStyleSolid.
  ///
  /// In cs, this message translates to:
  /// **'Plný'**
  String get floorMapStyleSolid;

  /// No description provided for @vouchersTitle.
  ///
  /// In cs, this message translates to:
  /// **'Vouchery'**
  String get vouchersTitle;

  /// No description provided for @voucherCreate.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořit voucher'**
  String get voucherCreate;

  /// No description provided for @voucherTypeGift.
  ///
  /// In cs, this message translates to:
  /// **'Dárkový'**
  String get voucherTypeGift;

  /// No description provided for @voucherTypeDeposit.
  ///
  /// In cs, this message translates to:
  /// **'Zálohový'**
  String get voucherTypeDeposit;

  /// No description provided for @voucherTypeDiscount.
  ///
  /// In cs, this message translates to:
  /// **'Slevový'**
  String get voucherTypeDiscount;

  /// No description provided for @voucherStatusActive.
  ///
  /// In cs, this message translates to:
  /// **'Aktivní'**
  String get voucherStatusActive;

  /// No description provided for @voucherStatusRedeemed.
  ///
  /// In cs, this message translates to:
  /// **'Uplatněný'**
  String get voucherStatusRedeemed;

  /// No description provided for @voucherStatusExpired.
  ///
  /// In cs, this message translates to:
  /// **'Expirovaný'**
  String get voucherStatusExpired;

  /// No description provided for @voucherStatusCancelled.
  ///
  /// In cs, this message translates to:
  /// **'Zrušený'**
  String get voucherStatusCancelled;

  /// No description provided for @voucherCode.
  ///
  /// In cs, this message translates to:
  /// **'Kód'**
  String get voucherCode;

  /// No description provided for @voucherValue.
  ///
  /// In cs, this message translates to:
  /// **'Hodnota'**
  String get voucherValue;

  /// No description provided for @voucherDiscount.
  ///
  /// In cs, this message translates to:
  /// **'Sleva'**
  String get voucherDiscount;

  /// No description provided for @voucherExpires.
  ///
  /// In cs, this message translates to:
  /// **'Platnost do'**
  String get voucherExpires;

  /// No description provided for @voucherCustomer.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník'**
  String get voucherCustomer;

  /// No description provided for @voucherNote.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka'**
  String get voucherNote;

  /// No description provided for @voucherCreatedAt.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořeno'**
  String get voucherCreatedAt;

  /// No description provided for @voucherCreatedBy.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořil'**
  String get voucherCreatedBy;

  /// No description provided for @voucherScopeBill.
  ///
  /// In cs, this message translates to:
  /// **'Celý účet'**
  String get voucherScopeBill;

  /// No description provided for @voucherScopeProduct.
  ///
  /// In cs, this message translates to:
  /// **'Produkt'**
  String get voucherScopeProduct;

  /// No description provided for @voucherScopeCategory.
  ///
  /// In cs, this message translates to:
  /// **'Kategorie'**
  String get voucherScopeCategory;

  /// No description provided for @voucherMaxUses.
  ///
  /// In cs, this message translates to:
  /// **'Max. použití'**
  String get voucherMaxUses;

  /// No description provided for @voucherUsedCount.
  ///
  /// In cs, this message translates to:
  /// **'Použito'**
  String get voucherUsedCount;

  /// No description provided for @voucherMinOrderValue.
  ///
  /// In cs, this message translates to:
  /// **'Min. hodnota účtu'**
  String get voucherMinOrderValue;

  /// No description provided for @voucherSell.
  ///
  /// In cs, this message translates to:
  /// **'Prodat'**
  String get voucherSell;

  /// No description provided for @voucherPrint.
  ///
  /// In cs, this message translates to:
  /// **'Tisk'**
  String get voucherPrint;

  /// No description provided for @voucherCancel.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit voucher'**
  String get voucherCancel;

  /// No description provided for @voucherRedeem.
  ///
  /// In cs, this message translates to:
  /// **'Uplatnit'**
  String get voucherRedeem;

  /// No description provided for @voucherEnterCode.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte kód voucheru'**
  String get voucherEnterCode;

  /// No description provided for @voucherInvalid.
  ///
  /// In cs, this message translates to:
  /// **'Neplatný kód voucheru'**
  String get voucherInvalid;

  /// No description provided for @voucherExpiredError.
  ///
  /// In cs, this message translates to:
  /// **'Voucher expiroval'**
  String get voucherExpiredError;

  /// No description provided for @voucherAlreadyUsed.
  ///
  /// In cs, this message translates to:
  /// **'Voucher byl již uplatněn'**
  String get voucherAlreadyUsed;

  /// No description provided for @voucherMinOrderNotMet.
  ///
  /// In cs, this message translates to:
  /// **'Minimální hodnota účtu nesplněna'**
  String get voucherMinOrderNotMet;

  /// No description provided for @voucherCustomerMismatch.
  ///
  /// In cs, this message translates to:
  /// **'Voucher je vázán na jiného zákazníka'**
  String get voucherCustomerMismatch;

  /// No description provided for @voucherDepositReturn.
  ///
  /// In cs, this message translates to:
  /// **'Vrácení přeplatku zálohy'**
  String get voucherDepositReturn;

  /// No description provided for @voucherFilterAll.
  ///
  /// In cs, this message translates to:
  /// **'Všechny'**
  String get voucherFilterAll;

  /// No description provided for @voucherRedeemedAt.
  ///
  /// In cs, this message translates to:
  /// **'Uplatněno'**
  String get voucherRedeemedAt;

  /// No description provided for @voucherIdLabel.
  ///
  /// In cs, this message translates to:
  /// **'ID'**
  String get voucherIdLabel;

  /// No description provided for @billDetailVoucher.
  ///
  /// In cs, this message translates to:
  /// **'Voucher'**
  String get billDetailVoucher;

  /// No description provided for @billDetailRemoveVoucher.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit voucher'**
  String get billDetailRemoveVoucher;

  /// No description provided for @billDetailRemoveVoucherConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat použitý voucher z tohoto účtu?'**
  String get billDetailRemoveVoucherConfirm;

  /// No description provided for @wizardLanguage.
  ///
  /// In cs, this message translates to:
  /// **'Jazyk'**
  String get wizardLanguage;

  /// No description provided for @wizardCurrency.
  ///
  /// In cs, this message translates to:
  /// **'Výchozí měna'**
  String get wizardCurrency;

  /// No description provided for @wizardWithTestData.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořit s testovacími daty'**
  String get wizardWithTestData;

  /// No description provided for @orderItemStorno.
  ///
  /// In cs, this message translates to:
  /// **'Storno'**
  String get orderItemStorno;

  /// No description provided for @orderItemStornoConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Opravdu chcete stornovat tuto položku?'**
  String get orderItemStornoConfirm;

  /// No description provided for @ordersTitle.
  ///
  /// In cs, this message translates to:
  /// **'Objednávky'**
  String get ordersTitle;

  /// No description provided for @ordersFilterActive.
  ///
  /// In cs, this message translates to:
  /// **'Aktivní'**
  String get ordersFilterActive;

  /// No description provided for @ordersFilterCreated.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořené'**
  String get ordersFilterCreated;

  /// No description provided for @ordersFilterReady.
  ///
  /// In cs, this message translates to:
  /// **'Hotové'**
  String get ordersFilterReady;

  /// No description provided for @ordersFilterDelivered.
  ///
  /// In cs, this message translates to:
  /// **'Doručené'**
  String get ordersFilterDelivered;

  /// No description provided for @ordersFilterStorno.
  ///
  /// In cs, this message translates to:
  /// **'Stornované'**
  String get ordersFilterStorno;

  /// No description provided for @ordersScopeSession.
  ///
  /// In cs, this message translates to:
  /// **'Session'**
  String get ordersScopeSession;

  /// No description provided for @ordersScopeAll.
  ///
  /// In cs, this message translates to:
  /// **'Vše'**
  String get ordersScopeAll;

  /// No description provided for @ordersNoOrders.
  ///
  /// In cs, this message translates to:
  /// **'Žádné objednávky'**
  String get ordersNoOrders;

  /// No description provided for @ordersTimeCreated.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořeno'**
  String get ordersTimeCreated;

  /// No description provided for @ordersTimeUpdated.
  ///
  /// In cs, this message translates to:
  /// **'Změněno'**
  String get ordersTimeUpdated;

  /// No description provided for @ordersTableLabel.
  ///
  /// In cs, this message translates to:
  /// **'Stůl'**
  String get ordersTableLabel;

  /// No description provided for @ordersCustomerLabel.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník'**
  String get ordersCustomerLabel;

  /// No description provided for @ordersStornoPrefix.
  ///
  /// In cs, this message translates to:
  /// **'STORNO'**
  String get ordersStornoPrefix;

  /// No description provided for @ordersStornoRef.
  ///
  /// In cs, this message translates to:
  /// **'→ {orderNumber}'**
  String ordersStornoRef(String orderNumber);

  /// No description provided for @customerDisplayTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zákaznický displej'**
  String get customerDisplayTitle;

  /// No description provided for @customerDisplayWelcome.
  ///
  /// In cs, this message translates to:
  /// **'Vítejte'**
  String get customerDisplayWelcome;

  /// No description provided for @customerDisplayHeader.
  ///
  /// In cs, this message translates to:
  /// **'Váš účet'**
  String get customerDisplayHeader;

  /// No description provided for @customerDisplaySubtotal.
  ///
  /// In cs, this message translates to:
  /// **'Mezisoučet'**
  String get customerDisplaySubtotal;

  /// No description provided for @customerDisplayDiscount.
  ///
  /// In cs, this message translates to:
  /// **'Sleva'**
  String get customerDisplayDiscount;

  /// No description provided for @customerDisplayTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celkem'**
  String get customerDisplayTotal;

  /// No description provided for @kdsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Kuchyně'**
  String get kdsTitle;

  /// No description provided for @kdsNoOrders.
  ///
  /// In cs, this message translates to:
  /// **'Žádné objednávky k přípravě'**
  String get kdsNoOrders;

  /// No description provided for @kdsBump.
  ///
  /// In cs, this message translates to:
  /// **'Další'**
  String get kdsBump;

  /// No description provided for @kdsMinAgo.
  ///
  /// In cs, this message translates to:
  /// **'{minutes} min'**
  String kdsMinAgo(String minutes);

  /// No description provided for @sellSeparator.
  ///
  /// In cs, this message translates to:
  /// **'Oddělit'**
  String get sellSeparator;

  /// No description provided for @sellSeparatorLabel.
  ///
  /// In cs, this message translates to:
  /// **'--- Další objednávka ---'**
  String get sellSeparatorLabel;

  /// No description provided for @customerEnterName.
  ///
  /// In cs, this message translates to:
  /// **'Zadat jméno'**
  String get customerEnterName;

  /// No description provided for @customerNameHint.
  ///
  /// In cs, this message translates to:
  /// **'Jméno hosta'**
  String get customerNameHint;

  /// No description provided for @settingsRegisters.
  ///
  /// In cs, this message translates to:
  /// **'Pokladny'**
  String get settingsRegisters;

  /// No description provided for @registerName.
  ///
  /// In cs, this message translates to:
  /// **'Název'**
  String get registerName;

  /// No description provided for @registerType.
  ///
  /// In cs, this message translates to:
  /// **'Typ'**
  String get registerType;

  /// No description provided for @registerNumber.
  ///
  /// In cs, this message translates to:
  /// **'Číslo'**
  String get registerNumber;

  /// No description provided for @registerParent.
  ///
  /// In cs, this message translates to:
  /// **'Nadřazená pokladna'**
  String get registerParent;

  /// No description provided for @registerAllowCash.
  ///
  /// In cs, this message translates to:
  /// **'Hotovost'**
  String get registerAllowCash;

  /// No description provided for @registerAllowCard.
  ///
  /// In cs, this message translates to:
  /// **'Karta'**
  String get registerAllowCard;

  /// No description provided for @registerAllowTransfer.
  ///
  /// In cs, this message translates to:
  /// **'Převod'**
  String get registerAllowTransfer;

  /// No description provided for @registerAllowCredit.
  ///
  /// In cs, this message translates to:
  /// **'Kredit'**
  String get registerAllowCredit;

  /// No description provided for @registerAllowVoucher.
  ///
  /// In cs, this message translates to:
  /// **'Stravenky'**
  String get registerAllowVoucher;

  /// No description provided for @registerAllowOther.
  ///
  /// In cs, this message translates to:
  /// **'Ostatní'**
  String get registerAllowOther;

  /// No description provided for @registerAllowRefunds.
  ///
  /// In cs, this message translates to:
  /// **'Refundy'**
  String get registerAllowRefunds;

  /// No description provided for @registerPaymentFlags.
  ///
  /// In cs, this message translates to:
  /// **'Povolené platby'**
  String get registerPaymentFlags;

  /// No description provided for @registerTypeLocal.
  ///
  /// In cs, this message translates to:
  /// **'Stacionární'**
  String get registerTypeLocal;

  /// No description provided for @registerTypeMobile.
  ///
  /// In cs, this message translates to:
  /// **'Mobilní'**
  String get registerTypeMobile;

  /// No description provided for @registerTypeVirtual.
  ///
  /// In cs, this message translates to:
  /// **'Virtuální'**
  String get registerTypeVirtual;

  /// No description provided for @registerDeviceBinding.
  ///
  /// In cs, this message translates to:
  /// **'Svázání zařízení'**
  String get registerDeviceBinding;

  /// No description provided for @registerBound.
  ///
  /// In cs, this message translates to:
  /// **'Svázáno s: {name}'**
  String registerBound(String name);

  /// No description provided for @registerNotBound.
  ///
  /// In cs, this message translates to:
  /// **'Nesvázáno'**
  String get registerNotBound;

  /// No description provided for @registerBind.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat pokladnu'**
  String get registerBind;

  /// No description provided for @registerUnbind.
  ///
  /// In cs, this message translates to:
  /// **'Odpojit'**
  String get registerUnbind;

  /// No description provided for @registerSelectTitle.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte pokladnu'**
  String get registerSelectTitle;

  /// No description provided for @registerNone.
  ///
  /// In cs, this message translates to:
  /// **'Žádná'**
  String get registerNone;

  /// No description provided for @registerIsMain.
  ///
  /// In cs, this message translates to:
  /// **'Hlavní'**
  String get registerIsMain;

  /// No description provided for @registerSetMain.
  ///
  /// In cs, this message translates to:
  /// **'Nastavit jako hlavní'**
  String get registerSetMain;

  /// No description provided for @registerBoundHere.
  ///
  /// In cs, this message translates to:
  /// **'Toto zařízení'**
  String get registerBoundHere;

  /// No description provided for @registerBindAction.
  ///
  /// In cs, this message translates to:
  /// **'Svázat'**
  String get registerBindAction;

  /// No description provided for @registerSessionActiveCannotChange.
  ///
  /// In cs, this message translates to:
  /// **'Nelze změnit svázání během aktivní směny.'**
  String get registerSessionActiveCannotChange;

  /// No description provided for @registerBoundOnOtherDevice.
  ///
  /// In cs, this message translates to:
  /// **'Používá jiné zařízení'**
  String get registerBoundOnOtherDevice;

  /// No description provided for @infoPanelRegisterName.
  ///
  /// In cs, this message translates to:
  /// **'Název pokladny'**
  String get infoPanelRegisterName;

  /// No description provided for @connectCompanySelectRegister.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte pokladnu'**
  String get connectCompanySelectRegister;

  /// No description provided for @connectCompanySelectRegisterSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte pokladnu pro toto zařízení'**
  String get connectCompanySelectRegisterSubtitle;

  /// No description provided for @connectCompanyNoRegisters.
  ///
  /// In cs, this message translates to:
  /// **'Žádné pokladny k dispozici'**
  String get connectCompanyNoRegisters;

  /// No description provided for @connectCompanyCreateRegister.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořit novou pokladnu'**
  String get connectCompanyCreateRegister;

  /// No description provided for @registerNotBoundMessage.
  ///
  /// In cs, this message translates to:
  /// **'Pokladna není přiřazena k tomuto zařízení. Přiřaďte pokladnu v Nastavení.'**
  String get registerNotBoundMessage;

  /// No description provided for @modeTitle.
  ///
  /// In cs, this message translates to:
  /// **'Režim'**
  String get modeTitle;

  /// No description provided for @modePOS.
  ///
  /// In cs, this message translates to:
  /// **'Pokladna'**
  String get modePOS;

  /// No description provided for @modeKDS.
  ///
  /// In cs, this message translates to:
  /// **'Objednávkový displej'**
  String get modeKDS;

  /// No description provided for @modeCustomerDisplay.
  ///
  /// In cs, this message translates to:
  /// **'Zákaznický displej'**
  String get modeCustomerDisplay;

  /// No description provided for @customerDisplayThankYou.
  ///
  /// In cs, this message translates to:
  /// **'Děkujeme!'**
  String get customerDisplayThankYou;

  /// No description provided for @customerDisplayPaid.
  ///
  /// In cs, this message translates to:
  /// **'Zaplaceno'**
  String get customerDisplayPaid;

  /// No description provided for @billDetailShowOnDisplay.
  ///
  /// In cs, this message translates to:
  /// **'Zák. displej'**
  String get billDetailShowOnDisplay;

  /// No description provided for @onboardingSectionPos.
  ///
  /// In cs, this message translates to:
  /// **'Pokladna'**
  String get onboardingSectionPos;

  /// No description provided for @onboardingSectionDisplays.
  ///
  /// In cs, this message translates to:
  /// **'Displeje'**
  String get onboardingSectionDisplays;

  /// No description provided for @onboardingCustomerDisplay.
  ///
  /// In cs, this message translates to:
  /// **'Zákaznický displej'**
  String get onboardingCustomerDisplay;

  /// No description provided for @onboardingKdsDisplay.
  ///
  /// In cs, this message translates to:
  /// **'Objednávkový displej (KDS)'**
  String get onboardingKdsDisplay;

  /// No description provided for @displayCodeTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte kód'**
  String get displayCodeTitle;

  /// No description provided for @displayCodeSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte 6-místný kód zobrazený na pokladně'**
  String get displayCodeSubtitle;

  /// No description provided for @displayCodeConnect.
  ///
  /// In cs, this message translates to:
  /// **'Připojit'**
  String get displayCodeConnect;

  /// No description provided for @displayCodeBack.
  ///
  /// In cs, this message translates to:
  /// **'Zpět'**
  String get displayCodeBack;

  /// No description provided for @displayCodeNotFound.
  ///
  /// In cs, this message translates to:
  /// **'Kód nenalezen'**
  String get displayCodeNotFound;

  /// No description provided for @displayCodeError.
  ///
  /// In cs, this message translates to:
  /// **'Chyba při hledání kódu'**
  String get displayCodeError;

  /// No description provided for @displayCodeWaitingForConfirmation.
  ///
  /// In cs, this message translates to:
  /// **'Čeká se na potvrzení obsluhou…'**
  String get displayCodeWaitingForConfirmation;

  /// No description provided for @displayCodeRejected.
  ///
  /// In cs, this message translates to:
  /// **'Připojení bylo zamítnuto'**
  String get displayCodeRejected;

  /// No description provided for @displayCodeTimeout.
  ///
  /// In cs, this message translates to:
  /// **'Obsluha neodpověděla. Zkuste to znovu.'**
  String get displayCodeTimeout;

  /// No description provided for @pairingRequestTitle.
  ///
  /// In cs, this message translates to:
  /// **'Žádost o připojení'**
  String get pairingRequestTitle;

  /// No description provided for @pairingRequestMessage.
  ///
  /// In cs, this message translates to:
  /// **'Zařízení se chce připojit k této pokladně:'**
  String get pairingRequestMessage;

  /// No description provided for @pairingRequestCode.
  ///
  /// In cs, this message translates to:
  /// **'Kód'**
  String get pairingRequestCode;

  /// No description provided for @pairingConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Potvrdit'**
  String get pairingConfirm;

  /// No description provided for @pairingReject.
  ///
  /// In cs, this message translates to:
  /// **'Zamítnout'**
  String get pairingReject;

  /// No description provided for @displayDevicesTitle.
  ///
  /// In cs, this message translates to:
  /// **'Displeje'**
  String get displayDevicesTitle;

  /// No description provided for @displayDevicesEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Žádné displeje'**
  String get displayDevicesEmpty;

  /// No description provided for @displayDeviceAddCustomer.
  ///
  /// In cs, this message translates to:
  /// **'Zákaznický'**
  String get displayDeviceAddCustomer;

  /// No description provided for @displayDeviceAddKds.
  ///
  /// In cs, this message translates to:
  /// **'KDS'**
  String get displayDeviceAddKds;

  /// No description provided for @displayWelcomeText.
  ///
  /// In cs, this message translates to:
  /// **'Uvítací text'**
  String get displayWelcomeText;

  /// No description provided for @displayDefaultNameKds.
  ///
  /// In cs, this message translates to:
  /// **'Objednávkový systém'**
  String get displayDefaultNameKds;

  /// No description provided for @displayDefaultWelcomeText.
  ///
  /// In cs, this message translates to:
  /// **'Vítejte u nás!'**
  String get displayDefaultWelcomeText;

  /// No description provided for @wizardStepAccount.
  ///
  /// In cs, this message translates to:
  /// **'Cloudový účet'**
  String get wizardStepAccount;

  /// No description provided for @wizardAccountEmail.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get wizardAccountEmail;

  /// No description provided for @wizardAccountPassword.
  ///
  /// In cs, this message translates to:
  /// **'Heslo'**
  String get wizardAccountPassword;

  /// No description provided for @wizardAccountPasswordConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Potvrzení hesla'**
  String get wizardAccountPasswordConfirm;

  /// No description provided for @wizardAccountPasswordMismatch.
  ///
  /// In cs, this message translates to:
  /// **'Hesla se neshodují'**
  String get wizardAccountPasswordMismatch;

  /// No description provided for @wizardAccountSignUp.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořit účet'**
  String get wizardAccountSignUp;

  /// No description provided for @wizardAccountSignIn.
  ///
  /// In cs, this message translates to:
  /// **'Přihlásit se'**
  String get wizardAccountSignIn;

  /// No description provided for @wizardAccountSwitchToSignIn.
  ///
  /// In cs, this message translates to:
  /// **'Máte účet? Přihlaste se'**
  String get wizardAccountSwitchToSignIn;

  /// No description provided for @wizardAccountSwitchToSignUp.
  ///
  /// In cs, this message translates to:
  /// **'Nemáte účet? Vytvořte si ho'**
  String get wizardAccountSwitchToSignUp;

  /// No description provided for @cloudConnectedAs.
  ///
  /// In cs, this message translates to:
  /// **'Připojeno jako {email}'**
  String cloudConnectedAs(String email);

  /// No description provided for @actionExitApp.
  ///
  /// In cs, this message translates to:
  /// **'Ukončit aplikaci'**
  String get actionExitApp;

  /// No description provided for @actionOk.
  ///
  /// In cs, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @errorGeneric.
  ///
  /// In cs, this message translates to:
  /// **'Chyba: {error}'**
  String errorGeneric(Object error);

  /// No description provided for @loyaltyMaxPoints.
  ///
  /// In cs, this message translates to:
  /// **'Max: {points}'**
  String loyaltyMaxPoints(Object points);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In cs, this message translates to:
  /// **'{h} h {m} min'**
  String durationHoursMinutes(int h, int m);

  /// No description provided for @durationHoursOnly.
  ///
  /// In cs, this message translates to:
  /// **'{h} h'**
  String durationHoursOnly(int h);

  /// No description provided for @durationMinutesOnly.
  ///
  /// In cs, this message translates to:
  /// **'{m} min'**
  String durationMinutesOnly(int m);

  /// No description provided for @variantPickerTitle.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte variantu'**
  String get variantPickerTitle;

  /// No description provided for @addVariant.
  ///
  /// In cs, this message translates to:
  /// **'Přidat variantu'**
  String get addVariant;

  /// No description provided for @editVariant.
  ///
  /// In cs, this message translates to:
  /// **'Upravit variantu'**
  String get editVariant;

  /// No description provided for @variants.
  ///
  /// In cs, this message translates to:
  /// **'Varianty'**
  String get variants;

  /// No description provided for @noVariants.
  ///
  /// In cs, this message translates to:
  /// **'Žádné varianty'**
  String get noVariants;

  /// No description provided for @modifiers.
  ///
  /// In cs, this message translates to:
  /// **'Modifikátory'**
  String get modifiers;

  /// No description provided for @modifierGroups.
  ///
  /// In cs, this message translates to:
  /// **'Skupiny modifikátorů'**
  String get modifierGroups;

  /// No description provided for @modifierGroupName.
  ///
  /// In cs, this message translates to:
  /// **'Název skupiny'**
  String get modifierGroupName;

  /// No description provided for @addModifierGroup.
  ///
  /// In cs, this message translates to:
  /// **'Přidat skupinu'**
  String get addModifierGroup;

  /// No description provided for @editModifierGroup.
  ///
  /// In cs, this message translates to:
  /// **'Upravit skupinu'**
  String get editModifierGroup;

  /// No description provided for @deleteModifierGroup.
  ///
  /// In cs, this message translates to:
  /// **'Smazat skupinu'**
  String get deleteModifierGroup;

  /// No description provided for @minSelections.
  ///
  /// In cs, this message translates to:
  /// **'Min. výběr'**
  String get minSelections;

  /// No description provided for @maxSelections.
  ///
  /// In cs, this message translates to:
  /// **'Max. výběr'**
  String get maxSelections;

  /// No description provided for @required.
  ///
  /// In cs, this message translates to:
  /// **'Povinné'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In cs, this message translates to:
  /// **'Volitelné'**
  String get optional;

  /// No description provided for @unlimited.
  ///
  /// In cs, this message translates to:
  /// **'Neomezeno'**
  String get unlimited;

  /// No description provided for @addModifier.
  ///
  /// In cs, this message translates to:
  /// **'Přidat modifikátor'**
  String get addModifier;

  /// No description provided for @selectModifiers.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat modifikátory'**
  String get selectModifiers;

  /// No description provided for @editModifiers.
  ///
  /// In cs, this message translates to:
  /// **'Upravit modifikátory'**
  String get editModifiers;

  /// No description provided for @noModifierGroups.
  ///
  /// In cs, this message translates to:
  /// **'Žádné skupiny modifikátorů'**
  String get noModifierGroups;

  /// No description provided for @modifierTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celkem s modifikátory'**
  String get modifierTotal;

  /// No description provided for @modifierGroupRequired.
  ///
  /// In cs, this message translates to:
  /// **'Povinná skupina'**
  String get modifierGroupRequired;

  /// No description provided for @assignModifierGroup.
  ///
  /// In cs, this message translates to:
  /// **'Přiřadit skupinu'**
  String get assignModifierGroup;

  /// No description provided for @removeModifierGroup.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat skupinu'**
  String get removeModifierGroup;

  /// No description provided for @inventoryTypeTitle.
  ///
  /// In cs, this message translates to:
  /// **'Typ inventury'**
  String get inventoryTypeTitle;

  /// No description provided for @inventoryTypeComplete.
  ///
  /// In cs, this message translates to:
  /// **'Kompletní'**
  String get inventoryTypeComplete;

  /// No description provided for @inventoryTypeCompleteDesc.
  ///
  /// In cs, this message translates to:
  /// **'Všechny sledované položky'**
  String get inventoryTypeCompleteDesc;

  /// No description provided for @inventoryTypeByCategory.
  ///
  /// In cs, this message translates to:
  /// **'Dle kategorií'**
  String get inventoryTypeByCategory;

  /// No description provided for @inventoryTypeByCategoryDesc.
  ///
  /// In cs, this message translates to:
  /// **'Položky vybraných kategorií'**
  String get inventoryTypeByCategoryDesc;

  /// No description provided for @inventoryTypeBySupplier.
  ///
  /// In cs, this message translates to:
  /// **'Dle dodavatele'**
  String get inventoryTypeBySupplier;

  /// No description provided for @inventoryTypeBySupplierDesc.
  ///
  /// In cs, this message translates to:
  /// **'Položky vybraných dodavatelů'**
  String get inventoryTypeBySupplierDesc;

  /// No description provided for @inventoryTypeByManufacturer.
  ///
  /// In cs, this message translates to:
  /// **'Dle výrobce'**
  String get inventoryTypeByManufacturer;

  /// No description provided for @inventoryTypeByManufacturerDesc.
  ///
  /// In cs, this message translates to:
  /// **'Položky vybraných výrobců'**
  String get inventoryTypeByManufacturerDesc;

  /// No description provided for @inventoryTypeSelective.
  ///
  /// In cs, this message translates to:
  /// **'Selektivní'**
  String get inventoryTypeSelective;

  /// No description provided for @inventoryTypeSelectiveDesc.
  ///
  /// In cs, this message translates to:
  /// **'Ruční výběr položek'**
  String get inventoryTypeSelectiveDesc;

  /// No description provided for @inventoryTypeContinue.
  ///
  /// In cs, this message translates to:
  /// **'Pokračovat'**
  String get inventoryTypeContinue;

  /// No description provided for @inventoryTypeNoItems.
  ///
  /// In cs, this message translates to:
  /// **'Žádné položky k výběru'**
  String get inventoryTypeNoItems;

  /// No description provided for @inventoryBlindMode.
  ///
  /// In cs, this message translates to:
  /// **'Slepá inventura'**
  String get inventoryBlindMode;

  /// No description provided for @inventoryBlindModeDesc.
  ///
  /// In cs, this message translates to:
  /// **'Bez zobrazení předpokládaných stavů'**
  String get inventoryBlindModeDesc;

  /// No description provided for @inventoryPrintTemplate.
  ///
  /// In cs, this message translates to:
  /// **'Tisk předlohy'**
  String get inventoryPrintTemplate;

  /// No description provided for @inventoryResultTitle.
  ///
  /// In cs, this message translates to:
  /// **'Výsledky inventury'**
  String get inventoryResultTitle;

  /// No description provided for @inventoryResultSurplus.
  ///
  /// In cs, this message translates to:
  /// **'Přebytek'**
  String get inventoryResultSurplus;

  /// No description provided for @inventoryResultShortage.
  ///
  /// In cs, this message translates to:
  /// **'Manko'**
  String get inventoryResultShortage;

  /// No description provided for @inventoryResultItemCount.
  ///
  /// In cs, this message translates to:
  /// **'{count} položek'**
  String inventoryResultItemCount(int count);

  /// No description provided for @inventoryResultApply.
  ///
  /// In cs, this message translates to:
  /// **'Opravit sklad'**
  String get inventoryResultApply;

  /// No description provided for @inventoryResultApplied.
  ///
  /// In cs, this message translates to:
  /// **'Opraveno'**
  String get inventoryResultApplied;

  /// No description provided for @inventoryResultPrint.
  ///
  /// In cs, this message translates to:
  /// **'Tisknout výsledky'**
  String get inventoryResultPrint;

  /// No description provided for @inventoryResultExpected.
  ///
  /// In cs, this message translates to:
  /// **'Předpoklad'**
  String get inventoryResultExpected;

  /// No description provided for @inventoryResultActual.
  ///
  /// In cs, this message translates to:
  /// **'Zjištěný'**
  String get inventoryResultActual;

  /// No description provided for @inventoryPdfTemplateTitle.
  ///
  /// In cs, this message translates to:
  /// **'INVENTURA — PŘEDLOHA'**
  String get inventoryPdfTemplateTitle;

  /// No description provided for @inventoryPdfResultsTitle.
  ///
  /// In cs, this message translates to:
  /// **'INVENTURA — VÝSLEDKY'**
  String get inventoryPdfResultsTitle;

  /// No description provided for @inventoryResultClose.
  ///
  /// In cs, this message translates to:
  /// **'Zavřít'**
  String get inventoryResultClose;

  /// No description provided for @inventoryResultNcValue.
  ///
  /// In cs, this message translates to:
  /// **'NC'**
  String get inventoryResultNcValue;

  /// No description provided for @tipStatsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Spropitné'**
  String get tipStatsTitle;

  /// No description provided for @tipStatsTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celkem'**
  String get tipStatsTotal;

  /// No description provided for @tipStatsColumnUser.
  ///
  /// In cs, this message translates to:
  /// **'Obsluha'**
  String get tipStatsColumnUser;

  /// No description provided for @tipStatsColumnCount.
  ///
  /// In cs, this message translates to:
  /// **'Počet'**
  String get tipStatsColumnCount;

  /// No description provided for @tipStatsColumnAmount.
  ///
  /// In cs, this message translates to:
  /// **'Částka'**
  String get tipStatsColumnAmount;

  /// No description provided for @tipStatsEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Žádné spropitné v tomto období'**
  String get tipStatsEmpty;

  /// No description provided for @moreTipStatistics.
  ///
  /// In cs, this message translates to:
  /// **'Spropitné'**
  String get moreTipStatistics;

  /// No description provided for @periodDay.
  ///
  /// In cs, this message translates to:
  /// **'Den'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In cs, this message translates to:
  /// **'Týden'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In cs, this message translates to:
  /// **'Měsíc'**
  String get periodMonth;

  /// No description provided for @periodYear.
  ///
  /// In cs, this message translates to:
  /// **'Rok'**
  String get periodYear;

  /// No description provided for @periodCustom.
  ///
  /// In cs, this message translates to:
  /// **'Vlastní'**
  String get periodCustom;

  /// No description provided for @periodToday.
  ///
  /// In cs, this message translates to:
  /// **'Dnes'**
  String get periodToday;

  /// No description provided for @periodYesterday.
  ///
  /// In cs, this message translates to:
  /// **'Včera'**
  String get periodYesterday;

  /// No description provided for @periodThisWeek.
  ///
  /// In cs, this message translates to:
  /// **'Tento týden'**
  String get periodThisWeek;

  /// No description provided for @periodLastWeek.
  ///
  /// In cs, this message translates to:
  /// **'Minulý týden'**
  String get periodLastWeek;

  /// No description provided for @periodThisMonth.
  ///
  /// In cs, this message translates to:
  /// **'Tento měsíc'**
  String get periodThisMonth;

  /// No description provided for @periodLastMonth.
  ///
  /// In cs, this message translates to:
  /// **'Minulý měsíc'**
  String get periodLastMonth;

  /// No description provided for @periodThisYear.
  ///
  /// In cs, this message translates to:
  /// **'Letošní rok'**
  String get periodThisYear;

  /// No description provided for @periodLastYear.
  ///
  /// In cs, this message translates to:
  /// **'Loňský rok'**
  String get periodLastYear;

  /// No description provided for @statsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Statistiky'**
  String get statsTitle;

  /// No description provided for @statsTabReceipts.
  ///
  /// In cs, this message translates to:
  /// **'Účtenky'**
  String get statsTabReceipts;

  /// No description provided for @statsTabSales.
  ///
  /// In cs, this message translates to:
  /// **'Prodeje'**
  String get statsTabSales;

  /// No description provided for @statsTabShifts.
  ///
  /// In cs, this message translates to:
  /// **'Směny'**
  String get statsTabShifts;

  /// No description provided for @statsTabZReports.
  ///
  /// In cs, this message translates to:
  /// **'Z-reporty'**
  String get statsTabZReports;

  /// No description provided for @statsTabTips.
  ///
  /// In cs, this message translates to:
  /// **'Spropitné'**
  String get statsTabTips;

  /// No description provided for @statsSummary.
  ///
  /// In cs, this message translates to:
  /// **'Souhrn'**
  String get statsSummary;

  /// No description provided for @statsReceiptCount.
  ///
  /// In cs, this message translates to:
  /// **'Počet účtenek'**
  String get statsReceiptCount;

  /// No description provided for @statsReceiptTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celková tržba'**
  String get statsReceiptTotal;

  /// No description provided for @statsReceiptAvg.
  ///
  /// In cs, this message translates to:
  /// **'Průměrná účtenka'**
  String get statsReceiptAvg;

  /// No description provided for @statsSalesItemCount.
  ///
  /// In cs, this message translates to:
  /// **'Prodaných položek'**
  String get statsSalesItemCount;

  /// No description provided for @statsSalesTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celková tržba'**
  String get statsSalesTotal;

  /// No description provided for @statsSalesUniqueItems.
  ///
  /// In cs, this message translates to:
  /// **'Unikátních položek'**
  String get statsSalesUniqueItems;

  /// No description provided for @statsShiftCount.
  ///
  /// In cs, this message translates to:
  /// **'Počet směn'**
  String get statsShiftCount;

  /// No description provided for @statsShiftTotalHours.
  ///
  /// In cs, this message translates to:
  /// **'Celkem hodin'**
  String get statsShiftTotalHours;

  /// No description provided for @statsShiftAvgDuration.
  ///
  /// In cs, this message translates to:
  /// **'Průměrná směna'**
  String get statsShiftAvgDuration;

  /// No description provided for @statsZReportCount.
  ///
  /// In cs, this message translates to:
  /// **'Počet uzávěrek'**
  String get statsZReportCount;

  /// No description provided for @statsZReportTotalRevenue.
  ///
  /// In cs, this message translates to:
  /// **'Celková tržba'**
  String get statsZReportTotalRevenue;

  /// No description provided for @statsZReportTotalDiff.
  ///
  /// In cs, this message translates to:
  /// **'Celkový rozdíl'**
  String get statsZReportTotalDiff;

  /// No description provided for @statsTipCount.
  ///
  /// In cs, this message translates to:
  /// **'Počet spropitných'**
  String get statsTipCount;

  /// No description provided for @statsTipTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celkem spropitné'**
  String get statsTipTotal;

  /// No description provided for @statsTipAvg.
  ///
  /// In cs, this message translates to:
  /// **'Průměrné spropitné'**
  String get statsTipAvg;

  /// No description provided for @statsEmpty.
  ///
  /// In cs, this message translates to:
  /// **'Žádná data v tomto období'**
  String get statsEmpty;

  /// No description provided for @statsSortDate.
  ///
  /// In cs, this message translates to:
  /// **'Datum'**
  String get statsSortDate;

  /// No description provided for @statsSortDateAsc.
  ///
  /// In cs, this message translates to:
  /// **'Datum (nejstarší)'**
  String get statsSortDateAsc;

  /// No description provided for @statsSortAmount.
  ///
  /// In cs, this message translates to:
  /// **'Částka'**
  String get statsSortAmount;

  /// No description provided for @statsSortAmountAsc.
  ///
  /// In cs, this message translates to:
  /// **'Částka (nejmenší)'**
  String get statsSortAmountAsc;

  /// No description provided for @statsSortName.
  ///
  /// In cs, this message translates to:
  /// **'Název'**
  String get statsSortName;

  /// No description provided for @statsSortNameDesc.
  ///
  /// In cs, this message translates to:
  /// **'Název (Z→A)'**
  String get statsSortNameDesc;

  /// No description provided for @statsSortQty.
  ///
  /// In cs, this message translates to:
  /// **'Množství'**
  String get statsSortQty;

  /// No description provided for @statsSortDuration.
  ///
  /// In cs, this message translates to:
  /// **'Délka'**
  String get statsSortDuration;

  /// No description provided for @statsSortRevenue.
  ///
  /// In cs, this message translates to:
  /// **'Tržba'**
  String get statsSortRevenue;

  /// No description provided for @statsColumnBillNumber.
  ///
  /// In cs, this message translates to:
  /// **'Číslo'**
  String get statsColumnBillNumber;

  /// No description provided for @statsColumnCustomer.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník'**
  String get statsColumnCustomer;

  /// No description provided for @statsColumnPaymentMethod.
  ///
  /// In cs, this message translates to:
  /// **'Platba'**
  String get statsColumnPaymentMethod;

  /// No description provided for @statsColumnTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celkem'**
  String get statsColumnTotal;

  /// No description provided for @statsColumnItemName.
  ///
  /// In cs, this message translates to:
  /// **'Položka'**
  String get statsColumnItemName;

  /// No description provided for @statsColumnQty.
  ///
  /// In cs, this message translates to:
  /// **'Mn.'**
  String get statsColumnQty;

  /// No description provided for @statsColumnUnitPrice.
  ///
  /// In cs, this message translates to:
  /// **'Cena/ks'**
  String get statsColumnUnitPrice;

  /// No description provided for @statsColumnBill.
  ///
  /// In cs, this message translates to:
  /// **'Účtenka'**
  String get statsColumnBill;

  /// No description provided for @statsColumnDateTime.
  ///
  /// In cs, this message translates to:
  /// **'Datum a čas'**
  String get statsColumnDateTime;

  /// No description provided for @statsColumnCategory.
  ///
  /// In cs, this message translates to:
  /// **'Kategorie'**
  String get statsColumnCategory;

  /// No description provided for @statsColumnTax.
  ///
  /// In cs, this message translates to:
  /// **'DPH'**
  String get statsColumnTax;

  /// No description provided for @statsColumnOrderNumber.
  ///
  /// In cs, this message translates to:
  /// **'Obj. č.'**
  String get statsColumnOrderNumber;

  /// No description provided for @statsColumnStatus.
  ///
  /// In cs, this message translates to:
  /// **'Stav'**
  String get statsColumnStatus;

  /// No description provided for @statsTabOrders.
  ///
  /// In cs, this message translates to:
  /// **'Objednávky'**
  String get statsTabOrders;

  /// No description provided for @statsOrderCount.
  ///
  /// In cs, this message translates to:
  /// **'Počet objednávek'**
  String get statsOrderCount;

  /// No description provided for @statsOrderTotalItems.
  ///
  /// In cs, this message translates to:
  /// **'Celkem položek'**
  String get statsOrderTotalItems;

  /// No description provided for @statsOrderTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celková částka'**
  String get statsOrderTotal;

  /// No description provided for @orderStorno.
  ///
  /// In cs, this message translates to:
  /// **'Storno'**
  String get orderStorno;

  /// No description provided for @statsSalesGrossRevenue.
  ///
  /// In cs, this message translates to:
  /// **'Hrubá tržba (položky)'**
  String get statsSalesGrossRevenue;

  /// No description provided for @statsSalesItemDiscounts.
  ///
  /// In cs, this message translates to:
  /// **'Slevy na položky'**
  String get statsSalesItemDiscounts;

  /// No description provided for @statsSalesBillDiscount.
  ///
  /// In cs, this message translates to:
  /// **'Sleva na účtenku'**
  String get statsSalesBillDiscount;

  /// No description provided for @statsSalesLoyaltyDiscount.
  ///
  /// In cs, this message translates to:
  /// **'Věrnostní sleva'**
  String get statsSalesLoyaltyDiscount;

  /// No description provided for @statsSalesVoucherDiscount.
  ///
  /// In cs, this message translates to:
  /// **'Voucherová sleva'**
  String get statsSalesVoucherDiscount;

  /// No description provided for @statsSalesRounding.
  ///
  /// In cs, this message translates to:
  /// **'Zaokrouhlení'**
  String get statsSalesRounding;

  /// No description provided for @statsSalesFinalTotal.
  ///
  /// In cs, this message translates to:
  /// **'Celkem (účtenky)'**
  String get statsSalesFinalTotal;

  /// No description provided for @sellEnterQuantity.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte množství'**
  String get sellEnterQuantity;

  /// No description provided for @statsFilterTitle.
  ///
  /// In cs, this message translates to:
  /// **'Filtr'**
  String get statsFilterTitle;

  /// No description provided for @statsFilterPaymentMethod.
  ///
  /// In cs, this message translates to:
  /// **'Typ platby'**
  String get statsFilterPaymentMethod;

  /// No description provided for @statsFilterTakeaway.
  ///
  /// In cs, this message translates to:
  /// **'Typ'**
  String get statsFilterTakeaway;

  /// No description provided for @statsFilterAll.
  ///
  /// In cs, this message translates to:
  /// **'Vše'**
  String get statsFilterAll;

  /// No description provided for @statsFilterDineIn.
  ///
  /// In cs, this message translates to:
  /// **'Na místě'**
  String get statsFilterDineIn;

  /// No description provided for @statsFilterTakeawayOnly.
  ///
  /// In cs, this message translates to:
  /// **'S sebou'**
  String get statsFilterTakeawayOnly;

  /// No description provided for @statsFilterCategory.
  ///
  /// In cs, this message translates to:
  /// **'Kategorie'**
  String get statsFilterCategory;

  /// No description provided for @statsFilterStatus.
  ///
  /// In cs, this message translates to:
  /// **'Stav'**
  String get statsFilterStatus;

  /// No description provided for @statsFilterApply.
  ///
  /// In cs, this message translates to:
  /// **'Použít'**
  String get statsFilterApply;

  /// No description provided for @statsFilterStorno.
  ///
  /// In cs, this message translates to:
  /// **'Storno'**
  String get statsFilterStorno;

  /// No description provided for @statsFilterDiscount.
  ///
  /// In cs, this message translates to:
  /// **'Sleva'**
  String get statsFilterDiscount;

  /// No description provided for @statsFilterWithDiscount.
  ///
  /// In cs, this message translates to:
  /// **'Se slevou'**
  String get statsFilterWithDiscount;

  /// No description provided for @statsFilterWithoutDiscount.
  ///
  /// In cs, this message translates to:
  /// **'Bez slevy'**
  String get statsFilterWithoutDiscount;

  /// No description provided for @permOrdersCreate.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořit objednávku'**
  String get permOrdersCreate;

  /// No description provided for @permOrdersView.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit vlastní objednávky'**
  String get permOrdersView;

  /// No description provided for @permOrdersViewAll.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit všechny objednávky'**
  String get permOrdersViewAll;

  /// No description provided for @permOrdersViewPaid.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit zaplacené účty'**
  String get permOrdersViewPaid;

  /// No description provided for @permOrdersViewCancelled.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit stornované účty'**
  String get permOrdersViewCancelled;

  /// No description provided for @permOrdersViewDetail.
  ///
  /// In cs, this message translates to:
  /// **'Detail objednávky v info panelu'**
  String get permOrdersViewDetail;

  /// No description provided for @permOrdersEdit.
  ///
  /// In cs, this message translates to:
  /// **'Upravit objednávku'**
  String get permOrdersEdit;

  /// No description provided for @permOrdersEditOthers.
  ///
  /// In cs, this message translates to:
  /// **'Upravit cizí objednávky'**
  String get permOrdersEditOthers;

  /// No description provided for @permOrdersVoidItem.
  ///
  /// In cs, this message translates to:
  /// **'Storno položky'**
  String get permOrdersVoidItem;

  /// No description provided for @permOrdersVoidBill.
  ///
  /// In cs, this message translates to:
  /// **'Storno účtu'**
  String get permOrdersVoidBill;

  /// No description provided for @permOrdersReopen.
  ///
  /// In cs, this message translates to:
  /// **'Znovu otevřít účet'**
  String get permOrdersReopen;

  /// No description provided for @permOrdersTransfer.
  ///
  /// In cs, this message translates to:
  /// **'Přesunout účet'**
  String get permOrdersTransfer;

  /// No description provided for @permOrdersSplit.
  ///
  /// In cs, this message translates to:
  /// **'Rozdělit účet'**
  String get permOrdersSplit;

  /// No description provided for @permOrdersMerge.
  ///
  /// In cs, this message translates to:
  /// **'Sloučit účty'**
  String get permOrdersMerge;

  /// No description provided for @permOrdersAssignCustomer.
  ///
  /// In cs, this message translates to:
  /// **'Přiřadit zákazníka'**
  String get permOrdersAssignCustomer;

  /// No description provided for @permOrdersBump.
  ///
  /// In cs, this message translates to:
  /// **'Posunout stav'**
  String get permOrdersBump;

  /// No description provided for @permOrdersBumpBack.
  ///
  /// In cs, this message translates to:
  /// **'Vrátit stav'**
  String get permOrdersBumpBack;

  /// No description provided for @permPaymentsAccept.
  ///
  /// In cs, this message translates to:
  /// **'Přijmout platbu'**
  String get permPaymentsAccept;

  /// No description provided for @permPaymentsRefund.
  ///
  /// In cs, this message translates to:
  /// **'Vrátit platbu'**
  String get permPaymentsRefund;

  /// No description provided for @permPaymentsRefundItem.
  ///
  /// In cs, this message translates to:
  /// **'Vrátit položku'**
  String get permPaymentsRefundItem;

  /// No description provided for @permPaymentsMethodCash.
  ///
  /// In cs, this message translates to:
  /// **'Platba hotovostí'**
  String get permPaymentsMethodCash;

  /// No description provided for @permPaymentsMethodCard.
  ///
  /// In cs, this message translates to:
  /// **'Platba kartou'**
  String get permPaymentsMethodCard;

  /// No description provided for @permPaymentsMethodVoucher.
  ///
  /// In cs, this message translates to:
  /// **'Platba voucherem'**
  String get permPaymentsMethodVoucher;

  /// No description provided for @permPaymentsMethodMealTicket.
  ///
  /// In cs, this message translates to:
  /// **'Platba stravenkami'**
  String get permPaymentsMethodMealTicket;

  /// No description provided for @permPaymentsMethodCredit.
  ///
  /// In cs, this message translates to:
  /// **'Platba na kredit'**
  String get permPaymentsMethodCredit;

  /// No description provided for @permPaymentsSkipCashDialog.
  ///
  /// In cs, this message translates to:
  /// **'Přeskočit dialog hotovosti'**
  String get permPaymentsSkipCashDialog;

  /// No description provided for @permPaymentsAcceptTip.
  ///
  /// In cs, this message translates to:
  /// **'Přijmout spropitné'**
  String get permPaymentsAcceptTip;

  /// No description provided for @permPaymentsAdjustTip.
  ///
  /// In cs, this message translates to:
  /// **'Upravit spropitné'**
  String get permPaymentsAdjustTip;

  /// No description provided for @permDiscountsApplyItem.
  ///
  /// In cs, this message translates to:
  /// **'Sleva na položku'**
  String get permDiscountsApplyItem;

  /// No description provided for @permDiscountsApplyBill.
  ///
  /// In cs, this message translates to:
  /// **'Sleva na účet'**
  String get permDiscountsApplyBill;

  /// No description provided for @permDiscountsCustom.
  ///
  /// In cs, this message translates to:
  /// **'Vlastní sleva'**
  String get permDiscountsCustom;

  /// No description provided for @permDiscountsPriceOverride.
  ///
  /// In cs, this message translates to:
  /// **'Přepsat cenu'**
  String get permDiscountsPriceOverride;

  /// No description provided for @permDiscountsLoyalty.
  ///
  /// In cs, this message translates to:
  /// **'Věrnostní sleva'**
  String get permDiscountsLoyalty;

  /// No description provided for @permRegisterOpenSession.
  ///
  /// In cs, this message translates to:
  /// **'Otevřít pokladnu'**
  String get permRegisterOpenSession;

  /// No description provided for @permRegisterCloseSession.
  ///
  /// In cs, this message translates to:
  /// **'Uzavřít pokladnu'**
  String get permRegisterCloseSession;

  /// No description provided for @permRegisterViewSession.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit stav pokladny'**
  String get permRegisterViewSession;

  /// No description provided for @permRegisterViewAllSessions.
  ///
  /// In cs, this message translates to:
  /// **'Historie uzávěrek'**
  String get permRegisterViewAllSessions;

  /// No description provided for @permRegisterCashIn.
  ///
  /// In cs, this message translates to:
  /// **'Vklad hotovosti'**
  String get permRegisterCashIn;

  /// No description provided for @permRegisterCashOut.
  ///
  /// In cs, this message translates to:
  /// **'Výběr hotovosti'**
  String get permRegisterCashOut;

  /// No description provided for @permRegisterOpenDrawer.
  ///
  /// In cs, this message translates to:
  /// **'Otevřít zásuvku'**
  String get permRegisterOpenDrawer;

  /// No description provided for @permShiftsClockInOut.
  ///
  /// In cs, this message translates to:
  /// **'Příchod/odchod'**
  String get permShiftsClockInOut;

  /// No description provided for @permShiftsViewOwn.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit vlastní směny'**
  String get permShiftsViewOwn;

  /// No description provided for @permShiftsViewAll.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit všechny směny'**
  String get permShiftsViewAll;

  /// No description provided for @permShiftsManage.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat směny'**
  String get permShiftsManage;

  /// No description provided for @permProductsView.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit produkty'**
  String get permProductsView;

  /// No description provided for @permProductsViewCost.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit nákupní ceny'**
  String get permProductsViewCost;

  /// No description provided for @permProductsManage.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat produkty'**
  String get permProductsManage;

  /// No description provided for @permProductsManageCategories.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat kategorie'**
  String get permProductsManageCategories;

  /// No description provided for @permProductsManageModifiers.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat modifikátory'**
  String get permProductsManageModifiers;

  /// No description provided for @permProductsManageRecipes.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat receptury'**
  String get permProductsManageRecipes;

  /// No description provided for @permProductsManagePurchasePrice.
  ///
  /// In cs, this message translates to:
  /// **'Měnit nákupní ceny'**
  String get permProductsManagePurchasePrice;

  /// No description provided for @permProductsManageTax.
  ///
  /// In cs, this message translates to:
  /// **'Měnit daňové sazby'**
  String get permProductsManageTax;

  /// No description provided for @permProductsManageSuppliers.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat dodavatele'**
  String get permProductsManageSuppliers;

  /// No description provided for @permProductsManageManufacturers.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat výrobce'**
  String get permProductsManageManufacturers;

  /// No description provided for @permProductsSetAvailability.
  ///
  /// In cs, this message translates to:
  /// **'Označit nedostupnost'**
  String get permProductsSetAvailability;

  /// No description provided for @permStockView.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit sklad'**
  String get permStockView;

  /// No description provided for @permStockReceive.
  ///
  /// In cs, this message translates to:
  /// **'Příjem zboží'**
  String get permStockReceive;

  /// No description provided for @permStockWastage.
  ///
  /// In cs, this message translates to:
  /// **'Zaznamenat odpis'**
  String get permStockWastage;

  /// No description provided for @permStockAdjust.
  ///
  /// In cs, this message translates to:
  /// **'Korekce skladu'**
  String get permStockAdjust;

  /// No description provided for @permStockCount.
  ///
  /// In cs, this message translates to:
  /// **'Inventura'**
  String get permStockCount;

  /// No description provided for @permStockTransfer.
  ///
  /// In cs, this message translates to:
  /// **'Přesun mezi sklady'**
  String get permStockTransfer;

  /// No description provided for @permStockSetPriceStrategy.
  ///
  /// In cs, this message translates to:
  /// **'Změnit strategii NC'**
  String get permStockSetPriceStrategy;

  /// No description provided for @permStockManageWarehouses.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat sklady'**
  String get permStockManageWarehouses;

  /// No description provided for @permCustomersView.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit zákazníky'**
  String get permCustomersView;

  /// No description provided for @permCustomersManage.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat zákazníky'**
  String get permCustomersManage;

  /// No description provided for @permCustomersManageCredit.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat kredit'**
  String get permCustomersManageCredit;

  /// No description provided for @permCustomersManageLoyalty.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat body'**
  String get permCustomersManageLoyalty;

  /// No description provided for @permVouchersView.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit vouchery'**
  String get permVouchersView;

  /// No description provided for @permVouchersManage.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat vouchery'**
  String get permVouchersManage;

  /// No description provided for @permVouchersRedeem.
  ///
  /// In cs, this message translates to:
  /// **'Uplatnit voucher'**
  String get permVouchersRedeem;

  /// No description provided for @permVenueView.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit stoly'**
  String get permVenueView;

  /// No description provided for @permVenueReservationsView.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit rezervace'**
  String get permVenueReservationsView;

  /// No description provided for @permVenueReservationsManage.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat rezervace'**
  String get permVenueReservationsManage;

  /// No description provided for @permStatsReceipts.
  ///
  /// In cs, this message translates to:
  /// **'Účtenky (session)'**
  String get permStatsReceipts;

  /// No description provided for @permStatsReceiptsAll.
  ///
  /// In cs, this message translates to:
  /// **'Účtenky (historie)'**
  String get permStatsReceiptsAll;

  /// No description provided for @permStatsSales.
  ///
  /// In cs, this message translates to:
  /// **'Prodeje (session)'**
  String get permStatsSales;

  /// No description provided for @permStatsSalesAll.
  ///
  /// In cs, this message translates to:
  /// **'Prodeje (historie)'**
  String get permStatsSalesAll;

  /// No description provided for @permStatsOrders.
  ///
  /// In cs, this message translates to:
  /// **'Objednávky (session)'**
  String get permStatsOrders;

  /// No description provided for @permStatsOrdersAll.
  ///
  /// In cs, this message translates to:
  /// **'Objednávky (historie)'**
  String get permStatsOrdersAll;

  /// No description provided for @permStatsTips.
  ///
  /// In cs, this message translates to:
  /// **'Spropitné (session)'**
  String get permStatsTips;

  /// No description provided for @permStatsTipsAll.
  ///
  /// In cs, this message translates to:
  /// **'Spropitné (historie)'**
  String get permStatsTipsAll;

  /// No description provided for @permStatsCashJournal.
  ///
  /// In cs, this message translates to:
  /// **'Pokladní deník (session)'**
  String get permStatsCashJournal;

  /// No description provided for @permStatsCashJournalAll.
  ///
  /// In cs, this message translates to:
  /// **'Pokladní deník (historie)'**
  String get permStatsCashJournalAll;

  /// No description provided for @permStatsShifts.
  ///
  /// In cs, this message translates to:
  /// **'Směny'**
  String get permStatsShifts;

  /// No description provided for @permStatsZReports.
  ///
  /// In cs, this message translates to:
  /// **'Uzávěrky'**
  String get permStatsZReports;

  /// No description provided for @permPrintingReceipt.
  ///
  /// In cs, this message translates to:
  /// **'Tisk účtenky'**
  String get permPrintingReceipt;

  /// No description provided for @permPrintingReprint.
  ///
  /// In cs, this message translates to:
  /// **'Opakovaný tisk'**
  String get permPrintingReprint;

  /// No description provided for @permPrintingZReport.
  ///
  /// In cs, this message translates to:
  /// **'Tisk Z-reportu'**
  String get permPrintingZReport;

  /// No description provided for @permPrintingInventoryReport.
  ///
  /// In cs, this message translates to:
  /// **'Tisk inventurního reportu'**
  String get permPrintingInventoryReport;

  /// No description provided for @permDataExport.
  ///
  /// In cs, this message translates to:
  /// **'Export dat'**
  String get permDataExport;

  /// No description provided for @permDataImport.
  ///
  /// In cs, this message translates to:
  /// **'Import dat'**
  String get permDataImport;

  /// No description provided for @permDataBackup.
  ///
  /// In cs, this message translates to:
  /// **'Záloha a obnova'**
  String get permDataBackup;

  /// No description provided for @permUsersView.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit uživatele'**
  String get permUsersView;

  /// No description provided for @permUsersManage.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat uživatele'**
  String get permUsersManage;

  /// No description provided for @permUsersAssignRoles.
  ///
  /// In cs, this message translates to:
  /// **'Přiřadit roli'**
  String get permUsersAssignRoles;

  /// No description provided for @permUsersManagePermissions.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat oprávnění'**
  String get permUsersManagePermissions;

  /// No description provided for @permSettingsCompanyInfo.
  ///
  /// In cs, this message translates to:
  /// **'Informace o firmě'**
  String get permSettingsCompanyInfo;

  /// No description provided for @permSettingsCompanySecurity.
  ///
  /// In cs, this message translates to:
  /// **'Zabezpečení'**
  String get permSettingsCompanySecurity;

  /// No description provided for @permSettingsCompanyFiscal.
  ///
  /// In cs, this message translates to:
  /// **'Fiskální nastavení'**
  String get permSettingsCompanyFiscal;

  /// No description provided for @permSettingsCompanyCloud.
  ///
  /// In cs, this message translates to:
  /// **'Cloud a synchronizace'**
  String get permSettingsCompanyCloud;

  /// No description provided for @permSettingsCompanyDataWipe.
  ///
  /// In cs, this message translates to:
  /// **'Smazat data'**
  String get permSettingsCompanyDataWipe;

  /// No description provided for @permSettingsCompanyViewLog.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit systémový log'**
  String get permSettingsCompanyViewLog;

  /// No description provided for @permSettingsCompanyClearLog.
  ///
  /// In cs, this message translates to:
  /// **'Smazat log'**
  String get permSettingsCompanyClearLog;

  /// No description provided for @permSettingsVenueSections.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat sekce'**
  String get permSettingsVenueSections;

  /// No description provided for @permSettingsVenueTables.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat stoly'**
  String get permSettingsVenueTables;

  /// No description provided for @permSettingsVenueFloorPlan.
  ///
  /// In cs, this message translates to:
  /// **'Editovat půdorys'**
  String get permSettingsVenueFloorPlan;

  /// No description provided for @permSettingsRegisterManage.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat pokladny'**
  String get permSettingsRegisterManage;

  /// No description provided for @permSettingsRegisterHardware.
  ///
  /// In cs, this message translates to:
  /// **'Nastavit hardware'**
  String get permSettingsRegisterHardware;

  /// No description provided for @permSettingsRegisterGrid.
  ///
  /// In cs, this message translates to:
  /// **'Editovat prodejní grid'**
  String get permSettingsRegisterGrid;

  /// No description provided for @permSettingsRegisterDisplays.
  ///
  /// In cs, this message translates to:
  /// **'Spravovat displeje'**
  String get permSettingsRegisterDisplays;

  /// No description provided for @permSettingsRegisterPaymentMethods.
  ///
  /// In cs, this message translates to:
  /// **'Platební metody'**
  String get permSettingsRegisterPaymentMethods;

  /// No description provided for @permSettingsRegisterTaxRates.
  ///
  /// In cs, this message translates to:
  /// **'Daňové sazby'**
  String get permSettingsRegisterTaxRates;

  /// No description provided for @permSettingsRegisterManageDevices.
  ///
  /// In cs, this message translates to:
  /// **'Správa zobrazovacích zařízení'**
  String get permSettingsRegisterManageDevices;

  /// No description provided for @permGroupOrders.
  ///
  /// In cs, this message translates to:
  /// **'Objednávky'**
  String get permGroupOrders;

  /// No description provided for @permGroupPayments.
  ///
  /// In cs, this message translates to:
  /// **'Platby'**
  String get permGroupPayments;

  /// No description provided for @permGroupDiscounts.
  ///
  /// In cs, this message translates to:
  /// **'Slevy a ceny'**
  String get permGroupDiscounts;

  /// No description provided for @permGroupRegister.
  ///
  /// In cs, this message translates to:
  /// **'Pokladna'**
  String get permGroupRegister;

  /// No description provided for @permGroupShifts.
  ///
  /// In cs, this message translates to:
  /// **'Směny'**
  String get permGroupShifts;

  /// No description provided for @permGroupProducts.
  ///
  /// In cs, this message translates to:
  /// **'Produkty a katalog'**
  String get permGroupProducts;

  /// No description provided for @permGroupStock.
  ///
  /// In cs, this message translates to:
  /// **'Sklad'**
  String get permGroupStock;

  /// No description provided for @permGroupCustomers.
  ///
  /// In cs, this message translates to:
  /// **'Zákazníci a věrnost'**
  String get permGroupCustomers;

  /// No description provided for @permGroupVouchers.
  ///
  /// In cs, this message translates to:
  /// **'Vouchery'**
  String get permGroupVouchers;

  /// No description provided for @permGroupVenue.
  ///
  /// In cs, this message translates to:
  /// **'Provoz'**
  String get permGroupVenue;

  /// No description provided for @permGroupStats.
  ///
  /// In cs, this message translates to:
  /// **'Statistiky a reporty'**
  String get permGroupStats;

  /// No description provided for @permGroupPrinting.
  ///
  /// In cs, this message translates to:
  /// **'Tisk'**
  String get permGroupPrinting;

  /// No description provided for @permGroupData.
  ///
  /// In cs, this message translates to:
  /// **'Data'**
  String get permGroupData;

  /// No description provided for @permGroupUsers.
  ///
  /// In cs, this message translates to:
  /// **'Uživatelé a role'**
  String get permGroupUsers;

  /// No description provided for @permGroupSettingsCompany.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení — firma'**
  String get permGroupSettingsCompany;

  /// No description provided for @permGroupSettingsVenue.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení — provozovna'**
  String get permGroupSettingsVenue;

  /// No description provided for @permGroupSettingsRegister.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení — pokladna'**
  String get permGroupSettingsRegister;

  /// No description provided for @tabProfile.
  ///
  /// In cs, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @tabPermissions.
  ///
  /// In cs, this message translates to:
  /// **'Oprávnění'**
  String get tabPermissions;

  /// No description provided for @permissionsResetToRole.
  ///
  /// In cs, this message translates to:
  /// **'Reset na šablonu'**
  String get permissionsResetToRole;

  /// No description provided for @permissionsCustomized.
  ///
  /// In cs, this message translates to:
  /// **'(upraveno)'**
  String get permissionsCustomized;

  /// No description provided for @permissionsResetConfirm.
  ///
  /// In cs, this message translates to:
  /// **'Resetovat oprávnění na šablonu role?'**
  String get permissionsResetConfirm;

  /// No description provided for @statsReceiptDetailTitle.
  ///
  /// In cs, this message translates to:
  /// **'Detail účtenky'**
  String get statsReceiptDetailTitle;

  /// No description provided for @statsReceiptType.
  ///
  /// In cs, this message translates to:
  /// **'Typ'**
  String get statsReceiptType;

  /// No description provided for @statsOrderDetailTitle.
  ///
  /// In cs, this message translates to:
  /// **'Detail objednávky'**
  String get statsOrderDetailTitle;

  /// No description provided for @statsOrderPrepStarted.
  ///
  /// In cs, this message translates to:
  /// **'Příprava zahájena'**
  String get statsOrderPrepStarted;

  /// No description provided for @statsOrderReady.
  ///
  /// In cs, this message translates to:
  /// **'Hotovo'**
  String get statsOrderReady;

  /// No description provided for @statsOrderDelivered.
  ///
  /// In cs, this message translates to:
  /// **'Doručeno'**
  String get statsOrderDelivered;

  /// No description provided for @statsOrderCreated.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořeno'**
  String get statsOrderCreated;

  /// No description provided for @statsOrderItems.
  ///
  /// In cs, this message translates to:
  /// **'Položky'**
  String get statsOrderItems;

  /// No description provided for @settingsCurrencyLocked.
  ///
  /// In cs, this message translates to:
  /// **'Výchozí měnu nelze změnit po vytvoření prvního účtu.'**
  String get settingsCurrencyLocked;

  /// No description provided for @settingsAlternativeCurrencies.
  ///
  /// In cs, this message translates to:
  /// **'Alternativní měny'**
  String get settingsAlternativeCurrencies;

  /// No description provided for @settingsAddCurrency.
  ///
  /// In cs, this message translates to:
  /// **'Přidat měnu'**
  String get settingsAddCurrency;

  /// No description provided for @settingsExchangeRate.
  ///
  /// In cs, this message translates to:
  /// **'Kurz'**
  String get settingsExchangeRate;

  /// No description provided for @settingsExchangeRateLabel.
  ///
  /// In cs, this message translates to:
  /// **'1 {code} ='**
  String settingsExchangeRateLabel(String code);

  /// No description provided for @paymentForeignCurrencySelect.
  ///
  /// In cs, this message translates to:
  /// **'Jiná měna'**
  String get paymentForeignCurrencySelect;

  /// No description provided for @paymentForeignRate.
  ///
  /// In cs, this message translates to:
  /// **'× {rate} = {amount}'**
  String paymentForeignRate(String rate, String amount);

  /// No description provided for @paymentChangeInBase.
  ///
  /// In cs, this message translates to:
  /// **'Vráceno v základní měně'**
  String get paymentChangeInBase;

  /// No description provided for @openingForeignCashTitle.
  ///
  /// In cs, this message translates to:
  /// **'Počáteční stav cizích měn'**
  String get openingForeignCashTitle;

  /// No description provided for @closingForeignCashTitle.
  ///
  /// In cs, this message translates to:
  /// **'Uzávěrka cizích měn'**
  String get closingForeignCashTitle;

  /// No description provided for @zReportForeignCashTitle.
  ///
  /// In cs, this message translates to:
  /// **'Pokladna cizí měny'**
  String get zReportForeignCashTitle;

  /// No description provided for @zReportForeignOpening.
  ///
  /// In cs, this message translates to:
  /// **'Počáteční stav'**
  String get zReportForeignOpening;

  /// No description provided for @zReportForeignRevenue.
  ///
  /// In cs, this message translates to:
  /// **'Tržby'**
  String get zReportForeignRevenue;

  /// No description provided for @zReportForeignExpected.
  ///
  /// In cs, this message translates to:
  /// **'Očekávaný stav'**
  String get zReportForeignExpected;

  /// No description provided for @zReportForeignClosing.
  ///
  /// In cs, this message translates to:
  /// **'Skutečný stav'**
  String get zReportForeignClosing;

  /// No description provided for @zReportForeignDifference.
  ///
  /// In cs, this message translates to:
  /// **'Rozdíl'**
  String get zReportForeignDifference;

  /// No description provided for @currencySelectorTitle.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte měnu'**
  String get currencySelectorTitle;

  /// No description provided for @currencySelectorBack.
  ///
  /// In cs, this message translates to:
  /// **'Zpět'**
  String get currencySelectorBack;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

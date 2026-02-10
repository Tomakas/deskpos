import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('cs')];

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
  /// **'Přepnout obsluhu'**
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
  /// **'Cena'**
  String get fieldPrice;

  /// No description provided for @fieldTaxRate.
  ///
  /// In cs, this message translates to:
  /// **'Daň. sazba'**
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

  /// No description provided for @prepStatusInPrep.
  ///
  /// In cs, this message translates to:
  /// **'Připravuje se'**
  String get prepStatusInPrep;

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
  /// **'Přesunout'**
  String get billDetailMove;

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

  /// No description provided for @moreDev.
  ///
  /// In cs, this message translates to:
  /// **'Dev'**
  String get moreDev;

  /// No description provided for @settingsTabSecurity.
  ///
  /// In cs, this message translates to:
  /// **'Zabezpečení'**
  String get settingsTabSecurity;

  /// No description provided for @settingsTabSales.
  ///
  /// In cs, this message translates to:
  /// **'Prodej'**
  String get settingsTabSales;

  /// No description provided for @settingsTabCloud.
  ///
  /// In cs, this message translates to:
  /// **'Cloud'**
  String get settingsTabCloud;

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

  /// No description provided for @paymentTip.
  ///
  /// In cs, this message translates to:
  /// **'Spropitné: {amount}'**
  String paymentTip(String amount);

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
  /// **'Původní částka'**
  String get changeTotalOriginal;

  /// No description provided for @changeTotalEdited.
  ///
  /// In cs, this message translates to:
  /// **'Upravená částka'**
  String get changeTotalEdited;

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
      <String>['cs'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

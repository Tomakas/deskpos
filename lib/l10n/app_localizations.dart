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
  /// **'Přihlášení'**
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

  /// No description provided for @newBillTakeaway.
  ///
  /// In cs, this message translates to:
  /// **'Jídlo s sebou'**
  String get newBillTakeaway;

  /// No description provided for @newBillTable.
  ///
  /// In cs, this message translates to:
  /// **'Přiřadit ke stolu'**
  String get newBillTable;

  /// No description provided for @newBillNoTable.
  ///
  /// In cs, this message translates to:
  /// **'Bez stolu'**
  String get newBillNoTable;

  /// No description provided for @newBillSelectTable.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte stůl'**
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

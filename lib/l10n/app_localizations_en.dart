// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EPOS';

  @override
  String get onboardingTitle => 'Welcome to EPOS';

  @override
  String get onboardingCreateCompany => 'Create New Company';

  @override
  String get onboardingJoinCompany => 'Join Company';

  @override
  String get onboardingJoinCompanyDisabled => 'Available from version 3.0';

  @override
  String get wizardStepCompany => 'Company';

  @override
  String get wizardStepAdmin => 'Administrator';

  @override
  String get wizardCompanyName => 'Company Name';

  @override
  String get wizardCompanyNameRequired => 'Company name is required';

  @override
  String get wizardBusinessId => 'Business ID';

  @override
  String get wizardAddress => 'Address';

  @override
  String get wizardEmail => 'Email';

  @override
  String get wizardPhone => 'Phone';

  @override
  String get wizardNext => 'Next';

  @override
  String get wizardBack => 'Back';

  @override
  String get wizardFinish => 'Finish';

  @override
  String get wizardFullName => 'Full Name';

  @override
  String get wizardFullNameRequired => 'Full name is required';

  @override
  String get wizardUsername => 'Username';

  @override
  String get wizardUsernameRequired => 'Username is required';

  @override
  String get wizardPin => 'PIN (4–6 digits)';

  @override
  String get wizardPinConfirm => 'Confirm PIN';

  @override
  String get wizardPinRequired => 'PIN is required';

  @override
  String get wizardPinLength => 'PIN must be 4–6 digits';

  @override
  String get wizardPinMismatch => 'PINs do not match';

  @override
  String get wizardPinDigitsOnly => 'PIN must contain digits only';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginPinLabel => 'Enter PIN';

  @override
  String get loginButton => 'Login';

  @override
  String get loginFailed => 'Invalid PIN';

  @override
  String loginLockedOut(int seconds) {
    return 'Too many attempts. Try again in $seconds s.';
  }

  @override
  String get billsTitle => 'Bills';

  @override
  String get billsEmpty => 'No bills';

  @override
  String get billsFilterOpened => 'Open';

  @override
  String get billsFilterPaid => 'Paid';

  @override
  String get billsFilterCancelled => 'Cancelled';

  @override
  String get billsQuickBill => 'Quick Bill';

  @override
  String get billsNewBill => 'Create Bill';

  @override
  String get billsSectionAll => 'All';

  @override
  String get columnTable => 'Table';

  @override
  String get columnGuest => 'Guest';

  @override
  String get columnGuests => 'Guests';

  @override
  String get columnTotal => 'Total';

  @override
  String get columnLastOrder => 'Last Order';

  @override
  String get columnStaff => 'Staff';

  @override
  String get billTimeJustNow => 'just now';

  @override
  String get infoPanelDate => 'Date';

  @override
  String get infoPanelStatus => 'Register Status';

  @override
  String get infoPanelStatusOffline => 'Offline';

  @override
  String get infoPanelActiveUser => 'Active Staff';

  @override
  String get infoPanelLoggedIn => 'Other Logins';

  @override
  String get actionSwitchUser => 'Lock / Switch';

  @override
  String get actionLogout => 'Logout';

  @override
  String get switchUserTitle => 'Switch Staff';

  @override
  String get switchUserSelectUser => 'Select User';

  @override
  String switchUserEnterPin(String name) {
    return 'Enter PIN for $name';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsUsers => 'Users';

  @override
  String get settingsSections => 'Sections';

  @override
  String get settingsTables => 'Tables';

  @override
  String get settingsCategories => 'Categories';

  @override
  String get settingsProducts => 'Products';

  @override
  String get settingsTaxRates => 'Tax Rates';

  @override
  String get settingsPaymentMethods => 'Payment Methods';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionClose => 'Close';

  @override
  String get actionConfirm => 'OK';

  @override
  String get unitPcs => 'pcs';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldUsername => 'Username';

  @override
  String get fieldRole => 'Role';

  @override
  String get fieldPin => 'PIN';

  @override
  String get fieldActive => 'Active';

  @override
  String get fieldActions => 'Actions';

  @override
  String get fieldSection => 'Section';

  @override
  String get fieldCapacity => 'Capacity';

  @override
  String get fieldColor => 'Color';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldPrice => 'Price';

  @override
  String get fieldTaxRate => 'Tax Rate';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldRate => 'Rate (%)';

  @override
  String get fieldDefault => 'Default';

  @override
  String get roleHelper => 'Helper';

  @override
  String get roleOperator => 'Operator';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get paymentTypeCash => 'Cash';

  @override
  String get paymentTypeCard => 'Card';

  @override
  String get paymentTypeBank => 'Transfer';

  @override
  String get paymentTypeOther => 'Other';

  @override
  String get taxTypeRegular => 'Regular';

  @override
  String get taxTypeNoTax => 'No Tax';

  @override
  String get taxTypeConstant => 'Constant';

  @override
  String get taxTypeMixed => 'Mixed';

  @override
  String get confirmDelete => 'Are you sure you want to delete this item?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get noPermission => 'You do not have permission for this action';

  @override
  String get newBillTitle => 'New Bill';

  @override
  String get newBillSelectTable => 'Table (optional)';

  @override
  String get newBillGuests => 'Number of Guests';

  @override
  String get newBillCreate => 'Create';

  @override
  String get billDetailTitle => 'Bill Detail';

  @override
  String billDetailTable(String name) {
    return 'Table: $name';
  }

  @override
  String get billDetailTakeaway => 'Takeaway';

  @override
  String get billDetailNoTable => 'No Table';

  @override
  String billDetailCreated(String time) {
    return 'Created: $time';
  }

  @override
  String billDetailLastOrder(String time) {
    return 'Last Order: $time';
  }

  @override
  String get billDetailNoOrders => 'No orders yet';

  @override
  String get billDetailOrder => 'Order';

  @override
  String get billDetailPay => 'Pay';

  @override
  String get billDetailCancel => 'Cancel Bill';

  @override
  String get billDetailConfirmCancel =>
      'Are you sure you want to cancel this bill?';

  @override
  String billDetailBillNumber(String number) {
    return 'Bill $number';
  }

  @override
  String get billStatusOpened => 'Open';

  @override
  String get billStatusPaid => 'Paid';

  @override
  String get billStatusCancelled => 'Cancelled';

  @override
  String get sellTitle => 'Sell';

  @override
  String get sellCart => 'Cart';

  @override
  String get sellCartEmpty => 'Cart is empty';

  @override
  String get sellTotal => 'Total';

  @override
  String get sellCancelOrder => 'Cancel';

  @override
  String get sellSaveToBill => 'Save';

  @override
  String get sellSubmitOrder => 'Order';

  @override
  String get sellSearch => 'Search';

  @override
  String get sellEditGrid => 'Edit Grid';

  @override
  String get sellExitEdit => 'Exit Edit';

  @override
  String get sellEmptySlot => 'Empty';

  @override
  String get sellBackToCategories => 'Back';

  @override
  String sellQuantity(String count) {
    return '$count×';
  }

  @override
  String get prepStatusCreated => 'Created';

  @override
  String get prepStatusInPrep => 'In Prep';

  @override
  String get prepStatusReady => 'Ready';

  @override
  String get prepStatusDelivered => 'Delivered';

  @override
  String get prepStatusCancelled => 'Cancelled';

  @override
  String get prepStatusVoided => 'Voided';

  @override
  String get orderStatusChange => 'Change Status';

  @override
  String get orderCancel => 'Cancel Order';

  @override
  String get orderVoid => 'Void Order';

  @override
  String get orderConfirmCancel =>
      'Are you sure you want to cancel this order?';

  @override
  String get orderConfirmVoid => 'Are you sure you want to void this order?';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get paymentAmount => 'Amount';

  @override
  String paymentTotalDue(String amount) {
    return 'Total Due: $amount';
  }

  @override
  String get paymentConfirm => 'Pay';

  @override
  String get gridEditorTitle => 'Grid Editor';

  @override
  String get gridEditorSelectType => 'Select Type';

  @override
  String get gridEditorItem => 'Product';

  @override
  String get gridEditorCategory => 'Category';

  @override
  String get gridEditorClear => 'Clear';

  @override
  String get gridEditorSelectItem => 'Select Product';

  @override
  String get gridEditorSelectCategory => 'Select Category';

  @override
  String get registerSessionStart => 'Start Session';

  @override
  String get registerSessionClose => 'Close Session';

  @override
  String get registerSessionNoSession => 'No active session';

  @override
  String get registerSessionConfirmClose =>
      'Are you sure you want to close the session?';

  @override
  String get registerSessionRequired =>
      'You must start a session before selling';

  @override
  String get registerSessionActive => 'Session active';

  @override
  String get billsSorting => 'Sorting';

  @override
  String get sortByTable => 'Table';

  @override
  String get sortByTotal => 'Total';

  @override
  String get sortByLastOrder => 'Last Order';

  @override
  String get billsCashJournal => 'Cash Journal';

  @override
  String get billsSalesOverview => 'Sales Overview';

  @override
  String get billsInventory => 'Inventory';

  @override
  String get billsMore => 'More';

  @override
  String get billsTableMap => 'Map';

  @override
  String get infoPanelRegisterTotal => 'Register';

  @override
  String get infoPanelRevenue => 'Revenue';

  @override
  String get infoPanelSalesCount => 'Sales Count';

  @override
  String get sellCartSummary => 'Item Summary';

  @override
  String get sellScan => 'Scan';

  @override
  String get sellCustomer => 'Customer';

  @override
  String get sellNote => 'Note';

  @override
  String get sellActions => 'Actions';

  @override
  String get billDetailCustomer => 'Customer';

  @override
  String get billDetailMove => 'Table';

  @override
  String get billDetailMoveTitle => 'Move Bill';

  @override
  String get billDetailMerge => 'Merge';

  @override
  String get billDetailSplit => 'Split';

  @override
  String get billDetailSummary => 'Summary';

  @override
  String get billDetailItemList => 'History';

  @override
  String get billDetailPrint => 'Print';

  @override
  String get billDetailOrderHistory => 'Order History';

  @override
  String billDetailTotalSpent(String amount) {
    return 'Total Spent: $amount';
  }

  @override
  String billDetailCreatedAt(String date) {
    return 'Bill created: $date';
  }

  @override
  String billDetailLastOrderAt(String date) {
    return 'Last order: $date';
  }

  @override
  String get billDetailNoOrderYet => 'No order yet';

  @override
  String billDetailCustomerName(String name) {
    return 'Customer: $name';
  }

  @override
  String get billDetailNoCustomer => 'No customer assigned';

  @override
  String get itemTypeProduct => 'Product';

  @override
  String get itemTypeService => 'Service';

  @override
  String get itemTypeCounter => 'Counter';

  @override
  String get itemTypeRecipe => 'Recipe';

  @override
  String get itemTypeIngredient => 'Ingredient';

  @override
  String get itemTypeVariant => 'Variant';

  @override
  String get itemTypeModifier => 'Modifier';

  @override
  String get moreReports => 'Reports';

  @override
  String get moreStatistics => 'Statistics';

  @override
  String get moreReservations => 'Reservations';

  @override
  String get moreSettings => 'Settings';

  @override
  String get moreCompanySettings => 'Company Settings';

  @override
  String get moreVenueSettings => 'Venue Settings';

  @override
  String get moreRegisterSettings => 'Register Settings';

  @override
  String get settingsCompanyTitle => 'Company Settings';

  @override
  String get settingsVenueTitle => 'Venue Settings';

  @override
  String get settingsRegisterTitle => 'Register Settings';

  @override
  String get settingsTabCompany => 'Company';

  @override
  String get settingsTabRegister => 'Register';

  @override
  String get settingsTabUsers => 'Users';

  @override
  String get settingsSectionCompanyInfo => 'Company Information';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsSectionCloud => 'Cloud';

  @override
  String get settingsSectionGrid => 'Grid Display';

  @override
  String get companyFieldVatNumber => 'VAT Number';

  @override
  String get settingsLanguage => 'App language';

  @override
  String get settingsCurrency => 'Default currency';

  @override
  String get languageCzech => 'Čeština';

  @override
  String get languageEnglish => 'English';

  @override
  String get cloudTitle => 'Cloud Sync';

  @override
  String get cloudEmail => 'Email';

  @override
  String get cloudPassword => 'Password';

  @override
  String get cloudSignUp => 'Sign Up';

  @override
  String get cloudSignIn => 'Sign In';

  @override
  String get cloudSignOut => 'Disconnect';

  @override
  String get cloudConnected => 'Connected';

  @override
  String get cloudDisconnected => 'Disconnected';

  @override
  String get cloudEmailRequired => 'Email is required';

  @override
  String get cloudPasswordRequired => 'Password is required';

  @override
  String get cloudPasswordLength => 'Password must be at least 6 characters';

  @override
  String get cloudDangerZone => 'Danger Zone';

  @override
  String get cloudDeleteLocalData => 'Delete Local Data';

  @override
  String get cloudDeleteLocalDataDescription =>
      'Deletes all data from this device including bills, items, settings and users. Data stored in cloud will remain intact.';

  @override
  String get cloudDeleteLocalDataConfirmTitle => 'Delete all local data?';

  @override
  String get cloudDeleteLocalDataConfirmMessage =>
      'This action is irreversible. All local data will be deleted and the app will return to the welcome screen.';

  @override
  String get cloudDeleteLocalDataConfirm => 'Delete All';

  @override
  String get infoPanelSync => 'Sync';

  @override
  String get infoPanelSyncConnected => 'Connected';

  @override
  String get infoPanelSyncDisconnected => 'Disconnected';

  @override
  String get connectCompanyTitle => 'Join Company';

  @override
  String get connectCompanySubtitle => 'Sign in with administrator account';

  @override
  String get connectCompanySearching => 'Searching for company...';

  @override
  String get connectCompanyFound => 'Company Found';

  @override
  String get connectCompanyNotFound => 'No company found for this account';

  @override
  String get connectCompanyConnect => 'Connect';

  @override
  String get connectCompanySyncing => 'Syncing data...';

  @override
  String get connectCompanySyncComplete => 'Sync complete';

  @override
  String get connectCompanySyncFailed => 'Sync failed';

  @override
  String get cashJournalTitle => 'Cash Journal';

  @override
  String get cashJournalBalance => 'Cash in Register:';

  @override
  String get cashJournalFilterDeposits => 'Deposits';

  @override
  String get cashJournalFilterWithdrawals => 'Withdrawals';

  @override
  String get cashJournalFilterSales => 'Sales';

  @override
  String get cashJournalAddMovement => 'Add Entry';

  @override
  String get cashJournalColumnTime => 'Time';

  @override
  String get cashJournalColumnType => 'Type';

  @override
  String get cashJournalColumnAmount => 'Amount';

  @override
  String get cashJournalColumnNote => 'Note';

  @override
  String get cashJournalEmpty => 'No entries';

  @override
  String get cashMovementTitle => 'Cash Movement';

  @override
  String get cashMovementAmount => 'Amount:';

  @override
  String get cashMovementDeposit => 'Deposit';

  @override
  String get cashMovementWithdrawal => 'Withdrawal';

  @override
  String get cashMovementSale => 'Sale';

  @override
  String get cashMovementNote => 'Note';

  @override
  String get cashMovementNoteTitle => 'Cash Movement Note';

  @override
  String get cashMovementNoteHint => 'Reason for movement...';

  @override
  String get openingCashTitle => 'Opening Cash';

  @override
  String get openingCashSubtitle =>
      'Enter the cash balance in the register before starting sales.';

  @override
  String get openingCashConfirm => 'Confirm';

  @override
  String get closingTitle => 'Closing';

  @override
  String get closingSessionTitle => 'Session Overview';

  @override
  String get closingOpenedAt => 'Opened';

  @override
  String get closingOpenedBy => 'Opened By';

  @override
  String get closingDuration => 'Duration';

  @override
  String get closingBillsPaid => 'Paid Bills';

  @override
  String get closingBillsCancelled => 'Cancelled Bills';

  @override
  String get closingRevenueTitle => 'Revenue by Payment';

  @override
  String get closingRevenueTotal => 'Total';

  @override
  String get closingTips => 'Tips';

  @override
  String get closingCashTitle => 'Cash Status';

  @override
  String get closingOpeningCash => 'Opening Cash';

  @override
  String get closingCashRevenue => 'Cash Revenue';

  @override
  String get closingDeposits => 'Deposits';

  @override
  String get closingWithdrawals => 'Withdrawals';

  @override
  String get closingExpectedCash => 'Expected Cash';

  @override
  String get closingActualCash => 'Actual Cash';

  @override
  String get closingDifference => 'Difference';

  @override
  String get closingPrint => 'Print';

  @override
  String get closingConfirm => 'Close Session';

  @override
  String get closingNoteTitle => 'Closing Note';

  @override
  String get closingNoteHint => 'Notes for closing...';

  @override
  String get paymentOtherCurrency => 'Other Currency';

  @override
  String get paymentEet => 'EET';

  @override
  String get paymentEditAmount => 'Edit Amount';

  @override
  String get paymentMixPayments => 'Mixed Payments';

  @override
  String get paymentOtherPayment => 'Other Payment';

  @override
  String get paymentPrintReceipt => 'Print Receipt';

  @override
  String get paymentPrintYes => 'YES';

  @override
  String paymentTip(String amount) {
    return 'Tip: $amount';
  }

  @override
  String paymentBillSubtitle(String billNumber, String tableName) {
    return 'Bill $billNumber - $tableName';
  }

  @override
  String get billDetailDiscount => 'Discount';

  @override
  String get billStatusRefunded => 'Refunded';

  @override
  String get refundTitle => 'Refund';

  @override
  String get refundConfirmFull =>
      'Are you sure you want to refund the entire bill?';

  @override
  String get refundConfirmItem => 'Are you sure you want to refund this item?';

  @override
  String get refundButton => 'REFUND';

  @override
  String get refundFullBill => 'Full Bill';

  @override
  String get refundSelectItems => 'Select Items';

  @override
  String get changeTotalTitle => 'Edit Amount';

  @override
  String get changeTotalOriginal => 'Original Amount';

  @override
  String get changeTotalEdited => 'Edited Amount';

  @override
  String get newBillSave => 'Save';

  @override
  String get newBillOrder => 'Order';

  @override
  String get newBillSelectSection => 'Select Section';

  @override
  String get newBillCustomer => 'Customer';

  @override
  String get newBillNoTable => 'No Table';

  @override
  String get zReportListTitle => 'Closings Overview';

  @override
  String get zReportListEmpty => 'No closings';

  @override
  String get zReportColumnDate => 'Date';

  @override
  String get zReportColumnTime => 'Time';

  @override
  String get zReportColumnUser => 'User';

  @override
  String get zReportColumnRevenue => 'Revenue';

  @override
  String get zReportColumnDifference => 'Difference';

  @override
  String get zReportTitle => 'Z-Report';

  @override
  String get zReportSessionInfo => 'Session Information';

  @override
  String get zReportOpenedAt => 'Opened';

  @override
  String get zReportClosedAt => 'Closed';

  @override
  String get zReportDuration => 'Duration';

  @override
  String get zReportOpenedBy => 'Opened By';

  @override
  String get zReportRevenueByPayment => 'Revenue by Payment';

  @override
  String get zReportRevenueTotal => 'Total';

  @override
  String get zReportTaxTitle => 'Tax';

  @override
  String get zReportTaxRate => 'Rate';

  @override
  String get zReportTaxNet => 'Net';

  @override
  String get zReportTaxAmount => 'Tax';

  @override
  String get zReportTaxGross => 'Gross';

  @override
  String get zReportTipsTotal => 'Total Tips';

  @override
  String get zReportTipsByUser => 'Tips by Staff';

  @override
  String get zReportDiscounts => 'Total Discounts';

  @override
  String get zReportBillsPaid => 'Paid Bills';

  @override
  String get zReportBillsCancelled => 'Cancelled Bills';

  @override
  String get zReportBillsRefunded => 'Refunded Bills';

  @override
  String get zReportCashTitle => 'Cash Status';

  @override
  String get zReportCashOpening => 'Opening Cash';

  @override
  String get zReportCashRevenue => 'Cash Revenue';

  @override
  String get zReportCashDeposits => 'Deposits';

  @override
  String get zReportCashWithdrawals => 'Withdrawals';

  @override
  String get zReportCashExpected => 'Expected Cash';

  @override
  String get zReportCashClosing => 'Closing Cash';

  @override
  String get zReportCashDifference => 'Difference';

  @override
  String get zReportShiftsTitle => 'Shifts';

  @override
  String get zReportPrint => 'Print';

  @override
  String get zReportClose => 'Close';

  @override
  String get moreShifts => 'Shifts';

  @override
  String get shiftsListTitle => 'Shifts Overview';

  @override
  String get shiftsListEmpty => 'No shifts in this period';

  @override
  String get shiftsColumnDate => 'Date';

  @override
  String get shiftsColumnUser => 'Staff';

  @override
  String get shiftsColumnLogin => 'Login';

  @override
  String get shiftsColumnLogout => 'Logout';

  @override
  String get shiftsColumnDuration => 'Duration';

  @override
  String get shiftsOngoing => 'ongoing';

  @override
  String get closingOpenBillsWarningTitle => 'Open Bills';

  @override
  String closingOpenBillsWarningMessage(int count, String amount) {
    return 'There are $count open bills at closing worth $amount.';
  }

  @override
  String get closingOpenBillsContinue => 'Continue';

  @override
  String get closingOpenBills => 'Open Bills';

  @override
  String get zReportOpenBillsAtOpen => 'Open Bills (opening)';

  @override
  String get zReportOpenBillsAtClose => 'Open Bills (closing)';

  @override
  String get settingsRequirePinOnSwitch => 'Require PIN when switching staff';

  @override
  String get settingsAutoLockTimeout => 'Auto-lock after inactivity';

  @override
  String get settingsAutoLockDisabled => 'Disabled';

  @override
  String settingsAutoLockMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get settingsGridRows => 'Grid Rows';

  @override
  String get settingsGridCols => 'Grid Columns';

  @override
  String get lockScreenTitle => 'Locked';

  @override
  String get lockScreenSubtitle => 'Select user to unlock';

  @override
  String get autoCorrection =>
      'Auto correction: opening cash differs from previous closing';

  @override
  String get errorNoCompanyFound => 'Company not found';

  @override
  String get openingCashNote => 'Opening balance';

  @override
  String get catalogTitle => 'Catalog';

  @override
  String get catalogTabProducts => 'Products';

  @override
  String get catalogTabCategories => 'Categories';

  @override
  String get catalogTabSuppliers => 'Suppliers';

  @override
  String get catalogTabManufacturers => 'Manufacturers';

  @override
  String get catalogTabRecipes => 'Recipes';

  @override
  String get fieldSupplierName => 'Supplier Name';

  @override
  String get fieldContactPerson => 'Contact Person';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldManufacturer => 'Manufacturer';

  @override
  String get fieldSupplier => 'Supplier';

  @override
  String get fieldParentCategory => 'Parent Category';

  @override
  String get fieldAltSku => 'Alternative SKU';

  @override
  String get fieldPurchasePrice => 'Purchase Price';

  @override
  String get fieldPurchaseTaxRate => 'Purchase Tax';

  @override
  String get fieldOnSale => 'On Sale';

  @override
  String get fieldStockTracked => 'Stock Tracked';

  @override
  String get fieldParentProduct => 'Parent Product';

  @override
  String get fieldComponent => 'Component';

  @override
  String get fieldQuantityRequired => 'Required Quantity';

  @override
  String get moreCatalog => 'Catalog';

  @override
  String get mergeBillTitle => 'Merge Bill';

  @override
  String get mergeBillDescription =>
      'Orders from this bill will be moved to the selected bill. Current bill will be cancelled.';

  @override
  String get mergeBillNoBills => 'No open bills to merge';

  @override
  String get splitBillTitle => 'Split Bill';

  @override
  String get splitBillSelectItems => 'Select items to split';

  @override
  String get splitBillPayButton => 'Split and Pay';

  @override
  String get splitBillNewBillButton => 'Split to New Bill';

  @override
  String get catalogTabCustomers => 'Customers';

  @override
  String get customerFirstName => 'First Name';

  @override
  String get customerLastName => 'Last Name';

  @override
  String get customerEmail => 'Email';

  @override
  String get customerPhone => 'Phone';

  @override
  String get customerAddress => 'Address';

  @override
  String get customerPoints => 'Points';

  @override
  String get customerCredit => 'Credit';

  @override
  String get customerTotalSpent => 'Total Spent';

  @override
  String get customerBirthdate => 'Birthdate';

  @override
  String get customerLastVisit => 'Last Visit';

  @override
  String get customerSearch => 'Search Customer';

  @override
  String get customerRemove => 'Remove Customer';

  @override
  String get customerNone => 'No Customer';

  @override
  String get inventoryTitle => 'Inventory';

  @override
  String get inventoryColumnItem => 'Item';

  @override
  String get inventoryColumnUnit => 'Unit';

  @override
  String get inventoryColumnQuantity => 'Quantity';

  @override
  String get inventoryColumnMinQuantity => 'Min. Quantity';

  @override
  String get inventoryColumnPurchasePrice => 'Purchase Price';

  @override
  String get inventoryColumnTotalValue => 'Total Value';

  @override
  String get inventoryTotalValue => 'Total Inventory Value';

  @override
  String get inventoryReceipt => 'Receipt';

  @override
  String get inventoryWaste => 'Waste';

  @override
  String get inventoryCorrection => 'Correction';

  @override
  String get inventoryInventory => 'Inventory';

  @override
  String get inventoryNoItems => 'No tracked items';

  @override
  String get stockDocumentTitle => 'Stock Document';

  @override
  String get stockDocumentSupplier => 'Supplier';

  @override
  String get stockDocumentPriceStrategy => 'Purchase Price Strategy';

  @override
  String get stockDocumentNote => 'Note';

  @override
  String get stockDocumentAddItem => 'Add Item';

  @override
  String get stockDocumentQuantity => 'Quantity';

  @override
  String get stockDocumentPrice => 'Purchase Price';

  @override
  String get stockDocumentSave => 'Save Document';

  @override
  String get stockDocumentNoItems => 'Add at least one item';

  @override
  String get stockDocumentSearchItem => 'Search Item';

  @override
  String get stockDocumentItemOverrideStrategy => 'Override Strategy';

  @override
  String get stockStrategyOverwrite => 'Overwrite';

  @override
  String get stockStrategyKeep => 'Keep';

  @override
  String get stockStrategyAverage => 'Average';

  @override
  String get stockStrategyWeightedAverage => 'Weighted Average';

  @override
  String get inventoryDialogTitle => 'Inventory';

  @override
  String get inventoryDialogActualQuantity => 'Actual Quantity';

  @override
  String get inventoryDialogDifference => 'Difference';

  @override
  String get inventoryDialogSave => 'Save Inventory';

  @override
  String get inventoryDialogNoDifferences => 'No differences';

  @override
  String get inventoryTabLevels => 'Levels';

  @override
  String get inventoryTabDocuments => 'Documents';

  @override
  String get documentColumnNumber => 'Number';

  @override
  String get documentColumnType => 'Type';

  @override
  String get documentColumnDate => 'Date';

  @override
  String get documentColumnSupplier => 'Supplier';

  @override
  String get documentColumnNote => 'Note';

  @override
  String get documentColumnTotal => 'Total';

  @override
  String get documentNoDocuments => 'No stock documents';

  @override
  String get documentTypeReceipt => 'Receipt';

  @override
  String get documentTypeWaste => 'Waste';

  @override
  String get documentTypeInventory => 'Inventory';

  @override
  String get documentTypeCorrection => 'Correction';

  @override
  String get recipeComponents => 'Components';

  @override
  String recipeComponentCount(int count) {
    return '$count components';
  }

  @override
  String get recipeAddComponent => 'Add Component';

  @override
  String get recipeNoComponents => 'No components. Add at least one.';

  @override
  String get searchHint => 'Search...';

  @override
  String get filterTitle => 'Filter';

  @override
  String get filterAll => 'All';

  @override
  String get filterReset => 'Reset';

  @override
  String get receiptSubtotal => 'Subtotal';

  @override
  String get receiptDiscount => 'Discount';

  @override
  String get receiptTotal => 'Total';

  @override
  String get receiptRounding => 'Rounding';

  @override
  String get receiptTaxTitle => 'Tax Summary';

  @override
  String get receiptTaxRate => 'Rate';

  @override
  String get receiptTaxNet => 'Net';

  @override
  String get receiptTaxAmount => 'Tax';

  @override
  String get receiptTaxGross => 'Gross';

  @override
  String get receiptPayment => 'Payment';

  @override
  String get receiptTip => 'Tip';

  @override
  String get receiptBillNumber => 'Receipt No.';

  @override
  String get receiptTable => 'Table';

  @override
  String get receiptTakeaway => 'Takeaway';

  @override
  String get receiptCashier => 'Cashier';

  @override
  String get receiptDate => 'Date';

  @override
  String get receiptThankYou => 'Thank you for your visit';

  @override
  String get receiptIco => 'Business ID';

  @override
  String get receiptDic => 'VAT Number';

  @override
  String get receiptPreviewTitle => 'Receipt Preview';

  @override
  String get zReportReportTitle => 'Z-Report';

  @override
  String get zReportSession => 'Session';

  @override
  String get zReportOpenedAtLabel => 'Opened';

  @override
  String get zReportClosedAtLabel => 'Closed';

  @override
  String get zReportDurationLabel => 'Duration';

  @override
  String get zReportOpenedByLabel => 'Opened By';

  @override
  String get zReportRevenueTitle => 'Revenue by Payment';

  @override
  String get zReportTaxReportTitle => 'Tax';

  @override
  String get zReportTipsTitle => 'Tips';

  @override
  String get zReportDiscountsTitle => 'Discounts';

  @override
  String get zReportBillCountsTitle => 'Bill Counts';

  @override
  String get zReportCashReportTitle => 'Cash Status';

  @override
  String get zReportShiftsReportTitle => 'Shifts';

  @override
  String get zReportRegisterBreakdown => 'Breakdown by Registers';

  @override
  String get zReportRegisterColumn => 'Register';

  @override
  String get zReportVenueReport => 'Venue Report';

  @override
  String get zReportVenueReportTitle => 'Venue Report';

  @override
  String zReportRegisterName(String name) {
    return 'Register: $name';
  }

  @override
  String cashHandoverReason(String registerName) {
    return 'Cash handover from $registerName';
  }

  @override
  String get reservationsTitle => 'Reservations';

  @override
  String get reservationNew => 'New Reservation';

  @override
  String get reservationEdit => 'Edit Reservation';

  @override
  String get reservationDate => 'Date';

  @override
  String get reservationTime => 'Time';

  @override
  String get reservationCustomerName => 'Name';

  @override
  String get reservationCustomerPhone => 'Phone';

  @override
  String get reservationPartySize => 'Party Size';

  @override
  String get reservationTable => 'Table';

  @override
  String get reservationNotes => 'Note';

  @override
  String get reservationStatus => 'Status';

  @override
  String get reservationStatusCreated => 'Created';

  @override
  String get reservationStatusConfirmed => 'Confirmed';

  @override
  String get reservationStatusSeated => 'Seated';

  @override
  String get reservationStatusCancelled => 'Cancelled';

  @override
  String get reservationLinkCustomer => 'Link Customer';

  @override
  String get reservationLinkedCustomer => 'Customer';

  @override
  String get reservationsEmpty => 'No reservations';

  @override
  String get reservationSave => 'Save';

  @override
  String get reservationDelete => 'Delete';

  @override
  String get reservationColumnDate => 'Date';

  @override
  String get reservationColumnTime => 'Time';

  @override
  String get reservationColumnName => 'Name';

  @override
  String get reservationColumnPhone => 'Phone';

  @override
  String get reservationColumnPartySize => 'Size';

  @override
  String get reservationColumnTable => 'Table';

  @override
  String get reservationColumnStatus => 'Status';

  @override
  String get paymentTypeCredit => 'Credit';

  @override
  String get loyaltySectionTitle => 'Loyalty Program';

  @override
  String loyaltyEarnRate(String unit) {
    return 'Points per $unit';
  }

  @override
  String get loyaltyPointValue => 'Point value (minor units)';

  @override
  String loyaltyDescription(int earn, String unit, String value) {
    return 'Customer earns $earn points per $unit. 1 point = $value.';
  }

  @override
  String get loyaltyDisabled => 'Loyalty program is disabled (set values > 0)';

  @override
  String get loyaltyRedeem => 'Redeem Points';

  @override
  String get loyaltyAvailablePoints => 'Available Points';

  @override
  String get loyaltyPointsValue => 'Value';

  @override
  String loyaltyPerPoint(String value) {
    return '$value/pt';
  }

  @override
  String get loyaltyPointsToUse => 'Points to Redeem';

  @override
  String loyaltyDiscountPreview(int points, String amount) {
    return '$points points = $amount discount';
  }

  @override
  String get loyaltyEarned => 'Points Earned';

  @override
  String loyaltyCustomerInfo(int points, String credit) {
    return 'Points: $points | Credit: $credit';
  }

  @override
  String get loyaltyCredit => 'Customer Credit';

  @override
  String get loyaltyCreditTopUp => 'Top Up Credit';

  @override
  String get loyaltyCreditDeduct => 'Deduct Credit';

  @override
  String get loyaltyCreditBalance => 'Balance';

  @override
  String get loyaltyTransactionHistory => 'Transaction History';

  @override
  String get loyaltyNoCustomer => 'No customer assigned to this bill';

  @override
  String get settingsSectionGridManagement => 'Grid Layout Management';

  @override
  String get settingsAutoArrange => 'Auto Arrange';

  @override
  String get settingsAutoArrangeDescription =>
      'Arrange categories and products in grid';

  @override
  String get settingsManualEditor => 'Manual Grid Editor';

  @override
  String get settingsManualEditorDescription => 'Open editor to assign items';

  @override
  String get autoArrangeTitle => 'Auto Arrange';

  @override
  String get autoArrangeHorizontal => 'Horizontal';

  @override
  String get autoArrangeHorizontalDesc => 'Row = category + its products';

  @override
  String get autoArrangeVertical => 'Vertical';

  @override
  String get autoArrangeVerticalDesc =>
      'Column = category + its products below';

  @override
  String get autoArrangeWarning => 'Existing layout will be replaced';

  @override
  String get autoArrangeConfirm => 'Arrange';

  @override
  String autoArrangeSummary(int categories, int products) {
    return '$categories categories, $products products';
  }

  @override
  String autoArrangeOverflow(int fit, int total) {
    return 'Only $fit of $total categories will fit on the main page. The rest will be accessible only on sub-pages.';
  }

  @override
  String get gridEditorTitle2 => 'Grid Editor';

  @override
  String get gridEditorBack => 'Back';

  @override
  String get gridEditorRootPage => 'Main Page';

  @override
  String gridEditorPage(int page) {
    return 'Page $page';
  }

  @override
  String get gridEditorColor => 'Button Color';

  @override
  String get settingsFloorMap => 'Map';

  @override
  String get billsTableList => 'List';

  @override
  String get floorMapEditorTitle => 'Map Editor';

  @override
  String get floorMapAddTable => 'Add Table to Map';

  @override
  String get floorMapEditTable => 'Edit Table Position';

  @override
  String get floorMapRemoveTable => 'Remove from Map';

  @override
  String get floorMapWidth => 'Width (cells)';

  @override
  String get floorMapHeight => 'Height (cells)';

  @override
  String get floorMapSelectSection => 'Section';

  @override
  String get floorMapSelectTable => 'Table';

  @override
  String get floorMapNewTable => 'New Table';

  @override
  String get floorMapNoTables =>
      'No tables on map. Add them in map editor in Settings.';

  @override
  String get floorMapEmptySlot => 'Empty';

  @override
  String get floorMapShapeRectangle => 'Rectangle';

  @override
  String get floorMapShapeRound => 'Oval';

  @override
  String get floorMapShapeTriangle => 'Triangle';

  @override
  String get floorMapShapeDiamond => 'Diamond';

  @override
  String get floorMapSegmentTable => 'Table';

  @override
  String get floorMapSegmentElement => 'Element';

  @override
  String get floorMapAddElement => 'Add Element to Map';

  @override
  String get floorMapEditElement => 'Edit Element';

  @override
  String get floorMapRemoveElement => 'Remove from Map';

  @override
  String get floorMapElementLabel => 'Label';

  @override
  String get floorMapElementColor => 'Color';

  @override
  String get floorMapColorNone => 'None';

  @override
  String get floorMapElementFontSize => 'Text size';

  @override
  String get floorMapElementFillStyle => 'Fill';

  @override
  String get floorMapElementBorderStyle => 'Border';

  @override
  String get floorMapStyleNone => 'None';

  @override
  String get floorMapStyleTranslucent => 'Translucent';

  @override
  String get floorMapStyleSolid => 'Solid';

  @override
  String get vouchersTitle => 'Vouchers';

  @override
  String get voucherCreate => 'Create Voucher';

  @override
  String get voucherTypeGift => 'Gift';

  @override
  String get voucherTypeDeposit => 'Deposit';

  @override
  String get voucherTypeDiscount => 'Discount';

  @override
  String get voucherStatusActive => 'Active';

  @override
  String get voucherStatusRedeemed => 'Redeemed';

  @override
  String get voucherStatusExpired => 'Expired';

  @override
  String get voucherStatusCancelled => 'Cancelled';

  @override
  String get voucherCode => 'Code';

  @override
  String get voucherValue => 'Value';

  @override
  String get voucherDiscount => 'Discount';

  @override
  String get voucherExpires => 'Expires';

  @override
  String get voucherCustomer => 'Customer';

  @override
  String get voucherNote => 'Note';

  @override
  String get voucherScopeBill => 'Full Bill';

  @override
  String get voucherScopeProduct => 'Product';

  @override
  String get voucherScopeCategory => 'Category';

  @override
  String get voucherMaxUses => 'Max Uses';

  @override
  String get voucherUsedCount => 'Used';

  @override
  String get voucherMinOrderValue => 'Min. Order Value';

  @override
  String get voucherSell => 'Sell';

  @override
  String get voucherCancel => 'Cancel Voucher';

  @override
  String get voucherRedeem => 'Redeem';

  @override
  String get voucherEnterCode => 'Enter voucher code';

  @override
  String get voucherInvalid => 'Invalid voucher code';

  @override
  String get voucherExpiredError => 'Voucher expired';

  @override
  String get voucherAlreadyUsed => 'Voucher already redeemed';

  @override
  String get voucherMinOrderNotMet => 'Minimum order value not met';

  @override
  String get voucherCustomerMismatch =>
      'Voucher is assigned to another customer';

  @override
  String get voucherDepositReturn => 'Deposit overpayment return';

  @override
  String get voucherFilterAll => 'All';

  @override
  String get voucherRedeemedAt => 'Redeemed';

  @override
  String get voucherIdLabel => 'ID';

  @override
  String get billDetailVoucher => 'Voucher';

  @override
  String get wizardLanguage => 'Language';

  @override
  String get wizardCurrency => 'Default Currency';

  @override
  String get wizardWithTestData => 'Create with test data';

  @override
  String get orderItemStorno => 'Void';

  @override
  String get orderItemStornoConfirm =>
      'Are you sure you want to void this item?';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersFilterActive => 'Active';

  @override
  String get ordersFilterCreated => 'Created';

  @override
  String get ordersFilterInPrep => 'In Prep';

  @override
  String get ordersFilterReady => 'Ready';

  @override
  String get ordersFilterDelivered => 'Delivered';

  @override
  String get ordersFilterStorno => 'Voided';

  @override
  String get ordersScopeSession => 'Session';

  @override
  String get ordersScopeAll => 'All';

  @override
  String get ordersNoOrders => 'No orders';

  @override
  String get ordersTimeCreated => 'Order creation time';

  @override
  String get ordersTimeUpdated => 'Last update time';

  @override
  String get ordersTableLabel => 'Table';

  @override
  String get ordersCustomerLabel => 'Customer';

  @override
  String get ordersStornoPrefix => 'VOID';

  @override
  String ordersStornoRef(String orderNumber) {
    return '→ $orderNumber';
  }

  @override
  String get customerDisplayTitle => 'Customer Display';

  @override
  String get customerDisplayWelcome => 'Welcome';

  @override
  String get customerDisplayHeader => 'Your Bill';

  @override
  String get customerDisplaySubtotal => 'Subtotal';

  @override
  String get customerDisplayDiscount => 'Discount';

  @override
  String get customerDisplayTotal => 'Total';

  @override
  String get kdsTitle => 'Kitchen';

  @override
  String get kdsNoOrders => 'No orders to prepare';

  @override
  String get kdsBump => 'Bump';

  @override
  String kdsMinAgo(String minutes) {
    return '$minutes min';
  }

  @override
  String get sellSeparator => 'Separate';

  @override
  String get sellSeparatorLabel => '--- Next Order ---';

  @override
  String get customerEnterName => 'Enter Name';

  @override
  String get customerNameHint => 'Guest name';

  @override
  String get settingsRegisters => 'Registers';

  @override
  String get registerName => 'Name';

  @override
  String get registerType => 'Type';

  @override
  String get registerNumber => 'Number';

  @override
  String get registerParent => 'Parent Register';

  @override
  String get registerAllowCash => 'Cash';

  @override
  String get registerAllowCard => 'Card';

  @override
  String get registerAllowTransfer => 'Transfer';

  @override
  String get registerAllowRefunds => 'Refunds';

  @override
  String get registerPaymentFlags => 'Allowed Payments';

  @override
  String get registerTypeLocal => 'Local';

  @override
  String get registerTypeMobile => 'Mobile';

  @override
  String get registerTypeVirtual => 'Virtual';

  @override
  String get registerDeviceBinding => 'Device Binding';

  @override
  String registerBound(String name) {
    return 'Bound to: $name';
  }

  @override
  String get registerNotBound => 'Not Bound';

  @override
  String get registerBind => 'Select Register';

  @override
  String get registerUnbind => 'Unbind';

  @override
  String get registerSelectTitle => 'Select Register';

  @override
  String get registerNone => 'None';

  @override
  String get registerIsMain => 'Main';

  @override
  String get registerSetMain => 'Set as Main';

  @override
  String get registerBoundHere => 'This Device';

  @override
  String get registerBindAction => 'Bind';

  @override
  String get registerSessionActiveCannotChange =>
      'Cannot change binding during active session.';

  @override
  String get registerBoundOnOtherDevice => 'Used by another device';

  @override
  String get infoPanelRegisterName => 'Register Name';

  @override
  String get connectCompanySelectRegister => 'Select Register';

  @override
  String get connectCompanySelectRegisterSubtitle =>
      'Select a register for this device';

  @override
  String get connectCompanyNoRegisters => 'No registers available';

  @override
  String get connectCompanyCreateRegister => 'Create New Register';

  @override
  String get registerNotBoundMessage =>
      'Register is not assigned to this device. Assign a register in Settings.';

  @override
  String get modeTitle => 'Mode';

  @override
  String get modePOS => 'POS';

  @override
  String get modePOSDescription => 'Standard sales mode';

  @override
  String get modeKDS => 'Kitchen Display';

  @override
  String get modeKDSDescription => 'Displays active orders for kitchen';

  @override
  String get modeCustomerDisplay => 'Customer Display';

  @override
  String get modeCustomerDisplayDescription => 'Shows bill to customer';

  @override
  String get modeCustomerDisplaySelectRegister => 'Monitored Register';

  @override
  String get customerDisplayThankYou => 'Thank You!';

  @override
  String get customerDisplayPaid => 'Paid';

  @override
  String get billDetailShowOnDisplay => 'Customer Display';

  @override
  String get onboardingSectionPos => 'Point of Sale';

  @override
  String get onboardingSectionDisplays => 'Displays';

  @override
  String get onboardingCustomerDisplay => 'Customer Display';

  @override
  String get onboardingKdsDisplay => 'Order Display (KDS)';

  @override
  String get displayCodeTitle => 'Enter Code';

  @override
  String get displayCodeSubtitle =>
      'Enter the 6-digit code shown on the register';

  @override
  String get displayCodeConnect => 'Connect';

  @override
  String get displayCodeBack => 'Back';

  @override
  String get displayCodeNotFound => 'Code not found';

  @override
  String get displayCodeError => 'Error looking up code';

  @override
  String get displayDevicesTitle => 'Displays';

  @override
  String get displayDevicesEmpty => 'No display devices';

  @override
  String get displayDeviceAddCustomer => 'Customer';

  @override
  String get displayDeviceAddKds => 'KDS';
}

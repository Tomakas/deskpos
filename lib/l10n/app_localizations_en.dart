// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Maty';

  @override
  String get onboardingTitle => 'Maty POS System';

  @override
  String get onboardingCreateCompany => 'Create New Company';

  @override
  String get onboardingJoinCompany => 'Sign In to Existing Company';

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
  String get billTimeNoOrder => 'none';

  @override
  String get infoPanelDate => 'Date';

  @override
  String get infoPanelStatus => 'Register Status';

  @override
  String get infoPanelStatusOffline => 'Closed';

  @override
  String get infoPanelActiveUser => 'Active Staff';

  @override
  String get infoPanelLoggedIn => 'Other Logins';

  @override
  String get actionSwitchUser => 'Switch';

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
  String get fieldPrice => 'Sale Price';

  @override
  String get fieldTaxRate => 'Sale Tax';

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
  String get roleManager => 'Manager';

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
  String get sellRemoveFromCart => 'Remove this item from the cart?';

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
  String get sellClearCart => 'Clear Cart';

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
  String get settingsTabInfo => 'Info';

  @override
  String get settingsTabVenue => 'Venue';

  @override
  String get settingsTabRegister => 'Register';

  @override
  String get settingsTabUsers => 'Users';

  @override
  String get settingsTabLog => 'Log';

  @override
  String get settingsSectionCompanyInfo => 'Company Information';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsSectionCloud => 'Cloud';

  @override
  String get settingsSectionSellOptions => 'Sell Options';

  @override
  String get settingsSellMode => 'Sell Mode';

  @override
  String get sellModeGastro => 'Gastro';

  @override
  String get sellModeRetail => 'Retail';

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
  String get cloudDiagnostics => 'Diagnostics';

  @override
  String get cloudExportLogs => 'Export Logs';

  @override
  String get cloudExportLogsDescription =>
      'Opens the application log file for troubleshooting.';

  @override
  String get cloudDangerZone => 'Danger Zone';

  @override
  String get cloudDeleteLocalData => 'Delete Local Data';

  @override
  String get cloudDeleteLocalDataDescription =>
      'Deletes data from this device. Server data will remain intact and will sync back after sign-in.';

  @override
  String get cloudDeleteLocalDataConfirmTitle => 'Delete local data?';

  @override
  String get cloudDeleteLocalDataConfirmMessage =>
      'All local data will be deleted and the app will return to the welcome screen. Server data will remain intact.';

  @override
  String get cloudDeleteLocalDataConfirm => 'Delete';

  @override
  String get cloudDeleteAllData => 'Delete All Data';

  @override
  String get cloudDeleteAllDataDescription =>
      'Deletes all data from this device and from the server. This action is irreversible.';

  @override
  String get cloudDeleteAllDataConfirmTitle => 'Delete all data?';

  @override
  String get cloudDeleteAllDataConfirmMessage =>
      'All data will be permanently deleted from this device and from the server. The app will return to the welcome screen.';

  @override
  String get cloudDeleteAllDataConfirm => 'Delete All';

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
  String get paymentMoreActions => 'More Actions';

  @override
  String get paymentMixPayments => 'Mixed Payments';

  @override
  String get paymentOtherPayment => 'Other Payment';

  @override
  String get paymentPrintReceipt => 'Print Receipt';

  @override
  String get paymentPrintYes => 'YES';

  @override
  String get paymentPrintNo => 'NO';

  @override
  String paymentTip(String amount) {
    return '+$amount tip';
  }

  @override
  String paymentRemaining(String amount) {
    return 'Remaining $amount';
  }

  @override
  String paymentBillSubtitle(String billNumber, String tableName) {
    return 'Bill $billNumber - $tableName';
  }

  @override
  String get discountTitleBill => 'Bill discount';

  @override
  String get discountTitleItem => 'Item discount';

  @override
  String get billDetailDiscount => 'Discount';

  @override
  String get billDetailRemoveDiscount => 'Remove Discount';

  @override
  String get billDetailRemoveDiscountConfirm =>
      'Remove discount from this bill?';

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
  String get changeTotalOriginal => 'Original';

  @override
  String get changeTotalEdited => 'Edited';

  @override
  String get changeTotalDifference => 'Change';

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
  String get fieldDescription => 'Description';

  @override
  String get fieldSku => 'SKU';

  @override
  String get fieldUnit => 'Unit';

  @override
  String get unitTypeKs => 'pcs';

  @override
  String get unitTypeG => 'g';

  @override
  String get unitTypeKg => 'kg';

  @override
  String get unitTypeMl => 'ml';

  @override
  String get unitTypeCl => 'cl';

  @override
  String get unitTypeL => 'l';

  @override
  String get unitTypeMm => 'mm';

  @override
  String get unitTypeCm => 'cm';

  @override
  String get unitTypeM => 'm';

  @override
  String get unitTypeMin => 'min';

  @override
  String get unitTypeH => 'h';

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
  String get splitBillPayButton => 'Split and Pay';

  @override
  String get splitBillNewBillButton => 'Split to New Bill';

  @override
  String splitBillSourceLabel(String billNumber) {
    return 'Bill #$billNumber';
  }

  @override
  String get splitBillTargetLabel => 'New bill';

  @override
  String get splitBillTotal => 'Total';

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
  String get inventoryNewDocument => 'New Document';

  @override
  String get inventoryNewDocumentTitle => 'Select Document Type';

  @override
  String get inventoryReceiptDesc => 'Record incoming goods from a supplier';

  @override
  String get inventoryWasteDesc => 'Write off damaged or expired goods';

  @override
  String get inventoryCorrectionDesc => 'Manually adjust stock quantities';

  @override
  String get inventoryInventoryDesc => 'Physical stock count and comparison';

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
  String get stockDocumentDetailTitle => 'Document Detail';

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
  String get inventoryTabMovements => 'Movements';

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
  String get movementColumnDate => 'Date';

  @override
  String get movementColumnItem => 'Item';

  @override
  String get movementColumnQuantity => 'Quantity';

  @override
  String get movementColumnType => 'Type';

  @override
  String get movementColumnDocument => 'Document';

  @override
  String get movementNoMovements => 'No stock movements';

  @override
  String get movementFilterItem => 'Filter by item';

  @override
  String get movementTypeSale => 'Sale';

  @override
  String get movementTypeReversal => 'Reversal';

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
  String get receiptVoucherDiscount => 'Voucher';

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
  String get reservationDuration => 'Duration (min)';

  @override
  String get reservationViewTable => 'Table';

  @override
  String get reservationViewChart => 'Chart';

  @override
  String get reservationChartNoData => 'No reservations to display';

  @override
  String get reservationSectionAll => 'All';

  @override
  String get paymentTypeCredit => 'Credit';

  @override
  String get paymentTypeVoucher => 'Meal Vouchers';

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
  String get settingsDiscountLimits => 'Discount Limits';

  @override
  String get settingsMaxItemDiscount => 'Max item discount (%)';

  @override
  String get settingsMaxBillDiscount => 'Max bill discount (%)';

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
  String get voucherCreatedAt => 'Created';

  @override
  String get voucherCreatedBy => 'Created by';

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
  String get voucherPrint => 'Print';

  @override
  String get voucherPdfTitle => 'VOUCHER';

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
  String get billDetailRemoveVoucher => 'Remove Voucher';

  @override
  String get billDetailRemoveVoucherConfirm =>
      'Remove applied voucher from this bill?';

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
  String get ordersTimeCreated => 'Created';

  @override
  String get ordersTimeUpdated => 'Updated';

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
  String get registerAllowCredit => 'Credit';

  @override
  String get registerAllowVoucher => 'Meal Vouchers';

  @override
  String get registerAllowOther => 'Other';

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
  String get modeKDS => 'Kitchen Display';

  @override
  String get modeCustomerDisplay => 'Customer Display';

  @override
  String get customerDisplayThankYou => 'Thank You!';

  @override
  String get customerDisplayPaid => 'Paid';

  @override
  String get billDetailShowOnDisplay => 'Customer Display';

  @override
  String get onboardingCustomerDisplay => 'Customer Display';

  @override
  String get onboardingCustomerDisplaySubtitle =>
      'This device will serve as a customer display after connecting.';

  @override
  String get onboardingCreateDemo => 'Demo Account';

  @override
  String get onboardingCreateDemoSubtitle =>
      'Creates a complete company with data including three months of history.';

  @override
  String get demoDialogTitle => 'Create Demo Company';

  @override
  String get demoDialogInfo => 'Demo auto-deletes after 6 hours';

  @override
  String get demoDialogCreate => 'Create';

  @override
  String get demoDialogCreating =>
      'Creating demo data, this may take a moment...';

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
  String get displayCodeWaitingForConfirmation =>
      'Waiting for operator confirmation…';

  @override
  String get displayCodeRejected => 'Connection was rejected';

  @override
  String get displayCodeTimeout => 'No response from operator. Try again.';

  @override
  String get pairingRequestTitle => 'Connection request';

  @override
  String get pairingRequestMessage =>
      'A device wants to connect to this register:';

  @override
  String get pairingRequestCode => 'Code';

  @override
  String get pairingConfirm => 'Confirm';

  @override
  String get pairingReject => 'Reject';

  @override
  String get displayDevicesTitle => 'Displays';

  @override
  String get displayDevicesEmpty => 'No display devices';

  @override
  String get displayDeviceAddCustomer => 'Customer';

  @override
  String get displayDeviceAddKds => 'KDS';

  @override
  String get displayWelcomeText => 'Welcome text';

  @override
  String get displayDefaultNameKds => 'Order System';

  @override
  String get displayDefaultWelcomeText => 'Welcome!';

  @override
  String get wizardStepAccount => 'Cloud Account';

  @override
  String get wizardAccountEmail => 'Email';

  @override
  String get wizardAccountPassword => 'Password';

  @override
  String get wizardAccountPasswordConfirm => 'Confirm Password';

  @override
  String get wizardAccountPasswordMismatch => 'Passwords do not match';

  @override
  String get wizardAccountSignUp => 'Create Account';

  @override
  String get wizardAccountSignIn => 'Sign In';

  @override
  String get wizardAccountSwitchToSignIn => 'Already have an account? Sign in';

  @override
  String get wizardAccountSwitchToSignUp =>
      'Don\'t have an account? Create one';

  @override
  String cloudConnectedAs(String email) {
    return 'Connected as $email';
  }

  @override
  String get actionExitApp => 'Exit App';

  @override
  String get actionOk => 'OK';

  @override
  String errorGeneric(Object error) {
    return 'Error: $error';
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
  String get variantPickerTitle => 'Select variant';

  @override
  String get addVariant => 'Add variant';

  @override
  String get editVariant => 'Edit variant';

  @override
  String get variants => 'Variants';

  @override
  String get noVariants => 'No variants';

  @override
  String get modifiers => 'Modifiers';

  @override
  String get modifierGroups => 'Modifier Groups';

  @override
  String get modifierGroupName => 'Group Name';

  @override
  String get addModifierGroup => 'Add Group';

  @override
  String get editModifierGroup => 'Edit Group';

  @override
  String get deleteModifierGroup => 'Delete Group';

  @override
  String get minSelections => 'Min. Selections';

  @override
  String get maxSelections => 'Max. Selections';

  @override
  String get required => 'Required';

  @override
  String get optional => 'Optional';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get addModifier => 'Add Modifier';

  @override
  String get selectModifiers => 'Select Modifiers';

  @override
  String get editModifiers => 'Edit Modifiers';

  @override
  String get noModifierGroups => 'No modifier groups';

  @override
  String get modifierTotal => 'Total with modifiers';

  @override
  String get modifierGroupRequired => 'Required group';

  @override
  String get assignModifierGroup => 'Assign Group';

  @override
  String get removeModifierGroup => 'Remove Group';

  @override
  String get inventoryTypeTitle => 'Inventory Type';

  @override
  String get inventoryTypeComplete => 'Complete';

  @override
  String get inventoryTypeCompleteDesc => 'All stock-tracked items';

  @override
  String get inventoryTypeByCategory => 'By Category';

  @override
  String get inventoryTypeByCategoryDesc => 'Items from selected categories';

  @override
  String get inventoryTypeBySupplier => 'By Supplier';

  @override
  String get inventoryTypeBySupplierDesc => 'Items from selected suppliers';

  @override
  String get inventoryTypeByManufacturer => 'By Manufacturer';

  @override
  String get inventoryTypeByManufacturerDesc =>
      'Items from selected manufacturers';

  @override
  String get inventoryTypeSelective => 'Selective';

  @override
  String get inventoryTypeSelectiveDesc => 'Manual item selection';

  @override
  String get inventoryTypeContinue => 'Continue';

  @override
  String get inventoryTypeNoItems => 'No items to select';

  @override
  String get inventoryBlindMode => 'Blind inventory';

  @override
  String get inventoryBlindModeDesc => 'Without showing expected quantities';

  @override
  String get inventoryPrintTemplate => 'Print template';

  @override
  String get inventoryResultTitle => 'Inventory Results';

  @override
  String get inventoryResultSurplus => 'Surplus';

  @override
  String get inventoryResultShortage => 'Shortage';

  @override
  String inventoryResultItemCount(int count) {
    return '$count items';
  }

  @override
  String get inventoryResultApply => 'Apply to stock';

  @override
  String get inventoryResultApplied => 'Applied';

  @override
  String get inventoryResultPrint => 'Print results';

  @override
  String get inventoryResultExpected => 'Expected';

  @override
  String get inventoryResultActual => 'Actual';

  @override
  String get inventoryPdfTemplateTitle => 'INVENTORY — TEMPLATE';

  @override
  String get inventoryPdfResultsTitle => 'INVENTORY — RESULTS';

  @override
  String get inventoryResultClose => 'Close';

  @override
  String get inventoryResultNcValue => 'PC';

  @override
  String get tipStatsTitle => 'Tips';

  @override
  String get tipStatsTotal => 'Total';

  @override
  String get tipStatsColumnUser => 'Staff';

  @override
  String get tipStatsColumnCount => 'Count';

  @override
  String get tipStatsColumnAmount => 'Amount';

  @override
  String get tipStatsEmpty => 'No tips in this period';

  @override
  String get moreTipStatistics => 'Tips';

  @override
  String get periodDay => 'Day';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodYear => 'Year';

  @override
  String get periodCustom => 'Custom';

  @override
  String get periodToday => 'Today';

  @override
  String get periodYesterday => 'Yesterday';

  @override
  String get periodThisWeek => 'This week';

  @override
  String get periodLastWeek => 'Last week';

  @override
  String get periodThisMonth => 'This month';

  @override
  String get periodLastMonth => 'Last month';

  @override
  String get periodThisYear => 'This year';

  @override
  String get periodLastYear => 'Last year';

  @override
  String get periodTomorrow => 'Tomorrow';

  @override
  String get periodNextWeek => 'Next week';

  @override
  String get periodNextMonth => 'Next month';

  @override
  String get periodNextYear => 'Next year';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsTabReceipts => 'Receipts';

  @override
  String get statsTabSales => 'Sales';

  @override
  String get statsTabShifts => 'Shifts';

  @override
  String get statsTabZReports => 'Z-reports';

  @override
  String get statsTabTips => 'Tips';

  @override
  String get statsSummary => 'Summary';

  @override
  String get statsReceiptCount => 'Receipt count';

  @override
  String get statsReceiptTotal => 'Total revenue';

  @override
  String get statsReceiptAvg => 'Average receipt';

  @override
  String get statsSalesItemCount => 'Items sold';

  @override
  String get statsSalesTotal => 'Total revenue';

  @override
  String get statsSalesUniqueItems => 'Unique items';

  @override
  String get statsShiftCount => 'Shift count';

  @override
  String get statsShiftTotalHours => 'Total hours';

  @override
  String get statsShiftAvgDuration => 'Average shift';

  @override
  String get statsZReportCount => 'Session count';

  @override
  String get statsZReportTotalRevenue => 'Total revenue';

  @override
  String get statsZReportTotalDiff => 'Total difference';

  @override
  String get statsTipCount => 'Tip count';

  @override
  String get statsTipTotal => 'Total tips';

  @override
  String get statsTipAvg => 'Average tip';

  @override
  String get statsEmpty => 'No data in this period';

  @override
  String get statsSortDate => 'Date';

  @override
  String get statsSortDateAsc => 'Date (oldest)';

  @override
  String get statsSortAmount => 'Amount';

  @override
  String get statsSortAmountAsc => 'Amount (lowest)';

  @override
  String get statsSortName => 'Name';

  @override
  String get statsSortNameDesc => 'Name (Z→A)';

  @override
  String get statsSortQty => 'Quantity';

  @override
  String get statsSortDuration => 'Duration';

  @override
  String get statsSortRevenue => 'Revenue';

  @override
  String get statsColumnBillNumber => 'Number';

  @override
  String get statsColumnCustomer => 'Customer';

  @override
  String get statsColumnPaymentMethod => 'Payment';

  @override
  String get statsColumnTotal => 'Total';

  @override
  String get statsColumnItemName => 'Item';

  @override
  String get statsColumnQty => 'Qty';

  @override
  String get statsColumnUnitPrice => 'Unit price';

  @override
  String get statsColumnBill => 'Bill';

  @override
  String get statsColumnDateTime => 'Date & time';

  @override
  String get statsColumnCategory => 'Category';

  @override
  String get statsColumnTax => 'Tax';

  @override
  String get statsColumnOrderNumber => 'Order #';

  @override
  String get statsColumnStatus => 'Status';

  @override
  String get statsTabOrders => 'Orders';

  @override
  String get statsOrderCount => 'Order count';

  @override
  String get statsOrderTotalItems => 'Total items';

  @override
  String get statsOrderTotal => 'Total amount';

  @override
  String get orderStorno => 'Storno';

  @override
  String get statsSalesGrossRevenue => 'Gross item revenue';

  @override
  String get statsSalesItemDiscounts => 'Item discounts';

  @override
  String get statsSalesBillDiscount => 'Bill discount';

  @override
  String get statsSalesLoyaltyDiscount => 'Loyalty discount';

  @override
  String get statsSalesVoucherDiscount => 'Voucher discount';

  @override
  String get statsSalesRounding => 'Rounding';

  @override
  String get statsSalesFinalTotal => 'Total (receipts)';

  @override
  String get sellEnterQuantity => 'Enter quantity';

  @override
  String get statsFilterTitle => 'Filter';

  @override
  String get statsFilterPaymentMethod => 'Payment method';

  @override
  String get statsFilterTakeaway => 'Type';

  @override
  String get statsFilterAll => 'All';

  @override
  String get statsFilterDineIn => 'Dine-in';

  @override
  String get statsFilterTakeawayOnly => 'Takeaway';

  @override
  String get statsFilterCategory => 'Category';

  @override
  String get statsFilterStatus => 'Status';

  @override
  String get statsFilterApply => 'Apply';

  @override
  String get statsFilterStorno => 'Storno';

  @override
  String get statsFilterDiscount => 'Discount';

  @override
  String get statsFilterWithDiscount => 'With discount';

  @override
  String get statsFilterWithoutDiscount => 'Without discount';

  @override
  String get permOrdersCreate => 'Create order';

  @override
  String get permOrdersView => 'View own orders';

  @override
  String get permOrdersViewAll => 'View all orders';

  @override
  String get permOrdersViewPaid => 'View paid bills';

  @override
  String get permOrdersViewCancelled => 'View cancelled bills';

  @override
  String get permOrdersViewDetail => 'Order detail in info panel';

  @override
  String get permOrdersEdit => 'Edit order';

  @override
  String get permOrdersEditOthers => 'Edit others\' orders';

  @override
  String get permOrdersVoidItem => 'Void item';

  @override
  String get permOrdersVoidBill => 'Void bill';

  @override
  String get permOrdersReopen => 'Reopen bill';

  @override
  String get permOrdersTransfer => 'Transfer bill';

  @override
  String get permOrdersSplit => 'Split bill';

  @override
  String get permOrdersMerge => 'Merge bills';

  @override
  String get permOrdersAssignCustomer => 'Assign customer';

  @override
  String get permOrdersBump => 'Bump status';

  @override
  String get permOrdersBumpBack => 'Bump back status';

  @override
  String get permPaymentsAccept => 'Accept payment';

  @override
  String get permPaymentsRefund => 'Refund payment';

  @override
  String get permPaymentsRefundItem => 'Refund item';

  @override
  String get permPaymentsMethodCash => 'Cash payment';

  @override
  String get permPaymentsMethodCard => 'Card payment';

  @override
  String get permPaymentsMethodVoucher => 'Voucher payment';

  @override
  String get permPaymentsMethodMealTicket => 'Meal ticket payment';

  @override
  String get permPaymentsMethodCredit => 'Credit payment';

  @override
  String get permPaymentsSkipCashDialog => 'Skip cash dialog';

  @override
  String get permPaymentsAcceptTip => 'Accept tip';

  @override
  String get permPaymentsAdjustTip => 'Adjust tip';

  @override
  String get permDiscountsApplyItemLimited => 'Item discount (limited)';

  @override
  String get permDiscountsApplyItem => 'Item discount (unlimited)';

  @override
  String get permDiscountsApplyBillLimited => 'Bill discount (limited)';

  @override
  String get permDiscountsApplyBill => 'Bill discount (unlimited)';

  @override
  String get permDiscountsLoyalty => 'Redeem loyalty points';

  @override
  String get permRegisterOpenSession => 'Open register session';

  @override
  String get permRegisterCloseSession => 'Close register session';

  @override
  String get permRegisterViewSession => 'View register session';

  @override
  String get permRegisterViewAllSessions => 'View all sessions';

  @override
  String get permRegisterCashIn => 'Cash deposit';

  @override
  String get permRegisterCashOut => 'Cash withdrawal';

  @override
  String get permRegisterOpenDrawer => 'Open cash drawer';

  @override
  String get permShiftsClockInOut => 'Clock in/out';

  @override
  String get permShiftsViewOwn => 'View own shifts';

  @override
  String get permShiftsViewAll => 'View all shifts';

  @override
  String get permShiftsManage => 'Manage shifts';

  @override
  String get permProductsView => 'View products';

  @override
  String get permProductsViewCost => 'View purchase prices';

  @override
  String get permProductsManage => 'Manage products';

  @override
  String get permProductsManageCategories => 'Manage categories';

  @override
  String get permProductsManageModifiers => 'Manage modifiers';

  @override
  String get permProductsManageRecipes => 'Manage recipes';

  @override
  String get permProductsManagePurchasePrice => 'Manage purchase prices';

  @override
  String get permProductsManageTax => 'Manage tax rates';

  @override
  String get permProductsManageSuppliers => 'Manage suppliers';

  @override
  String get permProductsManageManufacturers => 'Manage manufacturers';

  @override
  String get permProductsSetAvailability => 'Set availability';

  @override
  String get permStockViewLevels => 'View stock levels';

  @override
  String get permStockViewDocuments => 'View stock documents';

  @override
  String get permStockViewMovements => 'View stock movements';

  @override
  String get permStockReceive => 'Receive stock';

  @override
  String get permStockWastage => 'Record wastage';

  @override
  String get permStockAdjust => 'Adjust stock';

  @override
  String get permStockCount => 'Stock count';

  @override
  String get permStockTransfer => 'Stock transfer';

  @override
  String get permStockSetPriceStrategy => 'Set price strategy';

  @override
  String get permStockManageWarehouses => 'Manage warehouses';

  @override
  String get permCustomersView => 'View customers';

  @override
  String get permCustomersManage => 'Manage customers';

  @override
  String get permCustomersManageCredit => 'Manage customer credit';

  @override
  String get permCustomersManageLoyalty => 'Manage loyalty points';

  @override
  String get permVouchersView => 'View vouchers';

  @override
  String get permVouchersManage => 'Manage vouchers';

  @override
  String get permVouchersRedeem => 'Redeem voucher';

  @override
  String get permVenueView => 'View venue';

  @override
  String get permVenueReservationsView => 'View reservations';

  @override
  String get permVenueReservationsManage => 'Manage reservations';

  @override
  String get permStatsReceipts => 'Receipts (session)';

  @override
  String get permStatsReceiptsAll => 'Receipts (history)';

  @override
  String get permStatsSales => 'Sales (session)';

  @override
  String get permStatsSalesAll => 'Sales (history)';

  @override
  String get permStatsOrders => 'Orders (session)';

  @override
  String get permStatsOrdersAll => 'Orders (history)';

  @override
  String get permStatsTips => 'Tips (session)';

  @override
  String get permStatsTipsAll => 'Tips (history)';

  @override
  String get permStatsCashJournal => 'Cash journal (session)';

  @override
  String get permStatsCashJournalAll => 'Cash journal (history)';

  @override
  String get permStatsShifts => 'Shifts';

  @override
  String get permStatsZReports => 'Z-reports';

  @override
  String get permPrintingReceipt => 'Print receipt';

  @override
  String get permPrintingReprint => 'Reprint receipt';

  @override
  String get permPrintingZReport => 'Print Z-report';

  @override
  String get permPrintingInventoryReport => 'Print inventory report';

  @override
  String get permDataExport => 'Export data';

  @override
  String get permDataImport => 'Import data';

  @override
  String get permDataBackup => 'Backup and restore';

  @override
  String get permUsersView => 'View users';

  @override
  String get permUsersManage => 'Manage users';

  @override
  String get permUsersAssignRoles => 'Assign roles';

  @override
  String get permUsersManagePermissions => 'Manage permissions';

  @override
  String get permSettingsCompanyInfo => 'Company info';

  @override
  String get permSettingsCompanySecurity => 'Security settings';

  @override
  String get permSettingsCompanyFiscal => 'Fiscal settings';

  @override
  String get permSettingsCompanyCloud => 'Cloud and sync';

  @override
  String get permSettingsCompanyDataWipe => 'Wipe data';

  @override
  String get permSettingsCompanyViewLog => 'View system log';

  @override
  String get permSettingsCompanyClearLog => 'Clear system log';

  @override
  String get permSettingsVenueSections => 'Manage sections';

  @override
  String get permSettingsVenueTables => 'Manage tables';

  @override
  String get permSettingsVenueFloorPlan => 'Edit floor plan';

  @override
  String get permSettingsRegisterManage => 'Manage registers';

  @override
  String get permSettingsRegisterHardware => 'Configure hardware';

  @override
  String get permSettingsRegisterGrid => 'Edit sell grid';

  @override
  String get permSettingsRegisterDisplays => 'Manage displays';

  @override
  String get permSettingsRegisterPaymentMethods => 'Payment methods';

  @override
  String get permSettingsRegisterTaxRates => 'Tax rates';

  @override
  String get permSettingsRegisterManageDevices => 'Manage display devices';

  @override
  String get permGroupOrders => 'Orders';

  @override
  String get permGroupPayments => 'Payments';

  @override
  String get permGroupDiscounts => 'Discounts & prices';

  @override
  String get permGroupRegister => 'Register';

  @override
  String get permGroupShifts => 'Shifts';

  @override
  String get permGroupProducts => 'Products & catalog';

  @override
  String get permGroupStock => 'Stock';

  @override
  String get permGroupCustomers => 'Customers & loyalty';

  @override
  String get permGroupVouchers => 'Vouchers';

  @override
  String get permGroupVenue => 'Venue';

  @override
  String get permGroupStats => 'Statistics & reports';

  @override
  String get permGroupPrinting => 'Printing';

  @override
  String get permGroupData => 'Data';

  @override
  String get permGroupUsers => 'Users & roles';

  @override
  String get permGroupSettingsCompany => 'Settings — company';

  @override
  String get permGroupSettingsVenue => 'Settings — venue';

  @override
  String get permGroupSettingsRegister => 'Settings — register';

  @override
  String get tabProfile => 'Profile';

  @override
  String get tabPermissions => 'Permissions';

  @override
  String get permissionsResetToRole => 'Reset to role';

  @override
  String get permissionsCustomized => '(customized)';

  @override
  String get permissionsResetConfirm =>
      'Reset all permissions to role template?';

  @override
  String get statsReceiptDetailTitle => 'Receipt detail';

  @override
  String get statsReceiptType => 'Type';

  @override
  String get statsOrderDetailTitle => 'Order detail';

  @override
  String get statsOrderPrepStarted => 'Prep started';

  @override
  String get statsOrderReady => 'Ready';

  @override
  String get statsOrderDelivered => 'Delivered';

  @override
  String get statsOrderCreated => 'Created';

  @override
  String get statsOrderItems => 'Items';

  @override
  String get settingsCurrencyLocked =>
      'Default currency cannot be changed after the first bill is created.';

  @override
  String get settingsAlternativeCurrencies => 'Alternative currencies';

  @override
  String get settingsAddCurrency => 'Add currency';

  @override
  String get settingsExchangeRate => 'Exchange rate';

  @override
  String settingsExchangeRateLabel(String code) {
    return '1 $code =';
  }

  @override
  String get paymentForeignCurrencySelect => 'Other currency';

  @override
  String paymentForeignRate(String rate, String amount) {
    return '× $rate = $amount';
  }

  @override
  String get paymentChangeInBase => 'Change in base currency';

  @override
  String get cashTenderTitle => 'Cash';

  @override
  String get cashTenderAmountDue => 'Amount due';

  @override
  String cashTenderChange(String amount) {
    return 'Change: $amount';
  }

  @override
  String cashTenderRemaining(String amount) {
    return 'Remaining: $amount';
  }

  @override
  String get cashTenderSkip => 'Skip';

  @override
  String cashTenderConversion(
    String foreignAmount,
    String rate,
    String baseAmount,
  ) {
    return '$foreignAmount × $rate = $baseAmount';
  }

  @override
  String cashTenderChangeReason(String currencyCode) {
    return 'Change from $currencyCode payment';
  }

  @override
  String get openingForeignCashTitle => 'Opening cash for foreign currencies';

  @override
  String get closingForeignCashTitle => 'Closing cash for foreign currencies';

  @override
  String get zReportForeignCashTitle => 'Foreign currency cash';

  @override
  String get zReportForeignOpening => 'Opening';

  @override
  String get zReportForeignRevenue => 'Revenue';

  @override
  String get zReportForeignExpected => 'Expected';

  @override
  String get zReportForeignClosing => 'Actual';

  @override
  String get zReportForeignDifference => 'Difference';

  @override
  String get currencySelectorTitle => 'Select currency';

  @override
  String get currencySelectorBack => 'Back';

  @override
  String get statsTabDashboard => 'Dashboard';

  @override
  String get dashboardRevenue => 'Revenue';

  @override
  String get dashboardBillCount => 'Bills';

  @override
  String get dashboardAverage => 'Average';

  @override
  String get dashboardTips => 'Tips';

  @override
  String get dashboardPrevPeriod => 'Previous period:';

  @override
  String get dashboardRevenueOverTime => 'Revenue over time';

  @override
  String get dashboardPaymentMethods => 'Payment methods';

  @override
  String get dashboardCategories => 'Categories';

  @override
  String get dashboardTopProducts => 'Top 10 products';

  @override
  String get dashboardByQuantity => 'Quantity';

  @override
  String get dashboardByRevenue => 'Revenue';

  @override
  String get dashboardHeatmap => 'Weekly pattern';

  @override
  String get heatmapMon => 'Mon';

  @override
  String get heatmapTue => 'Tue';

  @override
  String get heatmapWed => 'Wed';

  @override
  String get heatmapThu => 'Thu';

  @override
  String get heatmapFri => 'Fri';

  @override
  String get heatmapSat => 'Sat';

  @override
  String get heatmapSun => 'Sun';

  @override
  String get heatmapLow => 'Low';

  @override
  String get heatmapHigh => 'High';

  @override
  String get dashboardOther => 'Other';

  @override
  String get wizardDemoMode => 'Demo mode';

  @override
  String get wizardDemoCreating => 'Creating demo data...';

  @override
  String get wizardDemoDownloading => 'Downloading data...';

  @override
  String get wizardDemoInfo => 'Demo creates 4 users, all with PIN 1111';

  @override
  String get ordersSortAsc => 'Oldest first';

  @override
  String get ordersSortDesc => 'Newest first';

  @override
  String get ordersSortByTime => 'Time';

  @override
  String get ordersSortByNumber => 'Number';

  @override
  String get ordersSortByStatus => 'Status';

  @override
  String get peripheralsTitle => 'Peripherals';

  @override
  String get peripheralsScanner => 'Scanner';

  @override
  String get peripheralsScannerConnection => 'Connection';

  @override
  String get peripheralsScannerEnabled => 'Scanner enabled';

  @override
  String get peripheralsCashDrawer => 'Cash Drawer';

  @override
  String get peripheralsCashDrawerOpenOnPayment => 'Open on payment';

  @override
  String get peripheralsCashDrawerConnection => 'Connection';

  @override
  String get peripheralsPrinter => 'Receipt Printer';

  @override
  String get peripheralsPrinterConnection => 'Connection';

  @override
  String get peripheralsPrinterAutoPrint => 'Auto-print receipt';

  @override
  String get peripheralsTerminal => 'Payment Terminal';

  @override
  String get peripheralsTerminalConnection => 'Connection';

  @override
  String get peripheralsNotConfigured => 'Not configured';

  @override
  String get inventoryFilterBelowMin => 'Below minimum';

  @override
  String get inventoryFilterZeroStock => 'Zero stock';

  @override
  String get inventoryFilterDocType => 'Document type';

  @override
  String get inventoryFilterDirection => 'Direction';

  @override
  String get inventoryFilterInbound => 'Inbound';

  @override
  String get inventoryFilterOutbound => 'Outbound';

  @override
  String get inventoryFilterCategory => 'Category';

  @override
  String get inventoryFilterSource => 'Source';

  @override
  String get inventoryFilterSourceSale => 'Sale';

  @override
  String get inventoryFilterSourceDocument => 'Documents';

  @override
  String get inventorySortName => 'Name';

  @override
  String get inventorySortQuantity => 'Quantity';

  @override
  String get inventorySortPrice => 'Purchase price';

  @override
  String get inventorySortValue => 'Total value';

  @override
  String get inventorySortDate => 'Date';

  @override
  String get inventorySortNumber => 'Number';

  @override
  String get inventorySortType => 'Type';

  @override
  String get inventorySortAmount => 'Amount';

  @override
  String get inventorySortItem => 'Item';

  @override
  String get settingsNegativeStockPolicy => 'Negative stock policy';

  @override
  String get negativeStockPolicyAllow => 'Allow';

  @override
  String get negativeStockPolicyWarn => 'Warn';

  @override
  String get negativeStockPolicyBlock => 'Block';

  @override
  String get stockInsufficientTitle => 'Insufficient stock';

  @override
  String get stockWarningTitle => 'Stock warning';

  @override
  String get stockWarningContinue => 'Continue';

  @override
  String get negativeStockPolicyDefault => 'Default (company setting)';

  @override
  String get fieldNegativeStockPolicy => 'Negative stock override';

  @override
  String get stockColumnItem => 'Item';

  @override
  String get stockColumnRequired => 'Order';

  @override
  String get stockColumnAvailable => 'In stock';

  @override
  String get stockColumnAfter => 'After sale';

  @override
  String get dataTitle => 'Data';

  @override
  String get dataExport => 'Export';

  @override
  String get dataExportDescription =>
      'Export business data (products, customers, orders) to a file for transfer or archival.';

  @override
  String get dataImport => 'Import';

  @override
  String get dataImportDescription =>
      'Import data from a previously exported file.';

  @override
  String get dataBackup => 'Backup';

  @override
  String get dataBackupDescription =>
      'Create a full backup of the local database.';

  @override
  String get dataRestore => 'Restore';

  @override
  String get dataRestoreDescription =>
      'Restore the local database from a backup file.';

  @override
  String get catalogSortName => 'Name';

  @override
  String get catalogSortPrice => 'Price';

  @override
  String get catalogSortType => 'Type';

  @override
  String get catalogSortRate => 'Rate';

  @override
  String get catalogSortSortOrder => 'Sort order';

  @override
  String get catalogSortMinSelections => 'Min. selections';

  @override
  String get catalogSortLastName => 'Last name';

  @override
  String get catalogSortPoints => 'Points';

  @override
  String get catalogSortCredit => 'Credit';

  @override
  String get catalogSortLastVisit => 'Last visit';

  @override
  String get catalogFilterActive => 'Active';

  @override
  String get catalogFilterHasPoints => 'Has points';

  @override
  String get catalogFilterHasCredit => 'Has credit';

  @override
  String get businessTypeLabel => 'Business Type';

  @override
  String get businessCategoryGastro => 'Gastro';

  @override
  String get businessCategoryRetail => 'Retail';

  @override
  String get businessCategoryServices => 'Services';

  @override
  String get businessCategoryOther => 'Other';

  @override
  String get businessTypeRestaurant => 'Restaurant';

  @override
  String get businessTypeBar => 'Bar';

  @override
  String get businessTypeCafe => 'Cafe';

  @override
  String get businessTypeCanteen => 'Canteen';

  @override
  String get businessTypeBistro => 'Bistro';

  @override
  String get businessTypeBakery => 'Bakery';

  @override
  String get businessTypeFoodTruck => 'Food Truck';

  @override
  String get businessTypeGrocery => 'Grocery';

  @override
  String get businessTypeClothing => 'Clothing';

  @override
  String get businessTypeElectronics => 'Electronics';

  @override
  String get businessTypeGeneralStore => 'General Store';

  @override
  String get businessTypeFlorist => 'Florist';

  @override
  String get businessTypeHairdresser => 'Hairdresser';

  @override
  String get businessTypeBeautySalon => 'Beauty Salon';

  @override
  String get businessTypeFitness => 'Fitness';

  @override
  String get businessTypeAutoService => 'Auto Service';

  @override
  String get businessTypeOther => 'Other';
}

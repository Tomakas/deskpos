// Pull helpers: Supabase JSON -> Drift Companion for upsert
import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../enums/discount_type.dart';
import '../enums/enums.dart';

DateTime? _parseDateTime(dynamic v) {
  if (v == null) return null;
  return DateTime.parse(v as String);
}

DateTime _requireDateTime(dynamic v) => DateTime.parse(v as String);

T _enumFromName<T extends Enum>(List<T> values, dynamic name) {
  return values.firstWhere((e) => e.name == (name as String));
}

/// Maps Supabase snake_case JSON -> Drift companion.
/// Sets serverCreatedAt/serverUpdatedAt from Supabase created_at/updated_at.
/// Sets lastSyncedAt to now.
Insertable fromSupabasePull(String tableName, Map<String, dynamic> json) {
  final now = DateTime.now();

  switch (tableName) {
    case 'sections':
      return SectionsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        name: Value(json['name'] as String),
        color: Value(json['color'] as String?),
        isActive: Value(json['is_active'] as bool? ?? true),
        isDefault: Value(json['is_default'] as bool? ?? false),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'categories':
      return CategoriesCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        name: Value(json['name'] as String),
        isActive: Value(json['is_active'] as bool? ?? true),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'items':
      return ItemsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        categoryId: Value(json['category_id'] as String?),
        name: Value(json['name'] as String),
        description: Value(json['description'] as String?),
        itemType: Value(_enumFromName(ItemType.values, json['item_type'])),
        sku: Value(json['sku'] as String?),
        unitPrice: Value(json['unit_price'] as int),
        saleTaxRateId: Value(json['sale_tax_rate_id'] as String?),
        isSellable: Value(json['is_sellable'] as bool? ?? true),
        isActive: Value(json['is_active'] as bool? ?? true),
        unit: Value(_enumFromName(UnitType.values, json['unit'])),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'tables':
      return TablesCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        sectionId: Value(json['section_id'] as String?),
        name: Value(json['table_name'] as String),
        capacity: Value(json['capacity'] as int? ?? 0),
        isActive: Value(json['is_active'] as bool? ?? true),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'payment_methods':
      return PaymentMethodsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        name: Value(json['name'] as String),
        type: Value(_enumFromName(PaymentType.values, json['type'])),
        isActive: Value(json['is_active'] as bool? ?? true),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'tax_rates':
      return TaxRatesCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        label: Value(json['label'] as String),
        type: Value(_enumFromName(TaxCalcType.values, json['type'])),
        rate: Value(json['rate'] as int),
        isDefault: Value(json['is_default'] as bool? ?? false),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'users':
      return UsersCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        authUserId: Value(json['auth_user_id'] as String?),
        username: Value(json['username'] as String),
        fullName: Value(json['full_name'] as String),
        email: Value(json['email'] as String?),
        phone: Value(json['phone'] as String?),
        pinHash: Value(json['pin_hash'] as String),
        pinEnabled: Value(json['pin_enabled'] as bool? ?? true),
        roleId: Value(json['role_id'] as String),
        isActive: Value(json['is_active'] as bool? ?? true),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'bills':
      return BillsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        tableId: Value(json['table_id'] as String?),
        openedByUserId: Value(json['opened_by_user_id'] as String),
        billNumber: Value(json['bill_number'] as String),
        numberOfGuests: Value(json['number_of_guests'] as int? ?? 0),
        isTakeaway: Value(json['is_takeaway'] as bool? ?? false),
        status: Value(_enumFromName(BillStatus.values, json['status'])),
        currencyId: Value(json['currency_id'] as String),
        subtotalGross: Value(json['subtotal_gross'] as int? ?? 0),
        subtotalNet: Value(json['subtotal_net'] as int? ?? 0),
        discountAmount: Value(json['discount_amount'] as int? ?? 0),
        discountType: Value(json['discount_type'] != null
            ? _enumFromName(DiscountType.values, json['discount_type'])
            : null),
        taxTotal: Value(json['tax_total'] as int? ?? 0),
        totalGross: Value(json['total_gross'] as int? ?? 0),
        roundingAmount: Value(json['rounding_amount'] as int? ?? 0),
        paidAmount: Value(json['paid_amount'] as int? ?? 0),
        openedAt: Value(_requireDateTime(json['opened_at'])),
        closedAt: Value(_parseDateTime(json['closed_at'])),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'orders':
      return OrdersCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        billId: Value(json['bill_id'] as String),
        createdByUserId: Value(json['created_by_user_id'] as String),
        orderNumber: Value(json['order_number'] as String),
        notes: Value(json['notes'] as String?),
        status: Value(_enumFromName(PrepStatus.values, json['status'])),
        itemCount: Value(json['item_count'] as int? ?? 0),
        subtotalGross: Value(json['subtotal_gross'] as int? ?? 0),
        subtotalNet: Value(json['subtotal_net'] as int? ?? 0),
        taxTotal: Value(json['tax_total'] as int? ?? 0),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'order_items':
      return OrderItemsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        orderId: Value(json['order_id'] as String),
        itemId: Value(json['item_id'] as String),
        itemName: Value(json['item_name'] as String),
        quantity: Value((json['quantity'] as num).toDouble()),
        salePriceAtt: Value(json['sale_price_att'] as int),
        saleTaxRateAtt: Value(json['sale_tax_rate_att'] as int),
        saleTaxAmount: Value(json['sale_tax_amount'] as int),
        discount: Value(json['discount'] as int? ?? 0),
        discountType: Value(json['discount_type'] != null
            ? _enumFromName(DiscountType.values, json['discount_type'])
            : null),
        notes: Value(json['notes'] as String?),
        status: Value(_enumFromName(PrepStatus.values, json['status'])),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'payments':
      return PaymentsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        billId: Value(json['bill_id'] as String),
        userId: Value(json['user_id'] as String?),
        paymentMethodId: Value(json['payment_method_id'] as String),
        amount: Value(json['amount'] as int),
        paidAt: Value(_requireDateTime(json['paid_at'])),
        currencyId: Value(json['currency_id'] as String),
        tipIncludedAmount: Value(json['tip_included_amount'] as int? ?? 0),
        notes: Value(json['notes'] as String?),
        transactionId: Value(json['transaction_id'] as String?),
        paymentProvider: Value(json['payment_provider'] as String?),
        cardLast4: Value(json['card_last4'] as String?),
        authorizationCode: Value(json['authorization_code'] as String?),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'companies':
      return CompaniesCompanion(
        id: Value(json['id'] as String),
        name: Value(json['name'] as String),
        status: Value(_enumFromName(CompanyStatus.values, json['status'])),
        businessId: Value(json['business_id'] as String?),
        address: Value(json['address'] as String?),
        phone: Value(json['phone'] as String?),
        email: Value(json['email'] as String?),
        vatNumber: Value(json['vat_number'] as String?),
        country: Value(json['country'] as String?),
        city: Value(json['city'] as String?),
        postalCode: Value(json['postal_code'] as String?),
        timezone: Value(json['timezone'] as String?),
        businessType: Value(json['business_type'] as String?),
        defaultCurrencyId: Value(json['default_currency_id'] as String),
        authUserId: Value(json['auth_user_id'] as String?),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    // --- Global tables (no company_id) ---

    case 'currencies':
      return CurrenciesCompanion(
        id: Value(json['id'] as String),
        code: Value(json['code'] as String),
        symbol: Value(json['symbol'] as String),
        name: Value(json['name'] as String),
        decimalPlaces: Value(json['decimal_places'] as int),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'roles':
      return RolesCompanion(
        id: Value(json['id'] as String),
        name: Value(_enumFromName(RoleName.values, json['name'])),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'permissions':
      return PermissionsCompanion(
        id: Value(json['id'] as String),
        code: Value(json['code'] as String),
        name: Value(json['name'] as String),
        description: Value(json['description'] as String?),
        category: Value(json['category'] as String),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'role_permissions':
      return RolePermissionsCompanion(
        id: Value(json['id'] as String),
        roleId: Value(json['role_id'] as String),
        permissionId: Value(json['permission_id'] as String),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    // --- Company-scoped tables (new) ---

    case 'registers':
      return RegistersCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        code: Value(json['code'] as String),
        isActive: Value(json['is_active'] as bool? ?? true),
        type: Value(_enumFromName(HardwareType.values, json['type'])),
        allowCash: Value(json['allow_cash'] as bool? ?? true),
        allowCard: Value(json['allow_card'] as bool? ?? true),
        allowTransfer: Value(json['allow_transfer'] as bool? ?? true),
        allowRefunds: Value(json['allow_refunds'] as bool? ?? false),
        gridRows: Value(json['grid_rows'] as int? ?? 5),
        gridCols: Value(json['grid_cols'] as int? ?? 8),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'register_sessions':
      return RegisterSessionsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        registerId: Value(json['register_id'] as String),
        openedByUserId: Value(json['opened_by_user_id'] as String),
        openedAt: Value(_requireDateTime(json['opened_at'])),
        closedAt: Value(_parseDateTime(json['closed_at'])),
        orderCounter: Value(json['order_counter'] as int? ?? 0),
        openingCash: Value(json['opening_cash'] as int?),
        closingCash: Value(json['closing_cash'] as int?),
        expectedCash: Value(json['expected_cash'] as int?),
        difference: Value(json['difference'] as int?),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'cash_movements':
      return CashMovementsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        registerSessionId: Value(json['register_session_id'] as String),
        userId: Value(json['user_id'] as String),
        type: Value(_enumFromName(CashMovementType.values, json['type'])),
        amount: Value(json['amount'] as int),
        reason: Value(json['reason'] as String?),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'layout_items':
      return LayoutItemsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        registerId: Value(json['register_id'] as String),
        page: Value(json['page'] as int? ?? 0),
        gridRow: Value(json['grid_row'] as int),
        gridCol: Value(json['grid_col'] as int),
        type: Value(_enumFromName(LayoutItemType.values, json['type'])),
        itemId: Value(json['item_id'] as String?),
        categoryId: Value(json['category_id'] as String?),
        label: Value(json['label'] as String?),
        color: Value(json['color'] as String?),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'shifts':
      return ShiftsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        registerSessionId: Value(json['register_session_id'] as String),
        userId: Value(json['user_id'] as String),
        loginAt: Value(_requireDateTime(json['login_at'])),
        logoutAt: Value(_parseDateTime(json['logout_at'])),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'user_permissions':
      return UserPermissionsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        userId: Value(json['user_id'] as String),
        permissionId: Value(json['permission_id'] as String),
        grantedBy: Value(json['granted_by'] as String),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    default:
      throw ArgumentError('Unknown table for pull: $tableName');
  }
}

/// Extract the entity ID from a Supabase JSON row.
String extractId(Map<String, dynamic> json) => json['id'] as String;

/// Extract the client_updated_at timestamp from a Supabase JSON row.
DateTime? extractClientUpdatedAt(Map<String, dynamic> json) =>
    _parseDateTime(json['client_updated_at']);

/// Extract the server updated_at timestamp from a Supabase JSON row.
DateTime extractServerUpdatedAt(Map<String, dynamic> json) =>
    _requireDateTime(json['updated_at']);

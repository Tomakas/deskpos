// Pull helpers: Supabase JSON -> Drift Companion for upsert
import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../enums/enums.dart';

DateTime? _parseDateTime(dynamic v) {
  if (v == null) return null;
  return DateTime.parse(v as String);
}

DateTime _requireDateTime(dynamic v) => DateTime.parse(v as String);

T _enumFromName<T extends Enum>(List<T> values, dynamic name) {
  final str = name as String?;
  if (str == null) throw ArgumentError('Null enum name for $T');
  return values.firstWhere(
    (e) => e.name == str,
    orElse: () => throw ArgumentError('Unknown enum value "$str" for $T'),
  );
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
        parentId: Value(json['parent_id'] as String?),
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
        altSku: Value(json['alt_sku'] as String?),
        purchasePrice: Value(json['purchase_price'] as int?),
        purchaseTaxRateId: Value(json['purchase_tax_rate_id'] as String?),
        isOnSale: Value(json['is_on_sale'] as bool? ?? true),
        isStockTracked: Value(json['is_stock_tracked'] as bool? ?? false),
        manufacturerId: Value(json['manufacturer_id'] as String?),
        supplierId: Value(json['supplier_id'] as String?),
        parentId: Value(json['parent_id'] as String?),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'customers':
      return CustomersCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        firstName: Value(json['first_name'] as String),
        lastName: Value(json['last_name'] as String),
        email: Value(json['email'] as String?),
        phone: Value(json['phone'] as String?),
        address: Value(json['address'] as String?),
        points: Value(json['points'] as int? ?? 0),
        credit: Value(json['credit'] as int? ?? 0),
        totalSpent: Value(json['total_spent'] as int? ?? 0),
        lastVisitDate: Value(_parseDateTime(json['last_visit_date'])),
        birthdate: Value(_parseDateTime(json['birthdate'])),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'customer_transactions':
      return CustomerTransactionsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        customerId: Value(json['customer_id'] as String),
        pointsChange: Value(json['points_change'] as int),
        creditChange: Value(json['credit_change'] as int),
        orderId: Value(json['order_id'] as String?),
        processedByUserId: Value(json['processed_by_user_id'] as String),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'suppliers':
      return SuppliersCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        supplierName: Value(json['supplier_name'] as String),
        contactPerson: Value(json['contact_person'] as String?),
        email: Value(json['email'] as String?),
        phone: Value(json['phone'] as String?),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'manufacturers':
      return ManufacturersCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        name: Value(json['name'] as String),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'product_recipes':
      return ProductRecipesCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        parentProductId: Value(json['parent_product_id'] as String),
        componentProductId: Value(json['component_product_id'] as String),
        quantityRequired: Value((json['quantity_required'] as num).toDouble()),
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
        gridRow: Value(json['grid_row'] as int? ?? 0),
        gridCol: Value(json['grid_col'] as int? ?? 0),
        gridWidth: Value(json['grid_width'] as int? ?? 3),
        gridHeight: Value(json['grid_height'] as int? ?? 3),
        color: Value(json['color'] as String?),
        fontSize: Value(json['font_size'] as int?),
        fillStyle: Value(json['fill_style'] as int? ?? 1),
        borderStyle: Value(json['border_style'] as int? ?? 1),
        shape: Value(json['shape'] != null
            ? _enumFromName(TableShape.values, json['shape'])
            : TableShape.rectangle),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'map_elements':
      return MapElementsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        sectionId: Value(json['section_id'] as String?),
        gridRow: Value(json['grid_row'] as int? ?? 0),
        gridCol: Value(json['grid_col'] as int? ?? 0),
        gridWidth: Value(json['grid_width'] as int? ?? 2),
        gridHeight: Value(json['grid_height'] as int? ?? 2),
        label: Value(json['label'] as String?),
        color: Value(json['color'] as String?),
        fontSize: Value(json['font_size'] as int?),
        fillStyle: Value(json['fill_style'] as int? ?? 1),
        borderStyle: Value(json['border_style'] as int? ?? 1),
        shape: Value(json['shape'] != null
            ? _enumFromName(TableShape.values, json['shape'])
            : TableShape.rectangle),
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

    case 'company_currencies':
      return CompanyCurrenciesCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        currencyId: Value(json['currency_id'] as String),
        exchangeRate: Value((json['exchange_rate'] as num).toDouble()),
        isActive: Value(json['is_active'] as bool? ?? true),
        sortOrder: Value(json['sort_order'] as int? ?? 0),
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
        customerId: Value(json['customer_id'] as String?),
        customerName: Value(json['customer_name'] as String?),
        sectionId: Value(json['section_id'] as String?),
        tableId: Value(json['table_id'] as String?),
        registerId: Value(json['register_id'] as String?),
        lastRegisterId: Value(json['last_register_id'] as String?),
        registerSessionId: Value(json['register_session_id'] as String?),
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
        loyaltyPointsUsed: Value(json['loyalty_points_used'] as int? ?? 0),
        loyaltyDiscountAmount: Value(json['loyalty_discount_amount'] as int? ?? 0),
        loyaltyPointsEarned: Value(json['loyalty_points_earned'] as int? ?? 0),
        voucherDiscountAmount: Value(json['voucher_discount_amount'] as int? ?? 0),
        voucherId: Value(json['voucher_id'] as String?),
        openedAt: Value(_requireDateTime(json['opened_at'])),
        closedAt: Value(_parseDateTime(json['closed_at'])),
        mapPosX: Value(json['map_pos_x'] as int?),
        mapPosY: Value(json['map_pos_y'] as int?),
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
        registerId: Value(json['register_id'] as String?),
        createdByUserId: Value(json['created_by_user_id'] as String),
        orderNumber: Value(json['order_number'] as String),
        notes: Value(json['notes'] as String?),
        status: Value(_enumFromName(PrepStatus.values, json['status'])),
        itemCount: Value(json['item_count'] as int? ?? 0),
        subtotalGross: Value(json['subtotal_gross'] as int? ?? 0),
        subtotalNet: Value(json['subtotal_net'] as int? ?? 0),
        taxTotal: Value(json['tax_total'] as int? ?? 0),
        isStorno: Value(json['is_storno'] as bool? ?? false),
        stornoSourceOrderId: Value(json['storno_source_order_id'] as String?),
        prepStartedAt: Value(_parseDateTime(json['prep_started_at'])),
        readyAt: Value(_parseDateTime(json['ready_at'])),
        deliveredAt: Value(_parseDateTime(json['delivered_at'])),
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
        unit: Value(_enumFromName(UnitType.values, json['unit'] ?? 'ks')),
        discount: Value(json['discount'] as int? ?? 0),
        discountType: Value(json['discount_type'] != null
            ? _enumFromName(DiscountType.values, json['discount_type'])
            : null),
        voucherDiscount: Value(json['voucher_discount'] as int? ?? 0),
        notes: Value(json['notes'] as String?),
        status: Value(_enumFromName(PrepStatus.values, json['status'])),
        prepStartedAt: Value(_parseDateTime(json['prep_started_at'])),
        readyAt: Value(_parseDateTime(json['ready_at'])),
        deliveredAt: Value(_parseDateTime(json['delivered_at'])),
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
        registerId: Value(json['register_id'] as String?),
        registerSessionId: Value(json['register_session_id'] as String?),
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
        foreignCurrencyId: Value(json['foreign_currency_id'] as String?),
        foreignAmount: Value(json['foreign_amount'] as int?),
        exchangeRate: Value(json['exchange_rate'] != null
            ? (json['exchange_rate'] as num).toDouble()
            : null),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'company_settings':
      return CompanySettingsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        requirePinOnSwitch: Value(json['require_pin_on_switch'] as bool? ?? true),
        autoLockTimeoutMinutes: Value(json['auto_lock_timeout_minutes'] as int?),
        loyaltyEarnRate: Value(json['loyalty_earn_rate'] as int? ?? 0),
        loyaltyPointValue: Value(json['loyalty_point_value'] as int? ?? 0),
        locale: Value(json['locale'] as String? ?? 'cs'),
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
        authUserId: Value(json['auth_user_id'] as String),
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

    case 'display_devices':
      return DisplayDevicesCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        parentRegisterId: Value(json['parent_register_id'] as String?),
        code: Value(json['code'] as String),
        name: Value(json['name'] as String? ?? ''),
        welcomeText: Value(json['welcome_text'] as String? ?? ''),
        type: Value(_enumFromName(DisplayDeviceType.values, json['type'])),
        isActive: Value(json['is_active'] as bool? ?? true),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'registers':
      return RegistersCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        code: Value(json['code'] as String),
        name: Value(json['name'] as String? ?? ''),
        registerNumber: Value(json['register_number'] as int? ?? 1),
        parentRegisterId: Value(json['parent_register_id'] as String?),
        isMain: Value(json['is_main'] as bool? ?? false),
        boundDeviceId: Value(json['bound_device_id'] as String?),
        activeBillId: Value(json['active_bill_id'] as String?),
        isActive: Value(json['is_active'] as bool? ?? true),
        type: Value(_enumFromName(HardwareType.values, json['type'])),
        allowCash: Value(json['allow_cash'] as bool? ?? true),
        allowCard: Value(json['allow_card'] as bool? ?? true),
        allowTransfer: Value(json['allow_transfer'] as bool? ?? true),
        allowCredit: Value(json['allow_credit'] as bool? ?? true),
        allowVoucher: Value(json['allow_voucher'] as bool? ?? true),
        allowOther: Value(json['allow_other'] as bool? ?? true),
        allowRefunds: Value(json['allow_refunds'] as bool? ?? false),
        gridRows: Value(json['grid_rows'] as int? ?? 5),
        gridCols: Value(json['grid_cols'] as int? ?? 8),
        displayCartJson: Value(json['display_cart_json'] as String?),
        sellMode: Value(_enumFromName(SellMode.values, json['sell_mode'] ?? 'gastro')),
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
        billCounter: Value(json['bill_counter'] as int? ?? 0),
        parentSessionId: Value(json['parent_session_id'] as String?),
        openingCash: Value(json['opening_cash'] as int?),
        closingCash: Value(json['closing_cash'] as int?),
        expectedCash: Value(json['expected_cash'] as int?),
        difference: Value(json['difference'] as int?),
        openBillsAtOpenCount: Value(json['open_bills_at_open_count'] as int?),
        openBillsAtOpenAmount: Value(json['open_bills_at_open_amount'] as int?),
        openBillsAtCloseCount: Value(json['open_bills_at_close_count'] as int?),
        openBillsAtCloseAmount: Value(json['open_bills_at_close_amount'] as int?),
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

    case 'session_currency_cash':
      return SessionCurrencyCashCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        registerSessionId: Value(json['register_session_id'] as String),
        currencyId: Value(json['currency_id'] as String),
        openingCash: Value(json['opening_cash'] as int? ?? 0),
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

    // --- Stock ---

    case 'warehouses':
      return WarehousesCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        name: Value(json['name'] as String),
        isDefault: Value(json['is_default'] as bool? ?? false),
        isActive: Value(json['is_active'] as bool? ?? true),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'stock_levels':
      return StockLevelsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        warehouseId: Value(json['warehouse_id'] as String),
        itemId: Value(json['item_id'] as String),
        quantity: Value((json['quantity'] as num).toDouble()),
        minQuantity: Value(json['min_quantity'] != null ? (json['min_quantity'] as num).toDouble() : null),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'stock_documents':
      return StockDocumentsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        warehouseId: Value(json['warehouse_id'] as String),
        supplierId: Value(json['supplier_id'] as String?),
        userId: Value(json['user_id'] as String),
        documentNumber: Value(json['document_number'] as String),
        type: Value(_enumFromName(StockDocumentType.values, json['type'])),
        purchasePriceStrategy: Value(json['purchase_price_strategy'] != null
            ? _enumFromName(PurchasePriceStrategy.values, json['purchase_price_strategy'])
            : null),
        note: Value(json['note'] as String?),
        totalAmount: Value(json['total_amount'] as int? ?? 0),
        documentDate: Value(_requireDateTime(json['document_date'])),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'reservations':
      return ReservationsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        customerId: Value(json['customer_id'] as String?),
        customerName: Value(json['customer_name'] as String),
        customerPhone: Value(json['customer_phone'] as String?),
        reservationDate: Value(_requireDateTime(json['reservation_date'])),
        partySize: Value(json['party_size'] as int? ?? 2),
        tableId: Value(json['table_id'] as String?),
        notes: Value(json['notes'] as String?),
        status: Value(_enumFromName(ReservationStatus.values, json['status'])),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'vouchers':
      return VouchersCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        code: Value(json['code'] as String),
        type: Value(_enumFromName(VoucherType.values, json['type'])),
        status: Value(_enumFromName(VoucherStatus.values, json['status'])),
        value: Value(json['value'] as int),
        discountType: Value(json['discount_type'] != null
            ? _enumFromName(DiscountType.values, json['discount_type'])
            : null),
        discountScope: Value(json['discount_scope'] != null
            ? _enumFromName(VoucherDiscountScope.values, json['discount_scope'])
            : null),
        itemId: Value(json['item_id'] as String?),
        categoryId: Value(json['category_id'] as String?),
        minOrderValue: Value(json['min_order_value'] as int?),
        maxUses: Value(json['max_uses'] as int? ?? 1),
        usedCount: Value(json['used_count'] as int? ?? 0),
        customerId: Value(json['customer_id'] as String?),
        expiresAt: Value(_parseDateTime(json['expires_at'])),
        redeemedAt: Value(_parseDateTime(json['redeemed_at'])),
        redeemedOnBillId: Value(json['redeemed_on_bill_id'] as String?),
        sourceBillId: Value(json['source_bill_id'] as String?),
        createdByUserId: Value(json['created_by_user_id'] as String?),
        note: Value(json['note'] as String?),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'stock_movements':
      return StockMovementsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        stockDocumentId: Value(json['stock_document_id'] as String?),
        itemId: Value(json['item_id'] as String),
        quantity: Value((json['quantity'] as num).toDouble()),
        purchasePrice: Value(json['purchase_price'] as int?),
        direction: Value(_enumFromName(StockMovementDirection.values, json['direction'])),
        purchasePriceStrategy: Value(json['purchase_price_strategy'] != null
            ? _enumFromName(PurchasePriceStrategy.values, json['purchase_price_strategy'])
            : null),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'modifier_groups':
      return ModifierGroupsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        name: Value(json['name'] as String),
        minSelections: Value(json['min_selections'] as int? ?? 0),
        maxSelections: Value(json['max_selections'] as int?),
        sortOrder: Value(json['sort_order'] as int? ?? 0),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'modifier_group_items':
      return ModifierGroupItemsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        modifierGroupId: Value(json['modifier_group_id'] as String),
        itemId: Value(json['item_id'] as String),
        sortOrder: Value(json['sort_order'] as int? ?? 0),
        isDefault: Value(json['is_default'] as bool? ?? false),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'item_modifier_groups':
      return ItemModifierGroupsCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        itemId: Value(json['item_id'] as String),
        modifierGroupId: Value(json['modifier_group_id'] as String),
        sortOrder: Value(json['sort_order'] as int? ?? 0),
        createdAt: Value(_parseDateTime(json['client_created_at']) ?? now),
        updatedAt: Value(_parseDateTime(json['client_updated_at']) ?? now),
        deletedAt: Value(_parseDateTime(json['deleted_at'])),
        serverCreatedAt: Value(_parseDateTime(json['created_at'])),
        serverUpdatedAt: Value(_parseDateTime(json['updated_at'])),
        lastSyncedAt: Value(now),
      );

    case 'order_item_modifiers':
      return OrderItemModifiersCompanion(
        id: Value(json['id'] as String),
        companyId: Value(json['company_id'] as String),
        orderItemId: Value(json['order_item_id'] as String),
        modifierItemId: Value(json['modifier_item_id'] as String),
        modifierGroupId: Value(json['modifier_group_id'] as String),
        modifierItemName: Value(json['modifier_item_name'] as String? ?? ''),
        quantity: Value((json['quantity'] as num?)?.toDouble() ?? 1.0),
        unitPrice: Value(json['unit_price'] as int),
        taxRate: Value(json['tax_rate'] as int),
        taxAmount: Value(json['tax_amount'] as int),
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


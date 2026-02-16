// Push helpers: Drift model -> Supabase JSON

import '../models/bill_model.dart';
import '../models/cash_movement_model.dart';
import '../models/category_model.dart';
import '../models/customer_model.dart';
import '../models/customer_transaction_model.dart';
import '../models/company_model.dart';
import '../models/display_device_model.dart';
import '../models/company_settings_model.dart';
import '../models/currency_model.dart';
import '../models/item_model.dart';
import '../models/layout_item_model.dart';
import '../models/map_element_model.dart';
import '../models/manufacturer_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../models/payment_method_model.dart';
import '../models/payment_model.dart';
import '../models/permission_model.dart';
import '../models/product_recipe_model.dart';
import '../models/register_model.dart';
import '../models/reservation_model.dart';
import '../models/voucher_model.dart';
import '../models/register_session_model.dart';
import '../models/role_model.dart';
import '../models/role_permission_model.dart';
import '../models/section_model.dart';
import '../models/shift_model.dart';
import '../models/stock_document_model.dart';
import '../models/stock_level_model.dart';
import '../models/stock_movement_model.dart';
import '../models/supplier_model.dart';
import '../models/table_model.dart';
import '../models/tax_rate_model.dart';
import '../models/user_model.dart';
import '../models/user_permission_model.dart';
import '../models/warehouse_model.dart';

String? toIso8601Utc(DateTime? dt) => dt?.toUtc().toIso8601String();

// Convention:
//   Drift createdAt  -> client_created_at
//   Drift updatedAt  -> client_updated_at
//   Drift deletedAt  -> deleted_at
// Never send created_at / updated_at (server trigger manages these)

Map<String, dynamic> _baseGlobalSyncFields({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  DateTime? deletedAt,
}) {
  return {
    'id': id,
    'client_created_at': toIso8601Utc(createdAt),
    'client_updated_at': toIso8601Utc(updatedAt),
    'deleted_at': toIso8601Utc(deletedAt),
  };
}

Map<String, dynamic> _baseSyncFields({
  required String id,
  required String companyId,
  required DateTime createdAt,
  required DateTime updatedAt,
  DateTime? deletedAt,
}) {
  return {
    ..._baseGlobalSyncFields(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    ),
    'company_id': companyId,
  };
}

Map<String, dynamic> sectionToSupabaseJson(SectionModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'name': m.name,
      'color': m.color,
      'is_active': m.isActive,
      'is_default': m.isDefault,
    };

Map<String, dynamic> categoryToSupabaseJson(CategoryModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'name': m.name,
      'is_active': m.isActive,
      'parent_id': m.parentId,
    };

Map<String, dynamic> itemToSupabaseJson(ItemModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'category_id': m.categoryId,
      'name': m.name,
      'description': m.description,
      'item_type': m.itemType.name,
      'sku': m.sku,
      'unit_price': m.unitPrice,
      'sale_tax_rate_id': m.saleTaxRateId,
      'is_sellable': m.isSellable,
      'is_active': m.isActive,
      'unit': m.unit.name,
      'alt_sku': m.altSku,
      'purchase_price': m.purchasePrice,
      'purchase_tax_rate_id': m.purchaseTaxRateId,
      'is_on_sale': m.isOnSale,
      'is_stock_tracked': m.isStockTracked,
      'manufacturer_id': m.manufacturerId,
      'supplier_id': m.supplierId,
      'parent_id': m.parentId,
    };

Map<String, dynamic> supplierToSupabaseJson(SupplierModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'supplier_name': m.supplierName,
      'contact_person': m.contactPerson,
      'email': m.email,
      'phone': m.phone,
    };

Map<String, dynamic> manufacturerToSupabaseJson(ManufacturerModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'name': m.name,
    };

Map<String, dynamic> productRecipeToSupabaseJson(ProductRecipeModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'parent_product_id': m.parentProductId,
      'component_product_id': m.componentProductId,
      'quantity_required': m.quantityRequired,
    };

Map<String, dynamic> mapElementToSupabaseJson(MapElementModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'section_id': m.sectionId,
      'grid_row': m.gridRow,
      'grid_col': m.gridCol,
      'grid_width': m.gridWidth,
      'grid_height': m.gridHeight,
      'label': m.label,
      'color': m.color,
      'font_size': m.fontSize,
      'fill_style': m.fillStyle,
      'border_style': m.borderStyle,
      'shape': m.shape.name,
    };

Map<String, dynamic> tableToSupabaseJson(TableModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'section_id': m.sectionId,
      'table_name': m.name,
      'capacity': m.capacity,
      'is_active': m.isActive,
      'grid_row': m.gridRow,
      'grid_col': m.gridCol,
      'grid_width': m.gridWidth,
      'grid_height': m.gridHeight,
      'color': m.color,
      'font_size': m.fontSize,
      'fill_style': m.fillStyle,
      'border_style': m.borderStyle,
      'shape': m.shape.name,
    };

Map<String, dynamic> paymentMethodToSupabaseJson(PaymentMethodModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'name': m.name,
      'type': m.type.name,
      'is_active': m.isActive,
    };

Map<String, dynamic> taxRateToSupabaseJson(TaxRateModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'label': m.label,
      'type': m.type.name,
      'rate': m.rate,
      'is_default': m.isDefault,
    };

Map<String, dynamic> userToSupabaseJson(UserModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'auth_user_id': m.authUserId,
      'username': m.username,
      'full_name': m.fullName,
      'email': m.email,
      'phone': m.phone,
      'pin_hash': m.pinHash,
      'pin_enabled': m.pinEnabled,
      'role_id': m.roleId,
      'is_active': m.isActive,
    };

Map<String, dynamic> customerToSupabaseJson(CustomerModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'first_name': m.firstName,
      'last_name': m.lastName,
      'email': m.email,
      'phone': m.phone,
      'address': m.address,
      'points': m.points,
      'credit': m.credit,
      'total_spent': m.totalSpent,
      'last_visit_date': toIso8601Utc(m.lastVisitDate),
      'birthdate': toIso8601Utc(m.birthdate),
    };

Map<String, dynamic> customerTransactionToSupabaseJson(CustomerTransactionModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'customer_id': m.customerId,
      'points_change': m.pointsChange,
      'credit_change': m.creditChange,
      'order_id': m.orderId,
      'processed_by_user_id': m.processedByUserId,
    };

Map<String, dynamic> billToSupabaseJson(BillModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'customer_id': m.customerId,
      'customer_name': m.customerName,
      'section_id': m.sectionId,
      'table_id': m.tableId,
      'register_id': m.registerId,
      'last_register_id': m.lastRegisterId,
      'register_session_id': m.registerSessionId,
      'opened_by_user_id': m.openedByUserId,
      'bill_number': m.billNumber,
      'number_of_guests': m.numberOfGuests,
      'is_takeaway': m.isTakeaway,
      'status': m.status.name,
      'currency_id': m.currencyId,
      'subtotal_gross': m.subtotalGross,
      'subtotal_net': m.subtotalNet,
      'discount_amount': m.discountAmount,
      'discount_type': m.discountType?.name,
      'tax_total': m.taxTotal,
      'total_gross': m.totalGross,
      'rounding_amount': m.roundingAmount,
      'paid_amount': m.paidAmount,
      'loyalty_points_used': m.loyaltyPointsUsed,
      'loyalty_discount_amount': m.loyaltyDiscountAmount,
      'voucher_discount_amount': m.voucherDiscountAmount,
      'voucher_id': m.voucherId,
      'opened_at': toIso8601Utc(m.openedAt),
      'closed_at': toIso8601Utc(m.closedAt),
      'map_pos_x': m.mapPosX,
      'map_pos_y': m.mapPosY,
    };

Map<String, dynamic> orderToSupabaseJson(OrderModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'bill_id': m.billId,
      'register_id': m.registerId,
      'created_by_user_id': m.createdByUserId,
      'order_number': m.orderNumber,
      'notes': m.notes,
      'status': m.status.name,
      'item_count': m.itemCount,
      'subtotal_gross': m.subtotalGross,
      'subtotal_net': m.subtotalNet,
      'tax_total': m.taxTotal,
      'is_storno': m.isStorno,
      'storno_source_order_id': m.stornoSourceOrderId,
      'prep_started_at': toIso8601Utc(m.prepStartedAt),
      'ready_at': toIso8601Utc(m.readyAt),
      'delivered_at': toIso8601Utc(m.deliveredAt),
    };

Map<String, dynamic> orderItemToSupabaseJson(OrderItemModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'order_id': m.orderId,
      'item_id': m.itemId,
      'item_name': m.itemName,
      'quantity': m.quantity,
      'sale_price_att': m.salePriceAtt,
      'sale_tax_rate_att': m.saleTaxRateAtt,
      'sale_tax_amount': m.saleTaxAmount,
      'discount': m.discount,
      'discount_type': m.discountType?.name,
      'notes': m.notes,
      'status': m.status.name,
      'prep_started_at': toIso8601Utc(m.prepStartedAt),
      'ready_at': toIso8601Utc(m.readyAt),
      'delivered_at': toIso8601Utc(m.deliveredAt),
    };

Map<String, dynamic> paymentToSupabaseJson(PaymentModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'bill_id': m.billId,
      'register_id': m.registerId,
      'register_session_id': m.registerSessionId,
      'user_id': m.userId,
      'payment_method_id': m.paymentMethodId,
      'amount': m.amount,
      'paid_at': toIso8601Utc(m.paidAt),
      'currency_id': m.currencyId,
      'tip_included_amount': m.tipIncludedAmount,
      'notes': m.notes,
      'transaction_id': m.transactionId,
      'payment_provider': m.paymentProvider,
      'card_last4': m.cardLast4,
      'authorization_code': m.authorizationCode,
    };

Map<String, dynamic> companySettingsToSupabaseJson(CompanySettingsModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'require_pin_on_switch': m.requirePinOnSwitch,
      'auto_lock_timeout_minutes': m.autoLockTimeoutMinutes,
      'loyalty_earn_rate': m.loyaltyEarnRate,
      'loyalty_point_value': m.loyaltyPointValue,
      'locale': m.locale,
    };

Map<String, dynamic> companyToSupabaseJson(CompanyModel m) => {
      'id': m.id,
      'name': m.name,
      'status': m.status.name,
      'business_id': m.businessId,
      'address': m.address,
      'phone': m.phone,
      'email': m.email,
      'vat_number': m.vatNumber,
      'country': m.country,
      'city': m.city,
      'postal_code': m.postalCode,
      'timezone': m.timezone,
      'business_type': m.businessType,
      'default_currency_id': m.defaultCurrencyId,
      'auth_user_id': m.authUserId,
      'client_created_at': toIso8601Utc(m.createdAt),
      'client_updated_at': toIso8601Utc(m.updatedAt),
      'deleted_at': toIso8601Utc(m.deletedAt),
    };

// --- Global tables (no company_id) ---

Map<String, dynamic> currencyToSupabaseJson(CurrencyModel m) => {
      ..._baseGlobalSyncFields(
        id: m.id,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'code': m.code,
      'symbol': m.symbol,
      'name': m.name,
      'decimal_places': m.decimalPlaces,
    };

Map<String, dynamic> roleToSupabaseJson(RoleModel m) => {
      ..._baseGlobalSyncFields(
        id: m.id,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'name': m.name.name,
    };

Map<String, dynamic> permissionToSupabaseJson(PermissionModel m) => {
      ..._baseGlobalSyncFields(
        id: m.id,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'code': m.code,
      'name': m.name,
      'description': m.description,
      'category': m.category,
    };

Map<String, dynamic> rolePermissionToSupabaseJson(RolePermissionModel m) => {
      ..._baseGlobalSyncFields(
        id: m.id,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'role_id': m.roleId,
      'permission_id': m.permissionId,
    };

// --- Company-scoped tables (new) ---

Map<String, dynamic> displayDeviceToSupabaseJson(DisplayDeviceModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'parent_register_id': m.parentRegisterId,
      'code': m.code,
      'name': m.name,
      'welcome_text': m.welcomeText,
      'type': m.type.name,
      'is_active': m.isActive,
    };

Map<String, dynamic> registerToSupabaseJson(RegisterModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'code': m.code,
      'name': m.name,
      'register_number': m.registerNumber,
      'parent_register_id': m.parentRegisterId,
      'is_main': m.isMain,
      'bound_device_id': m.boundDeviceId,
      'active_bill_id': m.activeBillId,
      'is_active': m.isActive,
      'type': m.type.name,
      'allow_cash': m.allowCash,
      'allow_card': m.allowCard,
      'allow_transfer': m.allowTransfer,
      'allow_refunds': m.allowRefunds,
      'grid_rows': m.gridRows,
      'grid_cols': m.gridCols,
      'display_cart_json': m.displayCartJson,
    };

Map<String, dynamic> registerSessionToSupabaseJson(RegisterSessionModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'register_id': m.registerId,
      'opened_by_user_id': m.openedByUserId,
      'opened_at': toIso8601Utc(m.openedAt),
      'closed_at': toIso8601Utc(m.closedAt),
      'order_counter': m.orderCounter,
      'bill_counter': m.billCounter,
      'parent_session_id': m.parentSessionId,
      'opening_cash': m.openingCash,
      'closing_cash': m.closingCash,
      'expected_cash': m.expectedCash,
      'difference': m.difference,
      'open_bills_at_open_count': m.openBillsAtOpenCount,
      'open_bills_at_open_amount': m.openBillsAtOpenAmount,
      'open_bills_at_close_count': m.openBillsAtCloseCount,
      'open_bills_at_close_amount': m.openBillsAtCloseAmount,
    };

Map<String, dynamic> cashMovementToSupabaseJson(CashMovementModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'register_session_id': m.registerSessionId,
      'user_id': m.userId,
      'type': m.type.name,
      'amount': m.amount,
      'reason': m.reason,
    };

Map<String, dynamic> layoutItemToSupabaseJson(LayoutItemModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'register_id': m.registerId,
      'page': m.page,
      'grid_row': m.gridRow,
      'grid_col': m.gridCol,
      'type': m.type.name,
      'item_id': m.itemId,
      'category_id': m.categoryId,
      'label': m.label,
      'color': m.color,
    };

Map<String, dynamic> shiftToSupabaseJson(ShiftModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'register_session_id': m.registerSessionId,
      'user_id': m.userId,
      'login_at': toIso8601Utc(m.loginAt),
      'logout_at': toIso8601Utc(m.logoutAt),
    };

Map<String, dynamic> userPermissionToSupabaseJson(UserPermissionModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'user_id': m.userId,
      'permission_id': m.permissionId,
      'granted_by': m.grantedBy,
    };

// --- Stock ---

Map<String, dynamic> warehouseToSupabaseJson(WarehouseModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'name': m.name,
      'is_default': m.isDefault,
      'is_active': m.isActive,
    };

Map<String, dynamic> stockLevelToSupabaseJson(StockLevelModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'warehouse_id': m.warehouseId,
      'item_id': m.itemId,
      'quantity': m.quantity,
      'min_quantity': m.minQuantity,
    };

Map<String, dynamic> stockDocumentToSupabaseJson(StockDocumentModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'warehouse_id': m.warehouseId,
      'supplier_id': m.supplierId,
      'user_id': m.userId,
      'document_number': m.documentNumber,
      'type': m.type.name,
      'purchase_price_strategy': m.purchasePriceStrategy?.name,
      'note': m.note,
      'total_amount': m.totalAmount,
      'document_date': toIso8601Utc(m.documentDate),
    };

Map<String, dynamic> stockMovementToSupabaseJson(StockMovementModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'stock_document_id': m.stockDocumentId,
      'item_id': m.itemId,
      'quantity': m.quantity,
      'purchase_price': m.purchasePrice,
      'direction': m.direction.name,
      'purchase_price_strategy': m.purchasePriceStrategy?.name,
    };

Map<String, dynamic> reservationToSupabaseJson(ReservationModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'customer_id': m.customerId,
      'customer_name': m.customerName,
      'customer_phone': m.customerPhone,
      'reservation_date': toIso8601Utc(m.reservationDate),
      'party_size': m.partySize,
      'table_id': m.tableId,
      'notes': m.notes,
      'status': m.status.name,
    };

Map<String, dynamic> voucherToSupabaseJson(VoucherModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'code': m.code,
      'type': m.type.name,
      'status': m.status.name,
      'value': m.value,
      'discount_type': m.discountType?.name,
      'discount_scope': m.discountScope?.name,
      'item_id': m.itemId,
      'category_id': m.categoryId,
      'min_order_value': m.minOrderValue,
      'max_uses': m.maxUses,
      'used_count': m.usedCount,
      'customer_id': m.customerId,
      'expires_at': toIso8601Utc(m.expiresAt),
      'redeemed_at': toIso8601Utc(m.redeemedAt),
      'redeemed_on_bill_id': m.redeemedOnBillId,
      'source_bill_id': m.sourceBillId,
      'note': m.note,
    };

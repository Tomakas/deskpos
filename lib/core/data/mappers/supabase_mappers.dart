// Push helpers: Drift model -> Supabase JSON

import '../models/bill_model.dart';
import '../models/cash_movement_model.dart';
import '../models/category_model.dart';
import '../models/company_model.dart';
import '../models/currency_model.dart';
import '../models/item_model.dart';
import '../models/layout_item_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../models/payment_method_model.dart';
import '../models/payment_model.dart';
import '../models/permission_model.dart';
import '../models/register_model.dart';
import '../models/register_session_model.dart';
import '../models/role_model.dart';
import '../models/role_permission_model.dart';
import '../models/section_model.dart';
import '../models/shift_model.dart';
import '../models/table_model.dart';
import '../models/tax_rate_model.dart';
import '../models/user_model.dart';
import '../models/user_permission_model.dart';

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

Map<String, dynamic> billToSupabaseJson(BillModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'table_id': m.tableId,
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
      'opened_at': toIso8601Utc(m.openedAt),
      'closed_at': toIso8601Utc(m.closedAt),
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
      'created_by_user_id': m.createdByUserId,
      'order_number': m.orderNumber,
      'notes': m.notes,
      'status': m.status.name,
      'item_count': m.itemCount,
      'subtotal_gross': m.subtotalGross,
      'subtotal_net': m.subtotalNet,
      'tax_total': m.taxTotal,
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

Map<String, dynamic> registerToSupabaseJson(RegisterModel m) => {
      ..._baseSyncFields(
        id: m.id,
        companyId: m.companyId,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
        deletedAt: m.deletedAt,
      ),
      'code': m.code,
      'is_active': m.isActive,
      'type': m.type.name,
      'allow_cash': m.allowCash,
      'allow_card': m.allowCard,
      'allow_transfer': m.allowTransfer,
      'allow_refunds': m.allowRefunds,
      'grid_rows': m.gridRows,
      'grid_cols': m.gridCols,
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
      'opening_cash': m.openingCash,
      'closing_cash': m.closingCash,
      'expected_cash': m.expectedCash,
      'difference': m.difference,
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

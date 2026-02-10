import 'package:drift/drift.dart';

import '../../database/app_database.dart';
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

// --- Company ---
CompanyModel companyFromEntity(Company e) => CompanyModel(
      id: e.id,
      name: e.name,
      status: e.status,
      businessId: e.businessId,
      address: e.address,
      phone: e.phone,
      email: e.email,
      vatNumber: e.vatNumber,
      country: e.country,
      city: e.city,
      postalCode: e.postalCode,
      timezone: e.timezone,
      businessType: e.businessType,
      defaultCurrencyId: e.defaultCurrencyId,
      authUserId: e.authUserId,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

CompaniesCompanion companyToCompanion(CompanyModel m) => CompaniesCompanion.insert(
      id: m.id,
      name: m.name,
      status: m.status,
      businessId: Value(m.businessId),
      address: Value(m.address),
      phone: Value(m.phone),
      email: Value(m.email),
      vatNumber: Value(m.vatNumber),
      country: Value(m.country),
      city: Value(m.city),
      postalCode: Value(m.postalCode),
      timezone: Value(m.timezone),
      businessType: Value(m.businessType),
      defaultCurrencyId: m.defaultCurrencyId,
      authUserId: Value(m.authUserId),
    );

// --- Currency ---
CurrencyModel currencyFromEntity(Currency e) => CurrencyModel(
      id: e.id,
      code: e.code,
      symbol: e.symbol,
      name: e.name,
      decimalPlaces: e.decimalPlaces,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

CurrenciesCompanion currencyToCompanion(CurrencyModel m) => CurrenciesCompanion.insert(
      id: m.id,
      code: m.code,
      symbol: m.symbol,
      name: m.name,
      decimalPlaces: m.decimalPlaces,
    );

// --- User ---
UserModel userFromEntity(User e) => UserModel(
      id: e.id,
      companyId: e.companyId,
      authUserId: e.authUserId,
      username: e.username,
      fullName: e.fullName,
      email: e.email,
      phone: e.phone,
      pinHash: e.pinHash,
      pinEnabled: e.pinEnabled,
      roleId: e.roleId,
      isActive: e.isActive,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

UsersCompanion userToCompanion(UserModel m) => UsersCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      authUserId: Value(m.authUserId),
      username: m.username,
      fullName: m.fullName,
      email: Value(m.email),
      phone: Value(m.phone),
      pinHash: m.pinHash,
      pinEnabled: Value(m.pinEnabled),
      roleId: m.roleId,
      isActive: Value(m.isActive),
    );

// --- Role ---
RoleModel roleFromEntity(Role e) => RoleModel(
      id: e.id,
      name: e.name,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

RolesCompanion roleToCompanion(RoleModel m) => RolesCompanion.insert(
      id: m.id,
      name: m.name,
    );

// --- Permission ---
PermissionModel permissionFromEntity(Permission e) => PermissionModel(
      id: e.id,
      code: e.code,
      name: e.name,
      description: e.description,
      category: e.category,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

PermissionsCompanion permissionToCompanion(PermissionModel m) => PermissionsCompanion.insert(
      id: m.id,
      code: m.code,
      name: m.name,
      description: Value(m.description),
      category: m.category,
    );

// --- RolePermission ---
RolePermissionModel rolePermissionFromEntity(RolePermission e) => RolePermissionModel(
      id: e.id,
      roleId: e.roleId,
      permissionId: e.permissionId,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

RolePermissionsCompanion rolePermissionToCompanion(RolePermissionModel m) =>
    RolePermissionsCompanion.insert(
      id: m.id,
      roleId: m.roleId,
      permissionId: m.permissionId,
    );

// --- UserPermission ---
UserPermissionModel userPermissionFromEntity(UserPermission e) => UserPermissionModel(
      id: e.id,
      companyId: e.companyId,
      userId: e.userId,
      permissionId: e.permissionId,
      grantedBy: e.grantedBy,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

UserPermissionsCompanion userPermissionToCompanion(UserPermissionModel m) =>
    UserPermissionsCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      userId: m.userId,
      permissionId: m.permissionId,
      grantedBy: m.grantedBy,
    );

// --- Category ---
CategoryModel categoryFromEntity(Category e) => CategoryModel(
      id: e.id,
      companyId: e.companyId,
      name: e.name,
      isActive: e.isActive,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

CategoriesCompanion categoryToCompanion(CategoryModel m) => CategoriesCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      name: m.name,
      isActive: Value(m.isActive),
    );

// --- Item ---
ItemModel itemFromEntity(Item e) => ItemModel(
      id: e.id,
      companyId: e.companyId,
      categoryId: e.categoryId,
      name: e.name,
      description: e.description,
      itemType: e.itemType,
      sku: e.sku,
      unitPrice: e.unitPrice,
      saleTaxRateId: e.saleTaxRateId,
      isSellable: e.isSellable,
      isActive: e.isActive,
      unit: e.unit,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

ItemsCompanion itemToCompanion(ItemModel m) => ItemsCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      categoryId: Value(m.categoryId),
      name: m.name,
      description: Value(m.description),
      itemType: m.itemType,
      sku: Value(m.sku),
      unitPrice: m.unitPrice,
      saleTaxRateId: Value(m.saleTaxRateId),
      isSellable: Value(m.isSellable),
      isActive: Value(m.isActive),
      unit: Value(m.unit),
    );

// --- TaxRate ---
TaxRateModel taxRateFromEntity(TaxRate e) => TaxRateModel(
      id: e.id,
      companyId: e.companyId,
      label: e.label,
      type: e.type,
      rate: e.rate,
      isDefault: e.isDefault,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

TaxRatesCompanion taxRateToCompanion(TaxRateModel m) => TaxRatesCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      label: m.label,
      type: m.type,
      rate: m.rate,
      isDefault: Value(m.isDefault),
    );

// --- Bill ---
BillModel billFromEntity(Bill e) => BillModel(
      id: e.id,
      companyId: e.companyId,
      tableId: e.tableId,
      openedByUserId: e.openedByUserId,
      billNumber: e.billNumber,
      numberOfGuests: e.numberOfGuests,
      isTakeaway: e.isTakeaway,
      status: e.status,
      currencyId: e.currencyId,
      subtotalGross: e.subtotalGross,
      subtotalNet: e.subtotalNet,
      discountAmount: e.discountAmount,
      discountType: e.discountType,
      taxTotal: e.taxTotal,
      totalGross: e.totalGross,
      roundingAmount: e.roundingAmount,
      paidAmount: e.paidAmount,
      openedAt: e.openedAt,
      closedAt: e.closedAt,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

// --- Order ---
OrderModel orderFromEntity(Order e) => OrderModel(
      id: e.id,
      companyId: e.companyId,
      billId: e.billId,
      createdByUserId: e.createdByUserId,
      orderNumber: e.orderNumber,
      notes: e.notes,
      status: e.status,
      itemCount: e.itemCount,
      subtotalGross: e.subtotalGross,
      subtotalNet: e.subtotalNet,
      taxTotal: e.taxTotal,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

// --- OrderItem ---
OrderItemModel orderItemFromEntity(OrderItem e) => OrderItemModel(
      id: e.id,
      companyId: e.companyId,
      orderId: e.orderId,
      itemId: e.itemId,
      itemName: e.itemName,
      quantity: e.quantity,
      salePriceAtt: e.salePriceAtt,
      saleTaxRateAtt: e.saleTaxRateAtt,
      saleTaxAmount: e.saleTaxAmount,
      discount: e.discount,
      discountType: e.discountType,
      notes: e.notes,
      status: e.status,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

// --- Payment ---
PaymentModel paymentFromEntity(Payment e) => PaymentModel(
      id: e.id,
      companyId: e.companyId,
      billId: e.billId,
      userId: e.userId,
      paymentMethodId: e.paymentMethodId,
      amount: e.amount,
      paidAt: e.paidAt,
      currencyId: e.currencyId,
      tipIncludedAmount: e.tipIncludedAmount,
      notes: e.notes,
      transactionId: e.transactionId,
      paymentProvider: e.paymentProvider,
      cardLast4: e.cardLast4,
      authorizationCode: e.authorizationCode,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

// --- PaymentMethod ---
PaymentMethodModel paymentMethodFromEntity(PaymentMethod e) => PaymentMethodModel(
      id: e.id,
      companyId: e.companyId,
      name: e.name,
      type: e.type,
      isActive: e.isActive,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

PaymentMethodsCompanion paymentMethodToCompanion(PaymentMethodModel m) =>
    PaymentMethodsCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      name: m.name,
      type: m.type,
      isActive: Value(m.isActive),
    );

// --- Register ---
RegisterModel registerFromEntity(Register e) => RegisterModel(
      id: e.id,
      companyId: e.companyId,
      code: e.code,
      isActive: e.isActive,
      type: e.type,
      allowCash: e.allowCash,
      allowCard: e.allowCard,
      allowTransfer: e.allowTransfer,
      allowRefunds: e.allowRefunds,
      gridRows: e.gridRows,
      gridCols: e.gridCols,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

// --- RegisterSession ---
RegisterSessionModel registerSessionFromEntity(RegisterSession e) => RegisterSessionModel(
      id: e.id,
      companyId: e.companyId,
      registerId: e.registerId,
      openedByUserId: e.openedByUserId,
      openedAt: e.openedAt,
      closedAt: e.closedAt,
      orderCounter: e.orderCounter,
      openingCash: e.openingCash,
      closingCash: e.closingCash,
      expectedCash: e.expectedCash,
      difference: e.difference,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

// --- CashMovement ---
CashMovementModel cashMovementFromEntity(CashMovement e) => CashMovementModel(
      id: e.id,
      companyId: e.companyId,
      registerSessionId: e.registerSessionId,
      userId: e.userId,
      type: e.type,
      amount: e.amount,
      reason: e.reason,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

// --- TableEntity ---
TableModel tableFromEntity(TableEntity e) => TableModel(
      id: e.id,
      companyId: e.companyId,
      sectionId: e.sectionId,
      name: e.name,
      capacity: e.capacity,
      isActive: e.isActive,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

TablesCompanion tableToCompanion(TableModel m) => TablesCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      sectionId: Value(m.sectionId),
      name: m.name,
      capacity: Value(m.capacity),
      isActive: Value(m.isActive),
    );

// --- Section ---
SectionModel sectionFromEntity(Section e) => SectionModel(
      id: e.id,
      companyId: e.companyId,
      name: e.name,
      color: e.color,
      isActive: e.isActive,
      isDefault: e.isDefault,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

SectionsCompanion sectionToCompanion(SectionModel m) => SectionsCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      name: m.name,
      color: Value(m.color),
      isActive: Value(m.isActive),
      isDefault: Value(m.isDefault),
    );

// --- Shift ---
ShiftModel shiftFromEntity(Shift e) => ShiftModel(
      id: e.id,
      companyId: e.companyId,
      registerSessionId: e.registerSessionId,
      userId: e.userId,
      loginAt: e.loginAt,
      logoutAt: e.logoutAt,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

// --- LayoutItem ---
LayoutItemModel layoutItemFromEntity(LayoutItem e) => LayoutItemModel(
      id: e.id,
      companyId: e.companyId,
      registerId: e.registerId,
      page: e.page,
      gridRow: e.gridRow,
      gridCol: e.gridCol,
      type: e.type,
      itemId: e.itemId,
      categoryId: e.categoryId,
      label: e.label,
      color: e.color,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

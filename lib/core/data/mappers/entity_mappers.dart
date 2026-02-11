import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../models/bill_model.dart';
import '../models/cash_movement_model.dart';
import '../models/category_model.dart';
import '../models/customer_model.dart';
import '../models/customer_transaction_model.dart';
import '../models/company_model.dart';
import '../models/company_settings_model.dart';
import '../models/currency_model.dart';
import '../models/item_model.dart';
import '../models/layout_item_model.dart';
import '../models/manufacturer_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../models/payment_method_model.dart';
import '../models/payment_model.dart';
import '../models/permission_model.dart';
import '../models/product_recipe_model.dart';
import '../models/register_model.dart';
import '../models/reservation_model.dart';
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
import '../models/map_element_model.dart';
import '../models/voucher_model.dart';
import '../models/warehouse_model.dart';

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
      authUserId: m.authUserId,
    );

// --- CompanySettings ---
CompanySettingsModel companySettingsFromEntity(CompanySetting e) => CompanySettingsModel(
      id: e.id,
      companyId: e.companyId,
      requirePinOnSwitch: e.requirePinOnSwitch,
      autoLockTimeoutMinutes: e.autoLockTimeoutMinutes,
      loyaltyEarnPerHundredCzk: e.loyaltyEarnPerHundredCzk,
      loyaltyPointValueHalere: e.loyaltyPointValueHalere,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

CompanySettingsCompanion companySettingsToCompanion(CompanySettingsModel m) =>
    CompanySettingsCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      requirePinOnSwitch: Value(m.requirePinOnSwitch),
      autoLockTimeoutMinutes: Value(m.autoLockTimeoutMinutes),
      loyaltyEarnPerHundredCzk: Value(m.loyaltyEarnPerHundredCzk),
      loyaltyPointValueHalere: Value(m.loyaltyPointValueHalere),
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
      parentId: e.parentId,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

CategoriesCompanion categoryToCompanion(CategoryModel m) => CategoriesCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      name: m.name,
      isActive: Value(m.isActive),
      parentId: Value(m.parentId),
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
      altSku: e.altSku,
      purchasePrice: e.purchasePrice,
      purchaseTaxRateId: e.purchaseTaxRateId,
      isOnSale: e.isOnSale,
      isStockTracked: e.isStockTracked,
      manufacturerId: e.manufacturerId,
      supplierId: e.supplierId,
      parentId: e.parentId,
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
      altSku: Value(m.altSku),
      purchasePrice: Value(m.purchasePrice),
      purchaseTaxRateId: Value(m.purchaseTaxRateId),
      isOnSale: Value(m.isOnSale),
      isStockTracked: Value(m.isStockTracked),
      manufacturerId: Value(m.manufacturerId),
      supplierId: Value(m.supplierId),
      parentId: Value(m.parentId),
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

// --- Customer ---
CustomerModel customerFromEntity(Customer e) => CustomerModel(
      id: e.id,
      companyId: e.companyId,
      firstName: e.firstName,
      lastName: e.lastName,
      email: e.email,
      phone: e.phone,
      address: e.address,
      points: e.points,
      credit: e.credit,
      totalSpent: e.totalSpent,
      lastVisitDate: e.lastVisitDate,
      birthdate: e.birthdate,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

CustomersCompanion customerToCompanion(CustomerModel m) => CustomersCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      firstName: m.firstName,
      lastName: m.lastName,
      email: Value(m.email),
      phone: Value(m.phone),
      address: Value(m.address),
      points: Value(m.points),
      credit: Value(m.credit),
      totalSpent: Value(m.totalSpent),
      lastVisitDate: Value(m.lastVisitDate),
      birthdate: Value(m.birthdate),
    );

// --- CustomerTransaction ---
CustomerTransactionModel customerTransactionFromEntity(CustomerTransaction e) =>
    CustomerTransactionModel(
      id: e.id,
      companyId: e.companyId,
      customerId: e.customerId,
      pointsChange: e.pointsChange,
      creditChange: e.creditChange,
      orderId: e.orderId,
      processedByUserId: e.processedByUserId,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

CustomerTransactionsCompanion customerTransactionToCompanion(CustomerTransactionModel m) =>
    CustomerTransactionsCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      customerId: m.customerId,
      pointsChange: m.pointsChange,
      creditChange: m.creditChange,
      orderId: Value(m.orderId),
      processedByUserId: m.processedByUserId,
    );

// --- Bill ---
BillModel billFromEntity(Bill e) => BillModel(
      id: e.id,
      companyId: e.companyId,
      customerId: e.customerId,
      customerName: e.customerName,
      sectionId: e.sectionId,
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
      loyaltyPointsUsed: e.loyaltyPointsUsed,
      loyaltyDiscountAmount: e.loyaltyDiscountAmount,
      voucherDiscountAmount: e.voucherDiscountAmount,
      voucherId: e.voucherId,
      openedAt: e.openedAt,
      closedAt: e.closedAt,
      mapPosX: e.mapPosX,
      mapPosY: e.mapPosY,
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
      isStorno: e.isStorno,
      stornoSourceOrderId: e.stornoSourceOrderId,
      prepStartedAt: e.prepStartedAt,
      readyAt: e.readyAt,
      deliveredAt: e.deliveredAt,
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
      openBillsAtOpenCount: e.openBillsAtOpenCount,
      openBillsAtOpenAmount: e.openBillsAtOpenAmount,
      openBillsAtCloseCount: e.openBillsAtCloseCount,
      openBillsAtCloseAmount: e.openBillsAtCloseAmount,
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
      gridRow: e.gridRow,
      gridCol: e.gridCol,
      gridWidth: e.gridWidth,
      gridHeight: e.gridHeight,
      shape: e.shape,
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
      gridRow: Value(m.gridRow),
      gridCol: Value(m.gridCol),
      gridWidth: Value(m.gridWidth),
      gridHeight: Value(m.gridHeight),
      shape: Value(m.shape),
    );

// --- MapElement ---
MapElementModel mapElementFromEntity(MapElementEntity e) => MapElementModel(
      id: e.id,
      companyId: e.companyId,
      sectionId: e.sectionId,
      gridRow: e.gridRow,
      gridCol: e.gridCol,
      gridWidth: e.gridWidth,
      gridHeight: e.gridHeight,
      label: e.label,
      color: e.color,
      shape: e.shape,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

MapElementsCompanion mapElementToCompanion(MapElementModel m) => MapElementsCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      sectionId: Value(m.sectionId),
      gridRow: Value(m.gridRow),
      gridCol: Value(m.gridCol),
      gridWidth: Value(m.gridWidth),
      gridHeight: Value(m.gridHeight),
      label: Value(m.label),
      color: Value(m.color),
      shape: Value(m.shape),
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

// --- Supplier ---
SupplierModel supplierFromEntity(Supplier e) => SupplierModel(
      id: e.id,
      companyId: e.companyId,
      supplierName: e.supplierName,
      contactPerson: e.contactPerson,
      email: e.email,
      phone: e.phone,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

SuppliersCompanion supplierToCompanion(SupplierModel m) => SuppliersCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      supplierName: m.supplierName,
      contactPerson: Value(m.contactPerson),
      email: Value(m.email),
      phone: Value(m.phone),
    );

// --- Manufacturer ---
ManufacturerModel manufacturerFromEntity(Manufacturer e) => ManufacturerModel(
      id: e.id,
      companyId: e.companyId,
      name: e.name,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

ManufacturersCompanion manufacturerToCompanion(ManufacturerModel m) =>
    ManufacturersCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      name: m.name,
    );

// --- ProductRecipe ---
ProductRecipeModel productRecipeFromEntity(ProductRecipe e) => ProductRecipeModel(
      id: e.id,
      companyId: e.companyId,
      parentProductId: e.parentProductId,
      componentProductId: e.componentProductId,
      quantityRequired: e.quantityRequired,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

ProductRecipesCompanion productRecipeToCompanion(ProductRecipeModel m) =>
    ProductRecipesCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      parentProductId: m.parentProductId,
      componentProductId: m.componentProductId,
      quantityRequired: m.quantityRequired,
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

// --- Warehouse ---
WarehouseModel warehouseFromEntity(Warehouse e) => WarehouseModel(
      id: e.id,
      companyId: e.companyId,
      name: e.name,
      isDefault: e.isDefault,
      isActive: e.isActive,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

WarehousesCompanion warehouseToCompanion(WarehouseModel m) => WarehousesCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      name: m.name,
      isDefault: Value(m.isDefault),
      isActive: Value(m.isActive),
    );

// --- StockLevel ---
StockLevelModel stockLevelFromEntity(StockLevel e) => StockLevelModel(
      id: e.id,
      companyId: e.companyId,
      warehouseId: e.warehouseId,
      itemId: e.itemId,
      quantity: e.quantity,
      minQuantity: e.minQuantity,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

StockLevelsCompanion stockLevelToCompanion(StockLevelModel m) => StockLevelsCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      warehouseId: m.warehouseId,
      itemId: m.itemId,
      quantity: Value(m.quantity),
      minQuantity: Value(m.minQuantity),
    );

// --- StockDocument ---
StockDocumentModel stockDocumentFromEntity(StockDocument e) => StockDocumentModel(
      id: e.id,
      companyId: e.companyId,
      warehouseId: e.warehouseId,
      supplierId: e.supplierId,
      userId: e.userId,
      documentNumber: e.documentNumber,
      type: e.type,
      purchasePriceStrategy: e.purchasePriceStrategy,
      note: e.note,
      totalAmount: e.totalAmount,
      documentDate: e.documentDate,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

StockDocumentsCompanion stockDocumentToCompanion(StockDocumentModel m) =>
    StockDocumentsCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      warehouseId: m.warehouseId,
      supplierId: Value(m.supplierId),
      userId: m.userId,
      documentNumber: m.documentNumber,
      type: m.type,
      purchasePriceStrategy: Value(m.purchasePriceStrategy),
      note: Value(m.note),
      totalAmount: Value(m.totalAmount),
      documentDate: m.documentDate,
    );

// --- StockMovement ---
StockMovementModel stockMovementFromEntity(StockMovement e) => StockMovementModel(
      id: e.id,
      companyId: e.companyId,
      stockDocumentId: e.stockDocumentId,
      itemId: e.itemId,
      quantity: e.quantity,
      purchasePrice: e.purchasePrice,
      direction: e.direction,
      purchasePriceStrategy: e.purchasePriceStrategy,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

StockMovementsCompanion stockMovementToCompanion(StockMovementModel m) =>
    StockMovementsCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      stockDocumentId: Value(m.stockDocumentId),
      itemId: m.itemId,
      quantity: m.quantity,
      purchasePrice: Value(m.purchasePrice),
      direction: m.direction,
      purchasePriceStrategy: Value(m.purchasePriceStrategy),
    );

// --- Reservation ---
ReservationModel reservationFromEntity(Reservation e) => ReservationModel(
      id: e.id,
      companyId: e.companyId,
      customerId: e.customerId,
      customerName: e.customerName,
      customerPhone: e.customerPhone,
      reservationDate: e.reservationDate,
      partySize: e.partySize,
      tableId: e.tableId,
      notes: e.notes,
      status: e.status,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

ReservationsCompanion reservationToCompanion(ReservationModel m) =>
    ReservationsCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      customerId: Value(m.customerId),
      customerName: m.customerName,
      customerPhone: Value(m.customerPhone),
      reservationDate: m.reservationDate,
      partySize: Value(m.partySize),
      tableId: Value(m.tableId),
      notes: Value(m.notes),
      status: m.status,
    );

// --- Voucher ---
VoucherModel voucherFromEntity(Voucher e) => VoucherModel(
      id: e.id,
      companyId: e.companyId,
      code: e.code,
      type: e.type,
      status: e.status,
      value: e.value,
      discountType: e.discountType,
      discountScope: e.discountScope,
      itemId: e.itemId,
      categoryId: e.categoryId,
      minOrderValue: e.minOrderValue,
      maxUses: e.maxUses,
      usedCount: e.usedCount,
      customerId: e.customerId,
      expiresAt: e.expiresAt,
      redeemedAt: e.redeemedAt,
      redeemedOnBillId: e.redeemedOnBillId,
      sourceBillId: e.sourceBillId,
      note: e.note,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      deletedAt: e.deletedAt,
    );

VouchersCompanion voucherToCompanion(VoucherModel m) => VouchersCompanion.insert(
      id: m.id,
      companyId: m.companyId,
      code: m.code,
      type: m.type,
      status: m.status,
      value: m.value,
      discountType: Value(m.discountType),
      discountScope: Value(m.discountScope),
      itemId: Value(m.itemId),
      categoryId: Value(m.categoryId),
      minOrderValue: Value(m.minOrderValue),
      maxUses: Value(m.maxUses),
      usedCount: Value(m.usedCount),
      customerId: Value(m.customerId),
      expiresAt: Value(m.expiresAt),
      redeemedAt: Value(m.redeemedAt),
      redeemedOnBillId: Value(m.redeemedOnBillId),
      sourceBillId: Value(m.sourceBillId),
      note: Value(m.note),
    );

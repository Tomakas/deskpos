import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/bill_repository.dart';
import '../repositories/cash_movement_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/customer_repository.dart';
import '../repositories/customer_transaction_repository.dart';
import '../repositories/company_repository.dart';
import '../repositories/company_settings_repository.dart';
import '../repositories/item_repository.dart';
import '../repositories/layout_item_repository.dart';
import '../repositories/manufacturer_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/payment_method_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/permission_repository.dart';
import '../repositories/product_recipe_repository.dart';
import '../repositories/register_repository.dart';
import '../repositories/reservation_repository.dart';
import '../repositories/register_session_repository.dart';
import '../repositories/shift_repository.dart';
import '../repositories/role_repository.dart';
import '../repositories/section_repository.dart';
import '../repositories/stock_document_repository.dart';
import '../repositories/stock_level_repository.dart';
import '../repositories/stock_movement_repository.dart';
import '../repositories/supplier_repository.dart';
import '../repositories/sync_metadata_repository.dart';
import '../repositories/sync_queue_repository.dart';
import '../repositories/table_repository.dart';
import '../repositories/tax_rate_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/warehouse_repository.dart';
import 'database_provider.dart';

// --- Sync repositories ---

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return SyncQueueRepository(ref.watch(appDatabaseProvider));
});

final syncMetadataRepositoryProvider = Provider<SyncMetadataRepository>((ref) {
  return SyncMetadataRepository(ref.watch(appDatabaseProvider));
});

// --- Domain repositories ---

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final companySettingsRepositoryProvider = Provider<CompanySettingsRepository>((ref) {
  return CompanySettingsRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final roleRepositoryProvider = Provider<RoleRepository>((ref) {
  return RoleRepository(ref.watch(appDatabaseProvider));
});

final permissionRepositoryProvider = Provider<PermissionRepository>((ref) {
  return PermissionRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final sectionRepositoryProvider = Provider<SectionRepository>((ref) {
  return SectionRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final tableRepositoryProvider = Provider<TableRepository>((ref) {
  return TableRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final taxRateRepositoryProvider = Provider<TaxRateRepository>((ref) {
  return TaxRateRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>((ref) {
  return PaymentMethodRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
    orderRepo: ref.watch(orderRepositoryProvider),
  );
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
    stockLevelRepo: ref.watch(stockLevelRepositoryProvider),
    stockMovementRepo: ref.watch(stockMovementRepositoryProvider),
  );
});

final registerRepositoryProvider = Provider<RegisterRepository>((ref) {
  return RegisterRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final registerSessionRepositoryProvider = Provider<RegisterSessionRepository>((ref) {
  return RegisterSessionRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  return ShiftRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final cashMovementRepositoryProvider = Provider<CashMovementRepository>((ref) {
  return CashMovementRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(appDatabaseProvider));
});

final layoutItemRepositoryProvider = Provider<LayoutItemRepository>((ref) {
  return LayoutItemRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return ReservationRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final customerTransactionRepositoryProvider = Provider<CustomerTransactionRepository>((ref) {
  return CustomerTransactionRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final manufacturerRepositoryProvider = Provider<ManufacturerRepository>((ref) {
  return ManufacturerRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final productRecipeRepositoryProvider = Provider<ProductRecipeRepository>((ref) {
  return ProductRecipeRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

// --- Stock repositories ---

final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  return WarehouseRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final stockLevelRepositoryProvider = Provider<StockLevelRepository>((ref) {
  return StockLevelRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final stockMovementRepositoryProvider = Provider<StockMovementRepository>((ref) {
  return StockMovementRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final stockDocumentRepositoryProvider = Provider<StockDocumentRepository>((ref) {
  return StockDocumentRepository(
    ref.watch(appDatabaseProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
    stockLevelRepo: ref.watch(stockLevelRepositoryProvider),
    stockMovementRepo: ref.watch(stockMovementRepositoryProvider),
  );
});

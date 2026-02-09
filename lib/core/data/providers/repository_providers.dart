import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/bill_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/company_repository.dart';
import '../repositories/item_repository.dart';
import '../repositories/layout_item_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/payment_method_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/permission_repository.dart';
import '../repositories/register_repository.dart';
import '../repositories/register_session_repository.dart';
import '../repositories/role_repository.dart';
import '../repositories/section_repository.dart';
import '../repositories/table_repository.dart';
import '../repositories/tax_rate_repository.dart';
import '../repositories/user_repository.dart';
import 'database_provider.dart';

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyRepository(ref.watch(appDatabaseProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(appDatabaseProvider));
});

final roleRepositoryProvider = Provider<RoleRepository>((ref) {
  return RoleRepository(ref.watch(appDatabaseProvider));
});

final permissionRepositoryProvider = Provider<PermissionRepository>((ref) {
  return PermissionRepository(ref.watch(appDatabaseProvider));
});

final sectionRepositoryProvider = Provider<SectionRepository>((ref) {
  return SectionRepository(ref.watch(appDatabaseProvider));
});

final tableRepositoryProvider = Provider<TableRepository>((ref) {
  return TableRepository(ref.watch(appDatabaseProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(appDatabaseProvider));
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository(ref.watch(appDatabaseProvider));
});

final taxRateRepositoryProvider = Provider<TaxRateRepository>((ref) {
  return TaxRateRepository(ref.watch(appDatabaseProvider));
});

final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>((ref) {
  return PaymentMethodRepository(ref.watch(appDatabaseProvider));
});

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository(ref.watch(appDatabaseProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(appDatabaseProvider));
});

final registerRepositoryProvider = Provider<RegisterRepository>((ref) {
  return RegisterRepository(ref.watch(appDatabaseProvider));
});

final registerSessionRepositoryProvider = Provider<RegisterSessionRepository>((ref) {
  return RegisterSessionRepository(ref.watch(appDatabaseProvider));
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(appDatabaseProvider));
});

final layoutItemRepositoryProvider = Provider<LayoutItemRepository>((ref) {
  return LayoutItemRepository(ref.watch(appDatabaseProvider));
});

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/enums/enums.dart';
import 'tables/bills.dart';
import 'tables/cash_movements.dart';
import 'tables/categories.dart';
import 'tables/customer_transactions.dart';
import 'tables/customers.dart';
import 'tables/companies.dart';
import 'tables/company_settings.dart';
import 'tables/currencies.dart';
import 'tables/device_registrations.dart';
import 'tables/display_devices.dart';
import 'tables/items.dart';
import 'tables/layout_items.dart';
import 'tables/map_elements.dart';
import 'tables/manufacturers.dart';
import 'tables/order_items.dart';
import 'tables/orders.dart';
import 'tables/payment_methods.dart';
import 'tables/payments.dart';
import 'tables/permissions.dart';
import 'tables/product_recipes.dart';
import 'tables/register_sessions.dart';
import 'tables/registers.dart';
import 'tables/role_permissions.dart';
import 'tables/roles.dart';
import 'tables/sections.dart';
import 'tables/shifts.dart';
import 'tables/stock_documents.dart';
import 'tables/stock_levels.dart';
import 'tables/stock_movements.dart';
import 'tables/suppliers.dart';
import 'tables/sync_metadata.dart';
import 'tables/reservations.dart';
import 'tables/vouchers.dart';
import 'tables/warehouses.dart';
import 'tables/sync_queue.dart';
import 'tables/table_entities.dart';
import 'tables/tax_rates.dart';
import 'tables/user_permissions.dart';
import 'tables/users.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Bills,
  CashMovements,
  Categories,
  Companies,
  CustomerTransactions,
  Customers,
  CompanySettings,
  Currencies,
  DeviceRegistrations,
  DisplayDevices,
  Items,
  LayoutItems,
  MapElements,
  Manufacturers,
  OrderItems,
  Orders,
  PaymentMethods,
  Payments,
  Permissions,
  ProductRecipes,
  RegisterSessions,
  Registers,
  Reservations,
  RolePermissions,
  Roles,
  Sections,
  Shifts,
  StockDocuments,
  StockLevels,
  StockMovements,
  Suppliers,
  SyncMetadata,
  SyncQueue,
  Tables,
  TaxRates,
  UserPermissions,
  Users,
  Vouchers,
  Warehouses,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'epos_database.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}

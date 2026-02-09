import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../data/enums/enums.dart';
import 'tables/bills.dart';
import 'tables/categories.dart';
import 'tables/companies.dart';
import 'tables/currencies.dart';
import 'tables/items.dart';
import 'tables/layout_items.dart';
import 'tables/order_items.dart';
import 'tables/orders.dart';
import 'tables/payment_methods.dart';
import 'tables/payments.dart';
import 'tables/permissions.dart';
import 'tables/register_sessions.dart';
import 'tables/registers.dart';
import 'tables/role_permissions.dart';
import 'tables/roles.dart';
import 'tables/sections.dart';
import 'tables/table_entities.dart';
import 'tables/tax_rates.dart';
import 'tables/user_permissions.dart';
import 'tables/users.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Bills,
  Categories,
  Companies,
  Currencies,
  Items,
  LayoutItems,
  OrderItems,
  Orders,
  PaymentMethods,
  Payments,
  Permissions,
  RegisterSessions,
  Registers,
  RolePermissions,
  Roles,
  Sections,
  Tables,
  TaxRates,
  UserPermissions,
  Users,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final file = File('epos_database.sqlite');
      return NativeDatabase.createInBackground(file);
    });
  }
}

import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_customers_company_updated', columns: {#companyId, #updatedAt})
class Customers extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  IntColumn get points => integer().withDefault(const Constant(0))();
  IntColumn get credit => integer().withDefault(const Constant(0))();
  IntColumn get totalSpent => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastVisitDate => dateTime().nullable()();
  DateTimeColumn get birthdate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

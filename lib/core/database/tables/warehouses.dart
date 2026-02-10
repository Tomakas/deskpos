import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_warehouses_company_updated', columns: {#companyId, #updatedAt})
class Warehouses extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get name => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

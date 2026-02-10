import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_categories_company_updated', columns: {#companyId, #updatedAt})
class Categories extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get parentId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

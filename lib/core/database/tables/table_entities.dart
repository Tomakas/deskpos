import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@DataClassName('TableEntity')
@TableIndex(name: 'idx_tables_company_updated', columns: {#companyId, #updatedAt})
class Tables extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get sectionId => text().nullable()();
  TextColumn get name => text().named('table_name')();
  IntColumn get capacity => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

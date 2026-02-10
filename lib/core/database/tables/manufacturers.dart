import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_manufacturers_company_updated', columns: {#companyId, #updatedAt})
class Manufacturers extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

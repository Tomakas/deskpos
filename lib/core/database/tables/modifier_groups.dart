import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_modifier_groups_company_updated', columns: {#companyId, #updatedAt})
class ModifierGroups extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get name => text()();
  IntColumn get minSelections => integer().withDefault(const Constant(0))();
  IntColumn get maxSelections => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

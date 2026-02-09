import 'package:drift/drift.dart';

import '../../data/enums/layout_item_type.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_layout_items_company_updated', columns: {#companyId, #updatedAt})
class LayoutItems extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get registerId => text()();
  IntColumn get page => integer().withDefault(const Constant(0))();
  IntColumn get row => integer()();
  IntColumn get col => integer()();
  TextColumn get type => textEnum<LayoutItemType>()();
  TextColumn get itemId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get label => text().nullable()();
  TextColumn get color => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

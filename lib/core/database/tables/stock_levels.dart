import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_stock_levels_company_updated', columns: {#companyId, #updatedAt})
@TableIndex(name: 'idx_stock_levels_warehouse_item', columns: {#warehouseId, #itemId})
class StockLevels extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get warehouseId => text()();
  TextColumn get itemId => text()();
  RealColumn get quantity => real().withDefault(const Constant(0.0))();
  RealColumn get minQuantity => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

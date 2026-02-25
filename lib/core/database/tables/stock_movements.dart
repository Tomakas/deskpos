import 'package:drift/drift.dart';

import '../../data/enums/purchase_price_strategy.dart';
import '../../data/enums/stock_movement_direction.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_stock_movements_company_updated', columns: {#companyId, #updatedAt})
@TableIndex(name: 'idx_stock_movements_document', columns: {#stockDocumentId})
@TableIndex(name: 'idx_stock_movements_item', columns: {#itemId})
@TableIndex(name: 'idx_stock_movements_bill', columns: {#billId})
class StockMovements extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get stockDocumentId => text().nullable()();
  TextColumn get billId => text().nullable()();
  TextColumn get itemId => text()();
  RealColumn get quantity => real()();
  IntColumn get purchasePrice => integer().nullable()();
  TextColumn get direction => textEnum<StockMovementDirection>()();
  TextColumn get purchasePriceStrategy => textEnum<PurchasePriceStrategy>().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

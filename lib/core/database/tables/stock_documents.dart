import 'package:drift/drift.dart';

import '../../data/enums/purchase_price_strategy.dart';
import '../../data/enums/stock_document_type.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_stock_documents_company_updated', columns: {#companyId, #updatedAt})
@TableIndex(name: 'idx_stock_documents_warehouse', columns: {#warehouseId})
class StockDocuments extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get warehouseId => text()();
  TextColumn get supplierId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get documentNumber => text()();
  TextColumn get type => textEnum<StockDocumentType>()();
  TextColumn get purchasePriceStrategy => textEnum<PurchasePriceStrategy>().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get totalAmount => integer().withDefault(const Constant(0))();
  DateTimeColumn get documentDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

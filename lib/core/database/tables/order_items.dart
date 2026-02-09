import 'package:drift/drift.dart';

import '../../data/enums/prep_status.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_order_items_company_updated', columns: {#companyId, #updatedAt})
class OrderItems extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get orderId => text()();
  TextColumn get itemId => text()();
  TextColumn get itemName => text()();
  RealColumn get quantity => real()();
  IntColumn get salePriceAtt => integer()();
  IntColumn get saleTaxRateAtt => integer()();
  IntColumn get saleTaxAmount => integer()();
  IntColumn get discount => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  TextColumn get status => textEnum<PrepStatus>()();

  @override
  Set<Column> get primaryKey => {id};
}

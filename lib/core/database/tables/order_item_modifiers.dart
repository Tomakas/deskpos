import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_order_item_modifiers_company_updated', columns: {#companyId, #updatedAt})
class OrderItemModifiers extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get orderItemId => text()();
  TextColumn get modifierItemId => text()();
  TextColumn get modifierGroupId => text()();
  TextColumn get modifierItemName => text().withDefault(const Constant(''))();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  IntColumn get unitPrice => integer()();
  IntColumn get taxRate => integer()();
  IntColumn get taxAmount => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

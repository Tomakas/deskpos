import 'package:drift/drift.dart';

import '../../data/enums/item_type.dart';
import '../../data/enums/unit_type.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_items_company_updated', columns: {#companyId, #updatedAt})
class Items extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get itemType => textEnum<ItemType>()();
  TextColumn get sku => text().nullable()();
  IntColumn get unitPrice => integer()();
  TextColumn get saleTaxRateId => text().nullable()();
  BoolColumn get isSellable => boolean().withDefault(const Constant(true))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get unit => textEnum<UnitType>().withDefault(Constant(UnitType.ks.name))();

  @override
  Set<Column> get primaryKey => {id};
}

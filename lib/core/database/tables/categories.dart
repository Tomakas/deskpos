import 'package:drift/drift.dart';

import '../../data/enums/prep_area.dart';
import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_categories_company_updated', columns: {#companyId, #updatedAt})
class Categories extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get parentId => text().nullable()();
  TextColumn get prepArea => textEnum<PrepArea>().nullable()();
  TextColumn get defaultSaleTaxRateId => text().nullable()();
  TextColumn get defaultPurchaseTaxRateId => text().nullable()();
  BoolColumn get defaultIsSellable => boolean().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get itemColor => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

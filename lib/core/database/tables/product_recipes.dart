import 'package:drift/drift.dart';

import 'sync_columns_mixin.dart';

@TableIndex(name: 'idx_product_recipes_company_updated', columns: {#companyId, #updatedAt})
class ProductRecipes extends Table with SyncColumnsMixin {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get parentProductId => text()();
  TextColumn get componentProductId => text()();
  RealColumn get quantityRequired => real()();

  @override
  Set<Column> get primaryKey => {id};
}

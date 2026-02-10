import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/item_model.dart';
import 'base_company_scoped_repository.dart';

class ItemRepository
    extends BaseCompanyScopedRepository<$ItemsTable, Item, ItemModel> {
  ItemRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$ItemsTable, Item> get table => db.items;

  @override
  String get entityName => 'item';

  @override
  String get supabaseTableName => 'items';

  @override
  ItemModel fromEntity(Item e) => itemFromEntity(e);

  @override
  Insertable<Item> toCompanion(ItemModel m) => itemToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(ItemModel m) => itemToSupabaseJson(m);

  @override
  Expression<bool> whereId($ItemsTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($ItemsTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($ItemsTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.name)];

  @override
  Insertable<Item> toUpdateCompanion(ItemModel m) => ItemsCompanion(
        categoryId: Value(m.categoryId),
        name: Value(m.name),
        description: Value(m.description),
        itemType: Value(m.itemType),
        sku: Value(m.sku),
        unitPrice: Value(m.unitPrice),
        saleTaxRateId: Value(m.saleTaxRateId),
        isSellable: Value(m.isSellable),
        isActive: Value(m.isActive),
        unit: Value(m.unit),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<Item> toDeleteCompanion(DateTime now) => ItemsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );
}

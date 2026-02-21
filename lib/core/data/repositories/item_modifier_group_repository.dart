import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/item_modifier_group_model.dart';
import 'base_company_scoped_repository.dart';

class ItemModifierGroupRepository
    extends BaseCompanyScopedRepository<$ItemModifierGroupsTable, ItemModifierGroup, ItemModifierGroupModel> {
  ItemModifierGroupRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$ItemModifierGroupsTable, ItemModifierGroup> get table => db.itemModifierGroups;

  @override
  String get entityName => 'item_modifier_group';

  @override
  String get supabaseTableName => 'item_modifier_groups';

  @override
  ItemModifierGroupModel fromEntity(ItemModifierGroup e) => itemModifierGroupFromEntity(e);

  @override
  Insertable<ItemModifierGroup> toCompanion(ItemModifierGroupModel m) => itemModifierGroupToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(ItemModifierGroupModel m) => itemModifierGroupToSupabaseJson(m);

  @override
  Expression<bool> whereId($ItemModifierGroupsTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($ItemModifierGroupsTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  Expression<bool> whereNotDeleted($ItemModifierGroupsTable t) => t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($ItemModifierGroupsTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.sortOrder)];

  @override
  Insertable<ItemModifierGroup> toUpdateCompanion(ItemModifierGroupModel m) =>
      ItemModifierGroupsCompanion(
        itemId: Value(m.itemId),
        modifierGroupId: Value(m.modifierGroupId),
        sortOrder: Value(m.sortOrder),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<ItemModifierGroup> toDeleteCompanion(DateTime now) => ItemModifierGroupsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );

  Stream<List<ItemModifierGroupModel>> watchByItem(String itemId) {
    return (db.select(db.itemModifierGroups)
          ..where((t) => t.itemId.equals(itemId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((rows) => rows.map(fromEntity).toList());
  }

  Future<List<ItemModifierGroupModel>> getByItem(String itemId) async {
    final rows = await (db.select(db.itemModifierGroups)
          ..where((t) => t.itemId.equals(itemId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return rows.map(fromEntity).toList();
  }
}

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/modifier_group_item_model.dart';
import 'base_company_scoped_repository.dart';

class ModifierGroupItemRepository
    extends BaseCompanyScopedRepository<$ModifierGroupItemsTable, ModifierGroupItem, ModifierGroupItemModel> {
  ModifierGroupItemRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$ModifierGroupItemsTable, ModifierGroupItem> get table => db.modifierGroupItems;

  @override
  String get entityName => 'modifier_group_item';

  @override
  String get supabaseTableName => 'modifier_group_items';

  @override
  ModifierGroupItemModel fromEntity(ModifierGroupItem e) => modifierGroupItemFromEntity(e);

  @override
  Insertable<ModifierGroupItem> toCompanion(ModifierGroupItemModel m) => modifierGroupItemToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(ModifierGroupItemModel m) => modifierGroupItemToSupabaseJson(m);

  @override
  Expression<bool> whereId($ModifierGroupItemsTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($ModifierGroupItemsTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  Expression<bool> whereNotDeleted($ModifierGroupItemsTable t) => t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($ModifierGroupItemsTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.sortOrder)];

  @override
  Insertable<ModifierGroupItem> toUpdateCompanion(ModifierGroupItemModel m) =>
      ModifierGroupItemsCompanion(
        modifierGroupId: Value(m.modifierGroupId),
        itemId: Value(m.itemId),
        sortOrder: Value(m.sortOrder),
        isDefault: Value(m.isDefault),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<ModifierGroupItem> toDeleteCompanion(DateTime now) => ModifierGroupItemsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );

  Stream<List<ModifierGroupItemModel>> watchByGroup(String groupId) {
    return (db.select(db.modifierGroupItems)
          ..where((t) => t.modifierGroupId.equals(groupId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((rows) => rows.map(fromEntity).toList());
  }

  Future<List<ModifierGroupItemModel>> getByGroup(String groupId) async {
    final rows = await (db.select(db.modifierGroupItems)
          ..where((t) => t.modifierGroupId.equals(groupId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return rows.map(fromEntity).toList();
  }
}

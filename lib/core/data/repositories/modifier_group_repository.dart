import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/modifier_group_model.dart';
import 'base_company_scoped_repository.dart';

class ModifierGroupRepository
    extends BaseCompanyScopedRepository<$ModifierGroupsTable, ModifierGroup, ModifierGroupModel> {
  ModifierGroupRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$ModifierGroupsTable, ModifierGroup> get table => db.modifierGroups;

  @override
  String get entityName => 'modifier_group';

  @override
  String get supabaseTableName => 'modifier_groups';

  @override
  ModifierGroupModel fromEntity(ModifierGroup e) => modifierGroupFromEntity(e);

  @override
  Insertable<ModifierGroup> toCompanion(ModifierGroupModel m) => modifierGroupToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(ModifierGroupModel m) => modifierGroupToSupabaseJson(m);

  @override
  Expression<bool> whereId($ModifierGroupsTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($ModifierGroupsTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  Expression<bool> whereNotDeleted($ModifierGroupsTable t) => t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($ModifierGroupsTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)];

  @override
  Insertable<ModifierGroup> toUpdateCompanion(ModifierGroupModel m) => ModifierGroupsCompanion(
        name: Value(m.name),
        minSelections: Value(m.minSelections),
        maxSelections: Value(m.maxSelections),
        sortOrder: Value(m.sortOrder),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<ModifierGroup> toDeleteCompanion(DateTime now) => ModifierGroupsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );
}

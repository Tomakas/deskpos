import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/table_model.dart';
import 'base_company_scoped_repository.dart';

class TableRepository
    extends BaseCompanyScopedRepository<$TablesTable, TableEntity, TableModel> {
  TableRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$TablesTable, TableEntity> get table => db.tables;

  @override
  String get entityName => 'table';

  @override
  String get supabaseTableName => 'tables';

  @override
  TableModel fromEntity(TableEntity e) => tableFromEntity(e);

  @override
  Insertable<TableEntity> toCompanion(TableModel m) => tableToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(TableModel m) => tableToSupabaseJson(m);

  @override
  Expression<bool> whereId($TablesTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($TablesTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($TablesTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.name)];

  @override
  Insertable<TableEntity> toUpdateCompanion(TableModel m) => TablesCompanion(
        sectionId: Value(m.sectionId),
        name: Value(m.name),
        capacity: Value(m.capacity),
        isActive: Value(m.isActive),
        gridRow: Value(m.gridRow),
        gridCol: Value(m.gridCol),
        gridWidth: Value(m.gridWidth),
        gridHeight: Value(m.gridHeight),
        shape: Value(m.shape),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<TableEntity> toDeleteCompanion(DateTime now) => TablesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );
}

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/map_element_model.dart';
import 'base_company_scoped_repository.dart';

class MapElementRepository
    extends BaseCompanyScopedRepository<$MapElementsTable, MapElementEntity, MapElementModel> {
  MapElementRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$MapElementsTable, MapElementEntity> get table => db.mapElements;

  @override
  String get entityName => 'map_element';

  @override
  String get supabaseTableName => 'map_elements';

  @override
  MapElementModel fromEntity(MapElementEntity e) => mapElementFromEntity(e);

  @override
  Insertable<MapElementEntity> toCompanion(MapElementModel m) => mapElementToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(MapElementModel m) => mapElementToSupabaseJson(m);

  @override
  Expression<bool> whereId($MapElementsTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($MapElementsTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($MapElementsTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.gridRow)];

  @override
  Insertable<MapElementEntity> toUpdateCompanion(MapElementModel m) => MapElementsCompanion(
        sectionId: Value(m.sectionId),
        gridRow: Value(m.gridRow),
        gridCol: Value(m.gridCol),
        gridWidth: Value(m.gridWidth),
        gridHeight: Value(m.gridHeight),
        label: Value(m.label),
        color: Value(m.color),
        fontSize: Value(m.fontSize),
        fillStyle: Value(m.fillStyle),
        borderStyle: Value(m.borderStyle),
        shape: Value(m.shape),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<MapElementEntity> toDeleteCompanion(DateTime now) => MapElementsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );
}

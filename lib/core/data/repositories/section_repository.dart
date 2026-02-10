import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/section_model.dart';
import 'base_company_scoped_repository.dart';

class SectionRepository
    extends BaseCompanyScopedRepository<$SectionsTable, Section, SectionModel> {
  SectionRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$SectionsTable, Section> get table => db.sections;

  @override
  String get entityName => 'section';

  @override
  String get supabaseTableName => 'sections';

  @override
  SectionModel fromEntity(Section e) => sectionFromEntity(e);

  @override
  Insertable<Section> toCompanion(SectionModel m) => sectionToCompanion(m);

  @override
  Map<String, dynamic> toSupabaseJson(SectionModel m) => sectionToSupabaseJson(m);

  @override
  Expression<bool> whereId($SectionsTable t, String id) => t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($SectionsTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($SectionsTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.name)];

  @override
  Insertable<Section> toUpdateCompanion(SectionModel m) => SectionsCompanion(
        name: Value(m.name),
        color: Value(m.color),
        isActive: Value(m.isActive),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<Section> toDeleteCompanion(DateTime now) => SectionsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );
}

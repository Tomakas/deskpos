import 'dart:convert';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/section_model.dart';
import '../result.dart';
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
  Expression<bool> whereNotDeleted($SectionsTable t) => t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($SectionsTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)];

  @override
  Insertable<Section> toUpdateCompanion(SectionModel m) => SectionsCompanion(
        name: Value(m.name),
        color: Value(m.color),
        isActive: Value(m.isActive),
        isDefault: Value(m.isDefault),
        sortOrder: Value(m.sortOrder),
        updatedAt: Value(DateTime.now()),
      );

  @override
  Insertable<Section> toDeleteCompanion(DateTime now) => SectionsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      );

  Future<Result<void>> clearDefault(String companyId, {String? exceptId}) async {
    try {
      // 1. Find affected records before update
      final selectQuery = db.select(db.sections)
        ..where((t) =>
            t.companyId.equals(companyId) &
            t.isDefault.equals(true) &
            t.deletedAt.isNull());
      if (exceptId != null) {
        selectQuery.where((t) => t.id.equals(exceptId).not());
      }
      final affected = await selectQuery.get();
      if (affected.isEmpty) return const Success(null);

      // 2. Bulk update + 3. Enqueue in a single transaction
      await db.transaction(() async {
        final updateQuery = db.update(db.sections)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.isDefault.equals(true) &
              t.deletedAt.isNull());
        if (exceptId != null) {
          updateQuery.where((t) => t.id.equals(exceptId).not());
        }
        await updateQuery.write(SectionsCompanion(
          isDefault: const Value(false),
          updatedAt: Value(DateTime.now()),
        ));

        if (syncQueueRepo != null) {
          for (final entity in affected) {
            final updated = await (db.select(db.sections)
                  ..where((t) => t.id.equals(entity.id)))
                .getSingle();
            final model = sectionFromEntity(updated);
            await syncQueueRepo!.enqueue(
              companyId: model.companyId,
              entityType: supabaseTableName,
              entityId: model.id,
              operation: 'update',
              payload: jsonEncode(sectionToSupabaseJson(model)),
            );
          }
        }
      });
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to clear default section', error: e, stackTrace: s);
      return Failure('Failed to clear default section: $e');
    }
  }
}

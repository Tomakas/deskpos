import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../models/section_model.dart';
import '../result.dart';

class SectionRepository {
  SectionRepository(this._db);
  final AppDatabase _db;

  Future<Result<SectionModel>> create(SectionModel model) async {
    try {
      await _db.into(_db.sections).insert(sectionToCompanion(model));
      final entity = await (_db.select(_db.sections)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(sectionFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to create section', error: e, stackTrace: s);
      return Failure('Failed to create section: $e');
    }
  }

  Future<Result<SectionModel>> update(SectionModel model) async {
    try {
      await (_db.update(_db.sections)..where((t) => t.id.equals(model.id))).write(
        SectionsCompanion(
          name: Value(model.name),
          color: Value(model.color),
          isActive: Value(model.isActive),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final entity = await (_db.select(_db.sections)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(sectionFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to update section', error: e, stackTrace: s);
      return Failure('Failed to update section: $e');
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      await (_db.update(_db.sections)..where((t) => t.id.equals(id))).write(
        SectionsCompanion(deletedAt: Value(DateTime.now()), updatedAt: Value(DateTime.now())),
      );
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to delete section', error: e, stackTrace: s);
      return Failure('Failed to delete section: $e');
    }
  }

  Stream<List<SectionModel>> watchAll(String companyId) {
    return (_db.select(_db.sections)
          ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(sectionFromEntity).toList());
  }
}

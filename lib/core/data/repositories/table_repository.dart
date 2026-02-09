import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../models/table_model.dart';
import '../result.dart';

class TableRepository {
  TableRepository(this._db);
  final AppDatabase _db;

  Future<Result<TableModel>> create(TableModel model) async {
    try {
      await _db.into(_db.tables).insert(tableToCompanion(model));
      final entity = await (_db.select(_db.tables)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(tableFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to create table', error: e, stackTrace: s);
      return Failure('Failed to create table: $e');
    }
  }

  Future<Result<TableModel>> update(TableModel model) async {
    try {
      await (_db.update(_db.tables)..where((t) => t.id.equals(model.id))).write(
        TablesCompanion(
          sectionId: Value(model.sectionId),
          name: Value(model.name),
          capacity: Value(model.capacity),
          isActive: Value(model.isActive),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final entity = await (_db.select(_db.tables)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      return Success(tableFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to update table', error: e, stackTrace: s);
      return Failure('Failed to update table: $e');
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      await (_db.update(_db.tables)..where((t) => t.id.equals(id))).write(
        TablesCompanion(deletedAt: Value(DateTime.now()), updatedAt: Value(DateTime.now())),
      );
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to delete table', error: e, stackTrace: s);
      return Failure('Failed to delete table: $e');
    }
  }

  Stream<List<TableModel>> watchAll(String companyId) {
    return (_db.select(_db.tables)
          ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(tableFromEntity).toList());
  }
}

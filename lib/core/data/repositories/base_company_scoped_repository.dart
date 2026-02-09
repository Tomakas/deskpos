import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../models/company_scoped_model.dart';
import '../result.dart';

abstract class BaseCompanyScopedRepository<TTable extends Table,
    TEntity, TModel extends CompanyScopedModel> {
  BaseCompanyScopedRepository(this.db);
  final AppDatabase db;

  // --- Abstract members subclass must implement ---

  TableInfo<TTable, TEntity> get table;
  TModel fromEntity(TEntity e);
  Insertable<TEntity> toCompanion(TModel m);
  Insertable<TEntity> toUpdateCompanion(TModel m);
  Insertable<TEntity> toDeleteCompanion(DateTime now);
  Expression<bool> whereId(TTable t, String id);
  Expression<bool> whereCompanyScope(TTable t, String companyId);
  List<OrderingTerm Function(TTable)> get defaultOrderBy;
  String get entityName;

  // --- Concrete CRUD methods ---

  Future<Result<TModel>> create(TModel model) async {
    try {
      await db.into(table).insert(toCompanion(model));
      final entity = await (db.select(table)
            ..where((t) => whereId(t, model.id)))
          .getSingle();
      return Success(fromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to create $entityName', error: e, stackTrace: s);
      return Failure('Failed to create $entityName: $e');
    }
  }

  Future<Result<TModel>> update(TModel model) async {
    try {
      await (db.update(table)..where((t) => whereId(t, model.id)))
          .write(toUpdateCompanion(model));
      final entity = await (db.select(table)
            ..where((t) => whereId(t, model.id)))
          .getSingle();
      return Success(fromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to update $entityName', error: e, stackTrace: s);
      return Failure('Failed to update $entityName: $e');
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      await (db.update(table)..where((t) => whereId(t, id)))
          .write(toDeleteCompanion(DateTime.now()));
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to delete $entityName', error: e, stackTrace: s);
      return Failure('Failed to delete $entityName: $e');
    }
  }

  Stream<List<TModel>> watchAll(String companyId) {
    return (db.select(table)
          ..where((t) => whereCompanyScope(t, companyId))
          ..orderBy(defaultOrderBy))
        .watch()
        .map((rows) => rows.map(fromEntity).toList());
  }

  Future<TModel?> getById(String id) async {
    final entity = await (db.select(table)
          ..where((t) => whereId(t, id)))
        .getSingleOrNull();
    return entity == null ? null : fromEntity(entity);
  }
}

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../models/company_scoped_model.dart';
import '../result.dart';
import 'sync_queue_repository.dart';

abstract class BaseCompanyScopedRepository<TTable extends Table,
    TEntity, TModel extends CompanyScopedModel> {
  BaseCompanyScopedRepository(this.db, {this.syncQueueRepo});
  final AppDatabase db;
  final SyncQueueRepository? syncQueueRepo;

  // --- Abstract members subclass must implement ---

  TableInfo<TTable, TEntity> get table;
  TModel fromEntity(TEntity e);
  Insertable<TEntity> toCompanion(TModel m);
  Insertable<TEntity> toUpdateCompanion(TModel m);
  Insertable<TEntity> toDeleteCompanion(DateTime now);
  Expression<bool> whereId(TTable t, String id);
  Expression<bool> whereCompanyScope(TTable t, String companyId);
  Expression<bool> whereNotDeleted(TTable t);
  List<OrderingTerm Function(TTable)> get defaultOrderBy;
  String get entityName;

  // --- Sync abstract members ---

  String get supabaseTableName;
  Map<String, dynamic> toSupabaseJson(TModel m);

  // --- Concrete CRUD methods ---

  Future<Result<TModel>> create(TModel model) async {
    try {
      return await db.transaction(() async {
        await db.into(table).insert(toCompanion(model));
        final entity = await (db.select(table)
              ..where((t) => whereId(t, model.id)))
            .getSingle();
        final created = fromEntity(entity);
        await _enqueue('insert', created);
        return Success(created);
      });
    } catch (e, s) {
      AppLogger.error('Failed to create $entityName', error: e, stackTrace: s);
      return Failure('Failed to create $entityName: $e');
    }
  }

  Future<Result<TModel>> update(TModel model) async {
    try {
      return await db.transaction(() async {
        await (db.update(table)..where((t) => whereId(t, model.id)))
            .write(toUpdateCompanion(model));
        final entity = await (db.select(table)
              ..where((t) => whereId(t, model.id)))
            .getSingle();
        final updated = fromEntity(entity);
        await _enqueue('update', updated);
        return Success(updated);
      });
    } catch (e, s) {
      AppLogger.error('Failed to update $entityName', error: e, stackTrace: s);
      return Failure('Failed to update $entityName: $e');
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      return await db.transaction(() async {
        final now = DateTime.now();
        await (db.update(table)..where((t) => whereId(t, id)))
            .write(toDeleteCompanion(now));
        // Re-read entity to get full model for sync payload
        final entity = await (db.select(table)
              ..where((t) => whereId(t, id)))
            .getSingle();
        final deleted = fromEntity(entity);
        await _enqueue('delete', deleted);
        return const Success(null);
      });
    } catch (e, s) {
      AppLogger.error('Failed to delete $entityName', error: e, stackTrace: s);
      return Failure('Failed to delete $entityName: $e');
    }
  }

  Future<void> _enqueue(String operation, TModel model) async {
    if (syncQueueRepo == null) return;
    final json = toSupabaseJson(model);
    await syncQueueRepo!.enqueue(
      companyId: model.companyId,
      entityType: supabaseTableName,
      entityId: model.id,
      operation: operation,
      payload: jsonEncode(json),
    );
  }

  /// Enqueue all existing (non-deleted) entities for initial push.
  Future<void> enqueueAll(String companyId) async {
    if (syncQueueRepo == null) return;
    final entities = await (db.select(table)
          ..where((t) => whereCompanyScope(t, companyId)))
        .get();
    for (final entity in entities) {
      final model = fromEntity(entity);
      await _enqueue('insert', model);
    }
    AppLogger.info(
      'Enqueued ${entities.length} existing $entityName(s) for initial sync',
      tag: 'SYNC',
    );
  }

  Stream<List<TModel>> watchAll(String companyId) {
    return (db.select(table)
          ..where((t) => whereCompanyScope(t, companyId))
          ..orderBy(defaultOrderBy))
        .watch()
        .map((rows) => rows.map(fromEntity).toList());
  }

  Future<TModel?> getById(String id, {bool includeDeleted = false, String? companyId}) async {
    final query = db.select(table)..where((t) => whereId(t, id));
    if (companyId != null) {
      query.where((t) => whereCompanyScope(t, companyId));
    }
    if (!includeDeleted) {
      query.where((t) => whereNotDeleted(t));
    }
    final entity = await query.getSingleOrNull();
    return entity == null ? null : fromEntity(entity);
  }
}

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';

class SyncQueueRepository {
  SyncQueueRepository(this._db);
  final AppDatabase _db;

  static const _uuid = Uuid();

  Future<void> enqueue({
    required String companyId,
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
  }) async {
    await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
      id: _uuid.v4(),
      companyId: companyId,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
    ));
    AppLogger.debug(
      'Enqueued sync: $operation $entityType/$entityId',
      tag: 'SYNC',
    );
  }

  Future<List<SyncQueueData>> getPending({int limit = 50}) async {
    return (
      _db.select(_db.syncQueue)
        ..where((t) => t.status.equals('pending'))
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
        ..limit(limit)
    ).get();
  }

  Future<void> markProcessing(String id) async {
    await (_db.update(_db.syncQueue)..where((t) => t.id.equals(id)))
        .write(const SyncQueueCompanion(status: Value('processing')));
  }

  Future<void> markCompleted(String id) async {
    await (_db.update(_db.syncQueue)..where((t) => t.id.equals(id)))
        .write(SyncQueueCompanion(
      status: const Value('completed'),
      processedAt: Value(DateTime.now()),
    ));
  }

  Future<void> markFailed(String id, String error) async {
    await (_db.update(_db.syncQueue)..where((t) => t.id.equals(id)))
        .write(SyncQueueCompanion(
      status: const Value('failed'),
      errorMessage: Value(error),
      processedAt: Value(DateTime.now()),
    ));
  }

  Future<void> incrementRetry(String id, String error) async {
    final entry = await (_db.select(_db.syncQueue)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    await (_db.update(_db.syncQueue)..where((t) => t.id.equals(id)))
        .write(SyncQueueCompanion(
      status: const Value('pending'),
      retryCount: Value(entry.retryCount + 1),
      errorMessage: Value(error),
      lastErrorAt: Value(DateTime.now()),
    ));
  }

  Future<void> resetStuck({Duration threshold = const Duration(minutes: 5)}) async {
    final cutoff = DateTime.now().subtract(threshold);
    final count = await (_db.update(_db.syncQueue)
          ..where((t) =>
              t.status.equals('processing') & t.createdAt.isSmallerOrEqualValue(cutoff)))
        .write(const SyncQueueCompanion(status: Value('pending')));
    if (count > 0) {
      AppLogger.warn('Reset $count stuck sync queue entries', tag: 'SYNC');
    }
  }

  Future<bool> hasPendingForEntity(String entityType, String entityId) async {
    final result = await (_db.select(_db.syncQueue)
          ..where((t) =>
              t.entityType.equals(entityType) &
              t.entityId.equals(entityId) &
              (t.status.equals('pending') | t.status.equals('processing')))
          ..limit(1))
        .get();
    return result.isNotEmpty;
  }

  Future<bool> hasCompletedEntries(String companyId) async {
    final result = await (_db.select(_db.syncQueue)
          ..where((t) =>
              t.companyId.equals(companyId) & t.status.equals('completed'))
          ..limit(1))
        .get();
    return result.isNotEmpty;
  }

  Future<void> deleteCompleted({Duration olderThan = const Duration(days: 7)}) async {
    final cutoff = DateTime.now().subtract(olderThan);
    await (_db.delete(_db.syncQueue)
          ..where((t) =>
              t.status.equals('completed') & t.processedAt.isSmallerOrEqualValue(cutoff)))
        .go();
  }

  /// Deletes all pending (and processing) entries.
  /// Used before initial push to clear entries created before sync was activated.
  /// Returns the number of deleted entries.
  Future<int> deleteAllPending() async {
    return (_db.delete(_db.syncQueue)
          ..where((t) =>
              t.status.equals('pending') | t.status.equals('processing')))
        .go();
  }
}

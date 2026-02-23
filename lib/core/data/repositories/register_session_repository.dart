import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/register_session_model.dart';
import '../result.dart';
import 'sync_queue_repository.dart';

class RegisterSessionRepository {
  RegisterSessionRepository(this._db, {this.syncQueueRepo});
  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;

  Future<Result<RegisterSessionModel>> openSession({
    required String companyId,
    required String registerId,
    required String userId,
    int? openingCash,
    int? openBillsAtOpenCount,
    int? openBillsAtOpenAmount,
    String? parentSessionId,
  }) async {
    try {
      return await _db.transaction(() async {
        final now = DateTime.now();
        final id = const Uuid().v7();
        await _db.into(_db.registerSessions).insert(
          RegisterSessionsCompanion.insert(
            id: id,
            companyId: companyId,
            registerId: registerId,
            openedByUserId: userId,
            openedAt: now,
            openingCash: Value(openingCash),
            openBillsAtOpenCount: Value(openBillsAtOpenCount),
            openBillsAtOpenAmount: Value(openBillsAtOpenAmount),
            parentSessionId: Value(parentSessionId),
          ),
        );
        final entity = await (_db.select(_db.registerSessions)
              ..where((t) => t.id.equals(id)))
            .getSingle();
        final model = registerSessionFromEntity(entity);
        await _enqueueSession('insert', model);
        return Success(model);
      });
    } catch (e, s) {
      AppLogger.error('Failed to open register session', error: e, stackTrace: s);
      return Failure('Failed to open register session: $e');
    }
  }

  Future<Result<RegisterSessionModel>> closeSession(
    String sessionId, {
    int? closingCash,
    int? expectedCash,
    int? difference,
    int? openBillsAtCloseCount,
    int? openBillsAtCloseAmount,
  }) async {
    try {
      return await _db.transaction(() async {
        final now = DateTime.now();
        await (_db.update(_db.registerSessions)..where((t) => t.id.equals(sessionId)))
            .write(RegisterSessionsCompanion(
          closedAt: Value(now),
          closingCash: Value(closingCash),
          expectedCash: Value(expectedCash),
          difference: Value(difference),
          openBillsAtCloseCount: Value(openBillsAtCloseCount),
          openBillsAtCloseAmount: Value(openBillsAtCloseAmount),
          updatedAt: Value(now),
        ));
        final entity = await (_db.select(_db.registerSessions)
              ..where((t) => t.id.equals(sessionId)))
            .getSingle();
        final model = registerSessionFromEntity(entity);
        await _enqueueSession('update', model);
        return Success(model);
      });
    } catch (e, s) {
      AppLogger.error('Failed to close register session', error: e, stackTrace: s);
      return Failure('Failed to close register session: $e');
    }
  }

  Future<int?> getLastClosingCash(String companyId, {String? registerId}) async {
    final query = _db.select(_db.registerSessions)
      ..where((t) {
        var expr = t.companyId.equals(companyId) &
            t.closedAt.isNotNull() &
            t.deletedAt.isNull();
        if (registerId != null) {
          expr = expr & t.registerId.equals(registerId);
        }
        return expr;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.closedAt)])
      ..limit(1);
    final entity = await query.getSingleOrNull();
    return entity?.closingCash;
  }

  Future<RegisterSessionModel?> getActiveSession(String companyId, {String? registerId}) async {
    final query = _db.select(_db.registerSessions)
      ..where((t) {
        var expr = t.companyId.equals(companyId) &
            t.closedAt.isNull() &
            t.deletedAt.isNull();
        if (registerId != null) {
          expr = expr & t.registerId.equals(registerId);
        }
        return expr;
      })
      ..limit(1);
    final entity = await query.getSingleOrNull();
    return entity == null ? null : registerSessionFromEntity(entity);
  }

  Stream<RegisterSessionModel?> watchActiveSession(String companyId, {String? registerId}) {
    return (_db.select(_db.registerSessions)
          ..where((t) {
            var expr = t.companyId.equals(companyId) &
                t.closedAt.isNull() &
                t.deletedAt.isNull();
            if (registerId != null) {
              expr = expr & t.registerId.equals(registerId);
            }
            return expr;
          })
          ..limit(1))
        .watchSingleOrNull()
        .map((e) => e == null ? null : registerSessionFromEntity(e));
  }

  Future<Result<int>> incrementOrderCounter(String sessionId) async {
    try {
      final newCounter = await _db.transaction(() async {
        final entity = await (_db.select(_db.registerSessions)
              ..where((t) => t.id.equals(sessionId)))
            .getSingle();
        final counter = entity.orderCounter + 1;
        await (_db.update(_db.registerSessions)..where((t) => t.id.equals(sessionId)))
            .write(RegisterSessionsCompanion(
          orderCounter: Value(counter),
          updatedAt: Value(DateTime.now()),
        ));
        final updated = await (_db.select(_db.registerSessions)
              ..where((t) => t.id.equals(sessionId)))
            .getSingle();
        await _enqueueSession('update', registerSessionFromEntity(updated));
        return counter;
      });
      return Success(newCounter);
    } catch (e, s) {
      AppLogger.error('Failed to increment order counter', error: e, stackTrace: s);
      return Failure('Failed to increment order counter: $e');
    }
  }

  Future<Result<int>> incrementBillCounter(String sessionId) async {
    try {
      final newCounter = await _db.transaction(() async {
        final entity = await (_db.select(_db.registerSessions)
              ..where((t) => t.id.equals(sessionId)))
            .getSingle();
        final counter = entity.billCounter + 1;
        await (_db.update(_db.registerSessions)..where((t) => t.id.equals(sessionId)))
            .write(RegisterSessionsCompanion(
          billCounter: Value(counter),
          updatedAt: Value(DateTime.now()),
        ));
        final updated = await (_db.select(_db.registerSessions)
              ..where((t) => t.id.equals(sessionId)))
            .getSingle();
        await _enqueueSession('update', registerSessionFromEntity(updated));
        return counter;
      });
      return Success(newCounter);
    } catch (e, s) {
      AppLogger.error('Failed to increment bill counter', error: e, stackTrace: s);
      return Failure('Failed to increment bill counter: $e');
    }
  }

  Future<List<RegisterSessionModel>> getClosedSessionsInRange(
      String companyId, DateTime from, DateTime to) async {
    final entities = await (_db.select(_db.registerSessions)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.closedAt.isNotNull() &
              t.closedAt.isBiggerOrEqualValue(from) &
              t.closedAt.isSmallerOrEqualValue(to) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.closedAt)]))
        .get();
    return entities.map(registerSessionFromEntity).toList();
  }

  Future<List<RegisterSessionModel>> getClosedSessions(String companyId) async {
    final entities = await (_db.select(_db.registerSessions)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.closedAt.isNotNull() &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.closedAt)]))
        .get();
    return entities.map(registerSessionFromEntity).toList();
  }

  Future<RegisterSessionModel?> getById(String sessionId, {bool includeDeleted = false}) async {
    final query = _db.select(_db.registerSessions)
      ..where((t) => t.id.equals(sessionId));
    if (!includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }
    final entity = await query.getSingleOrNull();
    return entity == null ? null : registerSessionFromEntity(entity);
  }

  Future<void> _enqueueSession(String operation, RegisterSessionModel model) async {
    if (syncQueueRepo == null) return;
    final json = registerSessionToSupabaseJson(model);
    await syncQueueRepo!.enqueue(
      companyId: model.companyId,
      entityType: 'register_sessions',
      entityId: model.id,
      operation: operation,
      payload: jsonEncode(json),
    );
  }
}

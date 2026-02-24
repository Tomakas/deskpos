import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/session_currency_cash_model.dart';
import '../result.dart';
import 'sync_queue_repository.dart';

class SessionCurrencyCashRepository {
  SessionCurrencyCashRepository(this._db, {this.syncQueueRepo});
  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;

  Future<Result<SessionCurrencyCashModel>> create({
    required String companyId,
    required String registerSessionId,
    required String currencyId,
    required int openingCash,
  }) async {
    try {
      return await _db.transaction(() async {
        final id = const Uuid().v7();
        await _db.into(_db.sessionCurrencyCash).insert(
          SessionCurrencyCashCompanion.insert(
            id: id,
            companyId: companyId,
            registerSessionId: registerSessionId,
            currencyId: currencyId,
            openingCash: Value(openingCash),
          ),
        );
        final entity = await (_db.select(_db.sessionCurrencyCash)
              ..where((t) => t.id.equals(id)))
            .getSingle();
        final model = sessionCurrencyCashFromEntity(entity);
        await _enqueue('insert', model);
        return Success(model);
      });
    } catch (e, s) {
      AppLogger.error('Failed to create session currency cash', error: e, stackTrace: s);
      return Failure('Failed to create session currency cash: $e');
    }
  }

  Future<List<SessionCurrencyCashModel>> getBySession(String sessionId) async {
    final entities = await (_db.select(_db.sessionCurrencyCash)
          ..where((t) => t.registerSessionId.equals(sessionId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return entities.map(sessionCurrencyCashFromEntity).toList();
  }

  Stream<List<SessionCurrencyCashModel>> watchBySession(String sessionId) {
    return (_db.select(_db.sessionCurrencyCash)
          ..where((t) => t.registerSessionId.equals(sessionId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(sessionCurrencyCashFromEntity).toList());
  }

  Future<Result<SessionCurrencyCashModel>> updateClosing(
    String id, {
    required int closingCash,
    required int expectedCash,
    required int difference,
  }) async {
    try {
      return await _db.transaction(() async {
        final now = DateTime.now();
        await (_db.update(_db.sessionCurrencyCash)
              ..where((t) => t.id.equals(id)))
            .write(SessionCurrencyCashCompanion(
          closingCash: Value(closingCash),
          expectedCash: Value(expectedCash),
          difference: Value(difference),
          updatedAt: Value(now),
        ));
        final entity = await (_db.select(_db.sessionCurrencyCash)
              ..where((t) => t.id.equals(id)))
            .getSingle();
        final model = sessionCurrencyCashFromEntity(entity);
        await _enqueue('update', model);
        return Success(model);
      });
    } catch (e, s) {
      AppLogger.error('Failed to update session currency cash closing', error: e, stackTrace: s);
      return Failure('Failed to update session currency cash closing: $e');
    }
  }

  Future<int?> getLastClosingCash(String companyId, String currencyId, {String? registerId}) async {
    // Find the most recent closing cash for this currency across sessions
    var query = _db.select(_db.sessionCurrencyCash).join([
      innerJoin(
        _db.registerSessions,
        _db.registerSessions.id.equalsExp(_db.sessionCurrencyCash.registerSessionId),
      ),
    ]);
    query.where(
      _db.sessionCurrencyCash.companyId.equals(companyId) &
      _db.sessionCurrencyCash.currencyId.equals(currencyId) &
      _db.sessionCurrencyCash.closingCash.isNotNull() &
      _db.sessionCurrencyCash.deletedAt.isNull(),
    );
    if (registerId != null) {
      query.where(_db.registerSessions.registerId.equals(registerId));
    }
    query.orderBy([OrderingTerm.desc(_db.sessionCurrencyCash.updatedAt)]);
    query.limit(1);

    final result = await query.getSingleOrNull();
    if (result == null) return null;
    return result.readTable(_db.sessionCurrencyCash).closingCash;
  }

  Future<void> _enqueue(String operation, SessionCurrencyCashModel model) async {
    if (syncQueueRepo == null) return;
    final json = sessionCurrencyCashToSupabaseJson(model);
    await syncQueueRepo!.enqueue(
      companyId: model.companyId,
      entityType: 'session_currency_cash',
      entityId: model.id,
      operation: operation,
      payload: jsonEncode(json),
    );
  }
}

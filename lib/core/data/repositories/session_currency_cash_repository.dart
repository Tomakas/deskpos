import 'dart:convert';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/session_currency_cash_model.dart';
import '../result.dart';
import 'base_company_scoped_repository.dart';

class SessionCurrencyCashRepository extends BaseCompanyScopedRepository<
    $SessionCurrencyCashTable, SessionCurrencyCashData, SessionCurrencyCashModel> {
  SessionCurrencyCashRepository(super.db, {super.syncQueueRepo});

  @override
  TableInfo<$SessionCurrencyCashTable, SessionCurrencyCashData> get table =>
      db.sessionCurrencyCash;

  @override
  String get entityName => 'session currency cash';

  @override
  String get supabaseTableName => 'session_currency_cash';

  @override
  SessionCurrencyCashModel fromEntity(SessionCurrencyCashData e) =>
      sessionCurrencyCashFromEntity(e);

  @override
  Insertable<SessionCurrencyCashData> toCompanion(SessionCurrencyCashModel m) =>
      sessionCurrencyCashToCompanion(m);

  @override
  Insertable<SessionCurrencyCashData> toUpdateCompanion(SessionCurrencyCashModel m) =>
      sessionCurrencyCashToUpdateCompanion(m);

  @override
  Insertable<SessionCurrencyCashData> toDeleteCompanion(DateTime now) =>
      sessionCurrencyCashToDeleteCompanion(now);

  @override
  Map<String, dynamic> toSupabaseJson(SessionCurrencyCashModel m) =>
      sessionCurrencyCashToSupabaseJson(m);

  @override
  Expression<bool> whereId($SessionCurrencyCashTable t, String id) =>
      t.id.equals(id);

  @override
  Expression<bool> whereCompanyScope($SessionCurrencyCashTable t, String companyId) =>
      t.companyId.equals(companyId) & t.deletedAt.isNull();

  @override
  Expression<bool> whereNotDeleted($SessionCurrencyCashTable t) =>
      t.deletedAt.isNull();

  @override
  List<OrderingTerm Function($SessionCurrencyCashTable)> get defaultOrderBy =>
      [(t) => OrderingTerm.asc(t.createdAt)];

  // --- Custom query methods ---

  Future<List<SessionCurrencyCashModel>> getBySession(String sessionId) async {
    final entities = await (db.select(db.sessionCurrencyCash)
          ..where((t) => t.registerSessionId.equals(sessionId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return entities.map(sessionCurrencyCashFromEntity).toList();
  }

  Stream<List<SessionCurrencyCashModel>> watchBySession(String sessionId) {
    return (db.select(db.sessionCurrencyCash)
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
      return await db.transaction(() async {
        final now = DateTime.now();
        await (db.update(db.sessionCurrencyCash)
              ..where((t) => t.id.equals(id)))
            .write(SessionCurrencyCashCompanion(
          closingCash: Value(closingCash),
          expectedCash: Value(expectedCash),
          difference: Value(difference),
          updatedAt: Value(now),
        ));
        final entity = await (db.select(db.sessionCurrencyCash)
              ..where((t) => t.id.equals(id)))
            .getSingle();
        final model = sessionCurrencyCashFromEntity(entity);
        await _enqueueSync('update', model);
        return Success(model);
      });
    } catch (e, s) {
      AppLogger.error('Failed to update session currency cash closing', error: e, stackTrace: s);
      return Failure('Failed to update session currency cash closing: $e');
    }
  }

  Future<int?> getLastClosingCash(String companyId, String currencyId, {String? registerId}) async {
    var query = db.select(db.sessionCurrencyCash).join([
      innerJoin(
        db.registerSessions,
        db.registerSessions.id.equalsExp(db.sessionCurrencyCash.registerSessionId),
      ),
    ]);
    query.where(
      db.sessionCurrencyCash.companyId.equals(companyId) &
      db.sessionCurrencyCash.currencyId.equals(currencyId) &
      db.sessionCurrencyCash.closingCash.isNotNull() &
      db.sessionCurrencyCash.deletedAt.isNull(),
    );
    if (registerId != null) {
      query.where(db.registerSessions.registerId.equals(registerId));
    }
    query.orderBy([OrderingTerm.desc(db.sessionCurrencyCash.updatedAt)]);
    query.limit(1);

    final result = await query.getSingleOrNull();
    if (result == null) return null;
    return result.readTable(db.sessionCurrencyCash).closingCash;
  }

  Future<void> _enqueueSync(String operation, SessionCurrencyCashModel model) async {
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

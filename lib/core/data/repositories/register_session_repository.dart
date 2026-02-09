import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../models/register_session_model.dart';
import '../result.dart';

class RegisterSessionRepository {
  RegisterSessionRepository(this._db);
  final AppDatabase _db;

  Future<Result<RegisterSessionModel>> openSession({
    required String companyId,
    required String registerId,
    required String userId,
  }) async {
    try {
      final now = DateTime.now();
      final id = const Uuid().v7();
      await _db.into(_db.registerSessions).insert(
        RegisterSessionsCompanion.insert(
          id: id,
          companyId: companyId,
          registerId: registerId,
          openedByUserId: userId,
          openedAt: now,
        ),
      );
      final entity = await (_db.select(_db.registerSessions)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      return Success(registerSessionFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to open register session', error: e, stackTrace: s);
      return Failure('Failed to open register session: $e');
    }
  }

  Future<Result<RegisterSessionModel>> closeSession(String sessionId) async {
    try {
      final now = DateTime.now();
      await (_db.update(_db.registerSessions)..where((t) => t.id.equals(sessionId)))
          .write(RegisterSessionsCompanion(
        closedAt: Value(now),
        updatedAt: Value(now),
      ));
      final entity = await (_db.select(_db.registerSessions)
            ..where((t) => t.id.equals(sessionId)))
          .getSingle();
      return Success(registerSessionFromEntity(entity));
    } catch (e, s) {
      AppLogger.error('Failed to close register session', error: e, stackTrace: s);
      return Failure('Failed to close register session: $e');
    }
  }

  Future<RegisterSessionModel?> getActiveSession(String companyId) async {
    final entity = await (_db.select(_db.registerSessions)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.closedAt.isNull() &
              t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return entity == null ? null : registerSessionFromEntity(entity);
  }

  Stream<RegisterSessionModel?> watchActiveSession(String companyId) {
    return (_db.select(_db.registerSessions)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.closedAt.isNull() &
              t.deletedAt.isNull())
          ..limit(1))
        .watchSingleOrNull()
        .map((e) => e == null ? null : registerSessionFromEntity(e));
  }

  Future<Result<int>> incrementOrderCounter(String sessionId) async {
    try {
      final entity = await (_db.select(_db.registerSessions)
            ..where((t) => t.id.equals(sessionId)))
          .getSingle();
      final newCounter = entity.orderCounter + 1;
      await (_db.update(_db.registerSessions)..where((t) => t.id.equals(sessionId)))
          .write(RegisterSessionsCompanion(
        orderCounter: Value(newCounter),
        updatedAt: Value(DateTime.now()),
      ));
      return Success(newCounter);
    } catch (e, s) {
      AppLogger.error('Failed to increment order counter', error: e, stackTrace: s);
      return Failure('Failed to increment order counter: $e');
    }
  }
}

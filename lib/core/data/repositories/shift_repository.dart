import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/shift_model.dart';
import '../result.dart';
import 'sync_queue_repository.dart';

class ShiftRepository {
  ShiftRepository(this._db, {this.syncQueueRepo});
  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;

  Future<Result<ShiftModel>> create({
    required String companyId,
    required String registerSessionId,
    required String userId,
  }) async {
    try {
      return await _db.transaction(() async {
        final now = DateTime.now();
        final id = const Uuid().v7();
        await _db.into(_db.shifts).insert(ShiftsCompanion.insert(
          id: id,
          companyId: companyId,
          registerSessionId: registerSessionId,
          userId: userId,
          loginAt: now,
        ));
        final entity = await (_db.select(_db.shifts)
              ..where((t) => t.id.equals(id)))
            .getSingle();
        final model = shiftFromEntity(entity);
        await _enqueue('insert', model);
        return Success(model);
      });
    } catch (e, s) {
      AppLogger.error('Failed to create shift', error: e, stackTrace: s);
      return Failure('Failed to create shift: $e');
    }
  }

  Future<Result<ShiftModel>> closeShift(String shiftId) async {
    try {
      return await _db.transaction(() async {
        final now = DateTime.now();
        await (_db.update(_db.shifts)..where((t) => t.id.equals(shiftId)))
            .write(ShiftsCompanion(
          logoutAt: Value(now),
          updatedAt: Value(now),
        ));
        final entity = await (_db.select(_db.shifts)
              ..where((t) => t.id.equals(shiftId)))
            .getSingle();
        final model = shiftFromEntity(entity);
        await _enqueue('update', model);
        return Success(model);
      });
    } catch (e, s) {
      AppLogger.error('Failed to close shift', error: e, stackTrace: s);
      return Failure('Failed to close shift: $e');
    }
  }

  Future<void> closeAllForSession(String registerSessionId) async {
    try {
      await _db.transaction(() async {
        final openShifts = await (_db.select(_db.shifts)
              ..where((t) =>
                  t.registerSessionId.equals(registerSessionId) &
                  t.logoutAt.isNull() &
                  t.deletedAt.isNull()))
            .get();
        final now = DateTime.now();
        for (final shift in openShifts) {
          await (_db.update(_db.shifts)..where((t) => t.id.equals(shift.id)))
              .write(ShiftsCompanion(
            logoutAt: Value(now),
            updatedAt: Value(now),
          ));
          final updated = await (_db.select(_db.shifts)
                ..where((t) => t.id.equals(shift.id)))
              .getSingle();
          await _enqueue('update', shiftFromEntity(updated));
        }
      });
    } catch (e, s) {
      AppLogger.error('Failed to close all shifts for session', error: e, stackTrace: s);
    }
  }

  Future<List<ShiftModel>> getByCompany(String companyId) async {
    final entities = await (_db.select(_db.shifts)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.loginAt)]))
        .get();
    return entities.map(shiftFromEntity).toList();
  }

  Future<List<ShiftModel>> getBySession(String registerSessionId) async {
    final entities = await (_db.select(_db.shifts)
          ..where((t) =>
              t.registerSessionId.equals(registerSessionId) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.loginAt)]))
        .get();
    return entities.map(shiftFromEntity).toList();
  }

  Future<ShiftModel?> getActiveShiftForUser(String userId, String registerSessionId) async {
    final entity = await (_db.select(_db.shifts)
          ..where((t) =>
              t.userId.equals(userId) &
              t.registerSessionId.equals(registerSessionId) &
              t.logoutAt.isNull() &
              t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return entity == null ? null : shiftFromEntity(entity);
  }

  Future<void> _enqueue(String operation, ShiftModel model) async {
    if (syncQueueRepo == null) return;
    final json = shiftToSupabaseJson(model);
    await syncQueueRepo!.enqueue(
      companyId: model.companyId,
      entityType: 'shifts',
      entityId: model.id,
      operation: operation,
      payload: jsonEncode(json),
    );
  }
}

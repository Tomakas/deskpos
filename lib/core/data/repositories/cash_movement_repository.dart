import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../enums/cash_movement_type.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/cash_movement_model.dart';
import '../result.dart';
import 'sync_queue_repository.dart';

class CashMovementRepository {
  CashMovementRepository(this._db, {this.syncQueueRepo});
  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;

  Future<Result<CashMovementModel>> create({
    required String companyId,
    required String registerSessionId,
    required String userId,
    required CashMovementType type,
    required int amount,
    String? reason,
  }) async {
    try {
      final id = const Uuid().v7();
      await _db.into(_db.cashMovements).insert(
        CashMovementsCompanion.insert(
          id: id,
          companyId: companyId,
          registerSessionId: registerSessionId,
          userId: userId,
          type: type,
          amount: amount,
          reason: Value(reason),
        ),
      );
      final entity = await (_db.select(_db.cashMovements)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      final model = cashMovementFromEntity(entity);
      await _enqueue('insert', model);
      return Success(model);
    } catch (e, s) {
      AppLogger.error('Failed to create cash movement', error: e, stackTrace: s);
      return Failure('Failed to create cash movement: $e');
    }
  }

  Future<List<CashMovementModel>> getBySession(String sessionId) async {
    final entities = await (_db.select(_db.cashMovements)
          ..where((t) => t.registerSessionId.equals(sessionId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return entities.map(cashMovementFromEntity).toList();
  }

  Stream<List<CashMovementModel>> watchBySession(String sessionId) {
    return (_db.select(_db.cashMovements)
          ..where((t) => t.registerSessionId.equals(sessionId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(cashMovementFromEntity).toList());
  }

  Future<void> _enqueue(String operation, CashMovementModel model) async {
    if (syncQueueRepo == null) return;
    final json = cashMovementToSupabaseJson(model);
    await syncQueueRepo!.enqueue(
      companyId: model.companyId,
      entityType: 'cash_movements',
      entityId: model.id,
      operation: operation,
      payload: jsonEncode(json),
    );
  }
}

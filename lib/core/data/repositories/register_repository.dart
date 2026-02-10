import 'dart:convert';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/register_model.dart';
import 'sync_queue_repository.dart';

class RegisterRepository {
  RegisterRepository(this._db, {this.syncQueueRepo});
  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;

  Future<RegisterModel?> getFirstActive(String companyId) async {
    final entity = await (_db.select(_db.registers)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.isActive.equals(true) &
              t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return entity == null ? null : registerFromEntity(entity);
  }

  Stream<RegisterModel?> watchFirstActive(String companyId) {
    return (_db.select(_db.registers)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.isActive.equals(true) &
              t.deletedAt.isNull())
          ..limit(1))
        .watchSingleOrNull()
        .map((e) => e == null ? null : registerFromEntity(e));
  }

  Future<RegisterModel?> updateGrid(String registerId, int gridRows, int gridCols) async {
    final now = DateTime.now();
    await (_db.update(_db.registers)..where((t) => t.id.equals(registerId)))
        .write(RegistersCompanion(
      gridRows: Value(gridRows),
      gridCols: Value(gridCols),
      updatedAt: Value(now),
    ));
    final entity = await (_db.select(_db.registers)
          ..where((t) => t.id.equals(registerId)))
        .getSingleOrNull();
    if (entity == null) return null;
    final model = registerFromEntity(entity);
    if (syncQueueRepo != null) {
      await syncQueueRepo!.enqueue(
        companyId: model.companyId,
        entityType: 'registers',
        entityId: model.id,
        operation: 'update',
        payload: jsonEncode(registerToSupabaseJson(model)),
      );
    }
    return model;
  }
}

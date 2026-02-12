import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../enums/hardware_type.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/register_model.dart';
import '../result.dart';
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

  Future<RegisterModel?> getById(String registerId) async {
    final entity = await (_db.select(_db.registers)
          ..where((t) => t.id.equals(registerId)))
        .getSingleOrNull();
    return entity == null ? null : registerFromEntity(entity);
  }

  Stream<RegisterModel?> watchById(String registerId) {
    return (_db.select(_db.registers)
          ..where((t) => t.id.equals(registerId)))
        .watchSingleOrNull()
        .map((e) => e == null ? null : registerFromEntity(e));
  }

  Future<List<RegisterModel>> getAll(String companyId) async {
    final entities = await (_db.select(_db.registers)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.isActive.equals(true) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.registerNumber)]))
        .get();
    return entities.map(registerFromEntity).toList();
  }

  Stream<List<RegisterModel>> watchAll(String companyId) {
    return (_db.select(_db.registers)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.isActive.equals(true) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.registerNumber)]))
        .watch()
        .map((rows) => rows.map(registerFromEntity).toList());
  }

  Future<int> getNextRegisterNumber(String companyId) async {
    final entities = await (_db.select(_db.registers)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.registerNumber)])
          ..limit(1))
        .get();
    if (entities.isEmpty) return 1;
    return entities.first.registerNumber + 1;
  }

  Future<Result<RegisterModel>> create({
    required String companyId,
    required String name,
    required HardwareType type,
    String? parentRegisterId,
    bool isMain = false,
    bool allowCash = true,
    bool allowCard = true,
    bool allowTransfer = true,
    bool allowRefunds = false,
    int gridRows = 5,
    int gridCols = 8,
  }) async {
    try {
      final id = const Uuid().v7();
      final registerNumber = await getNextRegisterNumber(companyId);
      final code = 'REG-$registerNumber';

      await _db.into(_db.registers).insert(RegistersCompanion.insert(
        id: id,
        companyId: companyId,
        code: code,
        name: Value(name),
        registerNumber: Value(registerNumber),
        parentRegisterId: Value(parentRegisterId),
        isMain: Value(isMain),
        type: type,
        allowCash: Value(allowCash),
        allowCard: Value(allowCard),
        allowTransfer: Value(allowTransfer),
        allowRefunds: Value(allowRefunds),
        gridRows: Value(gridRows),
        gridCols: Value(gridCols),
      ));

      final entity = await (_db.select(_db.registers)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      final model = registerFromEntity(entity);
      await _enqueue('insert', model);
      return Success(model);
    } catch (e, s) {
      AppLogger.error('Failed to create register', error: e, stackTrace: s);
      return Failure('Failed to create register: $e');
    }
  }

  Future<Result<RegisterModel>> update(RegisterModel model) async {
    try {
      final now = DateTime.now();
      await (_db.update(_db.registers)..where((t) => t.id.equals(model.id)))
          .write(RegistersCompanion(
        name: Value(model.name),
        type: Value(model.type),
        parentRegisterId: Value(model.parentRegisterId),
        isMain: Value(model.isMain),
        isActive: Value(model.isActive),
        allowCash: Value(model.allowCash),
        allowCard: Value(model.allowCard),
        allowTransfer: Value(model.allowTransfer),
        allowRefunds: Value(model.allowRefunds),
        gridRows: Value(model.gridRows),
        gridCols: Value(model.gridCols),
        updatedAt: Value(now),
      ));
      final entity = await (_db.select(_db.registers)
            ..where((t) => t.id.equals(model.id)))
          .getSingle();
      final updated = registerFromEntity(entity);
      await _enqueue('update', updated);
      return Success(updated);
    } catch (e, s) {
      AppLogger.error('Failed to update register', error: e, stackTrace: s);
      return Failure('Failed to update register: $e');
    }
  }

  Future<Result<void>> delete(String registerId) async {
    try {
      final now = DateTime.now();
      await (_db.update(_db.registers)..where((t) => t.id.equals(registerId)))
          .write(RegistersCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
      final entity = await (_db.select(_db.registers)
            ..where((t) => t.id.equals(registerId)))
          .getSingle();
      final model = registerFromEntity(entity);
      await _enqueue('delete', model);
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to delete register', error: e, stackTrace: s);
      return Failure('Failed to delete register: $e');
    }
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
    await _enqueue('update', model);
    return model;
  }

  /// Sets the given register as main and clears isMain from all others in the company.
  Future<Result<void>> setMain(String companyId, String registerId) async {
    try {
      final now = DateTime.now();
      // Clear isMain from all registers in the company
      await (_db.update(_db.registers)
            ..where((t) => t.companyId.equals(companyId) & t.isMain.equals(true)))
          .write(RegistersCompanion(
        isMain: const Value(false),
        updatedAt: Value(now),
      ));
      // Set isMain on the target register
      await (_db.update(_db.registers)
            ..where((t) => t.id.equals(registerId)))
          .write(RegistersCompanion(
        isMain: const Value(true),
        updatedAt: Value(now),
      ));
      // Enqueue both changes
      final all = await getAll(companyId);
      for (final reg in all) {
        await _enqueue('update', reg);
      }
      return const Success(null);
    } catch (e, s) {
      AppLogger.error('Failed to set main register', error: e, stackTrace: s);
      return Failure('Failed to set main register: $e');
    }
  }

  /// Returns the main register for a company, or null if none is set.
  Future<RegisterModel?> getMain(String companyId) async {
    final entity = await (_db.select(_db.registers)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.isMain.equals(true) &
              t.deletedAt.isNull()))
        .getSingleOrNull();
    return entity == null ? null : registerFromEntity(entity);
  }

  /// Sets the boundDeviceId on a register (marks it as bound to a device).
  Future<void> setBoundDevice(String registerId, String deviceId) async {
    final now = DateTime.now();
    await (_db.update(_db.registers)..where((t) => t.id.equals(registerId)))
        .write(RegistersCompanion(
      boundDeviceId: Value(deviceId),
      updatedAt: Value(now),
    ));
    final entity = await (_db.select(_db.registers)
          ..where((t) => t.id.equals(registerId)))
        .getSingleOrNull();
    if (entity != null) {
      await _enqueue('update', registerFromEntity(entity));
    }
  }

  /// Sets (or clears) the activeBillId on a register.
  Future<void> setActiveBill(String registerId, String? billId) async {
    final now = DateTime.now();
    await (_db.update(_db.registers)..where((t) => t.id.equals(registerId)))
        .write(RegistersCompanion(
      activeBillId: Value(billId),
      updatedAt: Value(now),
    ));
    final entity = await (_db.select(_db.registers)
          ..where((t) => t.id.equals(registerId)))
        .getSingleOrNull();
    if (entity != null) {
      await _enqueue('update', registerFromEntity(entity));
    }
  }

  /// Sets (or clears) the displayCartJson on a register.
  Future<void> setDisplayCart(String registerId, String? cartJson) async {
    final now = DateTime.now();
    await (_db.update(_db.registers)..where((t) => t.id.equals(registerId)))
        .write(RegistersCompanion(
      displayCartJson: Value(cartJson),
      updatedAt: Value(now),
    ));
    final entity = await (_db.select(_db.registers)
          ..where((t) => t.id.equals(registerId)))
        .getSingleOrNull();
    if (entity != null) {
      await _enqueue('update', registerFromEntity(entity));
    }
  }

  /// Clears the boundDeviceId on a register (releases it for other devices).
  Future<void> clearBoundDevice(String registerId) async {
    final now = DateTime.now();
    await (_db.update(_db.registers)..where((t) => t.id.equals(registerId)))
        .write(RegistersCompanion(
      boundDeviceId: const Value(null),
      updatedAt: Value(now),
    ));
    final entity = await (_db.select(_db.registers)
          ..where((t) => t.id.equals(registerId)))
        .getSingleOrNull();
    if (entity != null) {
      await _enqueue('update', registerFromEntity(entity));
    }
  }

  Future<void> _enqueue(String operation, RegisterModel model) async {
    if (syncQueueRepo == null) return;
    await syncQueueRepo!.enqueue(
      companyId: model.companyId,
      entityType: 'registers',
      entityId: model.id,
      operation: operation,
      payload: jsonEncode(registerToSupabaseJson(model)),
    );
  }
}

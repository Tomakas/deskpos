import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../logging/app_logger.dart';
import '../enums/display_device_type.dart';
import '../mappers/entity_mappers.dart';
import '../mappers/supabase_mappers.dart';
import '../models/display_device_model.dart';
import '../result.dart';
import 'sync_queue_repository.dart';

class DisplayDeviceRepository {
  DisplayDeviceRepository(this._db, {this.syncQueueRepo, this.supabaseClient});

  final AppDatabase _db;
  final SyncQueueRepository? syncQueueRepo;
  final SupabaseClient? supabaseClient;

  Future<Result<DisplayDeviceModel>> create({
    required String companyId,
    required String name,
    required DisplayDeviceType type,
    String? parentRegisterId,
    String welcomeText = '',
  }) async {
    try {
      return await _db.transaction(() async {
        final id = const Uuid().v7();
        final code = await _generateUniqueCode();

        await _db.into(_db.displayDevices).insert(DisplayDevicesCompanion.insert(
              id: id,
              companyId: companyId,
              parentRegisterId: Value(parentRegisterId),
              code: code,
              name: Value(name),
              welcomeText: Value(welcomeText),
              type: type,
            ));

        final entity = await (_db.select(_db.displayDevices)
              ..where((t) => t.id.equals(id)))
            .getSingle();
        final model = displayDeviceFromEntity(entity);
        await _enqueue('insert', model);
        return Success(model);
      });
    } catch (e, s) {
      AppLogger.error('Failed to create display device', error: e, stackTrace: s);
      return Failure('Failed to create display device: $e');
    }
  }

  Future<DisplayDeviceModel?> getById(String id) async {
    final entity = await (_db.select(_db.displayDevices)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return entity == null ? null : displayDeviceFromEntity(entity);
  }

  Future<DisplayDeviceModel?> getByCode(String code) async {
    final entity = await (_db.select(_db.displayDevices)
          ..where((t) => t.code.equals(code) & t.isActive.equals(true) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return entity == null ? null : displayDeviceFromEntity(entity);
  }

  /// Narrow RPC lookup for pairing flow — returns only the fields needed.
  /// Uses SECURITY DEFINER function, no broad anon SELECT policy required.
  Future<DisplayDeviceModel?> lookupByCode(String code) async {
    if (supabaseClient == null) return null;
    try {
      final response = await supabaseClient!
          .rpc('lookup_display_device_by_code', params: {'lookup_code': code});
      if (response == null) return null;
      final json = response as Map<String, dynamic>;
      // RPC returns only fields needed for pairing; the rest are placeholders
      // not read by the pairing flow in screen_display_code.dart.
      return DisplayDeviceModel(
        id: '',
        companyId: json['company_id'] as String,
        code: code,
        name: json['name'] as String? ?? '',
        welcomeText: json['welcome_text'] as String? ?? '',
        type: DisplayDeviceType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => DisplayDeviceType.customerDisplay,
        ),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e, s) {
      AppLogger.error('Failed to lookup display device by code', error: e, stackTrace: s);
      return null;
    }
  }

  Future<List<DisplayDeviceModel>> getByParentRegister(String registerId) async {
    final entities = await (_db.select(_db.displayDevices)
          ..where((t) =>
              t.parentRegisterId.equals(registerId) &
              t.isActive.equals(true) &
              t.deletedAt.isNull()))
        .get();
    return entities.map(displayDeviceFromEntity).toList();
  }

  Stream<List<DisplayDeviceModel>> watchAll(String companyId) {
    return (_db.select(_db.displayDevices)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(displayDeviceFromEntity).toList());
  }

  Stream<List<DisplayDeviceModel>> watchByParentRegister(String registerId) {
    return (_db.select(_db.displayDevices)
          ..where((t) =>
              t.parentRegisterId.equals(registerId) &
              t.deletedAt.isNull()))
        .watch()
        .map((rows) => rows.map(displayDeviceFromEntity).toList());
  }

  Future<Result<DisplayDeviceModel>> update({
    required String id,
    required String name,
    required String welcomeText,
    required bool isActive,
  }) async {
    try {
      return await _db.transaction(() async {
        final now = DateTime.now();
        await (_db.update(_db.displayDevices)..where((t) => t.id.equals(id)))
            .write(DisplayDevicesCompanion(
          name: Value(name),
          welcomeText: Value(welcomeText),
          isActive: Value(isActive),
          updatedAt: Value(now),
        ));
        final entity = await (_db.select(_db.displayDevices)
              ..where((t) => t.id.equals(id)))
            .getSingle();
        final model = displayDeviceFromEntity(entity);
        await _enqueue('update', model);
        return Success(model);
      });
    } catch (e, s) {
      AppLogger.error('Failed to update display device', error: e, stackTrace: s);
      return Failure('Failed to update display device: $e');
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      return await _db.transaction(() async {
        final now = DateTime.now();
        await (_db.update(_db.displayDevices)..where((t) => t.id.equals(id)))
            .write(DisplayDevicesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ));
        final entity = await (_db.select(_db.displayDevices)
              ..where((t) => t.id.equals(id)))
            .getSingle();
        final model = displayDeviceFromEntity(entity);
        await _enqueue('delete', model);
        return const Success(null);
      });
    } catch (e, s) {
      AppLogger.error('Failed to delete display device', error: e, stackTrace: s);
      return Failure('Failed to delete display device: $e');
    }
  }

  Future<String> _generateUniqueCode() async {
    final rng = Random();
    for (var attempt = 0; attempt < 10; attempt++) {
      final code = (100000 + rng.nextInt(900000)).toString();
      final existing = await (_db.select(_db.displayDevices)
            ..where((t) => t.code.equals(code) & t.deletedAt.isNull()))
          .getSingleOrNull();
      if (existing == null) return code;
    }
    // Fallback: use timestamp-based code
    return DateTime.now().millisecondsSinceEpoch.toString().substring(7);
  }

  Future<void> _enqueue(String operation, DisplayDeviceModel model) async {
    if (syncQueueRepo == null) return;
    await syncQueueRepo!.enqueue(
      companyId: model.companyId,
      entityType: 'display_devices',
      entityId: model.id,
      operation: operation,
      payload: jsonEncode(displayDeviceToSupabaseJson(model)),
    );
  }
}

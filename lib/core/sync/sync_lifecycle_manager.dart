import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/mappers/entity_mappers.dart';
import '../data/mappers/supabase_mappers.dart';
import '../data/models/company_model.dart';
import '../data/repositories/base_company_scoped_repository.dart';
import '../data/repositories/company_repository.dart';
import '../data/repositories/sync_queue_repository.dart';
import '../data/result.dart';
import '../database/app_database.dart';
import '../logging/app_logger.dart';
import 'outbox_processor.dart';
import 'sync_service.dart';

class SyncLifecycleManager {
  SyncLifecycleManager({
    required OutboxProcessor outboxProcessor,
    required SyncService syncService,
    required SyncQueueRepository syncQueueRepo,
    required CompanyRepository companyRepo,
    required List<BaseCompanyScopedRepository> companyRepos,
    required AppDatabase db,
  })  : _outboxProcessor = outboxProcessor,
        _syncService = syncService,
        _syncQueueRepo = syncQueueRepo,
        _companyRepo = companyRepo,
        _companyRepos = companyRepos,
        _db = db;

  final OutboxProcessor _outboxProcessor;
  final SyncService _syncService;
  final SyncQueueRepository _syncQueueRepo;
  final CompanyRepository _companyRepo;
  final List<BaseCompanyScopedRepository> _companyRepos;
  final AppDatabase _db;

  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Future<void> start(String companyId) async {
    if (_isRunning) return;
    _isRunning = true;

    AppLogger.info('SyncLifecycleManager: starting', tag: 'SYNC');

    // Crash recovery: reset stuck processing entries
    await _syncQueueRepo.resetStuck();

    // Cleanup old completed entries
    await _syncQueueRepo.deleteCompleted();

    // Initial push: enqueue all existing entities that have never been synced
    await _initialPush(companyId);

    // Start outbox push
    _outboxProcessor.start();

    // Start pull sync
    _syncService.startAutoSync(companyId);
  }

  void stop() {
    if (!_isRunning) return;
    _isRunning = false;

    AppLogger.info('SyncLifecycleManager: stopping', tag: 'SYNC');
    _outboxProcessor.stop();
    _syncService.stop();
  }

  Future<void> _initialPush(String companyId) async {
    // Check if we already have any pending entries — skip if so
    final pending = await _syncQueueRepo.getPending(limit: 1);
    if (pending.isNotEmpty) {
      AppLogger.debug('SyncLifecycleManager: sync_queue not empty, skipping initial push', tag: 'SYNC');
      return;
    }

    // Also check if there are any completed entries (means we already did initial push)
    final hasHistory = await _syncQueueRepo.hasCompletedEntries(companyId);
    if (hasHistory) {
      AppLogger.debug('SyncLifecycleManager: completed entries exist, skipping initial push', tag: 'SYNC');
      return;
    }

    AppLogger.info('SyncLifecycleManager: initial push for existing data', tag: 'SYNC');

    // Push global reference data (no company_id)
    await _enqueueGlobalTable(
      companyId,
      'currencies',
      _db.currencies,
      (e) => currencyToSupabaseJson(currencyFromEntity(e as Currency)),
    );
    await _enqueueGlobalTable(
      companyId,
      'roles',
      _db.roles,
      (e) => roleToSupabaseJson(roleFromEntity(e as Role)),
    );
    await _enqueueGlobalTable(
      companyId,
      'permissions',
      _db.permissions,
      (e) => permissionToSupabaseJson(permissionFromEntity(e as Permission)),
    );
    await _enqueueGlobalTable(
      companyId,
      'role_permissions',
      _db.rolePermissions,
      (e) => rolePermissionToSupabaseJson(rolePermissionFromEntity(e as RolePermission)),
    );

    // Push company — RLS on child tables requires company to exist
    await _enqueueCompany(companyId);

    // Push all BaseCompanyScopedRepository child entities
    for (final repo in _companyRepos) {
      try {
        await repo.enqueueAll(companyId);
      } catch (e, s) {
        AppLogger.error(
          'Failed to enqueue existing ${repo.entityName}s',
          tag: 'SYNC',
          error: e,
          stackTrace: s,
        );
      }
    }

    // Push registers (not in companyRepos)
    await _enqueueRegisters(companyId);

    // Push user_permissions (not in companyRepos)
    await _enqueueUserPermissions(companyId);
  }

  Future<void> _enqueueCompany(String companyId) async {
    final result = await _companyRepo.getById(companyId);
    if (result case Success(value: final CompanyModel company)) {
      final json = companyToSupabaseJson(company);
      await _syncQueueRepo.enqueue(
        companyId: companyId,
        entityType: 'companies',
        entityId: companyId,
        operation: 'insert',
        payload: jsonEncode(json),
      );
      AppLogger.info('Enqueued company for initial sync', tag: 'SYNC');
    }
  }

  Future<void> _enqueueGlobalTable(
    String companyId,
    String tableName,
    TableInfo table,
    Map<String, dynamic> Function(dynamic entity) toJson,
  ) async {
    try {
      final entities = await _db.select(table).get();
      for (final entity in entities) {
        final json = toJson(entity);
        await _syncQueueRepo.enqueue(
          companyId: companyId,
          entityType: tableName,
          entityId: (entity as dynamic).id as String,
          operation: 'insert',
          payload: jsonEncode(json),
        );
      }
      AppLogger.info(
        'Enqueued ${entities.length} existing $tableName for initial sync',
        tag: 'SYNC',
      );
    } catch (e, s) {
      AppLogger.error(
        'Failed to enqueue existing $tableName',
        tag: 'SYNC',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> _enqueueRegisters(String companyId) async {
    try {
      final entities = await (_db.select(_db.registers)
            ..where((t) => t.companyId.equals(companyId)))
          .get();
      for (final entity in entities) {
        final model = registerFromEntity(entity);
        final json = registerToSupabaseJson(model);
        await _syncQueueRepo.enqueue(
          companyId: companyId,
          entityType: 'registers',
          entityId: model.id,
          operation: 'insert',
          payload: jsonEncode(json),
        );
      }
      AppLogger.info(
        'Enqueued ${entities.length} existing registers for initial sync',
        tag: 'SYNC',
      );
    } catch (e, s) {
      AppLogger.error(
        'Failed to enqueue existing registers',
        tag: 'SYNC',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> _enqueueUserPermissions(String companyId) async {
    try {
      final entities = await (_db.select(_db.userPermissions)
            ..where((t) => t.companyId.equals(companyId)))
          .get();
      for (final entity in entities) {
        final model = userPermissionFromEntity(entity);
        final json = userPermissionToSupabaseJson(model);
        await _syncQueueRepo.enqueue(
          companyId: companyId,
          entityType: 'user_permissions',
          entityId: model.id,
          operation: 'insert',
          payload: jsonEncode(json),
        );
      }
      AppLogger.info(
        'Enqueued ${entities.length} existing user_permissions for initial sync',
        tag: 'SYNC',
      );
    } catch (e, s) {
      AppLogger.error(
        'Failed to enqueue existing user_permissions',
        tag: 'SYNC',
        error: e,
        stackTrace: s,
      );
    }
  }
}

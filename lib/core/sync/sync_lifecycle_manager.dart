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
    // Check if initial push was already completed.
    // Any completed entry for this company means sync has run before.
    final hasHistory = await _syncQueueRepo.hasCompletedEntries(companyId);
    if (hasHistory) {
      AppLogger.debug('SyncLifecycleManager: initial push already completed, skipping', tag: 'SYNC');
      return;
    }

    AppLogger.info('SyncLifecycleManager: initial push for existing data', tag: 'SYNC');

    // Clear any pending/processing entries created before sync was activated.
    // They will be re-enqueued below as part of the full push in correct FK order.
    final cleared = await _syncQueueRepo.deleteAllPending();
    if (cleared > 0) {
      AppLogger.info(
        'SyncLifecycleManager: cleared $cleared pre-sync pending entries',
        tag: 'SYNC',
      );
    }

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

    // Push register_sessions
    await _enqueueCompanyTable(
      companyId,
      'register_sessions',
      _db.registerSessions,
      (e) => registerSessionToSupabaseJson(registerSessionFromEntity(e as RegisterSession)),
    );

    // Push cash_movements (depends on register_sessions)
    await _enqueueCompanyTable(
      companyId,
      'cash_movements',
      _db.cashMovements,
      (e) => cashMovementToSupabaseJson(cashMovementFromEntity(e as CashMovement)),
    );

    // Push shifts (depends on register_sessions)
    await _enqueueCompanyTable(
      companyId,
      'shifts',
      _db.shifts,
      (e) => shiftToSupabaseJson(shiftFromEntity(e as Shift)),
    );

    // Push layout_items
    await _enqueueCompanyTable(
      companyId,
      'layout_items',
      _db.layoutItems,
      (e) => layoutItemToSupabaseJson(layoutItemFromEntity(e as LayoutItem)),
    );

    // Push warehouses
    await _enqueueCompanyTable(
      companyId,
      'warehouses',
      _db.warehouses,
      (e) => warehouseToSupabaseJson(warehouseFromEntity(e as Warehouse)),
    );

    // Push stock_levels (depends on warehouses, items)
    await _enqueueCompanyTable(
      companyId,
      'stock_levels',
      _db.stockLevels,
      (e) => stockLevelToSupabaseJson(stockLevelFromEntity(e as StockLevel)),
    );

    // Push stock_documents (depends on warehouses, suppliers)
    await _enqueueCompanyTable(
      companyId,
      'stock_documents',
      _db.stockDocuments,
      (e) => stockDocumentToSupabaseJson(stockDocumentFromEntity(e as StockDocument)),
    );

    // Push stock_movements (depends on stock_documents, items)
    await _enqueueCompanyTable(
      companyId,
      'stock_movements',
      _db.stockMovements,
      (e) => stockMovementToSupabaseJson(stockMovementFromEntity(e as StockMovement)),
    );

    // Push bills
    await _enqueueCompanyTable(
      companyId,
      'bills',
      _db.bills,
      (e) => billToSupabaseJson(billFromEntity(e as Bill)),
    );

    // Push orders (depends on bills)
    await _enqueueCompanyTable(
      companyId,
      'orders',
      _db.orders,
      (e) => orderToSupabaseJson(orderFromEntity(e as Order)),
    );

    // Push order_items (depends on orders)
    await _enqueueCompanyTable(
      companyId,
      'order_items',
      _db.orderItems,
      (e) => orderItemToSupabaseJson(orderItemFromEntity(e as OrderItem)),
    );

    // Push payments (depends on bills)
    await _enqueueCompanyTable(
      companyId,
      'payments',
      _db.payments,
      (e) => paymentToSupabaseJson(paymentFromEntity(e as Payment)),
    );
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
      final entities = await (_db.select(table)
            ..where((t) => (t as dynamic).deletedAt.isNull()))
          .get();
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

  Future<void> _enqueueCompanyTable(
    String companyId,
    String tableName,
    TableInfo table,
    Map<String, dynamic> Function(dynamic entity) toJson,
  ) async {
    try {
      final entities = await (_db.select(table)
            ..where((t) => (t as dynamic).companyId.equals(companyId))
            ..where((t) => (t as dynamic).deletedAt.isNull()))
          .get();
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

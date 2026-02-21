import 'dart:async';
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
import 'broadcast_channel.dart';
import 'outbox_processor.dart';
import 'realtime_service.dart';
import 'sync_service.dart';

class SyncLifecycleManager {
  SyncLifecycleManager({
    required OutboxProcessor outboxProcessor,
    required SyncService syncService,
    required RealtimeService realtimeService,
    required SyncQueueRepository syncQueueRepo,
    required CompanyRepository companyRepo,
    required List<BaseCompanyScopedRepository> companyRepos,
    required AppDatabase db,
    BroadcastChannel? kdsBroadcastChannel,
  })  : _outboxProcessor = outboxProcessor,
        _syncService = syncService,
        _realtimeService = realtimeService,
        _syncQueueRepo = syncQueueRepo,
        _companyRepo = companyRepo,
        _companyRepos = companyRepos,
        _db = db,
        _kdsBroadcastChannel = kdsBroadcastChannel;

  final OutboxProcessor _outboxProcessor;
  final SyncService _syncService;
  final RealtimeService _realtimeService;
  final SyncQueueRepository _syncQueueRepo;
  final CompanyRepository _companyRepo;
  final List<BaseCompanyScopedRepository> _companyRepos;
  final AppDatabase _db;
  final BroadcastChannel? _kdsBroadcastChannel;

  bool _isRunning = false;
  StreamSubscription<Map<String, dynamic>>? _kdsSubscription;

  bool get isRunning => _isRunning;

  Future<void> start(String companyId) async {
    if (_isRunning) {
      AppLogger.info('SyncLifecycleManager: start() skipped — already running', tag: 'SYNC');
      return;
    }
    _isRunning = true;

    try {
      AppLogger.info('SyncLifecycleManager: starting', tag: 'SYNC');

      // Crash recovery: reset stuck processing entries
      await _syncQueueRepo.resetStuck();

      // Retry recovery: reset permanently failed entries (e.g. after schema fix)
      await _syncQueueRepo.resetFailed();

      // Cleanup old completed entries
      await _syncQueueRepo.deleteCompleted();

      // Initial push: enqueue all existing entities that have never been synced
      await _initialPush(companyId);

      // Drain all enqueued entries before starting the periodic timer.
      // Errors here must NOT prevent periodic processors from starting.
      try {
        const maxDrainIterations = 50;
        for (var i = 0; i < maxDrainIterations && _isRunning; i++) {
          final pending = await _syncQueueRepo.countPending();
          if (pending == 0) break;
          await _outboxProcessor.processQueue(limit: 500);
        }
      } catch (e, s) {
        AppLogger.error(
          'SyncLifecycleManager: drain loop failed, continuing with periodic sync',
          tag: 'SYNC',
          error: e,
          stackTrace: s,
        );
      }

      // Start outbox push (periodic timer picks up remaining/failed entries)
      _outboxProcessor.start();

      // Start pull sync (5-min polling as fallback)
      _syncService.startAutoSync(companyId);

      // Start realtime subscriptions (<2s latency)
      _realtimeService.start(companyId);

      // Subscribe to KDS broadcast for instant order delivery
      _subscribeKdsBroadcast(companyId);
    } catch (e, s) {
      _isRunning = false;
      // Stop any partially started services to prevent orphaned timers
      _stopServices();
      AppLogger.error(
        'SyncLifecycleManager: start failed, will retry on next trigger',
        tag: 'SYNC',
        error: e,
        stackTrace: s,
      );
    }
  }

  void stop() {
    if (!_isRunning) {
      // Always stop child services even if _isRunning is false.
      // Handles edge cases: catch block in start() set _isRunning=false
      // but timers are still active, or provider was recreated.
      _stopServices();
      return;
    }
    _isRunning = false;
    AppLogger.info('SyncLifecycleManager: stopping', tag: 'SYNC');
    _stopServices();
  }

  void _stopServices() {
    _kdsSubscription?.cancel();
    _kdsSubscription = null;
    _kdsBroadcastChannel?.leave();
    _realtimeService.stop();
    _outboxProcessor.stop();
    _syncService.stop();
  }

  Future<void> _subscribeKdsBroadcast(String companyId) async {
    final channel = _kdsBroadcastChannel;
    if (channel == null) return;

    await channel.join('kds:$companyId');
    _kdsSubscription = channel.stream.listen((payload) {
      _handleKdsBroadcast(companyId, payload);
    });
    AppLogger.info('SyncLifecycleManager: subscribed to KDS broadcast', tag: 'SYNC');
  }

  Future<void> _handleKdsBroadcast(
    String companyId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final action = payload['action'] as String?;
      if (action != 'new_order') return;

      final orderJson = payload['order'] as Map<String, dynamic>?;
      final itemsJson = payload['order_items'] as List?;
      if (orderJson == null) return;

      final orderId = orderJson['id'] as String?;
      if (orderId == null) return;

      AppLogger.debug(
        'SyncLifecycleManager: KDS broadcast new_order id=$orderId',
        tag: 'BROADCAST',
      );

      await _syncService.mergeRow(companyId, 'orders', orderId, orderJson);

      if (itemsJson != null) {
        for (final item in itemsJson) {
          final itemMap = item as Map<String, dynamic>;
          final itemId = itemMap['id'] as String?;
          if (itemId != null) {
            await _syncService.mergeRow(companyId, 'order_items', itemId, itemMap);
          }
        }
      }
    } catch (e, s) {
      AppLogger.error(
        'SyncLifecycleManager: failed to process KDS broadcast',
        tag: 'BROADCAST',
        error: e,
        stackTrace: s,
      );
    }
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

    // Remaining tables not in companyRepos — order matches tableDependencyOrder.

    // Push user_permissions (11)
    await _enqueueUserPermissions(companyId);

    // Push registers (18)
    await _enqueueRegisters(companyId);

    // Push display_devices (19, depends on registers)
    await _enqueueCompanyTable(
      companyId,
      'display_devices',
      _db.displayDevices,
      (e) => displayDeviceToSupabaseJson(displayDeviceFromEntity(e as DisplayDevice)),
    );

    // Push layout_items (20)
    await _enqueueCompanyTable(
      companyId,
      'layout_items',
      _db.layoutItems,
      (e) => layoutItemToSupabaseJson(layoutItemFromEntity(e as LayoutItem)),
    );

    // Push bills (24)
    await _enqueueCompanyTable(
      companyId,
      'bills',
      _db.bills,
      (e) => billToSupabaseJson(billFromEntity(e as Bill)),
    );

    // Push orders (25, depends on bills)
    await _enqueueCompanyTable(
      companyId,
      'orders',
      _db.orders,
      (e) => orderToSupabaseJson(orderFromEntity(e as Order)),
    );

    // Push order_items (26, depends on orders)
    await _enqueueCompanyTable(
      companyId,
      'order_items',
      _db.orderItems,
      (e) => orderItemToSupabaseJson(orderItemFromEntity(e as OrderItem)),
    );

    // Push order_item_modifiers (27, depends on order_items + modifier_groups)
    await _enqueueCompanyTable(
      companyId,
      'order_item_modifiers',
      _db.orderItemModifiers,
      (e) => orderItemModifierToSupabaseJson(orderItemModifierFromEntity(e as OrderItemModifier)),
    );

    // Push payments (28, depends on bills)
    await _enqueueCompanyTable(
      companyId,
      'payments',
      _db.payments,
      (e) => paymentToSupabaseJson(paymentFromEntity(e as Payment)),
    );

    // Push register_sessions (28)
    await _enqueueCompanyTable(
      companyId,
      'register_sessions',
      _db.registerSessions,
      (e) => registerSessionToSupabaseJson(registerSessionFromEntity(e as RegisterSession)),
    );

    // Push cash_movements (29, depends on register_sessions)
    await _enqueueCompanyTable(
      companyId,
      'cash_movements',
      _db.cashMovements,
      (e) => cashMovementToSupabaseJson(cashMovementFromEntity(e as CashMovement)),
    );

    // Push shifts (30, depends on register_sessions)
    await _enqueueCompanyTable(
      companyId,
      'shifts',
      _db.shifts,
      (e) => shiftToSupabaseJson(shiftFromEntity(e as Shift)),
    );

    // Push stock_levels (33, depends on warehouses, items)
    await _enqueueCompanyTable(
      companyId,
      'stock_levels',
      _db.stockLevels,
      (e) => stockLevelToSupabaseJson(stockLevelFromEntity(e as StockLevel)),
    );

    // Push stock_documents (34, depends on warehouses, suppliers)
    await _enqueueCompanyTable(
      companyId,
      'stock_documents',
      _db.stockDocuments,
      (e) => stockDocumentToSupabaseJson(stockDocumentFromEntity(e as StockDocument)),
    );

    // Push stock_movements (35, depends on stock_documents, items)
    await _enqueueCompanyTable(
      companyId,
      'stock_movements',
      _db.stockMovements,
      (e) => stockMovementToSupabaseJson(stockMovementFromEntity(e as StockMovement)),
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

  Future<void> _enqueueCompanyTable(
    String companyId,
    String tableName,
    TableInfo table,
    Map<String, dynamic> Function(dynamic entity) toJson,
  ) async {
    try {
      final entities = await (_db.select(table)
            ..where((t) {
              final d = t as dynamic;
              return (d.companyId as GeneratedColumn<String>).equals(companyId) &
                  (d.deletedAt as GeneratedColumn).isNull();
            }))
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

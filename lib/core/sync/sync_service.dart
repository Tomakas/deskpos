import 'dart:async';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/mappers/supabase_pull_mappers.dart';
import '../data/repositories/sync_metadata_repository.dart';
import '../data/repositories/sync_queue_repository.dart';
import '../database/app_database.dart';
import '../logging/app_logger.dart';

class SyncService {
  SyncService({
    required SyncMetadataRepository syncMetadataRepo,
    required SyncQueueRepository syncQueueRepo,
    required SupabaseClient supabaseClient,
    required AppDatabase db,
  })  : _syncMetadataRepo = syncMetadataRepo,
        _syncQueueRepo = syncQueueRepo,
        _supabase = supabaseClient,
        _db = db;

  final SyncMetadataRepository _syncMetadataRepo;
  final SyncQueueRepository _syncQueueRepo;
  final SupabaseClient _supabase;
  final AppDatabase _db;

  Timer? _pullTimer;
  bool _isPulling = false;
  int _pullVersion = 0;
  static const _pullInterval = Duration(minutes: 5);

  // Global tables have no company_id — pull all rows without filter
  static const _globalTables = {
    'currencies',
    'roles',
    'permissions',
    'role_permissions',
  };

  // Table order respects FK dependencies (used for both pull and push).
  static const tableDependencyOrder = [
    'currencies',
    'companies',
    'company_settings',
    'roles',
    'permissions',
    'role_permissions',
    'sections',
    'tax_rates',
    'payment_methods',
    'categories',
    'users',
    'user_permissions',
    'tables',
    'map_elements',
    'suppliers',
    'manufacturers',
    'items',
    'product_recipes',
    'registers',
    'display_devices',
    'layout_items',
    'customers',
    'reservations',
    'warehouses',
    'bills',
    'orders',
    'order_items',
    'payments',
    'register_sessions',
    'cash_movements',
    'shifts',
    'customer_transactions',
    'vouchers',
    'stock_levels',
    'stock_documents',
    'stock_movements',
  ];

  void startAutoSync(String companyId) {
    stop();
    AppLogger.info('SyncService: starting auto-sync', tag: 'SYNC');
    // Immediate first pull
    pullAll(companyId);
    _pullTimer = Timer.periodic(_pullInterval, (_) => pullAll(companyId));
  }

  void stop() {
    _pullTimer?.cancel();
    _pullTimer = null;
    _pullVersion++;
    _isPulling = false;
  }

  Future<void> pullAll(String companyId) async {
    if (_isPulling) return;
    _isPulling = true;
    final version = _pullVersion;
    try {
      AppLogger.debug('SyncService: pulling all tables', tag: 'SYNC');
      for (final tableName in tableDependencyOrder) {
        if (_pullVersion != version) {
          AppLogger.info('SyncService: pull cancelled', tag: 'SYNC');
          break;
        }
        try {
          await pullTable(companyId, tableName);
        } catch (e, s) {
          AppLogger.error(
            'SyncService: failed to pull $tableName',
            tag: 'SYNC',
            error: e,
            stackTrace: s,
          );
        }
      }
    } finally {
      _isPulling = false;
    }
  }

  Future<void> pullTable(String companyId, String tableName) async {
    final lastPulledAt = await _syncMetadataRepo.getLastPulledAt(companyId, tableName);

    // Global tables: no company filter. Companies: filter by id. Others: filter by company_id.
    var query = _supabase.from(tableName).select();
    if (tableName == 'companies') {
      query = query.eq('id', companyId);
    } else if (!_globalTables.contains(tableName)) {
      query = query.eq('company_id', companyId);
    }

    if (lastPulledAt != null) {
      query = query.gt('updated_at', lastPulledAt.toUtc().toIso8601String());
    }

    final rows = await query.order('updated_at', ascending: true) as List<dynamic>;

    if (rows.isEmpty) return;

    AppLogger.debug('SyncService: pulled ${rows.length} rows from $tableName', tag: 'SYNC');

    DateTime? maxUpdatedAt;

    for (final row in rows) {
      final json = row as Map<String, dynamic>;
      final entityId = extractId(json);
      final serverUpdatedAt = extractServerUpdatedAt(json);

      if (maxUpdatedAt == null || serverUpdatedAt.isAfter(maxUpdatedAt)) {
        maxUpdatedAt = serverUpdatedAt;
      }

      await mergeRow(companyId, tableName, entityId, json);
    }

    if (maxUpdatedAt != null) {
      await _syncMetadataRepo.setLastPulledAt(companyId, tableName, maxUpdatedAt);
    }
  }

  /// Merge a single row from Supabase (pull or realtime) into local DB using LWW.
  Future<void> mergeRow(
    String companyId,
    String tableName,
    String entityId,
    Map<String, dynamic> json,
  ) async {
    final Insertable companion;
    try {
      companion = fromSupabasePull(tableName, json);
    } catch (e, s) {
      AppLogger.error(
        'SyncService: failed to parse $tableName/$entityId, skipping row',
        tag: 'SYNC',
        error: e,
        stackTrace: s,
      );
      return;
    }
    final driftTable = _getDriftTable(tableName);

    // Check if entity exists locally
    final existing = await (
      _db.select(driftTable)
        ..where((t) => (t as dynamic).id.equals(entityId))
    ).getSingleOrNull();

    if (existing == null) {
      // Entity not in local DB -> INSERT (or update if a concurrent mergeRow already inserted)
      await _db.into(driftTable).insertOnConflictUpdate(companion);
      return;
    }

    // Entity exists — check for pending outbox entries
    final hasPending = await _syncQueueRepo.hasPendingForEntity(tableName, entityId);

    if (!hasPending) {
      // No pending outbox entries -> overwrite with remote
      await (_db.update(driftTable)
            ..where((t) => (t as dynamic).id.equals(entityId)))
          .write(companion);
      return;
    }

    // Has pending outbox entries -> LWW compare client_updated_at
    final remoteUpdatedAt = extractClientUpdatedAt(json);
    final localUpdatedAt = (existing as dynamic).updatedAt as DateTime;

    if (remoteUpdatedAt != null && remoteUpdatedAt.isAfter(localUpdatedAt)) {
      // Remote is newer — overwrite
      await (_db.update(driftTable)
            ..where((t) => (t as dynamic).id.equals(entityId)))
          .write(companion);
    }
    // else: local is newer or equal — skip (outbox will push local version)
  }

  TableInfo _getDriftTable(String tableName) => switch (tableName) {
    'currencies' => _db.currencies,
    'companies' => _db.companies,
    'company_settings' => _db.companySettings,
    'roles' => _db.roles,
    'permissions' => _db.permissions,
    'role_permissions' => _db.rolePermissions,
    'sections' => _db.sections,
    'categories' => _db.categories,
    'items' => _db.items,
    'suppliers' => _db.suppliers,
    'manufacturers' => _db.manufacturers,
    'customers' => _db.customers,
    'reservations' => _db.reservations,
    'customer_transactions' => _db.customerTransactions,
    'product_recipes' => _db.productRecipes,
    'tables' => _db.tables,
    'map_elements' => _db.mapElements,
    'payment_methods' => _db.paymentMethods,
    'tax_rates' => _db.taxRates,
    'users' => _db.users,
    'user_permissions' => _db.userPermissions,
    'registers' => _db.registers,
    'register_sessions' => _db.registerSessions,
    'layout_items' => _db.layoutItems,
    'bills' => _db.bills,
    'orders' => _db.orders,
    'order_items' => _db.orderItems,
    'payments' => _db.payments,
    'cash_movements' => _db.cashMovements,
    'shifts' => _db.shifts,
    'warehouses' => _db.warehouses,
    'vouchers' => _db.vouchers,
    'stock_levels' => _db.stockLevels,
    'stock_documents' => _db.stockDocuments,
    'stock_movements' => _db.stockMovements,
    'display_devices' => _db.displayDevices,
    _ => throw ArgumentError('Unknown Drift table: $tableName'),
  };
}

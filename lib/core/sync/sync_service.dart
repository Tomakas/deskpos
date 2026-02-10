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
  static const _pullInterval = Duration(minutes: 5);

  // Pull order respects FK dependencies
  static const _pullTables = [
    'companies',
    'sections',
    'tax_rates',
    'payment_methods',
    'categories',
    'users',
    'tables',
    'items',
    'bills',
    'orders',
    'order_items',
    'payments',
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
  }

  Future<void> pullAll(String companyId) async {
    AppLogger.debug('SyncService: pulling all tables', tag: 'SYNC');
    for (final tableName in _pullTables) {
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
  }

  Future<void> pullTable(String companyId, String tableName) async {
    final lastPulledAt = await _syncMetadataRepo.getLastPulledAt(companyId, tableName);

    // companies uses 'id', all others use 'company_id'
    final idColumn = tableName == 'companies' ? 'id' : 'company_id';
    var query = _supabase
        .from(tableName)
        .select()
        .eq(idColumn, companyId);

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

      await _mergeRow(companyId, tableName, entityId, json);
    }

    if (maxUpdatedAt != null) {
      await _syncMetadataRepo.setLastPulledAt(companyId, tableName, maxUpdatedAt);
    }
  }

  Future<void> _mergeRow(
    String companyId,
    String tableName,
    String entityId,
    Map<String, dynamic> json,
  ) async {
    final companion = fromSupabasePull(tableName, json);
    final driftTable = _getDriftTable(tableName);

    // Check if entity exists locally
    final existing = await (
      _db.select(driftTable)
        ..where((t) => (t as dynamic).id.equals(entityId))
    ).getSingleOrNull();

    if (existing == null) {
      // Entity not in local DB -> INSERT
      await _db.into(driftTable).insert(companion);
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

  TableInfo _getDriftTable(String tableName) {
    switch (tableName) {
      case 'companies':
        return _db.companies;
      case 'sections':
        return _db.sections;
      case 'categories':
        return _db.categories;
      case 'items':
        return _db.items;
      case 'tables':
        return _db.tables;
      case 'payment_methods':
        return _db.paymentMethods;
      case 'tax_rates':
        return _db.taxRates;
      case 'users':
        return _db.users;
      case 'bills':
        return _db.bills;
      case 'orders':
        return _db.orders;
      case 'order_items':
        return _db.orderItems;
      case 'payments':
        return _db.payments;
      default:
        throw ArgumentError('Unknown Drift table: $tableName');
    }
  }
}

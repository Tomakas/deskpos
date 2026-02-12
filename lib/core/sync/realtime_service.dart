import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/mappers/supabase_pull_mappers.dart';
import '../logging/app_logger.dart';
import 'sync_service.dart';

/// Subscribes to Supabase Realtime PostgresChanges for company-scoped tables.
/// When a change arrives, delegates to [SyncService.mergeRow] for LWW merge.
/// The 5-min polling in SyncService remains as a fallback.
class RealtimeService {
  RealtimeService({
    required SupabaseClient supabaseClient,
    required SyncService syncService,
  })  : _supabase = supabaseClient,
        _syncService = syncService;

  final SupabaseClient _supabase;
  final SyncService _syncService;

  RealtimeChannel? _channel;
  bool _wasSubscribed = false;

  /// Company-scoped tables to subscribe to.
  /// Excludes global tables (currencies, roles, permissions, role_permissions)
  /// and low-frequency tables (suppliers, manufacturers, product_recipes,
  /// warehouses, stock_*, vouchers, customer_transactions) to reduce overhead.
  static const _realtimeTables = [
    'companies',
    'company_settings',
    'sections',
    'tax_rates',
    'payment_methods',
    'categories',
    'users',
    'user_permissions',
    'tables',
    'map_elements',
    'items',
    'registers',
    'layout_items',
    'customers',
    'reservations',
    'bills',
    'orders',
    'order_items',
    'payments',
    'register_sessions',
    'cash_movements',
    'shifts',
  ];

  void start(String companyId) {
    stop();
    _wasSubscribed = false;
    AppLogger.info(
      'RealtimeService: subscribing to ${_realtimeTables.length} tables',
      tag: 'REALTIME',
    );

    var channel = _supabase.channel('sync-$companyId');

    for (final tableName in _realtimeTables) {
      final filterColumn = tableName == 'companies' ? 'id' : 'company_id';
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: tableName,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: filterColumn,
          value: companyId,
        ),
        callback: (payload) => _handleChange(companyId, tableName, payload),
      );
    }

    channel.subscribe((status, [error]) {
      AppLogger.info('RealtimeService: channel status=$status', tag: 'REALTIME');
      if (error != null) {
        AppLogger.error('RealtimeService: channel error', tag: 'REALTIME', error: error);
      }
      // On reconnect, trigger immediate pull to catch events missed during disconnection
      if (status == RealtimeSubscribeStatus.subscribed) {
        if (_wasSubscribed) {
          AppLogger.info('RealtimeService: reconnected, triggering immediate pull', tag: 'REALTIME');
          _syncService.pullAll(companyId);
        }
        _wasSubscribed = true;
      }
    });

    _channel = channel;
  }

  void stop() {
    if (_channel != null) {
      _supabase.removeChannel(_channel!);
      _channel = null;
      AppLogger.info('RealtimeService: unsubscribed', tag: 'REALTIME');
    }
  }

  void _handleChange(
    String companyId,
    String tableName,
    PostgresChangePayload payload,
  ) {
    _processChange(companyId, tableName, payload);
  }

  Future<void> _processChange(
    String companyId,
    String tableName,
    PostgresChangePayload payload,
  ) async {
    try {
      final json = payload.newRecord;
      if (json.isEmpty) {
        // Hard DELETE — our system uses soft deletes, so this is unexpected.
        return;
      }

      final entityId = extractId(json);
      AppLogger.debug(
        'RealtimeService: $tableName ${payload.eventType} id=$entityId',
        tag: 'REALTIME',
      );

      await _syncService.mergeRow(companyId, tableName, entityId, json);
    } catch (e, s) {
      AppLogger.error(
        'RealtimeService: failed to process $tableName event',
        tag: 'REALTIME',
        error: e,
        stackTrace: s,
      );
    }
  }
}

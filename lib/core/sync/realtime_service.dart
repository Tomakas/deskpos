import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/mappers/supabase_pull_mappers.dart';
import '../logging/app_logger.dart';
import 'sync_service.dart';

/// Subscribes to Supabase Broadcast from Database for company-scoped tables.
/// Server-side triggers on 36 tables fire realtime.send() into channel
/// sync:{companyId}. When a broadcast arrives, delegates to
/// [SyncService.mergeRow] for LWW merge.
/// The 30s polling in SyncService remains as a fallback.
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
  String? _companyId;
  Timer? _reconnectTimer;

  void start(String companyId) {
    stop();
    _companyId = companyId;
    _wasSubscribed = false;
    AppLogger.info(
      'RealtimeService: subscribing to sync:$companyId',
      tag: 'REALTIME',
    );

    _channel = _supabase
        .channel('sync:$companyId')
        .onBroadcast(
          event: 'change',
          callback: (payload) => _handleBroadcast(companyId, payload),
        )
        .subscribe((status, [error]) {
      AppLogger.info('RealtimeService: channel status=$status', tag: 'REALTIME');
      if (error != null) {
        AppLogger.error('RealtimeService: channel error', tag: 'REALTIME', error: error);
      }
      if (status == RealtimeSubscribeStatus.subscribed) {
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
        if (_wasSubscribed) {
          AppLogger.info('RealtimeService: reconnected, triggering immediate pull', tag: 'REALTIME');
          _syncService.pullAll(companyId);
        }
        _wasSubscribed = true;
      }
      if (status == RealtimeSubscribeStatus.channelError ||
          status == RealtimeSubscribeStatus.timedOut) {
        _scheduleReconnect();
      }
    });
  }

  void stop() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    if (_channel != null) {
      _supabase.removeChannel(_channel!);
      _channel = null;
      AppLogger.info('RealtimeService: unsubscribed', tag: 'REALTIME');
    }
    _companyId = null;
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive ?? false) return;
    if (_companyId == null) return;
    AppLogger.info('RealtimeService: scheduling reconnect in 10s', tag: 'REALTIME');
    _reconnectTimer = Timer(const Duration(seconds: 10), () {
      final companyId = _companyId;
      if (companyId == null) return;
      final wasSubscribed = _wasSubscribed;
      AppLogger.info('RealtimeService: reconnecting...', tag: 'REALTIME');
      stop();
      _wasSubscribed = wasSubscribed;
      start(companyId);
    });
  }

  Future<void> _handleBroadcast(
    String companyId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final tableName = payload['table'] as String?;
      final record = payload['record'] as Map<String, dynamic>?;
      if (tableName == null || record == null || record.isEmpty) return;

      final entityId = extractId(record);
      AppLogger.debug(
        'RealtimeService: broadcast $tableName id=$entityId',
        tag: 'REALTIME',
      );

      await _syncService.mergeRow(companyId, tableName, entityId, record);
    } catch (e, s) {
      AppLogger.error(
        'RealtimeService: failed to process broadcast',
        tag: 'REALTIME',
        error: e,
        stackTrace: s,
      );
    }
  }
}

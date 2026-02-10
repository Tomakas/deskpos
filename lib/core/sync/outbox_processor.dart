import 'dart:async';
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/sync_queue_repository.dart';
import '../logging/app_logger.dart';

class OutboxProcessor {
  OutboxProcessor({
    required SyncQueueRepository syncQueueRepo,
    required SupabaseClient supabaseClient,
  })  : _syncQueueRepo = syncQueueRepo,
        _supabaseClient = supabaseClient;

  final SyncQueueRepository _syncQueueRepo;
  final SupabaseClient _supabaseClient;

  Timer? _timer;
  bool _isProcessing = false;

  static const _interval = Duration(seconds: 5);
  static const _maxRetries = 10;

  void start() {
    stop();
    _timer = Timer.periodic(_interval, (_) => processQueue());
    AppLogger.info('OutboxProcessor started', tag: 'SYNC');
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    AppLogger.info('OutboxProcessor stopped', tag: 'SYNC');
  }

  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final entries = await _syncQueueRepo.getPending();
      if (entries.isEmpty) return;

      AppLogger.debug('Processing ${entries.length} outbox entries', tag: 'SYNC');

      for (final entry in entries) {
        await _processEntry(entry);
      }
    } catch (e, s) {
      AppLogger.error('OutboxProcessor error', tag: 'SYNC', error: e, stackTrace: s);
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _processEntry(dynamic entry) async {
    try {
      await _syncQueueRepo.markProcessing(entry.id as String);

      final payload = jsonDecode(entry.payload as String) as Map<String, dynamic>;
      final entityType = entry.entityType as String;
      final operation = entry.operation as String;

      if (operation == 'delete') {
        // Soft delete: upsert with deleted_at set
        await _supabaseClient.from(entityType).upsert(payload, onConflict: 'id');
      } else {
        // insert or update: upsert
        await _supabaseClient.from(entityType).upsert(payload, onConflict: 'id');
      }

      await _syncQueueRepo.markCompleted(entry.id as String);
      AppLogger.debug('Pushed $operation $entityType/${entry.entityId}', tag: 'SYNC');
    } on PostgrestException catch (e) {
      await _handleError(entry, e.message, _isPermanentError(e));
    } on AuthException catch (e) {
      await _handleError(entry, e.message, true);
    } catch (e) {
      // Network or transient error
      await _handleError(entry, e.toString(), false);
    }
  }

  bool _isPermanentError(PostgrestException e) {
    final code = e.code;
    if (code == null) return false;
    // 4xx-level Postgres errors (constraint violations, etc.)
    return code.startsWith('2') || // e.g. 23xxx unique/fk violations
        code == 'PGRST' ||
        code == '42'; // syntax/access errors
  }

  Future<void> _handleError(dynamic entry, String error, bool permanent) async {
    final id = entry.id as String;
    final retryCount = entry.retryCount as int;

    if (permanent || retryCount >= _maxRetries) {
      await _syncQueueRepo.markFailed(id, error);
      AppLogger.error(
        'Outbox entry $id permanently failed: $error',
        tag: 'SYNC',
      );
    } else {
      await _syncQueueRepo.incrementRetry(id, error);
      AppLogger.warn(
        'Outbox entry $id retry ${retryCount + 1}: $error',
        tag: 'SYNC',
      );
    }
  }
}

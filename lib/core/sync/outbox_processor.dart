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
  DateTime? _lastCleanup;

  static const _interval = Duration(seconds: 5);
  static const _cleanupInterval = Duration(hours: 1);
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
      // Periodic cleanup of completed entries
      final now = DateTime.now();
      if (_lastCleanup == null || now.difference(_lastCleanup!) >= _cleanupInterval) {
        await _syncQueueRepo.deleteCompleted();
        _lastCleanup = now;
      }

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

      // Route all writes through the ingest Edge Function.
      // The EF validates JWT, verifies company ownership, writes via
      // service_role (bypassing RLS), and logs to audit_log.
      final response = await _supabaseClient.functions.invoke(
        'ingest',
        body: {
          'table': entityType,
          'operation': operation,
          'payload': payload,
          'idempotency_key': entry.idempotencyKey as String,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['ok'] == true) {
          await _syncQueueRepo.markCompleted(entry.id as String);
          AppLogger.debug('Pushed $operation $entityType/${entry.entityId}', tag: 'SYNC');
        } else {
          final errorType = data['error_type'] as String? ?? 'unknown';
          final message = data['message'] as String? ?? errorType;

          if (errorType == 'lww_conflict') {
            await _syncQueueRepo.markCompleted(entry.id as String);
            AppLogger.info(
              'LWW conflict for $entityType/${entry.entityId} — marked completed',
              tag: 'SYNC',
            );
          } else if (errorType == 'permanent' || errorType == 'rejected') {
            await _handleError(entry, message, true);
          } else {
            // transient — retry
            await _handleError(entry, message, false);
          }
        }
      } else {
        // Unexpected response format — treat as transient
        await _handleError(entry, 'Unexpected EF response: $data', false);
      }
    } on FunctionException catch (e) {
      // EF returned 500 or network error — transient, retry
      await _handleError(entry, 'EF error: ${e.reasonPhrase ?? e.toString()}', false);
    } on AuthException catch (e) {
      await _handleError(entry, e.message, true);
    } catch (e) {
      // Network or other transient error
      await _handleError(entry, e.toString(), false);
    }
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

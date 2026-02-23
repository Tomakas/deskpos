import 'dart:async';
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../data/repositories/sync_queue_repository.dart';
import '../logging/app_logger.dart';
import 'sync_service.dart';

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
  DateTime? _processingStartedAt;

  static const _interval = Duration(seconds: 5);
  static const _cleanupInterval = Duration(hours: 1);
  static const _maxRetries = 10;
  static const _stuckTimeout = Duration(seconds: 60);

  void start() {
    stop();
    _isProcessing = false;
    _processingStartedAt = null;
    // Reset previously failed entries so they get retried with correct ordering.
    _syncQueueRepo.resetFailed();
    _timer = Timer.periodic(_interval, (_) => processQueue());
    AppLogger.info('OutboxProcessor started', tag: 'SYNC');
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    AppLogger.info('OutboxProcessor stopped', tag: 'SYNC');
  }

  /// Trigger immediate queue processing (called when new entry is enqueued).
  /// Runs processQueue in the root Zone to avoid inheriting Drift transaction
  /// context when enqueue() is called inside _db.transaction().
  void nudge() {
    if (_timer != null && !_isProcessing) {
      AppLogger.info('OutboxProcessor: nudge → processQueue', tag: 'SYNC');
      Zone.root.run(() => Timer.run(() => processQueue()));
    }
  }

  Future<void> processQueue({int limit = 50}) async {
    // Watchdog: reset stuck _isProcessing flag
    if (_isProcessing && _processingStartedAt != null) {
      final elapsed = DateTime.now().difference(_processingStartedAt!);
      if (elapsed > _stuckTimeout) {
        AppLogger.warn(
          'OutboxProcessor: _isProcessing stuck for ${elapsed.inSeconds}s, resetting',
          tag: 'SYNC',
        );
        _isProcessing = false;
        _processingStartedAt = null;
      }
    }

    if (_isProcessing) return;
    _isProcessing = true;
    _processingStartedAt = DateTime.now();

    try {
      // Periodic cleanup of completed entries
      final now = DateTime.now();
      if (_lastCleanup == null || now.difference(_lastCleanup!) >= _cleanupInterval) {
        await _syncQueueRepo.deleteCompleted();
        _lastCleanup = now;
      }

      final entries = await _syncQueueRepo.getPending(limit: limit);
      if (entries.isEmpty) return;

      // Sort by FK dependency order so parent rows are pushed before children.
      final order = SyncService.tableDependencyOrder;
      entries.sort((a, b) {
        final ia = order.indexOf(a.entityType);
        final ib = order.indexOf(b.entityType);
        // Unknown tables go last; within the same table keep createdAt order.
        return (ia == -1 ? 999 : ia).compareTo(ib == -1 ? 999 : ib);
      });

      AppLogger.info('Processing ${entries.length} outbox entries', tag: 'SYNC');

      for (final entry in entries) {
        await _processEntry(entry);
      }
    } catch (e, s) {
      AppLogger.error('OutboxProcessor error', tag: 'SYNC', error: e, stackTrace: s);
    } finally {
      _isProcessing = false;
      _processingStartedAt = null;
    }
  }

  Future<void> _processEntry(SyncQueueData entry) async {
    try {
      await _syncQueueRepo.markProcessing(entry.id);

      final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
      final entityType = entry.entityType;
      final operation = entry.operation;

      // Route all writes through the ingest Edge Function.
      // The EF validates JWT, verifies company ownership, writes via
      // service_role (bypassing RLS), and logs to audit_log.
      final response = await _supabaseClient.functions.invoke(
        'ingest',
        body: {
          'table': entityType,
          'operation': operation,
          'payload': payload,
          'idempotency_key': entry.idempotencyKey,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['ok'] == true) {
          await _syncQueueRepo.markCompleted(entry.id);
          AppLogger.info('Pushed $operation $entityType/${entry.entityId}', tag: 'SYNC');
        } else {
          final errorType = data['error_type'] as String? ?? 'unknown';
          final message = data['message'] as String? ?? errorType;

          if (errorType == 'lww_conflict') {
            await _syncQueueRepo.markCompleted(entry.id);
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
    } on FunctionException catch (e, s) {
      // EF returned 500 or network error — transient, retry
      await _handleError(entry, 'EF error: ${e.reasonPhrase ?? e.toString()}', false, s);
    } on AuthException catch (e, s) {
      await _handleError(entry, e.message, true, s);
    } catch (e, s) {
      // Network or other transient error
      AppLogger.error('Outbox unexpected error: $e', error: e, stackTrace: s, tag: 'SYNC');
      await _handleError(entry, e.toString(), false);
    }
  }

  Future<void> _handleError(SyncQueueData entry, String error, bool permanent, [StackTrace? stackTrace]) async {
    final id = entry.id;
    final retryCount = entry.retryCount;

    if (permanent || retryCount >= _maxRetries) {
      await _syncQueueRepo.markFailed(id, error);
      AppLogger.error(
        'Outbox entry $id permanently failed: $error',
        tag: 'SYNC',
        stackTrace: stackTrace,
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

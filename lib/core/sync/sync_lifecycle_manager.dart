import 'dart:convert';

import '../data/mappers/supabase_mappers.dart';
import '../data/models/company_model.dart';
import '../data/repositories/base_company_scoped_repository.dart';
import '../data/repositories/company_repository.dart';
import '../data/repositories/sync_queue_repository.dart';
import '../data/result.dart';
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
  })  : _outboxProcessor = outboxProcessor,
        _syncService = syncService,
        _syncQueueRepo = syncQueueRepo,
        _companyRepo = companyRepo,
        _companyRepos = companyRepos;

  final OutboxProcessor _outboxProcessor;
  final SyncService _syncService;
  final SyncQueueRepository _syncQueueRepo;
  final CompanyRepository _companyRepo;
  final List<BaseCompanyScopedRepository> _companyRepos;

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

    // Push company FIRST — RLS on child tables requires company to exist
    await _enqueueCompany(companyId);

    // Then push all child entities
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
}

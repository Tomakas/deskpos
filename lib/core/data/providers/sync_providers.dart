import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/supabase_auth_service.dart';
import '../../sync/outbox_processor.dart';
import '../../sync/sync_lifecycle_manager.dart';
import '../../sync/sync_service.dart';
import 'auth_providers.dart';
import 'database_provider.dart';
import 'repository_providers.dart';

// --- Auth ---

final supabaseAuthServiceProvider = Provider<SupabaseAuthService>((ref) {
  return SupabaseAuthService(Supabase.instance.client);
});

final supabaseAuthStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseAuthServiceProvider).authStateChanges;
});

final isSupabaseAuthenticatedProvider = Provider<bool>((ref) {
  // Watch the auth state stream so this recomputes on sign in/out
  ref.watch(supabaseAuthStateProvider);
  return ref.watch(supabaseAuthServiceProvider).isAuthenticated;
});

// --- Sync engine ---

final outboxProcessorProvider = Provider<OutboxProcessor>((ref) {
  return OutboxProcessor(
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
    supabaseClient: Supabase.instance.client,
  );
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    syncMetadataRepo: ref.watch(syncMetadataRepositoryProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
    supabaseClient: Supabase.instance.client,
    db: ref.watch(appDatabaseProvider),
  );
});

final syncLifecycleManagerProvider = Provider<SyncLifecycleManager>((ref) {
  final manager = SyncLifecycleManager(
    outboxProcessor: ref.watch(outboxProcessorProvider),
    syncService: ref.watch(syncServiceProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
    companyRepo: ref.watch(companyRepositoryProvider),
    companyRepos: [
      ref.watch(sectionRepositoryProvider),
      ref.watch(categoryRepositoryProvider),
      ref.watch(itemRepositoryProvider),
      ref.watch(tableRepositoryProvider),
      ref.watch(paymentMethodRepositoryProvider),
      ref.watch(taxRateRepositoryProvider),
      ref.watch(userRepositoryProvider),
    ],
    db: ref.watch(appDatabaseProvider),
  );
  ref.onDispose(() => manager.stop());
  return manager;
});

// --- Sync lifecycle watcher ---
// Watch this provider from the app root to auto-start/stop sync.

final syncLifecycleWatcherProvider = Provider<void>((ref) {
  final isAuthenticated = ref.watch(isSupabaseAuthenticatedProvider);
  final company = ref.watch(currentCompanyProvider);
  final manager = ref.watch(syncLifecycleManagerProvider);

  if (isAuthenticated && company != null && company.authUserId != null) {
    manager.start(company.id);
  } else {
    manager.stop();
  }
});

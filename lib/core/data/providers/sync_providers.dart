import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide BroadcastChannel;

import '../../auth/supabase_auth_service.dart';
import '../../logging/app_logger.dart';
import '../../sync/broadcast_channel.dart';
import '../../sync/outbox_processor.dart';
import '../../sync/realtime_service.dart';
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

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  return RealtimeService(
    supabaseClient: Supabase.instance.client,
    syncService: ref.watch(syncServiceProvider),
  );
});

final syncLifecycleManagerProvider = Provider<SyncLifecycleManager>((ref) {
  final manager = SyncLifecycleManager(
    outboxProcessor: ref.watch(outboxProcessorProvider),
    syncService: ref.watch(syncServiceProvider),
    realtimeService: ref.watch(realtimeServiceProvider),
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
    companyRepo: ref.watch(companyRepositoryProvider),
    kdsBroadcastChannel: ref.watch(kdsBroadcastChannelProvider),
    // Order matches tableDependencyOrder (FK parents before children).
    companyRepos: [
      ref.watch(companySettingsRepositoryProvider),    // company_settings (2)
      ref.watch(sectionRepositoryProvider),            // sections (6)
      ref.watch(taxRateRepositoryProvider),            // tax_rates (7)
      ref.watch(paymentMethodRepositoryProvider),      // payment_methods (8)
      ref.watch(categoryRepositoryProvider),           // categories (9)
      ref.watch(userRepositoryProvider),               // users (10)
      ref.watch(tableRepositoryProvider),              // tables (12)
      ref.watch(mapElementRepositoryProvider),         // map_elements (13)
      ref.watch(supplierRepositoryProvider),           // suppliers (14)
      ref.watch(manufacturerRepositoryProvider),       // manufacturers (15)
      ref.watch(itemRepositoryProvider),               // items (16)
      ref.watch(modifierGroupRepositoryProvider),      // modifier_groups (17)
      ref.watch(modifierGroupItemRepositoryProvider),  // modifier_group_items (18)
      ref.watch(itemModifierGroupRepositoryProvider),  // item_modifier_groups (19)
      ref.watch(productRecipeRepositoryProvider),      // product_recipes (20)
      ref.watch(customerRepositoryProvider),           // customers (21)
      ref.watch(reservationRepositoryProvider),        // reservations (22)
      ref.watch(warehouseRepositoryProvider),          // warehouses (23)
      ref.watch(customerTransactionRepositoryProvider),// customer_transactions (31)
      ref.watch(voucherRepositoryProvider),            // vouchers (32)
    ],
    db: ref.watch(appDatabaseProvider),
  );
  ref.onDispose(() => manager.stop());
  return manager;
});

// --- Broadcast channels ---

final customerDisplayChannelProvider = Provider<BroadcastChannel>((ref) {
  final channel = BroadcastChannel(Supabase.instance.client);
  ref.onDispose(() => channel.dispose());
  return channel;
});

final kdsBroadcastChannelProvider = Provider<BroadcastChannel>((ref) {
  final channel = BroadcastChannel(Supabase.instance.client);
  ref.onDispose(() => channel.dispose());
  return channel;
});

// --- Pairing confirmation ---

/// Broadcast channel for display pairing confirmation.
final pairingChannelProvider = Provider<BroadcastChannel>((ref) {
  final channel = BroadcastChannel(Supabase.instance.client);
  ref.onDispose(() => channel.dispose());
  return channel;
});

/// Pending pairing request awaiting operator confirmation on main register.
class PairingRequest {
  PairingRequest({
    required this.code,
    required this.deviceName,
    required this.deviceType,
    required this.requestId,
  });
  final String code;
  final String deviceName;
  final String deviceType;
  final String requestId;
}

final pendingPairingRequestProvider = StateProvider<PairingRequest?>((ref) => null);

/// Auto-subscribes main register to pairing channel.
/// Watch this from app root to activate.
final pairingListenerProvider = Provider<void>((ref) {
  final company = ref.watch(currentCompanyProvider);
  final register = ref.watch(activeRegisterProvider).value;

  // Only main register listens for pairing requests
  if (company == null || register == null || !register.isMain) {
    AppLogger.debug(
      'pairingListener: skipped (company=${company?.id}, register=${register?.id}, isMain=${register?.isMain})',
      tag: 'PAIRING',
    );
    return;
  }

  AppLogger.info(
    'pairingListener: subscribing to pairing:${company.id}',
    tag: 'PAIRING',
  );

  final channel = ref.watch(pairingChannelProvider);
  final displayDeviceRepo = ref.read(displayDeviceRepositoryProvider);
  var disposed = false;

  // Register stream listener BEFORE join to avoid missing messages
  final sub = channel.stream.listen((payload) {
    final action = payload['action'] as String?;
    AppLogger.debug('pairingListener: received broadcast action=$action', tag: 'PAIRING');
    if (action != 'pairing_request') return;

    final code = payload['code'] as String? ?? '';
    final requestId = payload['request_id'] as String? ?? '';

    // Verify code exists in local DB before showing dialog
    displayDeviceRepo.getByCode(code).then((device) {
      if (disposed) return;
      if (device == null) {
        AppLogger.warn(
          'Pairing request for unknown code: $code',
          tag: 'PAIRING',
        );
        return;
      }
      ref.read(pendingPairingRequestProvider.notifier).state = PairingRequest(
        code: code,
        deviceName: payload['device_name'] as String? ?? device.name,
        deviceType: payload['device_type'] as String? ?? '',
        requestId: requestId,
      );
    });
  });

  // Join the channel (messages arriving after join will be caught by listener above)
  channel.join('pairing:${company.id}').then((_) {
    if (disposed) channel.leave();
  });

  ref.onDispose(() {
    disposed = true;
    sub.cancel();
    channel.leave();
  });
});

// --- Sync lifecycle watcher ---
// Watch this provider from the app root to auto-start/stop sync.

final syncLifecycleWatcherProvider = Provider<void>((ref) {
  final isAuthenticated = ref.watch(isSupabaseAuthenticatedProvider);
  final company = ref.watch(currentCompanyProvider);
  final manager = ref.watch(syncLifecycleManagerProvider);

  AppLogger.info(
    'syncWatcher: isAuth=$isAuthenticated, company=${company?.id}, managerRunning=${manager.isRunning}',
    tag: 'SYNC',
  );

  if (isAuthenticated && company != null) {
    manager.start(company.id);
  } else {
    manager.stop();
  }
});

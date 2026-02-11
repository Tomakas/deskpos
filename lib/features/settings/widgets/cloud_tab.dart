import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/database_provider.dart';
import '../../../core/data/providers/sync_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/logging/app_logger.dart';
import '../screens/screen_cloud_auth.dart';

class CloudTab extends ConsumerWidget {
  const CloudTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l.settingsSectionCloud,
              style: theme.textTheme.titleMedium,
            ),
          ),
          const ScreenCloudAuth(),
          const SizedBox(height: 32),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l.cloudDangerZone,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l.cloudDeleteLocalDataDescription,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
                onPressed: () => _deleteLocalData(context, ref),
                child: Text(l.cloudDeleteLocalData),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLocalData(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.cloudDeleteLocalDataConfirmTitle),
        content: Text(l.cloudDeleteLocalDataConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.cloudDeleteLocalDataConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      // Stop sync BEFORE deleting data to prevent re-pull race condition
      ref.read(syncLifecycleManagerProvider).stop();

      // Clear in-memory state first so sync watcher won't restart
      ref.read(sessionManagerProvider).logoutAll();
      ref.read(activeUserProvider.notifier).state = null;
      ref.read(loggedInUsersProvider.notifier).state = [];
      ref.read(currentCompanyProvider.notifier).state = null;

      // Close the database connection
      final db = ref.read(appDatabaseProvider);
      await db.close();

      // Delete the database file (and WAL/SHM companions)
      final dir = await getApplicationDocumentsDirectory();
      final basePath = p.join(dir.path, 'epos_database.sqlite');
      for (final suffix in ['', '-wal', '-shm', '-journal']) {
        final file = File('$basePath$suffix');
        if (await file.exists()) await file.delete();
      }

      // Invalidate providers — next read creates fresh DB with current schema
      ref.invalidate(appDatabaseProvider);
      ref.invalidate(appInitProvider);
    } catch (e, s) {
      AppLogger.error('Failed to delete local data', error: e, stackTrace: s);
      return;
    }

    if (!context.mounted) return;
    context.go('/onboarding');
  }
}

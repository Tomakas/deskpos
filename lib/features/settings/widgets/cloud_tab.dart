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
import '../../../core/utils/file_opener.dart';
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
              l.cloudDiagnostics,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l.cloudExportLogsDescription,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => _exportLogs(),
                child: Text(l.cloudExportLogs),
              ),
            ),
          ),
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

  Future<void> _exportLogs() async {
    final logPath = AppLogger.logFilePath;
    if (logPath == null) return;
    final file = File(logPath);
    if (!await file.exists()) return;
    await FileOpener.share(logPath);
  }

  Future<void> _deleteLocalData(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    // Cache router before async gaps — context may become defunct after
    // provider changes trigger widget tree disposal.
    final router = GoRouter.of(context);

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
      // Cache all refs before async gaps to avoid using defunct context/ref
      final syncManager = ref.read(syncLifecycleManagerProvider);
      final authService = ref.read(supabaseAuthServiceProvider);
      final sessionManager = ref.read(sessionManagerProvider);
      final db = ref.read(appDatabaseProvider);

      // Stop sync BEFORE deleting data to prevent re-pull race condition
      syncManager.stop();

      // Wipe server data so re-onboarding starts clean
      if (authService.isAuthenticated) {
        await authService.wipeServerData();
        await authService.signOut();
      }

      // Clear session state (does not trigger widget rebuild cascade)
      sessionManager.logoutAll();

      // NOTE: Do NOT set activeUserProvider/loggedInUsersProvider/
      // currentCompanyProvider to null here — those synchronous state
      // notifications trigger rebuild cascades on already-disposing widgets
      // (defunct element crash). Provider invalidation below handles cleanup.

      // Close the database connection
      await db.close();

      // Delete the database file (and WAL/SHM companions)
      final dir = await getApplicationDocumentsDirectory();
      final basePath = p.join(dir.path, 'epos_database.sqlite');
      for (final suffix in ['', '-wal', '-shm', '-journal']) {
        final file = File('$basePath$suffix');
        if (await file.exists()) await file.delete();
      }

      // Invalidate providers — marks them dirty for next read (no sync rebuild).
      // appInitProvider re-resolves company/user state from the fresh DB.
      ref.invalidate(appDatabaseProvider);
      ref.invalidate(appInitProvider);
    } catch (e, s) {
      AppLogger.error('Failed to delete local data', error: e, stackTrace: s);
      return;
    }

    // Navigate using cached router (safe even if this widget is already defunct)
    router.go('/onboarding');
  }
}

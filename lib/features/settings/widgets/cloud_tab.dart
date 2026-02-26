import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/database_provider.dart';
import '../../../core/data/providers/sync_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/platform/platform_io.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.cloudDeleteLocalDataDescription,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
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
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.cloudDeleteAllDataDescription,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                          ),
                          onPressed: () => _deleteAllData(context, ref),
                          child: Text(l.cloudDeleteAllData),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLocalData(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final confirmed = await _showConfirmDialog(
      context,
      title: l.cloudDeleteLocalDataConfirmTitle,
      message: l.cloudDeleteLocalDataConfirmMessage,
      confirm: l.cloudDeleteLocalDataConfirm,
    );
    if (confirmed != true || !context.mounted) return;
    await _performDelete(context, ref, wipeServer: false);
  }

  Future<void> _deleteAllData(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final confirmed = await _showConfirmDialog(
      context,
      title: l.cloudDeleteAllDataConfirmTitle,
      message: l.cloudDeleteAllDataConfirmMessage,
      confirm: l.cloudDeleteAllDataConfirm,
    );
    if (confirmed != true || !context.mounted) return;
    await _performDelete(context, ref, wipeServer: true);
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirm,
  }) {
    final l = context.l10n;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => PosDialogShell(
        title: title,
        scrollable: true,
        children: [
          Text(message),
          const SizedBox(height: 24),
        ],
        bottomActions: PosDialogActions(
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              style: PosButtonStyles.destructiveFilled(ctx),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirm),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performDelete(
    BuildContext context,
    WidgetRef ref, {
    required bool wipeServer,
  }) async {
    // Cache router before async gaps — context may become defunct after
    // provider changes trigger widget tree disposal.
    final router = GoRouter.of(context);

    try {
      // Cache all refs before async gaps to avoid using defunct context/ref
      final syncManager = ref.read(syncLifecycleManagerProvider);
      final authService = ref.read(supabaseAuthServiceProvider);
      final sessionManager = ref.read(sessionManagerProvider);
      final db = ref.read(appDatabaseProvider);

      // Stop sync BEFORE deleting data to prevent re-pull race condition
      syncManager.stop();

      if (authService.isAuthenticated) {
        if (wipeServer) {
          await authService.wipeServerData();
        }
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

      // Delete the database files
      await deleteDatabaseFiles('maty_database');

      // Invalidate providers — marks them dirty for next read (no sync rebuild).
      // appInitProvider re-resolves company/user state from the fresh DB.
      ref.invalidate(appDatabaseProvider);
      ref.invalidate(appInitProvider);
    } catch (e, s) {
      AppLogger.error('Failed to delete data', error: e, stackTrace: s);
      return;
    }

    // Navigate using cached router (safe even if this widget is already defunct)
    router.go('/onboarding');
  }
}

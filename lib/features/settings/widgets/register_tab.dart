import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import 'dialog_auto_arrange.dart';
import 'dialog_grid_editor.dart';

class RegisterTab extends ConsumerWidget {
  const RegisterTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final registerAsync = ref.watch(activeRegisterProvider);

    return registerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
      data: (register) {
        if (register == null) return const SizedBox.shrink();

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l.settingsSectionGrid,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              title: Text(l.settingsGridRows),
              trailing: SizedBox(
                width: 100,
                child: DropdownButtonFormField<int>(
                  initialValue: register.gridRows,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    for (int i = 1; i <= 10; i++)
                      DropdownMenuItem(value: i, child: Text('$i')),
                  ],
                  onChanged: (value) async {
                    if (value == null) return;
                    final repo = ref.read(registerRepositoryProvider);
                    await repo.updateGrid(
                          register.id,
                          value,
                          register.gridCols,
                        );
                    if (!context.mounted) return;
                    ref.invalidate(activeRegisterProvider);
                  },
                ),
              ),
            ),
            ListTile(
              title: Text(l.settingsGridCols),
              trailing: SizedBox(
                width: 100,
                child: DropdownButtonFormField<int>(
                  initialValue: register.gridCols,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    for (int i = 1; i <= 12; i++)
                      DropdownMenuItem(value: i, child: Text('$i')),
                  ],
                  onChanged: (value) async {
                    if (value == null) return;
                    final repo = ref.read(registerRepositoryProvider);
                    await repo.updateGrid(
                          register.id,
                          register.gridRows,
                          value,
                        );
                    if (!context.mounted) return;
                    ref.invalidate(activeRegisterProvider);
                  },
                ),
              ),
            ),
            SwitchListTile(
              title: Text(l.settingsShowStockBadge),
              subtitle: Text(l.settingsShowStockBadgeDescription),
              value: register.showStockBadge,
              onChanged: (value) async {
                final repo = ref.read(registerRepositoryProvider);
                await repo.update(
                  register.copyWith(showStockBadge: value),
                );
                if (!context.mounted) return;
                ref.invalidate(activeRegisterProvider);
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l.settingsSectionGridManagement,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: Text(l.settingsAutoArrange),
              subtitle: Text(l.settingsAutoArrangeDescription),
              onTap: () => showDialog(
                context: context,
                builder: (_) => const DialogAutoArrange(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.grid_on),
              title: Text(l.settingsManualEditor),
              subtitle: Text(l.settingsManualEditorDescription),
              onTap: () => showDialog(
                context: context,
                builder: (_) => const DialogGridEditor(),
              ),
            ),
          ],
        );
      },
    );
  }
}

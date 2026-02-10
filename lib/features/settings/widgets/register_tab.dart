import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

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
                    await ref.read(registerRepositoryProvider).updateGrid(
                          register.id,
                          value,
                          register.gridCols,
                        );
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
                    await ref.read(registerRepositoryProvider).updateGrid(
                          register.id,
                          register.gridRows,
                          value,
                        );
                    ref.invalidate(activeRegisterProvider);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/enums/sell_mode.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../widgets/register_tab.dart';

class ScreenRegisterSettings extends ConsumerWidget {
  const ScreenRegisterSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.settingsRegisterTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.modeTitle),
              Tab(text: l.sellTitle),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ModeTab(),
            RegisterTab(),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends ConsumerWidget {
  const _ModeTab();

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
                l.settingsSectionSellOptions,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              title: Text(l.settingsSellMode),
              trailing: SizedBox(
                width: 160,
                child: DropdownButtonFormField<SellMode>(
                  initialValue: register.sellMode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: SellMode.gastro,
                      child: Text(l.sellModeGastro),
                    ),
                    DropdownMenuItem(
                      value: SellMode.retail,
                      child: Text(l.sellModeRetail),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == null || value == register.sellMode) return;
                    final repo = ref.read(registerRepositoryProvider);
                    await repo.update(
                      register.copyWith(sellMode: value),
                    );
                    if (!context.mounted) return;
                    ref.invalidate(activeRegisterProvider);
                    context.go(value == SellMode.retail ? '/sell' : '/bills');
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

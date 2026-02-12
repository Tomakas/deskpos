import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/models/register_model.dart';
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
              Tab(text: l.settingsRegisterTitle),
              Tab(text: l.modeTitle),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RegisterTab(),
            _ModeTab(),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends ConsumerStatefulWidget {
  const _ModeTab();

  @override
  ConsumerState<_ModeTab> createState() => _ModeTabState();
}

class _ModeTabState extends ConsumerState<_ModeTab> {
  String? _selectedRegisterId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final company = ref.watch(currentCompanyProvider);
    final activeReg = ref.watch(activeRegisterProvider).value;
    final effectiveRegisterId = _selectedRegisterId ?? activeReg?.id;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            l.modeTitle,
            style: theme.textTheme.titleMedium,
          ),
        ),
        _ModeCard(
          icon: Icons.point_of_sale,
          title: l.modePOS,
          subtitle: l.modePOSDescription,
          selected: true,
          onTap: null,
        ),
        const SizedBox(height: 8),
        _ModeCard(
          icon: Icons.restaurant,
          title: l.modeKDS,
          subtitle: l.modeKDSDescription,
          selected: false,
          onTap: () => context.go('/kds'),
        ),
        const SizedBox(height: 8),
        _ModeCard(
          icon: Icons.tv,
          title: l.modeCustomerDisplay,
          subtitle: l.modeCustomerDisplayDescription,
          selected: false,
          onTap: () {
            final regId = _selectedRegisterId ??
                ref.read(activeRegisterProvider).value?.id;
            if (regId != null) {
              context.go('/customer-display/$regId');
            } else {
              context.go('/customer-display');
            }
          },
          bottom: company == null
              ? null
              : StreamBuilder<List<RegisterModel>>(
                  stream: ref
                      .watch(registerRepositoryProvider)
                      .watchAll(company.id),
                  builder: (context, snap) {
                    final registers = snap.data ?? [];
                    if (registers.isEmpty) return const SizedBox.shrink();
                    return DropdownButton<String>(
                      value: registers.any((r) => r.id == effectiveRegisterId)
                          ? effectiveRegisterId
                          : null,
                      isExpanded: true,
                      hint: Text(l.modeCustomerDisplaySelectRegister),
                      items: [
                        for (final r in registers)
                          DropdownMenuItem(
                            value: r.id,
                            child: Text(
                                r.name.isNotEmpty ? r.name : r.code),
                          ),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedRegisterId = v),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.bottom,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;

    return Card(
      color: color,
      elevation: selected ? 2 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                    ?bottom,
                  ],
                ),
              ),
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.check_circle, color: theme.colorScheme.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

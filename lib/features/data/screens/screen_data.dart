import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/providers/permission_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class ScreenData extends ConsumerStatefulWidget {
  const ScreenData({super.key});

  @override
  ConsumerState<ScreenData> createState() => _ScreenDataState();
}

class _ScreenDataState extends ConsumerState<ScreenData> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final canExport = ref.watch(hasPermissionProvider('data.export'));
    final canImport = ref.watch(hasPermissionProvider('data.import'));
    final canBackup = ref.watch(hasPermissionProvider('data.backup'));

    // Build filtered tabs: (originalIndex, label)
    final allTabs = <(int, String)>[
      if (canExport) (0, l.dataExport),
      if (canImport) (1, l.dataImport),
      if (canBackup) (2, l.dataBackup),
    ];

    if (allTabs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (GoRouter.of(context).canPop()) context.pop();
            },
          ),
          title: Text(l.dataTitle),
        ),
        body: const SizedBox.shrink(),
      );
    }

    final effectiveTab = _tabIndex.clamp(0, allTabs.length - 1);
    final originalIndex = allTabs[effectiveTab].$1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) context.pop();
          },
        ),
        title: Text(l.dataTitle),
      ),
      body: Column(
        children: [
          // Tab bar
          if (allTabs.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  for (var i = 0; i < allTabs.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: FilterChip(
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(allTabs[i].$2, textAlign: TextAlign.center),
                          ),
                          selected: effectiveTab == i,
                          onSelected: (_) => setState(() => _tabIndex = i),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          // Tab content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: switch (originalIndex) {
                0 => _buildExportTab(l),
                1 => _buildImportTab(l),
                2 => _buildBackupTab(l),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportTab(dynamic l) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: _DataCard(
            icon: Icons.upload_file,
            title: l.dataExport,
            description: l.dataExportDescription,
            onPressed: null,
          ),
        ),
      ],
    );
  }

  Widget _buildImportTab(dynamic l) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: _DataCard(
            icon: Icons.download,
            title: l.dataImport,
            description: l.dataImportDescription,
            onPressed: null,
          ),
        ),
      ],
    );
  }

  Widget _buildBackupTab(dynamic l) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: _DataCard(
            icon: Icons.backup,
            title: l.dataBackup,
            description: l.dataBackupDescription,
            onPressed: null,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: _DataCard(
            icon: Icons.restore,
            title: l.dataRestore,
            description: l.dataRestoreDescription,
            onPressed: null,
          ),
        ),
      ],
    );
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 36,
                color: onPressed != null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

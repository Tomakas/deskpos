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
    final items = <({IconData icon, String title, String description})>[
      (icon: Icons.inventory_2, title: l.dataExportProducts, description: l.dataExportProductsDesc),
      (icon: Icons.category, title: l.dataExportCategories, description: l.dataExportCategoriesDesc),
      (icon: Icons.people, title: l.dataExportCustomers, description: l.dataExportCustomersDesc),
      (icon: Icons.local_shipping, title: l.dataExportSuppliers, description: l.dataExportSuppliersDesc),
      (icon: Icons.tune, title: l.dataExportModifierGroups, description: l.dataExportModifierGroupsDesc),
      (icon: Icons.payment, title: l.dataExportPaymentMethods, description: l.dataExportPaymentMethodsDesc),
      (icon: Icons.percent, title: l.dataExportTaxRates, description: l.dataExportTaxRatesDesc),
      (icon: Icons.card_giftcard, title: l.dataExportVouchers, description: l.dataExportVouchersDesc),
      (icon: Icons.warehouse, title: l.dataExportStockLevels, description: l.dataExportStockLevelsDesc),
      (icon: Icons.receipt_long, title: l.dataExportOrders, description: l.dataExportOrdersDesc),
      (icon: Icons.description, title: l.dataExportBills, description: l.dataExportBillsDesc),
    ];
    return _buildItemList(items);
  }

  Widget _buildImportTab(dynamic l) {
    final items = <({IconData icon, String title, String description})>[
      (icon: Icons.inventory_2, title: l.dataImportProducts, description: l.dataImportProductsDesc),
      (icon: Icons.category, title: l.dataImportCategories, description: l.dataImportCategoriesDesc),
      (icon: Icons.people, title: l.dataImportCustomers, description: l.dataImportCustomersDesc),
      (icon: Icons.local_shipping, title: l.dataImportSuppliers, description: l.dataImportSuppliersDesc),
      (icon: Icons.tune, title: l.dataImportModifierGroups, description: l.dataImportModifierGroupsDesc),
      (icon: Icons.payment, title: l.dataImportPaymentMethods, description: l.dataImportPaymentMethodsDesc),
      (icon: Icons.percent, title: l.dataImportTaxRates, description: l.dataImportTaxRatesDesc),
      (icon: Icons.card_giftcard, title: l.dataImportVouchers, description: l.dataImportVouchersDesc),
      (icon: Icons.warehouse, title: l.dataImportStockLevels, description: l.dataImportStockLevelsDesc),
    ];
    return _buildItemList(items);
  }

  Widget _buildItemList(List<({IconData icon, String title, String description})> items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return _DataCard(
          icon: item.icon,
          title: item.title,
          description: item.description,
          onPressed: null,
        );
      },
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/layout_item_type.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/layout_item_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';

enum _ArrangeVariant { horizontal, vertical }

class DialogAutoArrange extends ConsumerStatefulWidget {
  const DialogAutoArrange({super.key});

  @override
  ConsumerState<DialogAutoArrange> createState() => _DialogAutoArrangeState();
}

class _DialogAutoArrangeState extends ConsumerState<DialogAutoArrange> {
  _ArrangeVariant _variant = _ArrangeVariant.horizontal;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    final registerAsync = ref.watch(activeRegisterProvider);

    if (company == null) return const SizedBox.shrink();

    return AlertDialog(
      title: Text(l.autoArrangeTitle),
      content: SizedBox(
        width: 400,
        child: StreamBuilder<List<CategoryModel>>(
          stream: ref.watch(categoryRepositoryProvider).watchAll(company.id),
          builder: (context, catSnap) {
            return StreamBuilder<List<ItemModel>>(
              stream: ref.watch(itemRepositoryProvider).watchAll(company.id),
              builder: (context, itemSnap) {
                final categories = (catSnap.data ?? [])
                    .where((c) => c.isActive)
                    .toList();
                final items = (itemSnap.data ?? [])
                    .where((i) => i.isActive && i.isSellable)
                    .toList();

                final register = registerAsync.value;
                final maxOnRoot = register != null
                    ? (_variant == _ArrangeVariant.horizontal
                        ? register.gridRows
                        : register.gridCols)
                    : 0;
                final overflows = categories.length > maxOnRoot;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioGroup<_ArrangeVariant>(
                      groupValue: _variant,
                      onChanged: _isProcessing
                          ? (v) {}
                          : (v) => setState(() { if (v != null) _variant = v; }),
                      child: Column(
                        children: [
                          RadioListTile<_ArrangeVariant>(
                            title: Text(l.autoArrangeHorizontal),
                            subtitle: Text(l.autoArrangeHorizontalDesc),
                            value: _ArrangeVariant.horizontal,
                          ),
                          RadioListTile<_ArrangeVariant>(
                            title: Text(l.autoArrangeVertical),
                            subtitle: Text(l.autoArrangeVerticalDesc),
                            value: _ArrangeVariant.vertical,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.autoArrangeSummary(categories.length, items.length),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (overflows) ...[
                      const SizedBox(height: 8),
                      Text(
                        l.autoArrangeOverflow(maxOnRoot, categories.length),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      l.autoArrangeWarning,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          onPressed: _isProcessing
              ? null
              : () => _execute(context, ref, registerAsync.value),
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l.autoArrangeConfirm),
        ),
      ],
    );
  }

  Future<void> _execute(
    BuildContext context,
    WidgetRef ref,
    dynamic register,
  ) async {
    if (register == null) return;

    final l = context.l10n;
    final rows = register.gridRows as int;
    final cols = register.gridCols as int;
    final maxOnRoot = _variant == _ArrangeVariant.horizontal ? rows : cols;

    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    final categories = await ref
        .read(categoryRepositoryProvider)
        .watchAll(company.id)
        .first;
    final activeCategories = categories.where((c) => c.isActive).toList();

    if (!context.mounted) return;

    if (activeCategories.length > maxOnRoot) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l.autoArrangeTitle),
          content: Text(
            l.autoArrangeOverflow(maxOnRoot, activeCategories.length),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.autoArrangeConfirm),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() => _isProcessing = true);

    try {
      final items =
          await ref.read(itemRepositoryProvider).watchAll(company.id).first;

      final activeItems =
          items.where((i) => i.isActive && i.isSellable).toList();

      final registerId = register.id as String;
      final companyId = company.id;

      final cells = _variant == _ArrangeVariant.horizontal
          ? _buildHorizontalLayout(
              activeCategories, activeItems, rows, cols, registerId, companyId)
          : _buildVerticalLayout(
              activeCategories, activeItems, rows, cols, registerId, companyId);

      final repo = ref.read(layoutItemRepositoryProvider);

      // 1. Clear existing
      final clearResult = await repo.clearByRegister(registerId);
      if (clearResult is Failure) {
        if (context.mounted) Navigator.pop(context);
        return;
      }

      // 2. Bulk insert
      await repo.bulkSetCells(cells);

      if (context.mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  List<BulkCellInput> _buildHorizontalLayout(
    List<CategoryModel> categories,
    List<ItemModel> items,
    int rows,
    int cols,
    String registerId,
    String companyId,
  ) {
    final cells = <BulkCellInput>[];
    int currentRow = 0;
    int pageCounter = 1;

    // Group items by category
    final itemsByCategory = <String?, List<ItemModel>>{};
    for (final item in items) {
      itemsByCategory.putIfAbsent(item.categoryId, () => []).add(item);
    }

    // Categories with their products
    for (final cat in categories) {
      if (currentRow >= rows) break;
      final catItems = itemsByCategory[cat.id] ?? [];

      // Column 0 = category
      cells.add(BulkCellInput(
        companyId: companyId,
        registerId: registerId,
        page: 0,
        gridRow: currentRow,
        gridCol: 0,
        type: LayoutItemType.category,
        categoryId: cat.id,
      ));

      // Columns 1..cols-1 = products
      for (int c = 1; c < cols && c - 1 < catItems.length; c++) {
        cells.add(BulkCellInput(
          companyId: companyId,
          registerId: registerId,
          page: 0,
          gridRow: currentRow,
          gridCol: c,
          type: LayoutItemType.item,
          itemId: catItems[c - 1].id,
        ));
      }

      // Sub-page for this category
      if (catItems.isNotEmpty) {
        final page = pageCounter++;
        // Marker at (0, 0)
        cells.add(BulkCellInput(
          companyId: companyId,
          registerId: registerId,
          page: page,
          gridRow: 0,
          gridCol: 0,
          type: LayoutItemType.category,
          categoryId: cat.id,
        ));

        // All products left-to-right, top-to-bottom
        int idx = 0;
        for (int r = 0; r < rows && idx < catItems.length; r++) {
          final startCol = r == 0 ? 1 : 0;
          for (int c = startCol; c < cols && idx < catItems.length; c++) {
            cells.add(BulkCellInput(
              companyId: companyId,
              registerId: registerId,
              page: page,
              gridRow: r,
              gridCol: c,
              type: LayoutItemType.item,
              itemId: catItems[idx].id,
            ));
            idx++;
          }
        }
      }

      currentRow++;
    }

    // Uncategorized products on remaining rows
    final uncategorized = itemsByCategory[null] ?? [];
    int uncatIdx = 0;
    while (currentRow < rows && uncatIdx < uncategorized.length) {
      for (int c = 0; c < cols && uncatIdx < uncategorized.length; c++) {
        cells.add(BulkCellInput(
          companyId: companyId,
          registerId: registerId,
          page: 0,
          gridRow: currentRow,
          gridCol: c,
          type: LayoutItemType.item,
          itemId: uncategorized[uncatIdx].id,
        ));
        uncatIdx++;
      }
      currentRow++;
    }

    return cells;
  }

  List<BulkCellInput> _buildVerticalLayout(
    List<CategoryModel> categories,
    List<ItemModel> items,
    int rows,
    int cols,
    String registerId,
    String companyId,
  ) {
    final cells = <BulkCellInput>[];
    int pageCounter = 1;

    // Group items by category
    final itemsByCategory = <String?, List<ItemModel>>{};
    for (final item in items) {
      itemsByCategory.putIfAbsent(item.categoryId, () => []).add(item);
    }

    // Row 0 = categories across columns
    for (int c = 0; c < cols && c < categories.length; c++) {
      final cat = categories[c];
      cells.add(BulkCellInput(
        companyId: companyId,
        registerId: registerId,
        page: 0,
        gridRow: 0,
        gridCol: c,
        type: LayoutItemType.category,
        categoryId: cat.id,
      ));

      final catItems = itemsByCategory[cat.id] ?? [];

      // Rows 1..rows-1 = products under their category
      for (int r = 1; r < rows && r - 1 < catItems.length; r++) {
        cells.add(BulkCellInput(
          companyId: companyId,
          registerId: registerId,
          page: 0,
          gridRow: r,
          gridCol: c,
          type: LayoutItemType.item,
          itemId: catItems[r - 1].id,
        ));
      }

      // Sub-page for this category
      if (catItems.isNotEmpty) {
        final page = pageCounter++;
        // Marker at (0, 0)
        cells.add(BulkCellInput(
          companyId: companyId,
          registerId: registerId,
          page: page,
          gridRow: 0,
          gridCol: 0,
          type: LayoutItemType.category,
          categoryId: cat.id,
        ));

        // All products left-to-right, top-to-bottom
        int idx = 0;
        for (int r = 0; r < rows && idx < catItems.length; r++) {
          final startCol = r == 0 ? 1 : 0;
          for (int c2 = startCol; c2 < cols && idx < catItems.length; c2++) {
            cells.add(BulkCellInput(
              companyId: companyId,
              registerId: registerId,
              page: page,
              gridRow: r,
              gridCol: c2,
              type: LayoutItemType.item,
              itemId: catItems[idx].id,
            ));
            idx++;
          }
        }
      }
    }

    return cells;
  }
}

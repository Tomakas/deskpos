import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/layout_item_type.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/register_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/layout_item_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';

enum _ArrangeMode { simple, smart }

enum _ArrangeVariant { horizontal, vertical }

class _PageCounter {
  int _next = 1;
  int allocate() => _next++;
}

class DialogAutoArrange extends ConsumerStatefulWidget {
  const DialogAutoArrange({super.key});

  @override
  ConsumerState<DialogAutoArrange> createState() => _DialogAutoArrangeState();
}

class _DialogAutoArrangeState extends ConsumerState<DialogAutoArrange> {
  _ArrangeMode _mode = _ArrangeMode.simple;
  _ArrangeVariant _variant = _ArrangeVariant.horizontal;
  bool _isProcessing = false;

  int _maxOnRoot(RegisterModel register) {
    if (_mode == _ArrangeMode.simple) {
      return register.gridRows * register.gridCols;
    } else {
      return _variant == _ArrangeVariant.horizontal
          ? register.gridRows
          : register.gridCols;
    }
  }

  String _description(AppLocalizations l) {
    if (_mode == _ArrangeMode.simple) {
      return _variant == _ArrangeVariant.horizontal
          ? l.autoArrangeSimpleHorizontalDesc
          : l.autoArrangeSimpleVerticalDesc;
    } else {
      return _variant == _ArrangeVariant.horizontal
          ? l.autoArrangeSmartHorizontalDesc
          : l.autoArrangeSmartVerticalDesc;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    final registerAsync = ref.watch(activeRegisterProvider);

    if (company == null) return const SizedBox.shrink();

    return PosDialogShell(
      title: l.autoArrangeTitle,
      maxWidth: 480,
      scrollable: true,
      bottomActions: PosDialogActions(
        actions: [
          OutlinedButton(
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
      ),
      children: [
        StreamBuilder<List<CategoryModel>>(
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

                final rootCategories =
                    categories.where((c) => c.parentId == null).toList();
                final register = registerAsync.value;
                final maxOnRoot =
                    register != null ? _maxOnRoot(register) : 0;
                final overflows = rootCategories.length > maxOnRoot;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: FilterChip(
                              label: SizedBox(
                                width: double.infinity,
                                child: Text(l.autoArrangeSimple,
                                    textAlign: TextAlign.center),
                              ),
                              selected: _mode == _ArrangeMode.simple,
                              onSelected: _isProcessing
                                  ? null
                                  : (_) => setState(
                                      () => _mode = _ArrangeMode.simple),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: FilterChip(
                              label: SizedBox(
                                width: double.infinity,
                                child: Text(l.autoArrangeSmart,
                                    textAlign: TextAlign.center),
                              ),
                              selected: _mode == _ArrangeMode.smart,
                              onSelected: _isProcessing
                                  ? null
                                  : (_) => setState(
                                      () => _mode = _ArrangeMode.smart),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: FilterChip(
                              label: SizedBox(
                                width: double.infinity,
                                child: Text(l.autoArrangeHorizontal,
                                    textAlign: TextAlign.center),
                              ),
                              selected:
                                  _variant == _ArrangeVariant.horizontal,
                              onSelected: _isProcessing
                                  ? null
                                  : (_) => setState(() =>
                                      _variant = _ArrangeVariant.horizontal),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: FilterChip(
                              label: SizedBox(
                                width: double.infinity,
                                child: Text(l.autoArrangeVertical,
                                    textAlign: TextAlign.center),
                              ),
                              selected:
                                  _variant == _ArrangeVariant.vertical,
                              onSelected: _isProcessing
                                  ? null
                                  : (_) => setState(() =>
                                      _variant = _ArrangeVariant.vertical),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _description(l),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.autoArrangeSummary(categories.length, items.length),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (overflows) ...[
                      const SizedBox(height: 8),
                      Text(
                        l.autoArrangeOverflow(
                            maxOnRoot, rootCategories.length),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
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
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _execute(
    BuildContext context,
    WidgetRef ref,
    RegisterModel? register,
  ) async {
    if (register == null) return;

    final l = context.l10n;
    final rows = register.gridRows;
    final cols = register.gridCols;
    final maxOnRoot = _maxOnRoot(register);

    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    final categories = await ref
        .read(categoryRepositoryProvider)
        .watchAll(company.id)
        .first;
    final activeCategories = categories.where((c) => c.isActive).toList();
    final rootCategories =
        activeCategories.where((c) => c.parentId == null).toList();

    if (!context.mounted) return;

    if (rootCategories.length > maxOnRoot) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => PosDialogShell(
          title: l.autoArrangeTitle,
          maxWidth: 400,
          children: [
            Text(l.autoArrangeOverflow(maxOnRoot, rootCategories.length)),
            const SizedBox(height: 16),
            PosDialogActions(
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l.actionCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l.autoArrangeConfirm),
                ),
              ],
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
      if (!mounted) return;

      final registerId = register.id;
      final companyId = company.id;

      final List<BulkCellInput> cells;
      if (_mode == _ArrangeMode.simple) {
        cells = _variant == _ArrangeVariant.horizontal
            ? _buildSimpleHorizontalLayout(rootCategories, activeCategories,
                activeItems, rows, cols, registerId, companyId)
            : _buildSimpleVerticalLayout(rootCategories, activeCategories,
                activeItems, rows, cols, registerId, companyId);
      } else {
        cells = _variant == _ArrangeVariant.horizontal
            ? _buildSmartHorizontalLayout(rootCategories, activeCategories,
                activeItems, rows, cols, registerId, companyId)
            : _buildSmartVerticalLayout(rootCategories, activeCategories,
                activeItems, rows, cols, registerId, companyId);
      }

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

  List<CategoryModel> _childrenOf(
          String parentId, List<CategoryModel> all) =>
      all.where((c) => c.parentId == parentId).toList();

  void _fillSubPage({
    required List<BulkCellInput> cells,
    required CategoryModel category,
    required List<CategoryModel> allCategories,
    required Map<String?, List<ItemModel>> itemsByCategory,
    required int rows,
    required int cols,
    required String registerId,
    required String companyId,
    required _PageCounter pageCounter,
    required _ArrangeVariant variant,
  }) {
    final page = pageCounter.allocate();
    final children = _childrenOf(category.id, allCategories);
    final directItems = itemsByCategory[category.id] ?? [];

    // Marker (back button) at [0,0]
    cells.add(BulkCellInput(
      companyId: companyId,
      registerId: registerId,
      page: page,
      gridRow: 0,
      gridCol: 0,
      type: LayoutItemType.category,
      categoryId: category.id,
    ));

    if (variant == _ArrangeVariant.horizontal) {
      // Row 0, cols 1+ = direct items (next to back button)
      for (int c = 1; c < cols && c - 1 < directItems.length; c++) {
        cells.add(BulkCellInput(
          companyId: companyId,
          registerId: registerId,
          page: page,
          gridRow: 0,
          gridCol: c,
          type: LayoutItemType.item,
          itemId: directItems[c - 1].id,
        ));
      }

      // Child categories in col 0 starting at row 1, their items in cols 1+
      int currentRow = 1;
      for (final child in children) {
        if (currentRow >= rows) break;
        final childItems = itemsByCategory[child.id] ?? [];

        cells.add(BulkCellInput(
          companyId: companyId,
          registerId: registerId,
          page: page,
          gridRow: currentRow,
          gridCol: 0,
          type: LayoutItemType.category,
          categoryId: child.id,
        ));

        for (int c = 1; c < cols && c - 1 < childItems.length; c++) {
          cells.add(BulkCellInput(
            companyId: companyId,
            registerId: registerId,
            page: page,
            gridRow: currentRow,
            gridCol: c,
            type: LayoutItemType.item,
            itemId: childItems[c - 1].id,
          ));
        }

        currentRow++;
      }

      // Remaining direct items on remaining rows
      int directIdx = cols - 1;
      while (currentRow < rows && directIdx < directItems.length) {
        for (int c = 0; c < cols && directIdx < directItems.length; c++) {
          cells.add(BulkCellInput(
            companyId: companyId,
            registerId: registerId,
            page: page,
            gridRow: currentRow,
            gridCol: c,
            type: LayoutItemType.item,
            itemId: directItems[directIdx].id,
          ));
          directIdx++;
        }
        currentRow++;
      }
    } else {
      // Col 0, rows 1+ = direct items (below back button)
      for (int r = 1; r < rows && r - 1 < directItems.length; r++) {
        cells.add(BulkCellInput(
          companyId: companyId,
          registerId: registerId,
          page: page,
          gridRow: r,
          gridCol: 0,
          type: LayoutItemType.item,
          itemId: directItems[r - 1].id,
        ));
      }

      // Child categories in row 0 starting at col 1, their items in rows 1+
      int currentCol = 1;
      for (final child in children) {
        if (currentCol >= cols) break;
        final childItems = itemsByCategory[child.id] ?? [];

        cells.add(BulkCellInput(
          companyId: companyId,
          registerId: registerId,
          page: page,
          gridRow: 0,
          gridCol: currentCol,
          type: LayoutItemType.category,
          categoryId: child.id,
        ));

        for (int r = 1; r < rows && r - 1 < childItems.length; r++) {
          cells.add(BulkCellInput(
            companyId: companyId,
            registerId: registerId,
            page: page,
            gridRow: r,
            gridCol: currentCol,
            type: LayoutItemType.item,
            itemId: childItems[r - 1].id,
          ));
        }

        currentCol++;
      }

      // Remaining direct items in remaining columns
      int directIdx = rows - 1;
      while (currentCol < cols && directIdx < directItems.length) {
        for (int r = 0; r < rows && directIdx < directItems.length; r++) {
          cells.add(BulkCellInput(
            companyId: companyId,
            registerId: registerId,
            page: page,
            gridRow: r,
            gridCol: currentCol,
            type: LayoutItemType.item,
            itemId: directItems[directIdx].id,
          ));
          directIdx++;
        }
        currentCol++;
      }
    }

    // Recursively create sub-pages for each child category
    for (final child in children) {
      _fillSubPage(
        cells: cells,
        category: child,
        allCategories: allCategories,
        itemsByCategory: itemsByCategory,
        rows: rows,
        cols: cols,
        registerId: registerId,
        companyId: companyId,
        pageCounter: pageCounter,
        variant: variant,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Simple layouts — categories only on root page, products on sub-pages
  // ---------------------------------------------------------------------------

  List<BulkCellInput> _buildSimpleHorizontalLayout(
    List<CategoryModel> rootCategories,
    List<CategoryModel> allCategories,
    List<ItemModel> items,
    int rows,
    int cols,
    String registerId,
    String companyId,
  ) {
    final cells = <BulkCellInput>[];
    final pageCounter = _PageCounter();

    final itemsByCategory = <String?, List<ItemModel>>{};
    for (final item in items) {
      itemsByCategory.putIfAbsent(item.categoryId, () => []).add(item);
    }

    // Root categories left to right, top to bottom
    int catIdx = 0;
    int currentRow = 0;
    while (currentRow < rows && catIdx < rootCategories.length) {
      for (int c = 0; c < cols && catIdx < rootCategories.length; c++) {
        cells.add(BulkCellInput(
          companyId: companyId,
          registerId: registerId,
          page: 0,
          gridRow: currentRow,
          gridCol: c,
          type: LayoutItemType.category,
          categoryId: rootCategories[catIdx].id,
        ));

        _fillSubPage(
          cells: cells,
          category: rootCategories[catIdx],
          allCategories: allCategories,
          itemsByCategory: itemsByCategory,
          rows: rows,
          cols: cols,
          registerId: registerId,
          companyId: companyId,
          pageCounter: pageCounter,
          variant: _ArrangeVariant.horizontal,
        );

        catIdx++;
      }
      currentRow++;
    }

    return cells;
  }

  List<BulkCellInput> _buildSimpleVerticalLayout(
    List<CategoryModel> rootCategories,
    List<CategoryModel> allCategories,
    List<ItemModel> items,
    int rows,
    int cols,
    String registerId,
    String companyId,
  ) {
    final cells = <BulkCellInput>[];
    final pageCounter = _PageCounter();

    final itemsByCategory = <String?, List<ItemModel>>{};
    for (final item in items) {
      itemsByCategory.putIfAbsent(item.categoryId, () => []).add(item);
    }

    // Root categories top to bottom, left to right
    int catIdx = 0;
    int currentCol = 0;
    while (currentCol < cols && catIdx < rootCategories.length) {
      for (int r = 0; r < rows && catIdx < rootCategories.length; r++) {
        cells.add(BulkCellInput(
          companyId: companyId,
          registerId: registerId,
          page: 0,
          gridRow: r,
          gridCol: currentCol,
          type: LayoutItemType.category,
          categoryId: rootCategories[catIdx].id,
        ));

        _fillSubPage(
          cells: cells,
          category: rootCategories[catIdx],
          allCategories: allCategories,
          itemsByCategory: itemsByCategory,
          rows: rows,
          cols: cols,
          registerId: registerId,
          companyId: companyId,
          pageCounter: pageCounter,
          variant: _ArrangeVariant.vertical,
        );

        catIdx++;
      }
      currentCol++;
    }

    return cells;
  }

  // ---------------------------------------------------------------------------
  // Smart layouts — categories + product previews on root page
  // ---------------------------------------------------------------------------

  List<BulkCellInput> _buildSmartHorizontalLayout(
    List<CategoryModel> rootCategories,
    List<CategoryModel> allCategories,
    List<ItemModel> items,
    int rows,
    int cols,
    String registerId,
    String companyId,
  ) {
    final cells = <BulkCellInput>[];
    final pageCounter = _PageCounter();
    int currentRow = 0;

    final itemsByCategory = <String?, List<ItemModel>>{};
    for (final item in items) {
      itemsByCategory.putIfAbsent(item.categoryId, () => []).add(item);
    }

    // Root categories with their direct products on page 0
    for (final cat in rootCategories) {
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

      // Columns 1..cols-1 = direct products
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

      _fillSubPage(
        cells: cells,
        category: cat,
        allCategories: allCategories,
        itemsByCategory: itemsByCategory,
        rows: rows,
        cols: cols,
        registerId: registerId,
        companyId: companyId,
        pageCounter: pageCounter,
        variant: _ArrangeVariant.horizontal,
      );

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

  List<BulkCellInput> _buildSmartVerticalLayout(
    List<CategoryModel> rootCategories,
    List<CategoryModel> allCategories,
    List<ItemModel> items,
    int rows,
    int cols,
    String registerId,
    String companyId,
  ) {
    final cells = <BulkCellInput>[];
    final pageCounter = _PageCounter();

    final itemsByCategory = <String?, List<ItemModel>>{};
    for (final item in items) {
      itemsByCategory.putIfAbsent(item.categoryId, () => []).add(item);
    }

    // Row 0 = root categories across columns
    for (int c = 0; c < cols && c < rootCategories.length; c++) {
      final cat = rootCategories[c];
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

      // Rows 1..rows-1 = direct products under their category
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

      _fillSubPage(
        cells: cells,
        category: cat,
        allCategories: allCategories,
        itemsByCategory: itemsByCategory,
        rows: rows,
        cols: cols,
        registerId: registerId,
        companyId: companyId,
        pageCounter: pageCounter,
        variant: _ArrangeVariant.vertical,
      );
    }

    return cells;
  }
}

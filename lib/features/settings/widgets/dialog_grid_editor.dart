import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/layout_item_type.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/layout_item_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/search_utils.dart';

class DialogGridEditor extends ConsumerStatefulWidget {
  const DialogGridEditor({super.key});

  @override
  ConsumerState<DialogGridEditor> createState() => _DialogGridEditorState();
}

class _DialogGridEditorState extends ConsumerState<DialogGridEditor> {
  int _currentPage = 0;
  final List<int> _pageStack = [];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    final registerAsync = ref.watch(activeRegisterProvider);

    if (company == null) return const SizedBox.shrink();

    return registerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
      data: (register) {
        if (register == null) return const SizedBox.shrink();

        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            setState(() {
                              if (_pageStack.isNotEmpty) {
                                _currentPage = _pageStack.removeLast();
                              } else {
                                _currentPage = 0;
                              }
                            });
                          },
                          tooltip: l.gridEditorBack,
                        ),
                      Text(
                        _currentPage == 0
                            ? l.gridEditorTitle2
                            : '${l.gridEditorTitle2} — ${l.gridEditorPage(_currentPage)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Grid
                Expanded(
                  child: _buildGrid(context, register, company.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, dynamic register, String companyId) {
    final rows = register.gridRows as int;
    final cols = register.gridCols as int;
    final registerId = register.id as String;

    return StreamBuilder<List<LayoutItemModel>>(
      stream: ref
          .watch(layoutItemRepositoryProvider)
          .watchByRegister(registerId, page: _currentPage),
      builder: (context, layoutSnap) {
        final layoutItems = layoutSnap.data ?? [];
        return StreamBuilder<List<ItemModel>>(
          stream: ref.watch(itemRepositoryProvider).watchAll(companyId),
          builder: (context, itemSnap) {
            final allItems = itemSnap.data ?? [];
            return StreamBuilder<List<CategoryModel>>(
              stream:
                  ref.watch(categoryRepositoryProvider).watchAll(companyId),
              builder: (context, catSnap) {
                final allCategories = catSnap.data ?? [];
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final cellW = constraints.maxWidth / cols;
                    final cellH = constraints.maxHeight / rows;

                    return Stack(
                      children: [
                        for (int r = 0; r < rows; r++)
                          for (int c = 0; c < cols; c++)
                            Positioned(
                              left: c * cellW,
                              top: r * cellH,
                              width: cellW,
                              height: cellH,
                              child: _buildCell(
                                context,
                                layoutItems,
                                allItems,
                                allCategories,
                                r,
                                c,
                                registerId,
                                companyId,
                              ),
                            ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCell(
    BuildContext context,
    List<LayoutItemModel> layoutItems,
    List<ItemModel> allItems,
    List<CategoryModel> allCategories,
    int row,
    int col,
    String registerId,
    String companyId,
  ) {
    final l = context.l10n;
    final layoutItem = layoutItems
        .where((li) => li.gridRow == row && li.gridCol == col)
        .firstOrNull;

    String label = l.sellEmptySlot;
    Color color = Theme.of(context).colorScheme.surfaceContainerHighest;

    if (layoutItem != null) {
      if (layoutItem.type == LayoutItemType.item) {
        final item =
            allItems.where((i) => i.id == layoutItem.itemId).firstOrNull;
        label = layoutItem.label ?? item?.name ?? '?';
        color = Theme.of(context).colorScheme.primaryContainer;
      } else {
        final cat = allCategories
            .where((c) => c.id == layoutItem.categoryId)
            .firstOrNull;
        label = layoutItem.label ?? cat?.name ?? '?';
        color = Theme.of(context).colorScheme.secondaryContainer;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            if (layoutItem != null &&
                layoutItem.type == LayoutItemType.category &&
                _currentPage == 0) {
              _navigateToCategory(registerId, layoutItem.categoryId!);
            } else {
              _showEditDialog(
                context, allItems, allCategories, row, col, registerId,
                companyId,
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const Positioned(
                top: 2,
                right: 2,
                child: Icon(Icons.edit, size: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToCategory(
      String registerId, String categoryId) async {
    final page = await ref
        .read(layoutItemRepositoryProvider)
        .getPageForCategory(registerId, categoryId);
    if (page != null && mounted) {
      setState(() {
        _pageStack.add(_currentPage);
        _currentPage = page;
      });
    } else if (mounted) {
      // No sub-page exists — create one with just a marker
      await _createSubPage(registerId, categoryId);
    }
  }

  Future<void> _createSubPage(String registerId, String categoryId) async {
    // Determine next page number
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    // Find max page currently used
    // We'll use a simple approach: try pages 1..100 until we find one not used
    int newPage = 1;
    while (true) {
      final items = await ref
          .read(layoutItemRepositoryProvider)
          .watchByRegister(registerId, page: newPage)
          .first;
      if (items.isEmpty) break;
      newPage++;
      if (newPage > 100) return; // safety
    }

    await ref.read(layoutItemRepositoryProvider).setCell(
      companyId: company.id,
      registerId: registerId,
      page: newPage,
      gridRow: 0,
      gridCol: 0,
      type: LayoutItemType.category,
      categoryId: categoryId,
    );

    if (mounted) {
      setState(() {
        _pageStack.add(_currentPage);
        _currentPage = newPage;
      });
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    List<ItemModel> allItems,
    List<CategoryModel> allCategories,
    int row,
    int col,
    String registerId,
    String companyId,
  ) async {
    final l = context.l10n;
    final result = await showDialog<_GridEditResult>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.gridEditorTitle),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () => _selectItem(context, allItems, l),
                  child: Text(l.gridEditorItem),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () =>
                      _selectCategory(context, allCategories, l),
                  child: Text(l.gridEditorCategory),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () =>
                      Navigator.pop(context, _GridEditResult(clear: true)),
                  child: Text(l.gridEditorClear),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionCancel),
          ),
        ],
      ),
    );

    if (result == null) return;
    final repo = ref.read(layoutItemRepositoryProvider);

    if (result.clear) {
      await repo.clearCell(
        registerId: registerId,
        page: _currentPage,
        gridRow: row,
        gridCol: col,
      );
    } else {
      await repo.setCell(
        companyId: companyId,
        registerId: registerId,
        page: _currentPage,
        gridRow: row,
        gridCol: col,
        type: result.type!,
        itemId: result.itemId,
        categoryId: result.categoryId,
      );

      // If assigning a category on page 0, ensure sub-page exists
      if (_currentPage == 0 &&
          result.type == LayoutItemType.category &&
          result.categoryId != null) {
        final existingPage = await repo.getPageForCategory(
            registerId, result.categoryId!);
        if (existingPage == null) {
          await _createSubPage(registerId, result.categoryId!);
          // Navigate back to root since _createSubPage navigates to the new page
          if (mounted) {
            setState(() {
              _pageStack.clear();
              _currentPage = 0;
            });
          }
        }
      }
    }
  }

  Future<void> _selectItem(
      BuildContext context, List<ItemModel> allItems, dynamic l) async {
    final sellableItems =
        allItems.where((i) => i.isActive && i.isSellable).toList();
    final selected = await showDialog<ItemModel>(
      context: context,
      builder: (_) {
        var query = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = query.isEmpty
                ? sellableItems
                : sellableItems
                    .where((i) => normalizeSearch(i.name).contains(query))
                    .toList();
            return AlertDialog(
              title: Text(l.gridEditorSelectItem),
              content: SizedBox(
                width: 350,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: l.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onChanged: (v) =>
                          setDialogState(() => query = normalizeSearch(v)),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return ListTile(
                            title: Text(item.name),
                            subtitle: Text('${item.unitPrice ~/ 100} Kč'),
                            onTap: () => Navigator.pop(context, item),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null && context.mounted) {
      Navigator.pop(
        context,
        _GridEditResult(
          type: LayoutItemType.item,
          itemId: selected.id,
        ),
      );
    }
  }

  Future<void> _selectCategory(BuildContext context,
      List<CategoryModel> allCategories, dynamic l) async {
    final activeCategories =
        allCategories.where((c) => c.isActive).toList();
    final selected = await showDialog<CategoryModel>(
      context: context,
      builder: (_) {
        var query = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = query.isEmpty
                ? activeCategories
                : activeCategories
                    .where((c) => normalizeSearch(c.name).contains(query))
                    .toList();
            return AlertDialog(
              title: Text(l.gridEditorSelectCategory),
              content: SizedBox(
                width: 350,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: l.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onChanged: (v) =>
                          setDialogState(() => query = normalizeSearch(v)),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final cat = filtered[index];
                          return ListTile(
                            title: Text(cat.name),
                            onTap: () => Navigator.pop(context, cat),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null && context.mounted) {
      Navigator.pop(
        context,
        _GridEditResult(
          type: LayoutItemType.category,
          categoryId: selected.id,
        ),
      );
    }
  }
}

class _GridEditResult {
  _GridEditResult({this.type, this.itemId, this.categoryId, this.clear = false});
  final LayoutItemType? type;
  final String? itemId;
  final String? categoryId;
  final bool clear;
}

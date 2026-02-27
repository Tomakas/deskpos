import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/layout_item_type.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/layout_item_model.dart';
import '../../../core/data/models/register_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/pos_color_palette.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';

enum GridDialogMode { editor, picker }

class DialogGridEditor extends ConsumerStatefulWidget {
  const DialogGridEditor({super.key, this.mode = GridDialogMode.editor});

  final GridDialogMode mode;

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
                            ? widget.mode == GridDialogMode.picker
                                ? l.assignToGridPickTitle
                                : l.gridEditorTitle2
                            : '${widget.mode == GridDialogMode.picker ? l.assignToGridPickTitle : l.gridEditorTitle2} — ${l.gridEditorPage(_currentPage)}',
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

  Widget _buildGrid(BuildContext context, RegisterModel register, String companyId) {
    final rows = register.gridRows;
    final cols = register.gridCols;
    final registerId = register.id;

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
    final theme = Theme.of(context);
    final layoutItem = layoutItems
        .where((li) => li.gridRow == row && li.gridCol == col)
        .firstOrNull;

    final bool isEmpty = layoutItem == null;
    final bool isPicker = widget.mode == GridDialogMode.picker;

    String label = l.sellEmptySlot;
    Color color = theme.colorScheme.surfaceContainerHighest;

    if (layoutItem != null) {
      if (layoutItem.type == LayoutItemType.item) {
        final item =
            allItems.where((i) => i.id == layoutItem.itemId).firstOrNull;
        label = layoutItem.label ?? item?.name ?? '?';
        color = layoutItem.color != null
            ? parseHexColor(layoutItem.color)
            : theme.colorScheme.primaryContainer;
      } else {
        final cat = allCategories
            .where((c) => c.id == layoutItem.categoryId)
            .firstOrNull;
        label = layoutItem.label ?? cat?.name ?? '?';
        color = layoutItem.color != null
            ? parseHexColor(layoutItem.color)
            : theme.colorScheme.secondaryContainer;
      }
    }

    // [0,0] on sub-pages is always back button
    final isBackCell = _currentPage > 0 && row == 0 && col == 0 &&
        layoutItem != null && layoutItem.type == LayoutItemType.category;
    if (isBackCell) {
      label = l.sellBackToCategories;
      color = theme.colorScheme.surfaceContainerHighest;
    }

    if (isPicker && isEmpty) {
      color = theme.colorScheme.primary.withValues(alpha: 0.08);
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            // [0,0] on sub-pages is always back button
            if (_currentPage > 0 && row == 0 && col == 0 &&
                layoutItem != null && layoutItem.type == LayoutItemType.category) {
              setState(() {
                if (_pageStack.isNotEmpty) {
                  _currentPage = _pageStack.removeLast();
                } else {
                  _currentPage = 0;
                }
              });
              return;
            }
            if (isPicker) {
              if (isEmpty) {
                Navigator.pop(
                  context,
                  (page: _currentPage, row: row, col: col),
                );
              } else if (layoutItem.type == LayoutItemType.category) {
                _navigateToCategory(registerId, layoutItem.categoryId!);
              }
            } else {
              if (layoutItem != null &&
                  layoutItem.type == LayoutItemType.category) {
                _navigateToCategory(registerId, layoutItem.categoryId!);
              } else {
                _showEditDialog(
                  context, allItems, allCategories, row, col, registerId,
                  companyId, layoutItem,
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: isPicker
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isEmpty ? FontWeight.bold : null,
                        color: isEmpty ? theme.colorScheme.primary : null,
                      ),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isBackCell)
                              const Icon(Icons.arrow_back, size: 14),
                            Text(
                              label,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isBackCell)
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
    } else if (widget.mode == GridDialogMode.editor && mounted) {
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
    LayoutItemModel? layoutItem,
  ) async {
    final l = context.l10n;

    // Pre-populate state from existing cell
    var selectedType = layoutItem?.type ?? LayoutItemType.item;
    String? selectedItemId = layoutItem?.type == LayoutItemType.item ? layoutItem?.itemId : null;
    String? selectedItemName;
    String? selectedCategoryId = layoutItem?.type == LayoutItemType.category ? layoutItem?.categoryId : null;
    String? selectedCategoryName;
    var selectedColor = layoutItem?.color;

    if (selectedItemId != null) {
      selectedItemName = allItems.where((i) => i.id == selectedItemId).firstOrNull?.name;
    }
    if (selectedCategoryId != null) {
      selectedCategoryName = allCategories.where((c) => c.id == selectedCategoryId).firstOrNull?.name;
    }

    final hasExisting = layoutItem != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isItem = selectedType == LayoutItemType.item;
          final currentName = isItem ? selectedItemName : selectedCategoryName;
          final placeholder = isItem ? l.gridEditorSelectItem : l.gridEditorSelectCategory;

          return PosDialogShell(
            title: l.gridEditorTitle,
            maxWidth: 400,
            scrollable: true,
            bottomActions: PosDialogActions(
              leading: hasExisting
                  ? OutlinedButton(
                      style: PosButtonStyles.destructiveOutlined(ctx),
                      onPressed: () async {
                        await ref.read(layoutItemRepositoryProvider).clearCell(
                          registerId: registerId,
                          page: _currentPage,
                          gridRow: row,
                          gridCol: col,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: Text(l.gridEditorClear),
                    )
                  : null,
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l.actionCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l.actionSave),
                ),
              ],
            ),
            children: [
              // Type toggle
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: FilterChip(
                        label: SizedBox(
                          width: double.infinity,
                          child: Text(l.gridEditorItem, textAlign: TextAlign.center),
                        ),
                        selected: isItem,
                        onSelected: (_) => setDialogState(() {
                          selectedType = LayoutItemType.item;
                          selectedCategoryId = null;
                          selectedCategoryName = null;
                        }),
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
                          child: Text(l.gridEditorCategory, textAlign: TextAlign.center),
                        ),
                        selected: !isItem,
                        onSelected: (_) => setDialogState(() {
                          selectedType = LayoutItemType.category;
                          selectedItemId = null;
                          selectedItemName = null;
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Cell preview tile — looks like a grid cell
              () {
                final hasSelection = currentName != null;
                final theme = Theme.of(ctx);
                final Color tileColor;
                if (selectedColor != null) {
                  tileColor = parseHexColor(selectedColor);
                } else if (hasSelection) {
                  tileColor = isItem
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.secondaryContainer;
                } else {
                  tileColor = theme.colorScheme.surfaceContainerHighest;
                }

                return Center(
                  child: SizedBox(
                  height: 80,
                  width: 120,
                  child: Material(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        if (isItem) {
                          final item = await _selectItemStandalone(ctx, allItems, l);
                          if (item != null) {
                            setDialogState(() {
                              selectedItemId = item.id;
                              selectedItemName = item.name;
                            });
                          }
                        } else {
                          final cat = await _selectCategoryStandalone(ctx, allCategories, l);
                          if (cat != null) {
                            setDialogState(() {
                              selectedCategoryId = cat.id;
                              selectedCategoryName = cat.name;
                            });
                          }
                        }
                      },
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            currentName ?? placeholder,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: hasSelection ? null : theme.hintColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ),
                );
              }(),
              const SizedBox(height: 16),
              // Color palette
              PosColorPalette(
                selectedColor: selectedColor,
                onColorSelected: (c) => setDialogState(() => selectedColor = c),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );

    if (result != true || !context.mounted) return;

    final hasSelection = (selectedType == LayoutItemType.item && selectedItemId != null) ||
        (selectedType == LayoutItemType.category && selectedCategoryId != null);
    if (!hasSelection) return;

    final repo = ref.read(layoutItemRepositoryProvider);

    await repo.setCell(
      companyId: companyId,
      registerId: registerId,
      page: _currentPage,
      gridRow: row,
      gridCol: col,
      type: selectedType,
      itemId: selectedType == LayoutItemType.item ? selectedItemId : null,
      categoryId: selectedType == LayoutItemType.category ? selectedCategoryId : null,
      color: selectedColor,
    );

    // If assigning a category, ensure sub-page exists
    if (selectedType == LayoutItemType.category &&
        selectedCategoryId != null) {
      final existingPage = await repo.getPageForCategory(
          registerId, selectedCategoryId!);
      if (existingPage == null) {
        await _createSubPage(registerId, selectedCategoryId!);
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

  Future<ItemModel?> _selectItemStandalone(
      BuildContext context, List<ItemModel> allItems, AppLocalizations l) async {
    final sellableItems =
        allItems.where((i) => i.isActive && i.isSellable).toList();
    return showDialog<ItemModel>(
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
            return PosDialogShell(
              title: l.gridEditorSelectItem,
              maxWidth: 420,
              maxHeight: 500,
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
                        subtitle: Text(ref.money(item.unitPrice)),
                        onTap: () => Navigator.pop(context, item),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<CategoryModel?> _selectCategoryStandalone(BuildContext context,
      List<CategoryModel> allCategories, AppLocalizations l) async {
    final activeCategories =
        allCategories.where((c) => c.isActive).toList();
    return showDialog<CategoryModel>(
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
            return PosDialogShell(
              title: l.gridEditorSelectCategory,
              maxWidth: 420,
              maxHeight: 500,
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
            );
          },
        );
      },
    );
  }
}

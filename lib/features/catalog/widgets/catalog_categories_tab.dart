import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/enums/prep_area.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/tax_rate_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/utils/category_tree.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/highlighted_text.dart';
import '../../../core/widgets/pos_color_palette.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';

enum _CategoriesSortField { name }

class CatalogCategoriesTab extends ConsumerStatefulWidget {
  const CatalogCategoriesTab({super.key});

  @override
  ConsumerState<CatalogCategoriesTab> createState() => _CatalogCategoriesTabState();
}

class _CatalogCategoriesTabState extends ConsumerState<CatalogCategoriesTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  // Sort state
  _CategoriesSortField _sortField = _CategoriesSortField.name;
  bool _sortAsc = true;

  // Filter state
  bool? _filterActive;

  bool get _hasActiveFilters => _filterActive != null;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    final categoriesStream = ref.watch(categoryRepositoryProvider).watchAll(company.id);
    final taxRatesStream = ref.watch(taxRateRepositoryProvider).watchAll(company.id);

    return StreamBuilder<List<CategoryModel>>(
      stream: categoriesStream,
      builder: (context, catSnap) {
        return StreamBuilder<List<TaxRateModel>>(
          stream: taxRatesStream,
          builder: (context, taxSnap) {
            final categories = catSnap.data ?? [];
            final taxRates = taxSnap.data ?? [];

            final filtered = categories.where((c) {
              if (_filterActive != null && c.isActive != _filterActive) return false;
              if (_query.isEmpty) return true;
              return normalizeSearch(c.name).contains(_query);
            }).toList()
              ..sort((a, b) {
                final cmp = switch (_sortField) {
                  _CategoriesSortField.name => a.name.compareTo(b.name),
                };
                return _sortAsc ? cmp : -cmp;
              });
            return Column(
              children: [
                PosTableToolbar(
                  searchController: _searchCtrl,
                  searchHint: l.searchHint,
                  onSearchChanged: (v) => setState(() => _query = normalizeSearch(v)),
                  trailing: [
                    IconButton(
                      icon: Icon(
                        Icons.filter_alt_outlined,
                        color: _hasActiveFilters
                            ? theme.colorScheme.primary
                            : null,
                      ),
                      onPressed: () => _showFilterDialog(context, l),
                    ),
                    PopupMenuButton<_CategoriesSortField>(
                      icon: const Icon(Icons.swap_vert),
                      onSelected: (field) {
                        if (field == _sortField) {
                          setState(() => _sortAsc = !_sortAsc);
                        } else {
                          setState(() {
                            _sortField = field;
                            _sortAsc = true;
                          });
                        }
                      },
                      itemBuilder: (_) => [
                        for (final entry in {
                          _CategoriesSortField.name: l.catalogSortName,
                        }.entries)
                          PopupMenuItem(
                            value: entry.key,
                            child: Row(
                              children: [
                                if (entry.key == _sortField)
                                  Icon(_sortAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 16)
                                else
                                  const SizedBox(width: 16),
                                const SizedBox(width: 8),
                                Text(entry.value, style: entry.key == _sortField ? const TextStyle(fontWeight: FontWeight.bold) : null),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => _showEditDialog(context, ref, categories, null),
                      icon: const Icon(Icons.add),
                      label: Text(l.actionAdd),
                    ),
                  ],
                ),
                Expanded(
                  child: PosTable<CategoryModel>(
                    columns: [
                      PosColumn(label: l.fieldName, flex: 3, cellBuilder: (c) => HighlightedText(c.name, query: _query, overflow: TextOverflow.ellipsis)),
                      PosColumn(
                        label: l.fieldParentCategory,
                        flex: 2,
                        cellBuilder: (c) => Text(
                          categories.where((p) => p.id == c.parentId).firstOrNull?.name ?? '-',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PosColumn(
                        label: l.fieldDefaultSaleTax,
                        flex: 2,
                        cellBuilder: (c) => Text(
                          taxRates.where((t) => t.id == c.defaultSaleTaxRateId).firstOrNull?.label ?? '-',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PosColumn(
                        label: l.fieldDefaultPurchaseTax,
                        flex: 2,
                        cellBuilder: (c) => Text(
                          taxRates.where((t) => t.id == c.defaultPurchaseTaxRateId).firstOrNull?.label ?? '-',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PosColumn(
                        label: l.fieldActive,
                        flex: 1,
                        cellBuilder: (c) => Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            c.isActive ? Icons.check_circle : Icons.cancel,
                            color: boolIndicatorColor(c.isActive, context),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                    items: filtered,
                    onRowTap: (c) => _showEditDialog(context, ref, categories, c),
                    onRowLongPress: (c) async {
                      if (!await confirmDelete(context, context.l10n) || !context.mounted) return;
                      await ref.read(categoryRepositoryProvider).delete(c.id);
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

  Future<void> _showFilterDialog(BuildContext context, AppLocalizations l) async {
    var active = _filterActive;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => PosDialogShell(
          title: l.filterTitle,
          showCloseButton: true,
          maxWidth: 350,
          scrollable: true,
          bottomActions: PosDialogActions(
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.actionConfirm),
              ),
            ],
          ),
          children: [
            Text(l.catalogFilterActive, style: Theme.of(ctx).textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: FilterChip(
                      label: SizedBox(
                        width: double.infinity,
                        child: Text(l.filterAll, textAlign: TextAlign.center),
                      ),
                      selected: active == null,
                      onSelected: (_) => setDialogState(() => active = null),
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
                        child: Text(l.yes, textAlign: TextAlign.center),
                      ),
                      selected: active == true,
                      onSelected: (_) => setDialogState(() => active = true),
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
                        child: Text(l.no, textAlign: TextAlign.center),
                      ),
                      selected: active == false,
                      onSelected: (_) => setDialogState(() => active = false),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _filterActive = active);
  }

  String _prepAreaLabel(AppLocalizations l, PrepArea? pa) => switch (pa) {
    PrepArea.kitchen => l.prepAreaKitchen,
    PrepArea.bar => l.prepAreaBar,
    PrepArea.all => l.prepAreaAll,
    PrepArea.none => l.prepAreaNone,
    null => '-',
  };

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    List<CategoryModel> allCategories,
    CategoryModel? existing,
  ) async {
    final l = context.l10n;
    final company = ref.read(currentCompanyProvider)!;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var isActive = existing?.isActive ?? true;
    var parentId = existing?.parentId;
    var prepArea = existing?.prepArea;
    var defaultSaleTaxRateId = existing?.defaultSaleTaxRateId;
    var defaultPurchaseTaxRateId = existing?.defaultPurchaseTaxRateId;
    var defaultIsSellable = existing?.defaultIsSellable;
    var color = existing?.color;
    var itemColor = existing?.itemColor;

    // To prevent circular dependencies, we cannot select current category 
    // or any of its descendants as a parent.
    final excludedIds = existing != null 
        ? CategoryTree.getAllDescendantIds(existing.id, allCategories)
        : <String>{};
    
    final parentOptions = allCategories.where((c) => !excludedIds.contains(c.id)).toList();
    final sortedParentOptions = CategoryTree.getSortedDisplayList(parentOptions);

    final result = await showDialog<Object>(
      context: context,
      builder: (_) => StreamBuilder<List<TaxRateModel>>(
        stream: ref.watch(taxRateRepositoryProvider).watchAll(company.id),
        builder: (ctx, taxSnap) {
          final taxRates = taxSnap.data ?? [];
          return StatefulBuilder(
            builder: (ctx, setDialogState) => PosDialogShell(
              title: existing == null ? l.actionAdd : l.actionEdit,
              showCloseButton: true,
              maxWidth: 500,
              scrollable: true,
              bottomActions: PosDialogActions(
                leading: existing != null
                    ? OutlinedButton(
                        style: PosButtonStyles.destructiveOutlined(ctx),
                        onPressed: () async {
                          if (!await confirmDelete(ctx, l) || !ctx.mounted) return;
                          await ref.read(categoryRepositoryProvider).delete(existing.id);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: Text(l.actionDelete),
                      )
                    : null,
                actions: [
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.actionSave)),
                ],
              ),
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: l.fieldName),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: parentId,
                  decoration: InputDecoration(labelText: l.fieldParentCategory),
                  items: [
                    DropdownMenuItem<String?>(value: null, child: Text(l.fieldNone)), 
                    ...sortedParentOptions.map((item) {
                      final prefix = item.depth > 0 ? '${'  ' * (item.depth - 1)}└─ ' : '';
                      return DropdownMenuItem(
                        value: item.category.id,
                        child: Text(
                          prefix + item.category.name,
                          style: TextStyle(
                            fontWeight: item.depth == 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }),
                  ],
                  onChanged: (v) => setDialogState(() => parentId = v),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(l.fieldActive),
                  value: isActive,
                  onChanged: (v) => setDialogState(() => isActive = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<PrepArea?>(
                  initialValue: prepArea,
                  decoration: InputDecoration(labelText: l.fieldPrepArea),
                  items: PrepArea.values.map((pa) => DropdownMenuItem<PrepArea?>(
                    value: pa,
                    child: Text(_prepAreaLabel(l, pa)),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => prepArea = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: defaultSaleTaxRateId,
                  decoration: InputDecoration(labelText: l.fieldDefaultSaleTax),
                  items: taxRates.map((tr) => DropdownMenuItem(
                    value: tr.id,
                    child: Text(tr.label),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => defaultSaleTaxRateId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: defaultPurchaseTaxRateId,
                  decoration: InputDecoration(labelText: l.fieldDefaultPurchaseTax),
                  items: taxRates.map((tr) => DropdownMenuItem(
                    value: tr.id,
                    child: Text(tr.label),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => defaultPurchaseTaxRateId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<bool?>(
                  initialValue: defaultIsSellable,
                  decoration: InputDecoration(labelText: l.fieldDefaultIsSellable),
                  items: [
                    DropdownMenuItem<bool?>(value: true, child: Text(l.yes)),
                    DropdownMenuItem<bool?>(value: false, child: Text(l.no)),
                  ],
                  onChanged: (v) => setDialogState(() => defaultIsSellable = v),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: PosColorField(
                        label: l.fieldCategoryColor,
                        selectedColor: color,
                        onColorSelected: (c) => setDialogState(() => color = c),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PosColorField(
                        label: l.fieldItemColor,
                        selectedColor: itemColor,
                        onColorSelected: (c) => setDialogState(() => itemColor = c),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty || !mounted) return;

    final repo = ref.read(categoryRepositoryProvider);
    final now = DateTime.now();

    if (existing != null) {
      await repo.update(existing.copyWith(
        name: nameCtrl.text.trim(),
        isActive: isActive,
        parentId: parentId,
        prepArea: prepArea,
        defaultSaleTaxRateId: defaultSaleTaxRateId,
        defaultPurchaseTaxRateId: defaultPurchaseTaxRateId,
        defaultIsSellable: defaultIsSellable,
        color: color,
        itemColor: itemColor,
      ));
    } else {
      await repo.create(CategoryModel(
        id: const Uuid().v7(),
        companyId: company.id,
        name: nameCtrl.text.trim(),
        isActive: isActive,
        parentId: parentId,
        prepArea: prepArea,
        defaultSaleTaxRateId: defaultSaleTaxRateId,
        defaultPurchaseTaxRateId: defaultPurchaseTaxRateId,
        defaultIsSellable: defaultIsSellable,
        color: color,
        itemColor: itemColor,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

}

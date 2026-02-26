import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/category_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/highlighted_text.dart';
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

    return StreamBuilder<List<CategoryModel>>(
      stream: ref.watch(categoryRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final categories = snap.data ?? [];
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
                    flex: 3,
                    cellBuilder: (c) => Text(
                      categories.where((p) => p.id == c.parentId).firstOrNull?.name ?? '-',
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
              ),
            ),
          ],
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
          maxWidth: 350,
          scrollable: true,
          bottomActions: PosDialogActions(
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.actionCancel),
              ),
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

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    List<CategoryModel> allCategories,
    CategoryModel? existing,
  ) async {
    final l = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var isActive = existing?.isActive ?? true;
    var parentId = existing?.parentId;

    final parentOptions = allCategories.where((c) => c.id != existing?.id).toList();

    final result = await showDialog<Object>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => PosDialogShell(
          title: existing == null ? l.actionAdd : l.actionEdit,
          maxWidth: 350,
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
              OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
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
                const DropdownMenuItem(value: null, child: Text('-')),
                ...parentOptions
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
              ],
              onChanged: (v) => setDialogState(() => parentId = v),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: Text(l.fieldActive),
              value: isActive,
              onChanged: (v) => setDialogState(() => isActive = v),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty || !mounted) return;

    final company = ref.read(currentCompanyProvider)!;
    final repo = ref.read(categoryRepositoryProvider);
    final now = DateTime.now();

    if (existing != null) {
      await repo.update(existing.copyWith(
        name: nameCtrl.text.trim(),
        isActive: isActive,
        parentId: parentId,
      ));
    } else {
      await repo.create(CategoryModel(
        id: const Uuid().v7(),
        companyId: company.id,
        name: nameCtrl.text.trim(),
        isActive: isActive,
        parentId: parentId,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

}

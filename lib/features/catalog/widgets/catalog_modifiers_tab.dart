import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/enums/item_type.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/modifier_group_item_model.dart';
import '../../../core/data/models/modifier_group_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/highlighted_text.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';

enum _ModifiersSortField { name, minSelections }

class CatalogModifiersTab extends ConsumerStatefulWidget {
  const CatalogModifiersTab({super.key});

  @override
  ConsumerState<CatalogModifiersTab> createState() => _CatalogModifiersTabState();
}

class _CatalogModifiersTabState extends ConsumerState<CatalogModifiersTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  // Sort state
  _ModifiersSortField _sortField = _ModifiersSortField.name;
  bool _sortAsc = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<ModifierGroupModel>>(
      stream: ref.watch(modifierGroupRepositoryProvider).watchAll(company.id),
      builder: (context, snap) {
        final groups = snap.data ?? [];
        final filtered = groups.where((g) {
          if (_query.isEmpty) return true;
          return normalizeSearch(g.name).contains(_query);
        }).toList()
          ..sort((a, b) {
            final cmp = switch (_sortField) {
              _ModifiersSortField.name => a.name.compareTo(b.name),
              _ModifiersSortField.minSelections => a.minSelections.compareTo(b.minSelections),
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
                PopupMenuButton<_ModifiersSortField>(
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
                      _ModifiersSortField.name: l.catalogSortName,
                      _ModifiersSortField.minSelections: l.catalogSortMinSelections,
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
                  onPressed: () => _showGroupEditDialog(context, ref, null),
                  icon: const Icon(Icons.add),
                  label: Text(l.addModifierGroup),
                ),
              ],
            ),
            Expanded(
              child: PosTable<ModifierGroupModel>(
                items: filtered,
                columns: [
                  PosColumn(label: l.modifierGroupName, flex: 3, cellBuilder: (g) => HighlightedText(g.name, query: _query)),
                  PosColumn(label: l.minSelections, flex: 1, cellBuilder: (g) => Text('${g.minSelections}')),
                  PosColumn(label: l.maxSelections, flex: 1, cellBuilder: (g) => Text(g.maxSelections?.toString() ?? l.unlimited)),
                ],
                onRowTap: (group) => _showGroupEditDialog(context, ref, group),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showGroupEditDialog(
    BuildContext context,
    WidgetRef ref,
    ModifierGroupModel? existing,
  ) async {
    final l = context.l10n;
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final minCtrl = TextEditingController(text: '${existing?.minSelections ?? 0}');
    final maxCtrl = TextEditingController(text: existing?.maxSelections?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => PosDialogShell(
        title: existing != null ? l.editModifierGroup : l.addModifierGroup,
        maxWidth: 500,
        scrollable: true,
        bottomActions: PosDialogActions(
          leading: existing != null
              ? OutlinedButton(
                  style: PosButtonStyles.destructiveOutlined(ctx),
                  onPressed: () async {
                    if (!await confirmDelete(ctx, l) || !ctx.mounted) return;
                    await ref.read(modifierGroupRepositoryProvider).delete(existing.id);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(l.deleteModifierGroup),
                )
              : null,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final min = int.tryParse(minCtrl.text) ?? 0;
                final max = maxCtrl.text.trim().isEmpty ? null : int.tryParse(maxCtrl.text);
                final repo = ref.read(modifierGroupRepositoryProvider);

                if (existing != null) {
                  await repo.update(existing.copyWith(
                    name: name,
                    minSelections: min,
                    maxSelections: max,
                  ));
                } else {
                  final now = DateTime.now();
                  await repo.create(ModifierGroupModel(
                    id: const Uuid().v7(),
                    companyId: company.id,
                    name: name,
                    minSelections: min,
                    maxSelections: max,
                    createdAt: now,
                    updatedAt: now,
                  ));
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(l.actionSave),
            ),
          ],
        ),
        children: [
          TextField(
            controller: nameCtrl,
            autofocus: existing == null,
            decoration: InputDecoration(
              labelText: l.modifierGroupName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.minSelections,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: maxCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.maxSelections,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: l.unlimited,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          if (existing != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            _GroupItemsSection(group: existing),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Displays and manages the items in a modifier group.
class _GroupItemsSection extends ConsumerWidget {
  const _GroupItemsSection({required this.group});
  final ModifierGroupModel group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return StreamBuilder<List<ModifierGroupItemModel>>(
      stream: ref.watch(modifierGroupItemRepositoryProvider).watchByGroup(group.id),
      builder: (context, snap) {
        final items = snap.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.modifiers, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Text(l.noModifierGroups, style: theme.textTheme.bodySmall),
            for (final gi in items)
              _GroupItemTile(groupItem: gi),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _showAddModifierItemDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l.addModifier),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddModifierItemDialog(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    // Get all modifier-type items
    final allItems = await ref.read(itemRepositoryProvider).watchAll(company.id).first;
    final modifierItems = allItems.where((i) => i.itemType != ItemType.recipe && i.deletedAt == null).toList();

    // Get existing group items to exclude already-added ones
    final existingGi = await ref.read(modifierGroupItemRepositoryProvider).getByGroup(group.id);
    final existingItemIds = existingGi.map((gi) => gi.itemId).toSet();
    final availableItems = modifierItems.where((i) => !existingItemIds.contains(i.id)).toList();

    if (!context.mounted) return;

    var onlyModifiers = true;
    var query = '';
    final searchCtrl = TextEditingController();

    final selected = await showDialog<ItemModel>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final filtered = availableItems.where((i) {
            if (onlyModifiers && i.itemType != ItemType.modifier) return false;
            if (query.isNotEmpty && !normalizeSearch(i.name).contains(query)) return false;
            return true;
          }).toList();
          return PosDialogShell(
            showCloseButton: true,
            title: l.addModifier,
            maxWidth: 400,
            expandHeight: true,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: l.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  searchCtrl.clear();
                                  setDialogState(() => query = '');
                                },
                              )
                            : null,
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (v) => setDialogState(() => query = normalizeSearch(v)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.filter_alt_outlined,
                      color: !onlyModifiers
                          ? Theme.of(ctx).colorScheme.primary
                          : null,
                    ),
                    onPressed: () async {
                      var tempOnly = onlyModifiers;
                      await showDialog<void>(
                        context: ctx,
                        builder: (_) => StatefulBuilder(
                          builder: (fCtx, setFilterState) => PosDialogShell(
                            title: l.filterTitle,
                            maxWidth: 400,
                            scrollable: true,
                            bottomActions: PosDialogActions(
                              leading: !tempOnly
                                  ? OutlinedButton(
                                      style: PosButtonStyles.destructiveOutlined(fCtx),
                                      onPressed: () {
                                        setDialogState(() => onlyModifiers = true);
                                        Navigator.of(fCtx).pop();
                                      },
                                      child: Text(l.filterReset),
                                    )
                                  : null,
                              actions: [
                                OutlinedButton(
                                  onPressed: () => Navigator.of(fCtx).pop(),
                                  child: Text(l.actionCancel),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    setDialogState(() => onlyModifiers = tempOnly);
                                    Navigator.of(fCtx).pop();
                                  },
                                  child: Text(l.actionConfirm),
                                ),
                              ],
                            ),
                            children: [
                              SwitchListTile(
                                title: Text(l.modifierFilterOnlyModifiers),
                                value: tempOnly,
                                onChanged: (v) => setFilterState(() => tempOnly = v),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          l.noModifierGroups,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final item = filtered[i];
                          return ListTile(
                            title: Text(item.name),
                            trailing: Text(ref.money(item.unitPrice)),
                            onTap: () => Navigator.pop(ctx, item),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
    searchCtrl.dispose();

    if (selected == null) return;

    final now = DateTime.now();
    await ref.read(modifierGroupItemRepositoryProvider).create(
      ModifierGroupItemModel(
        id: const Uuid().v7(),
        companyId: company.id,
        modifierGroupId: group.id,
        itemId: selected.id,
        sortOrder: existingGi.length,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}

class _GroupItemTile extends ConsumerWidget {
  const _GroupItemTile({required this.groupItem});
  final ModifierGroupItemModel groupItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return FutureBuilder<ItemModel?>(
      future: ref.watch(itemRepositoryProvider).getById(groupItem.itemId),
      builder: (context, snap) {
        final item = snap.data;
        if (item == null) return const SizedBox.shrink();

        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(item.name),
          subtitle: groupItem.isDefault
              ? Text(context.l10n.fieldDefault, style: theme.textTheme.bodySmall)
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ref.money(item.unitPrice)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () async {
                  await ref.read(modifierGroupItemRepositoryProvider).delete(groupItem.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

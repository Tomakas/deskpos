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
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/pos_table.dart';

class CatalogModifiersTab extends ConsumerStatefulWidget {
  const CatalogModifiersTab({super.key});

  @override
  ConsumerState<CatalogModifiersTab> createState() => _CatalogModifiersTabState();
}

class _CatalogModifiersTabState extends ConsumerState<CatalogModifiersTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

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
        }).toList();

        return Column(
          children: [
            PosTableToolbar(
              searchController: _searchCtrl,
              searchHint: l.searchHint,
              onSearchChanged: (v) => setState(() => _query = normalizeSearch(v)),
              trailing: [
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
                  PosColumn(label: l.modifierGroupName, flex: 3, cellBuilder: (g) => Text(g.name)),
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
      builder: (ctx) => AlertDialog(
        title: Text(existing != null ? l.editModifierGroup : l.addModifierGroup),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                          helperText: l.unlimited,
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
              ],
            ),
          ),
        ),
        actions: [
          if (existing != null)
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () async {
                await ref.read(modifierGroupRepositoryProvider).delete(existing.id);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(l.deleteModifierGroup),
            ),
          TextButton(
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
    final modifierItems = allItems.where((i) => i.itemType == ItemType.modifier && i.deletedAt == null).toList();

    // Get existing group items to exclude already-added ones
    final existingGi = await ref.read(modifierGroupItemRepositoryProvider).getByGroup(group.id);
    final existingItemIds = existingGi.map((gi) => gi.itemId).toSet();
    final availableItems = modifierItems.where((i) => !existingItemIds.contains(i.id)).toList();

    if (!context.mounted) return;

    final selected = await showDialog<ItemModel>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.addModifier),
        children: [
          for (final item in availableItems)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, item),
              child: Row(
                children: [
                  Expanded(child: Text(item.name)),
                  Text(ref.money(item.unitPrice)),
                ],
              ),
            ),
          if (availableItems.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l.noModifierGroups, style: Theme.of(context).textTheme.bodySmall),
            ),
        ],
      ),
    );

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
              ? Text('Default', style: theme.textTheme.bodySmall)
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

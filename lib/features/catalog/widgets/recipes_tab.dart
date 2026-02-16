import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/enums/item_type.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/product_recipe_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/pos_table.dart';

class RecipesTab extends ConsumerStatefulWidget {
  const RecipesTab({super.key});

  @override
  ConsumerState<RecipesTab> createState() => _RecipesTabState();
}

class _RecipesTabState extends ConsumerState<RecipesTab> {
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

    final recipesStream = ref.watch(productRecipeRepositoryProvider).watchAll(company.id);
    final itemsStream = ref.watch(itemRepositoryProvider).watchAll(company.id);

    return StreamBuilder<List<ProductRecipeModel>>(
      stream: recipesStream,
      builder: (context, recipesSnap) {
        return StreamBuilder<List<ItemModel>>(
          stream: itemsStream,
          builder: (context, itemsSnap) {
            final recipes = recipesSnap.data ?? [];
            final items = itemsSnap.data ?? [];
            final itemMap = {for (final i in items) i.id: i};

            // Group recipes by parent product
            final grouped = <String, List<ProductRecipeModel>>{};
            for (final r in recipes) {
              grouped.putIfAbsent(r.parentProductId, () => []).add(r);
            }

            final filteredEntries = grouped.entries.where((entry) {
              if (_query.isEmpty) return true;
              final parentName = itemMap[entry.key]?.name ?? '';
              return normalizeSearch(parentName).contains(_query);
            }).toList();

            return Column(
              children: [
                PosTableToolbar(
                  searchController: _searchCtrl,
                  searchHint: l.searchHint,
                  onSearchChanged: (v) => setState(() => _query = normalizeSearch(v)),
                  trailing: [
                    FilledButton.icon(
                      onPressed: () => _showRecipeDialog(context, ref, items, null, []),
                      icon: const Icon(Icons.add),
                      label: Text(l.actionAdd),
                    ),
                  ],
                ),
                Expanded(
                  child: PosTable<MapEntry<String, List<ProductRecipeModel>>>(
                    columns: [
                      PosColumn(
                        label: l.fieldParentProduct,
                        flex: 2,
                        cellBuilder: (entry) => Text(itemMap[entry.key]?.name ?? '-', overflow: TextOverflow.ellipsis),
                      ),
                      PosColumn(
                        label: l.recipeComponents,
                        flex: 5,
                        cellBuilder: (entry) {
                          final summary = entry.value.map((r) {
                            final name = itemMap[r.componentProductId]?.name ?? '?';
                            final qty = _formatQty(r.quantityRequired);
                            return '$qty $name';
                          }).join(', ');
                          return Text(summary, overflow: TextOverflow.ellipsis);
                        },
                      ),
                    ],
                    items: filteredEntries,
                    onRowTap: (entry) => _showRecipeDialog(
                      context, ref, items, entry.key, entry.value,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatQty(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  Future<void> _showRecipeDialog(
    BuildContext context,
    WidgetRef ref,
    List<ItemModel> items,
    String? existingParentId,
    List<ProductRecipeModel> existingComponents,
  ) async {
    final l = context.l10n;
    final theme = Theme.of(context);
    final isNew = existingParentId == null;

    var parentProductId = existingParentId;
    final components = existingComponents
        .map((r) => _ComponentEntry(
              recipeId: r.id,
              itemId: r.componentProductId,
              quantity: r.quantityRequired,
              quantityController: TextEditingController(
                text: _formatQty(r.quantityRequired),
              ),
            ))
        .toList();

    final recipeItems = items.where((i) => i.itemType == ItemType.recipe).toList();

    final result = await showDialog<Object>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isNew ? l.actionAdd : l.actionEdit),
          content: SizedBox(
            width: 500,
            height: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Parent product dropdown (locked when editing)
                DropdownButtonFormField<String?>(
                  initialValue: parentProductId,
                  decoration: InputDecoration(labelText: l.fieldParentProduct),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('-')),
                    ...recipeItems.map(
                      (i) => DropdownMenuItem(value: i.id, child: Text(i.name)),
                    ),
                  ],
                  onChanged: isNew
                      ? (v) => setDialogState(() => parentProductId = v)
                      : null,
                ),
                const SizedBox(height: 16),

                // Components list
                Expanded(
                  child: components.isEmpty
                      ? Center(
                          child: Text(
                            l.recipeNoComponents,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: components.length,
                          itemBuilder: (context, i) {
                            final comp = components[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<String?>(
                                      initialValue: comp.itemId,
                                      decoration: InputDecoration(
                                        labelText: l.fieldComponent,
                                        isDense: true,
                                      ),
                                      items: [
                                        const DropdownMenuItem(value: null, child: Text('-')),
                                        ...items.map(
                                          (it) => DropdownMenuItem(value: it.id, child: Text(it.name)),
                                        ),
                                      ],
                                      onChanged: (v) => setDialogState(() => comp.itemId = v),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: comp.quantityController,
                                      decoration: InputDecoration(
                                        labelText: l.fieldQuantityRequired,
                                        isDense: true,
                                      ),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => setDialogState(() {
                                      components[i].quantityController.dispose();
                                      components.removeAt(i);
                                    }),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Add component button
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setDialogState(() {
                      components.add(_ComponentEntry(
                        quantityController: TextEditingController(text: '1'),
                      ));
                    }),
                    icon: const Icon(Icons.add),
                    label: Text(l.recipeAddComponent),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.actionCancel),
            ),
            if (!isNew)
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'delete'),
                child: Text(l.actionDelete, style: TextStyle(color: theme.colorScheme.error)),
              ),
            FilledButton(
              onPressed: parentProductId != null && components.isNotEmpty
                  ? () => Navigator.pop(ctx, true)
                  : null,
              child: Text(l.actionSave),
            ),
          ],
        ),
      ),
    );

    // Dispose controllers
    for (final comp in components) {
      final qty = double.tryParse(comp.quantityController.text.replaceAll(',', '.')) ?? 1.0;
      comp.quantity = qty;
      comp.quantityController.dispose();
    }

    if (result == 'delete' && existingParentId != null) {
      if (!context.mounted) return;
      await _deleteRecipe(context, ref, existingComponents);
      return;
    }

    if (result != true || parentProductId == null) return;
    if (!mounted) return;

    await _saveRecipe(ref, parentProductId!, existingComponents, components);
  }

  Future<void> _saveRecipe(
    WidgetRef ref,
    String parentProductId,
    List<ProductRecipeModel> existingComponents,
    List<_ComponentEntry> newComponents,
  ) async {
    final company = ref.read(currentCompanyProvider)!;
    final repo = ref.read(productRecipeRepositoryProvider);
    final now = DateTime.now();

    final existingMap = {for (final r in existingComponents) r.id: r};
    final keptIds = <String>{};

    for (final comp in newComponents) {
      if (comp.itemId == null) continue;

      if (comp.recipeId != null && existingMap.containsKey(comp.recipeId)) {
        // Update existing
        final existing = existingMap[comp.recipeId]!;
        keptIds.add(comp.recipeId!);
        if (existing.componentProductId != comp.itemId ||
            existing.quantityRequired != comp.quantity) {
          await repo.update(existing.copyWith(
            componentProductId: comp.itemId!,
            quantityRequired: comp.quantity,
          ));
        }
      } else {
        // Create new
        await repo.create(ProductRecipeModel(
          id: const Uuid().v7(),
          companyId: company.id,
          parentProductId: parentProductId,
          componentProductId: comp.itemId!,
          quantityRequired: comp.quantity,
          createdAt: now,
          updatedAt: now,
        ));
      }
    }

    // Delete removed components
    for (final existing in existingComponents) {
      if (!keptIds.contains(existing.id)) {
        await repo.delete(existing.id);
      }
    }
  }

  Future<void> _deleteRecipe(
    BuildContext context,
    WidgetRef ref,
    List<ProductRecipeModel> components,
  ) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(l.confirmDelete),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.no)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.yes)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final repo = ref.read(productRecipeRepositoryProvider);
    for (final c in components) {
      await repo.delete(c.id);
    }
  }
}

class _ComponentEntry {
  _ComponentEntry({
    this.recipeId,
    this.itemId,
    this.quantity = 1.0,
    required this.quantityController,
  });

  final String? recipeId;
  String? itemId;
  double quantity;
  final TextEditingController quantityController;
}

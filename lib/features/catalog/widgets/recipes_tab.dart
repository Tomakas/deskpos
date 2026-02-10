import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/product_recipe_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class RecipesTab extends ConsumerWidget {
  const RecipesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () => _showEditDialog(context, ref, items, null),
                        icon: const Icon(Icons.add),
                        label: Text(l.actionAdd),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: DataTable(
                            columnSpacing: 16,
                            showCheckboxColumn: false,
                            columns: [
                              DataColumn(label: Text(l.fieldParentProduct)),
                              DataColumn(label: Text(l.fieldComponent)),
                              DataColumn(label: Text(l.fieldQuantityRequired)),
                            ],
                            rows: recipes
                                .map((r) => DataRow(
                                      onSelectChanged: (_) =>
                                          _showEditDialog(context, ref, items, r),
                                      cells: [
                                        DataCell(Text(
                                          items
                                                  .where((i) => i.id == r.parentProductId)
                                                  .firstOrNull
                                                  ?.name ??
                                              '-',
                                        )),
                                        DataCell(Text(
                                          items
                                                  .where((i) => i.id == r.componentProductId)
                                                  .firstOrNull
                                                  ?.name ??
                                              '-',
                                        )),
                                        DataCell(Text(r.quantityRequired.toString())),
                                      ],
                                    ))
                                .toList(),
                          ),
                        ),
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

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    List<ItemModel> items,
    ProductRecipeModel? existing,
  ) async {
    final l = context.l10n;
    final qtyCtrl = TextEditingController(
        text: existing != null ? existing.quantityRequired.toString() : '');
    var parentProductId = existing?.parentProductId;
    var componentProductId = existing?.componentProductId;

    final theme = Theme.of(context);
    final result = await showDialog<Object>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? l.actionAdd : l.actionEdit),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String?>(
                  initialValue: parentProductId,
                  decoration: InputDecoration(labelText: l.fieldParentProduct),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('-')),
                    ...items.map(
                        (i) => DropdownMenuItem(value: i.id, child: Text(i.name))),
                  ],
                  onChanged: (v) => setDialogState(() => parentProductId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: componentProductId,
                  decoration: InputDecoration(labelText: l.fieldComponent),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('-')),
                    ...items.map(
                        (i) => DropdownMenuItem(value: i.id, child: Text(i.name))),
                  ],
                  onChanged: (v) => setDialogState(() => componentProductId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyCtrl,
                  decoration: InputDecoration(labelText: l.fieldQuantityRequired),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
            if (existing != null)
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'delete'),
                child: Text(l.actionDelete, style: TextStyle(color: theme.colorScheme.error)),
              ),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.actionSave)),
          ],
        ),
      ),
    );

    if (result == 'delete') {
      if (!context.mounted) return;
      await _delete(context, ref, existing!);
      return;
    }
    if (result != true || parentProductId == null || componentProductId == null) return;

    final company = ref.read(currentCompanyProvider)!;
    final repo = ref.read(productRecipeRepositoryProvider);
    final now = DateTime.now();
    final qty = double.tryParse(qtyCtrl.text) ?? 1.0;

    if (existing != null) {
      await repo.update(existing.copyWith(
        parentProductId: parentProductId!,
        componentProductId: componentProductId!,
        quantityRequired: qty,
      ));
    } else {
      await repo.create(ProductRecipeModel(
        id: const Uuid().v7(),
        companyId: company.id,
        parentProductId: parentProductId!,
        componentProductId: componentProductId!,
        quantityRequired: qty,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, ProductRecipeModel recipe) async {
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
    if (confirmed == true) {
      await ref.read(productRecipeRepositoryProvider).delete(recipe.id);
    }
  }
}

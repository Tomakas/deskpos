import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/enums/item_type.dart';
import '../../../core/data/enums/unit_type.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/tax_rate_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';

class ProductsTab extends ConsumerWidget {
  const ProductsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    final itemsStream = ref.watch(itemRepositoryProvider).watchAll(company.id);
    final categoriesStream = ref.watch(categoryRepositoryProvider).watchAll(company.id);
    final taxRatesStream = ref.watch(taxRateRepositoryProvider).watchAll(company.id);

    return StreamBuilder<List<ItemModel>>(
      stream: itemsStream,
      builder: (context, itemsSnap) {
        return StreamBuilder<List<CategoryModel>>(
          stream: categoriesStream,
          builder: (context, catSnap) {
            return StreamBuilder<List<TaxRateModel>>(
              stream: taxRatesStream,
              builder: (context, taxSnap) {
                final items = itemsSnap.data ?? [];
                final categories = catSnap.data ?? [];
                final taxRates = taxSnap.data ?? [];

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: () =>
                                _showEditDialog(context, ref, categories, taxRates, null),
                            icon: const Icon(Icons.add),
                            label: Text(l.actionAdd),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text(l.fieldName)),
                            DataColumn(label: Text(l.fieldCategory)),
                            DataColumn(label: Text(l.fieldPrice)),
                            DataColumn(label: Text(l.fieldTaxRate)),
                            DataColumn(label: Text(l.fieldType)),
                            DataColumn(label: Text(l.fieldActive)),
                            DataColumn(label: Text(l.fieldActions)),
                          ],
                          rows: items
                              .map((item) => DataRow(cells: [
                                    DataCell(Text(item.name)),
                                    DataCell(Text(
                                      categories
                                              .where((c) => c.id == item.categoryId)
                                              .firstOrNull
                                              ?.name ??
                                          '-',
                                    )),
                                    DataCell(Text((item.unitPrice / 100).toStringAsFixed(2))),
                                    DataCell(Text(
                                      taxRates
                                              .where((t) => t.id == item.saleTaxRateId)
                                              .firstOrNull
                                              ?.label ??
                                          '-',
                                    )),
                                    DataCell(Text(item.itemType.name)),
                                    DataCell(Icon(
                                      item.isActive ? Icons.check_circle : Icons.cancel,
                                      color: item.isActive ? Colors.green : Colors.grey,
                                      size: 20,
                                    )),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () => _showEditDialog(
                                              context, ref, categories, taxRates, item),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20),
                                          onPressed: () => _delete(context, ref, item),
                                        ),
                                      ],
                                    )),
                                  ]))
                              .toList(),
                        ),
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
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    List<CategoryModel> categories,
    List<TaxRateModel> taxRates,
    ItemModel? existing,
  ) async {
    final l = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(
        text: existing != null ? (existing.unitPrice / 100).toStringAsFixed(2) : '');
    var categoryId = existing?.categoryId;
    var taxRateId = existing?.saleTaxRateId ??
        (taxRates.where((t) => t.isDefault).firstOrNull?.id);
    var itemType = existing?.itemType ?? ItemType.product;
    var isActive = existing?.isActive ?? true;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? l.actionAdd : l.actionEdit),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: l.fieldName),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceCtrl,
                    decoration: InputDecoration(labelText: l.fieldPrice),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: categoryId,
                    decoration: InputDecoration(labelText: l.fieldCategory),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('-')),
                      ...categories
                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (v) => setDialogState(() => categoryId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: taxRateId,
                    decoration: InputDecoration(labelText: l.fieldTaxRate),
                    items: taxRates
                        .map((t) => DropdownMenuItem(value: t.id, child: Text(t.label)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => taxRateId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ItemType>(
                    initialValue: itemType,
                    decoration: InputDecoration(labelText: l.fieldType),
                    items: ItemType.values
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => itemType = v!),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text(l.fieldActive),
                    value: isActive,
                    onChanged: (v) => setDialogState(() => isActive = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.actionSave)),
          ],
        ),
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty) return;

    final company = ref.read(currentCompanyProvider)!;
    final repo = ref.read(itemRepositoryProvider);
    final now = DateTime.now();
    final priceInCents = ((double.tryParse(priceCtrl.text) ?? 0) * 100).round();

    if (existing != null) {
      await repo.update(existing.copyWith(
        name: nameCtrl.text.trim(),
        categoryId: categoryId,
        unitPrice: priceInCents,
        saleTaxRateId: taxRateId,
        itemType: itemType,
        isActive: isActive,
      ));
    } else {
      await repo.create(ItemModel(
        id: const Uuid().v7(),
        companyId: company.id,
        name: nameCtrl.text.trim(),
        categoryId: categoryId,
        unitPrice: priceInCents,
        saleTaxRateId: taxRateId,
        itemType: itemType,
        unit: UnitType.ks,
        isActive: isActive,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, ItemModel item) async {
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
      await ref.read(itemRepositoryProvider).delete(item.id);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/enums/item_type.dart';
import '../../../core/data/enums/unit_type.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/manufacturer_model.dart';
import '../../../core/data/models/supplier_model.dart';
import '../../../core/data/models/tax_rate_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../l10n/app_localizations.dart';

String _localizedItemType(AppLocalizations l, ItemType type) {
  return switch (type) {
    ItemType.product => l.itemTypeProduct,
    ItemType.service => l.itemTypeService,
    ItemType.counter => l.itemTypeCounter,
    ItemType.recipe => l.itemTypeRecipe,
    ItemType.ingredient => l.itemTypeIngredient,
    ItemType.variant => l.itemTypeVariant,
    ItemType.modifier => l.itemTypeModifier,
  };
}

class CatalogProductsTab extends ConsumerWidget {
  const CatalogProductsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    final itemsStream = ref.watch(itemRepositoryProvider).watchAll(company.id);
    final categoriesStream = ref.watch(categoryRepositoryProvider).watchAll(company.id);
    final taxRatesStream = ref.watch(taxRateRepositoryProvider).watchAll(company.id);
    final suppliersStream = ref.watch(supplierRepositoryProvider).watchAll(company.id);
    final manufacturersStream = ref.watch(manufacturerRepositoryProvider).watchAll(company.id);

    return StreamBuilder<List<ItemModel>>(
      stream: itemsStream,
      builder: (context, itemsSnap) {
        return StreamBuilder<List<CategoryModel>>(
          stream: categoriesStream,
          builder: (context, catSnap) {
            return StreamBuilder<List<TaxRateModel>>(
              stream: taxRatesStream,
              builder: (context, taxSnap) {
                return StreamBuilder<List<SupplierModel>>(
                  stream: suppliersStream,
                  builder: (context, supplierSnap) {
                    return StreamBuilder<List<ManufacturerModel>>(
                      stream: manufacturersStream,
                      builder: (context, mfgSnap) {
                        final items = itemsSnap.data ?? [];
                        final categories = catSnap.data ?? [];
                        final taxRates = taxSnap.data ?? [];
                        final suppliers = supplierSnap.data ?? [];
                        final manufacturers = mfgSnap.data ?? [];

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  FilledButton.icon(
                                    onPressed: () => _showEditDialog(
                                        context, ref, categories, taxRates, suppliers, manufacturers, null),
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
                                    DataColumn(label: Text(l.fieldSupplier)),
                                    DataColumn(label: Text(l.fieldManufacturer)),
                                    DataColumn(label: Text(l.fieldPurchasePrice)),
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
                                            DataCell(Text(_localizedItemType(l, item.itemType))),
                                            DataCell(Text(
                                              suppliers
                                                      .where((s) => s.id == item.supplierId)
                                                      .firstOrNull
                                                      ?.supplierName ??
                                                  '-',
                                            )),
                                            DataCell(Text(
                                              manufacturers
                                                      .where((m) => m.id == item.manufacturerId)
                                                      .firstOrNull
                                                      ?.name ??
                                                  '-',
                                            )),
                                            DataCell(Text(
                                              item.purchasePrice != null
                                                  ? (item.purchasePrice! / 100).toStringAsFixed(2)
                                                  : '-',
                                            )),
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
                                                      context, ref, categories, taxRates, suppliers, manufacturers, item),
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
    List<SupplierModel> suppliers,
    List<ManufacturerModel> manufacturers,
    ItemModel? existing,
  ) async {
    final l = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(
        text: existing != null ? (existing.unitPrice / 100).toStringAsFixed(2) : '');
    final altSkuCtrl = TextEditingController(text: existing?.altSku ?? '');
    final purchasePriceCtrl = TextEditingController(
        text: existing?.purchasePrice != null
            ? (existing!.purchasePrice! / 100).toStringAsFixed(2)
            : '');
    var categoryId = existing?.categoryId;
    var taxRateId = existing?.saleTaxRateId ??
        (taxRates.where((t) => t.isDefault).firstOrNull?.id);
    var itemType = existing?.itemType ?? ItemType.product;
    var isActive = existing?.isActive ?? true;
    var isOnSale = existing?.isOnSale ?? true;
    var isStockTracked = existing?.isStockTracked ?? false;
    var supplierId = existing?.supplierId;
    var manufacturerId = existing?.manufacturerId;
    var purchaseTaxRateId = existing?.purchaseTaxRateId;
    var parentId = existing?.parentId;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? l.actionAdd : l.actionEdit),
          content: SizedBox(
            width: 500,
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
                        .map((t) => DropdownMenuItem(value: t, child: Text(_localizedItemType(l, t))))
                        .toList(),
                    onChanged: (v) => setDialogState(() => itemType = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: altSkuCtrl,
                    decoration: InputDecoration(labelText: l.fieldAltSku),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: purchasePriceCtrl,
                    decoration: InputDecoration(labelText: l.fieldPurchasePrice),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: purchaseTaxRateId,
                    decoration: InputDecoration(labelText: l.fieldPurchaseTaxRate),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('-')),
                      ...taxRates
                          .map((t) => DropdownMenuItem(value: t.id, child: Text(t.label))),
                    ],
                    onChanged: (v) => setDialogState(() => purchaseTaxRateId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: supplierId,
                    decoration: InputDecoration(labelText: l.fieldSupplier),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('-')),
                      ...suppliers
                          .map((s) => DropdownMenuItem(value: s.id, child: Text(s.supplierName))),
                    ],
                    onChanged: (v) => setDialogState(() => supplierId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: manufacturerId,
                    decoration: InputDecoration(labelText: l.fieldManufacturer),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('-')),
                      ...manufacturers
                          .map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))),
                    ],
                    onChanged: (v) => setDialogState(() => manufacturerId = v),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text(l.fieldActive),
                    value: isActive,
                    onChanged: (v) => setDialogState(() => isActive = v),
                  ),
                  SwitchListTile(
                    title: Text(l.fieldOnSale),
                    value: isOnSale,
                    onChanged: (v) => setDialogState(() => isOnSale = v),
                  ),
                  SwitchListTile(
                    title: Text(l.fieldStockTracked),
                    value: isStockTracked,
                    onChanged: (v) => setDialogState(() => isStockTracked = v),
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
    final purchasePriceCents = purchasePriceCtrl.text.trim().isNotEmpty
        ? ((double.tryParse(purchasePriceCtrl.text) ?? 0) * 100).round()
        : null;

    if (existing != null) {
      await repo.update(existing.copyWith(
        name: nameCtrl.text.trim(),
        categoryId: categoryId,
        unitPrice: priceInCents,
        saleTaxRateId: taxRateId,
        itemType: itemType,
        isActive: isActive,
        altSku: altSkuCtrl.text.trim().isNotEmpty ? altSkuCtrl.text.trim() : null,
        purchasePrice: purchasePriceCents,
        purchaseTaxRateId: purchaseTaxRateId,
        isOnSale: isOnSale,
        isStockTracked: isStockTracked,
        manufacturerId: manufacturerId,
        supplierId: supplierId,
        parentId: parentId,
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
        altSku: altSkuCtrl.text.trim().isNotEmpty ? altSkuCtrl.text.trim() : null,
        purchasePrice: purchasePriceCents,
        purchaseTaxRateId: purchaseTaxRateId,
        isOnSale: isOnSale,
        isStockTracked: isStockTracked,
        manufacturerId: manufacturerId,
        supplierId: supplierId,
        parentId: parentId,
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

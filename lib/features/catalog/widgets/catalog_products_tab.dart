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
import '../../../core/utils/search_utils.dart';
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

class CatalogProductsTab extends ConsumerStatefulWidget {
  const CatalogProductsTab({super.key});

  @override
  ConsumerState<CatalogProductsTab> createState() => _CatalogProductsTabState();
}

class _CatalogProductsTabState extends ConsumerState<CatalogProductsTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  // Filter state
  ItemType? _filterItemType;
  String? _filterCategoryId;
  bool? _filterIsActive;
  bool? _filterIsOnSale;
  bool? _filterIsStockTracked;
  String? _filterSupplierId;
  String? _filterManufacturerId;

  bool get _hasActiveFilters =>
      _filterItemType != null ||
      _filterCategoryId != null ||
      _filterIsActive != null ||
      _filterIsOnSale != null ||
      _filterIsStockTracked != null ||
      _filterSupplierId != null ||
      _filterManufacturerId != null;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold);
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

                        final filtered = items.where((item) {
                          // Filters
                          if (_filterItemType != null && item.itemType != _filterItemType) return false;
                          if (_filterCategoryId != null && item.categoryId != _filterCategoryId) return false;
                          if (_filterIsActive != null && item.isActive != _filterIsActive) return false;
                          if (_filterIsOnSale != null && item.isOnSale != _filterIsOnSale) return false;
                          if (_filterIsStockTracked != null && item.isStockTracked != _filterIsStockTracked) return false;
                          if (_filterSupplierId != null && item.supplierId != _filterSupplierId) return false;
                          if (_filterManufacturerId != null && item.manufacturerId != _filterManufacturerId) return false;

                          // Search
                          if (_query.isEmpty) return true;
                          final q = _query;
                          if (normalizeSearch(item.name).contains(q)) return true;
                          if (item.altSku != null && normalizeSearch(item.altSku!).contains(q)) return true;
                          final catName = categories
                              .where((c) => c.id == item.categoryId)
                              .firstOrNull
                              ?.name;
                          if (catName != null && normalizeSearch(catName).contains(q)) return true;
                          if (normalizeSearch(_localizedItemType(l, item.itemType)).contains(q)) return true;
                          return false;
                        }).toList();

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _searchCtrl,
                                      decoration: InputDecoration(
                                        hintText: l.searchHint,
                                        prefixIcon: const Icon(Icons.search),
                                        suffixIcon: _query.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(Icons.close),
                                                onPressed: () {
                                                  _searchCtrl.clear();
                                                  setState(() => _query = '');
                                                },
                                              )
                                            : null,
                                        isDense: true,
                                        border: const OutlineInputBorder(),
                                      ),
                                      onChanged: (v) => setState(() => _query = normalizeSearch(v)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.filter_list,
                                      color: _hasActiveFilters
                                          ? theme.colorScheme.primary
                                          : null,
                                    ),
                                    onPressed: () => _showFilterDialog(
                                      context,
                                      l,
                                      categories,
                                      suppliers,
                                      manufacturers,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton.icon(
                                    onPressed: () => _showEditDialog(
                                        context, ref, categories, taxRates, suppliers, manufacturers, null),
                                    icon: const Icon(Icons.add),
                                    label: Text(l.actionAdd),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                              ),
                              child: Row(
                                children: [
                                  Expanded(flex: 3, child: Text(l.fieldName, style: headerStyle)),
                                  Expanded(flex: 2, child: Text(l.fieldCategory, style: headerStyle)),
                                  Expanded(flex: 1, child: Text(l.fieldPrice, style: headerStyle)),
                                  Expanded(flex: 2, child: Text(l.fieldTaxRate, style: headerStyle)),
                                  Expanded(flex: 2, child: Text(l.fieldType, style: headerStyle)),
                                  Expanded(flex: 2, child: Text(l.fieldSupplier, style: headerStyle)),
                                  Expanded(flex: 1, child: Text(l.fieldPurchasePrice, style: headerStyle)),
                                  Expanded(flex: 1, child: Text(l.fieldActive, style: headerStyle)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  return InkWell(
                                    onTap: () => _showEditDialog(
                                        context, ref, categories, taxRates, suppliers, manufacturers, item),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3))),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(flex: 3, child: Text(item.name, overflow: TextOverflow.ellipsis)),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              categories
                                                      .where((c) => c.id == item.categoryId)
                                                      .firstOrNull
                                                      ?.name ??
                                                  '-',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(flex: 1, child: Text((item.unitPrice / 100).toStringAsFixed(2), overflow: TextOverflow.ellipsis)),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              taxRates
                                                      .where((t) => t.id == item.saleTaxRateId)
                                                      .firstOrNull
                                                      ?.label ??
                                                  '-',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(flex: 2, child: Text(_localizedItemType(l, item.itemType), overflow: TextOverflow.ellipsis)),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              suppliers
                                                      .where((s) => s.id == item.supplierId)
                                                      .firstOrNull
                                                      ?.supplierName ??
                                                  '-',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              item.purchasePrice != null
                                                  ? (item.purchasePrice! / 100).toStringAsFixed(2)
                                                  : '-',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Icon(
                                                item.isActive ? Icons.check_circle : Icons.cancel,
                                                color: item.isActive ? Colors.green : Colors.grey,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
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
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showFilterDialog(
    BuildContext context,
    AppLocalizations l,
    List<CategoryModel> categories,
    List<SupplierModel> suppliers,
    List<ManufacturerModel> manufacturers,
  ) async {
    var itemType = _filterItemType;
    var categoryId = _filterCategoryId;
    var isActive = _filterIsActive;
    var isOnSale = _filterIsOnSale;
    var isStockTracked = _filterIsStockTracked;
    var supplierId = _filterSupplierId;
    var manufacturerId = _filterManufacturerId;

    var resetCount = 0;

    final boolItems = [
      DropdownMenuItem<bool?>(value: null, child: Text(l.filterAll)),
      DropdownMenuItem<bool?>(value: true, child: Text(l.yes)),
      DropdownMenuItem<bool?>(value: false, child: Text(l.no)),
    ];

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l.filterTitle),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                key: ValueKey(resetCount),
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<ItemType?>(
                    initialValue: itemType,
                    decoration: InputDecoration(labelText: l.fieldType),
                    items: [
                      DropdownMenuItem<ItemType?>(value: null, child: Text(l.filterAll)),
                      ...ItemType.values.map(
                        (t) => DropdownMenuItem(value: t, child: Text(_localizedItemType(l, t))),
                      ),
                    ],
                    onChanged: (v) => setDialogState(() => itemType = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: categoryId,
                    decoration: InputDecoration(labelText: l.fieldCategory),
                    items: [
                      DropdownMenuItem<String?>(value: null, child: Text(l.filterAll)),
                      ...categories.map(
                        (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ),
                    ],
                    onChanged: (v) => setDialogState(() => categoryId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<bool?>(
                    initialValue: isActive,
                    decoration: InputDecoration(labelText: l.fieldActive),
                    items: boolItems,
                    onChanged: (v) => setDialogState(() => isActive = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<bool?>(
                    initialValue: isOnSale,
                    decoration: InputDecoration(labelText: l.fieldOnSale),
                    items: boolItems,
                    onChanged: (v) => setDialogState(() => isOnSale = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<bool?>(
                    initialValue: isStockTracked,
                    decoration: InputDecoration(labelText: l.fieldStockTracked),
                    items: boolItems,
                    onChanged: (v) => setDialogState(() => isStockTracked = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: supplierId,
                    decoration: InputDecoration(labelText: l.fieldSupplier),
                    items: [
                      DropdownMenuItem<String?>(value: null, child: Text(l.filterAll)),
                      ...suppliers.map(
                        (s) => DropdownMenuItem(value: s.id, child: Text(s.supplierName)),
                      ),
                    ],
                    onChanged: (v) => setDialogState(() => supplierId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: manufacturerId,
                    decoration: InputDecoration(labelText: l.fieldManufacturer),
                    items: [
                      DropdownMenuItem<String?>(value: null, child: Text(l.filterAll)),
                      ...manufacturers.map(
                        (m) => DropdownMenuItem(value: m.id, child: Text(m.name)),
                      ),
                    ],
                    onChanged: (v) => setDialogState(() => manufacturerId = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  itemType = null;
                  categoryId = null;
                  isActive = null;
                  isOnSale = null;
                  isStockTracked = null;
                  supplierId = null;
                  manufacturerId = null;
                  resetCount++;
                });
              },
              child: Text(l.filterReset),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.actionClose),
            ),
          ],
        ),
      ),
    );

    setState(() {
      _filterItemType = itemType;
      _filterCategoryId = categoryId;
      _filterIsActive = isActive;
      _filterIsOnSale = isOnSale;
      _filterIsStockTracked = isStockTracked;
      _filterSupplierId = supplierId;
      _filterManufacturerId = manufacturerId;
    });
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

    final theme = Theme.of(context);
    final result = await showDialog<Object>(
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

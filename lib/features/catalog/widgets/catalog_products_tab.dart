import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/enums/item_type.dart';
import '../../../core/data/enums/unit_type.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/item_modifier_group_model.dart';
import '../../../core/data/models/manufacturer_model.dart';
import '../../../core/data/models/modifier_group_model.dart';
import '../../../core/data/models/supplier_model.dart';
import '../../../core/data/models/tax_rate_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/utils/unit_type_l10n.dart';
import '../../../core/widgets/highlighted_text.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';
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
                            PosTableToolbar(
                              searchController: _searchCtrl,
                              searchHint: l.searchHint,
                              onSearchChanged: (v) => setState(() => _query = normalizeSearch(v)),
                              trailing: [
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
                            Expanded(
                              child: PosTable<ItemModel>(
                                columns: [
                                  PosColumn(label: l.fieldName, flex: 3, cellBuilder: (item) => HighlightedText(item.name, query: _query, overflow: TextOverflow.ellipsis)),
                                  PosColumn(
                                    label: l.fieldCategory,
                                    flex: 2,
                                    cellBuilder: (item) => HighlightedText(
                                      categories.where((c) => c.id == item.categoryId).firstOrNull?.name ?? '-',
                                      query: _query,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  PosColumn(label: l.fieldPrice, flex: 1, cellBuilder: (item) => Text(ref.moneyValue(item.unitPrice), overflow: TextOverflow.ellipsis)),
                                  PosColumn(
                                    label: l.fieldTaxRate,
                                    flex: 2,
                                    cellBuilder: (item) => Text(
                                      taxRates.where((t) => t.id == item.saleTaxRateId).firstOrNull?.label ?? '-',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  PosColumn(label: l.fieldType, flex: 2, cellBuilder: (item) => Text(_localizedItemType(l, item.itemType), overflow: TextOverflow.ellipsis)),
                                  PosColumn(
                                    label: l.fieldSupplier,
                                    flex: 2,
                                    cellBuilder: (item) => Text(
                                      suppliers.where((s) => s.id == item.supplierId).firstOrNull?.supplierName ?? '-',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  PosColumn(
                                    label: l.fieldPurchasePrice,
                                    flex: 1,
                                    cellBuilder: (item) => Text(
                                      item.purchasePrice != null ? ref.moneyValue(item.purchasePrice!) : '-',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  PosColumn(
                                    label: l.fieldActive,
                                    flex: 1,
                                    cellBuilder: (item) => Align(
                                      alignment: Alignment.centerLeft,
                                      child: Icon(
                                        item.isActive ? Icons.check_circle : Icons.cancel,
                                        color: boolIndicatorColor(item.isActive, context),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                                items: filtered,
                                onRowTap: (item) => _showEditDialog(
                                    context, ref, categories, taxRates, suppliers, manufacturers, item),
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
        builder: (ctx, setDialogState) => PosDialogShell(
          title: l.filterTitle,
          maxWidth: 400,
          scrollable: true,
          children: [
            Column(
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
            const SizedBox(height: 24),
            PosDialogActions(
              actions: [
                OutlinedButton(
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
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l.actionClose),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;
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
    final currency = ref.read(currentCurrencyProvider).value;
    final priceCtrl = TextEditingController(
        text: existing != null ? minorUnitsToInputString(existing.unitPrice, currency) : '');
    final descriptionCtrl = TextEditingController(text: existing?.description ?? '');
    final skuCtrl = TextEditingController(text: existing?.sku ?? '');
    final altSkuCtrl = TextEditingController(text: existing?.altSku ?? '');
    final purchasePriceCtrl = TextEditingController(
        text: existing?.purchasePrice != null
            ? minorUnitsToInputString(existing!.purchasePrice!, currency)
            : '');
    var categoryId = existing?.categoryId;
    var taxRateId = existing?.saleTaxRateId ??
        (taxRates.where((t) => t.isDefault).firstOrNull?.id);
    var itemType = existing?.itemType ?? ItemType.product;
    var unit = existing?.unit ?? UnitType.ks;
    var isActive = existing?.isActive ?? true;
    var isOnSale = existing?.isOnSale ?? true;
    var isStockTracked = existing?.isStockTracked ?? false;
    var supplierId = existing?.supplierId;
    var manufacturerId = existing?.manufacturerId;
    var purchaseTaxRateId = existing?.purchaseTaxRateId;
    var parentId = existing?.parentId;

    final result = await showDialog<Object>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => PosDialogShell(
          title: existing == null ? l.actionAdd : l.actionEdit,
          maxWidth: 600,
          scrollable: true,
          children: [
            // Row 1: Name + Category
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: l.fieldName),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String?>(
                    initialValue: categoryId,
                    decoration: InputDecoration(labelText: l.fieldCategory),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('-')),
                      ...categories
                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (v) => setDialogState(() => categoryId = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row 2: Sale Price + Purchase Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    decoration: InputDecoration(labelText: l.fieldPrice),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: purchasePriceCtrl,
                    decoration: InputDecoration(labelText: l.fieldPurchasePrice),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row 3: Sale Tax + Purchase Tax
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: taxRateId,
                    decoration: InputDecoration(labelText: l.fieldTaxRate),
                    items: taxRates
                        .map((t) => DropdownMenuItem(value: t.id, child: Text(t.label)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => taxRateId = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: purchaseTaxRateId,
                    decoration: InputDecoration(labelText: l.fieldPurchaseTaxRate),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('-')),
                      ...taxRates
                          .map((t) => DropdownMenuItem(value: t.id, child: Text(t.label))),
                    ],
                    onChanged: (v) => setDialogState(() => purchaseTaxRateId = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row 4: Supplier + Manufacturer
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: supplierId,
                    decoration: InputDecoration(labelText: l.fieldSupplier),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('-')),
                      ...suppliers
                          .map((s) => DropdownMenuItem(value: s.id, child: Text(s.supplierName))),
                    ],
                    onChanged: (v) => setDialogState(() => supplierId = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: manufacturerId,
                    decoration: InputDecoration(labelText: l.fieldManufacturer),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('-')),
                      ...manufacturers
                          .map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))),
                    ],
                    onChanged: (v) => setDialogState(() => manufacturerId = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row 5: Item Type — toggle buttons
            Row(
              children: [
                for (final t in ItemType.values) ...[
                  if (t != ItemType.values.first) const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: FilterChip(
                        label: SizedBox(
                          width: double.infinity,
                          child: Text(
                            _localizedItemType(l, t),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        selected: itemType == t,
                        onSelected: (_) => setDialogState(() => itemType = t),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Row 6: SKU + Alt SKU + Unit
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: skuCtrl,
                    decoration: InputDecoration(labelText: l.fieldSku),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: altSkuCtrl,
                    decoration: InputDecoration(labelText: l.fieldAltSku),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<UnitType>(
                    initialValue: unit,
                    decoration: InputDecoration(labelText: l.fieldUnit),
                    items: UnitType.values
                        .map((u) => DropdownMenuItem(value: u, child: Text(localizedUnitType(l, u))))
                        .toList(),
                    onChanged: (v) => setDialogState(() => unit = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row 8: Description
            TextField(
              controller: descriptionCtrl,
              decoration: InputDecoration(labelText: l.fieldDescription),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            // Switches
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
            // Variants section — only for existing products
            if (existing != null && existing.itemType == ItemType.product)
              _VariantsExpansionTile(
                product: existing,
                categories: categories,
                taxRates: taxRates,
              ),
            // Modifier groups section — only for existing products
            if (existing != null && existing.itemType == ItemType.product)
              _ModifierGroupsExpansionTile(product: existing),
            const SizedBox(height: 24),
            PosDialogActions(
              leading: existing != null
                  ? OutlinedButton(
                      style: PosButtonStyles.destructiveOutlined(ctx),
                      onPressed: () async {
                        if (!await confirmDelete(ctx, l) || !ctx.mounted) return;
                        await ref.read(itemRepositoryProvider).delete(existing.id);
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
          ],
        ),
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty || !mounted) return;

    final company = ref.read(currentCompanyProvider)!;
    final repo = ref.read(itemRepositoryProvider);
    final now = DateTime.now();
    final priceInCents = parseMoney(priceCtrl.text, currency);
    final purchasePriceCents = purchasePriceCtrl.text.trim().isNotEmpty
        ? parseMoney(purchasePriceCtrl.text, currency)
        : null;

    final descriptionValue = descriptionCtrl.text.trim().isNotEmpty ? descriptionCtrl.text.trim() : null;
    final skuValue = skuCtrl.text.trim().isNotEmpty ? skuCtrl.text.trim() : null;
    final altSkuValue = altSkuCtrl.text.trim().isNotEmpty ? altSkuCtrl.text.trim() : null;

    if (existing != null) {
      await repo.update(existing.copyWith(
        name: nameCtrl.text.trim(),
        description: descriptionValue,
        categoryId: categoryId,
        unitPrice: priceInCents,
        saleTaxRateId: taxRateId,
        itemType: itemType,
        unit: unit,
        isActive: isActive,
        sku: skuValue,
        altSku: altSkuValue,
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
        description: descriptionValue,
        categoryId: categoryId,
        unitPrice: priceInCents,
        saleTaxRateId: taxRateId,
        itemType: itemType,
        unit: unit,
        isActive: isActive,
        sku: skuValue,
        altSku: altSkuValue,
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

}

class _VariantsExpansionTile extends ConsumerWidget {
  const _VariantsExpansionTile({
    required this.product,
    required this.categories,
    required this.taxRates,
  });
  final ItemModel product;
  final List<CategoryModel> categories;
  final List<TaxRateModel> taxRates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return ExpansionTile(
      title: Text(l.variants),
      children: [
        StreamBuilder<List<ItemModel>>(
          stream: ref.watch(itemRepositoryProvider).watchVariants(product.id),
          builder: (context, snap) {
            final variants = snap.data ?? [];
            if (variants.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l.noVariants, style: theme.textTheme.bodySmall),
              );
            }
            return Column(
              children: [
                for (final v in variants)
                  ListTile(
                    dense: true,
                    title: Text(v.name),
                    trailing: Text(ref.moneyValue(v.unitPrice)),
                    onTap: () => _showVariantEditDialog(context, ref, v),
                    onLongPress: () => _confirmDeleteVariant(context, ref, v),
                  ),
              ],
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showVariantEditDialog(context, ref, null),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l.addVariant),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showVariantEditDialog(BuildContext context, WidgetRef ref, ItemModel? existing) async {
    final l = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final currency = ref.read(currentCurrencyProvider).value;
    final priceCtrl = TextEditingController(
      text: existing != null
          ? minorUnitsToInputString(existing.unitPrice, currency)
          : minorUnitsToInputString(product.unitPrice, currency),
    );
    final skuCtrl = TextEditingController(text: existing?.sku ?? '');
    final altSkuCtrl = TextEditingController(text: existing?.altSku ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => PosDialogShell(
        title: existing == null ? l.addVariant : l.editVariant,
        maxWidth: 400,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(labelText: l.fieldName),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: priceCtrl,
            decoration: InputDecoration(labelText: l.fieldPrice),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: skuCtrl,
            decoration: const InputDecoration(labelText: 'SKU'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: altSkuCtrl,
            decoration: InputDecoration(labelText: l.fieldAltSku),
          ),
          const SizedBox(height: 24),
          PosDialogActions(
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.actionSave),
              ),
            ],
          ),
        ],
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty) return;
    if (!context.mounted) return;

    final repo = ref.read(itemRepositoryProvider);
    final priceInCents = parseMoney(priceCtrl.text, currency);
    final now = DateTime.now();

    if (existing != null) {
      await repo.update(existing.copyWith(
        name: nameCtrl.text.trim(),
        unitPrice: priceInCents,
        sku: skuCtrl.text.trim().isNotEmpty ? skuCtrl.text.trim() : null,
        altSku: altSkuCtrl.text.trim().isNotEmpty ? altSkuCtrl.text.trim() : null,
      ));
    } else {
      await repo.create(ItemModel(
        id: const Uuid().v7(),
        companyId: product.companyId,
        name: nameCtrl.text.trim(),
        categoryId: product.categoryId,
        unitPrice: priceInCents,
        saleTaxRateId: product.saleTaxRateId,
        itemType: ItemType.variant,
        unit: product.unit,
        parentId: product.id,
        sku: skuCtrl.text.trim().isNotEmpty ? skuCtrl.text.trim() : null,
        altSku: altSkuCtrl.text.trim().isNotEmpty ? altSkuCtrl.text.trim() : null,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

  Future<void> _confirmDeleteVariant(BuildContext context, WidgetRef ref, ItemModel variant) async {
    if (!await confirmDelete(context, context.l10n)) return;
    await ref.read(itemRepositoryProvider).delete(variant.id);
  }
}

class _ModifierGroupsExpansionTile extends ConsumerWidget {
  const _ModifierGroupsExpansionTile({required this.product});
  final ItemModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final company = ref.watch(currentCompanyProvider);
    if (company == null) return const SizedBox.shrink();

    return StreamBuilder<List<ItemModifierGroupModel>>(
      stream: ref.watch(itemModifierGroupRepositoryProvider).watchByItem(product.id),
      builder: (context, assignSnap) {
        final assignments = assignSnap.data ?? [];

        return StreamBuilder<List<ModifierGroupModel>>(
          stream: ref.watch(modifierGroupRepositoryProvider).watchAll(company.id),
          builder: (context, groupsSnap) {
            final allGroups = groupsSnap.data ?? [];
            final groupMap = {for (final g in allGroups) g.id: g};

            return ExpansionTile(
              title: Text(l.modifierGroups),
              children: [
                if (assignments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l.noModifierGroups, style: theme.textTheme.bodySmall),
                  ),
                for (final assignment in assignments)
                  Builder(
                    builder: (context) {
                      final group = groupMap[assignment.modifierGroupId];
                      if (group == null) return const SizedBox.shrink();
                      final rule = group.minSelections >= 1
                          ? l.modifierGroupRequired
                          : l.optional;
                      final maxLabel = group.maxSelections?.toString() ?? l.unlimited;
                      return ListTile(
                        dense: true,
                        title: Text(group.name),
                        subtitle: Text('$rule  ·  ${l.minSelections}: ${group.minSelections}  ·  ${l.maxSelections}: $maxLabel'),
                        trailing: IconButton(
                          icon: Icon(Icons.close, size: 18, color: theme.colorScheme.error),
                          onPressed: () async {
                            await ref.read(itemModifierGroupRepositoryProvider).delete(assignment.id);
                          },
                        ),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showAssignGroupDialog(context, ref, allGroups, assignments),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l.assignModifierGroup),
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

  Future<void> _showAssignGroupDialog(
    BuildContext context,
    WidgetRef ref,
    List<ModifierGroupModel> allGroups,
    List<ItemModifierGroupModel> existing,
  ) async {
    final l = context.l10n;
    final assignedIds = existing.map((e) => e.modifierGroupId).toSet();
    final available = allGroups.where((g) => !assignedIds.contains(g.id)).toList();

    if (available.isEmpty) return;

    final selected = await showDialog<ModifierGroupModel>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.assignModifierGroup),
        children: [
          for (final group in available)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, group),
              child: Text(group.name),
            ),
        ],
      ),
    );

    if (selected == null || !context.mounted) return;

    final now = DateTime.now();
    await ref.read(itemModifierGroupRepositoryProvider).create(
      ItemModifierGroupModel(
        id: const Uuid().v7(),
        companyId: product.companyId,
        itemId: product.id,
        modifierGroupId: selected.id,
        sortOrder: existing.length,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/item_model.dart';
import '../../../core/data/models/manufacturer_model.dart';
import '../../../core/data/models/supplier_model.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/utils/category_tree.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';

typedef InventoryTypeResult = ({Set<String> itemIds, bool blindMode});

enum _InventoryType { complete, byCategory, bySupplier, byManufacturer, selective }

class DialogInventoryType extends ConsumerStatefulWidget {
  const DialogInventoryType({super.key, required this.companyId});

  final String companyId;

  @override
  ConsumerState<DialogInventoryType> createState() => _DialogInventoryTypeState();
}

class _DialogInventoryTypeState extends ConsumerState<DialogInventoryType> {
  _InventoryType? _selectedType;
  final _selectedIds = <String>{};
  bool _blindMode = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    if (_selectedType == null) {
      return _buildTypeSelection(l);
    }
    return _buildEntitySelection(l);
  }

  Widget _buildTypeSelection(dynamic l) {
    return PosDialogShell(
      title: l.inventoryTypeTitle,
      maxWidth: 480,
      scrollable: true,
      showCloseButton: true,
      children: [
        ListTile(
          leading: const Icon(Icons.select_all),
          title: Text(l.inventoryTypeComplete),
          subtitle: Text(l.inventoryTypeCompleteDesc),
          onTap: () => Navigator.pop(context, (itemIds: <String>{}, blindMode: _blindMode)),
        ),
        ListTile(
          leading: const Icon(Icons.category),
          title: Text(l.inventoryTypeByCategory),
          subtitle: Text(l.inventoryTypeByCategoryDesc),
          onTap: () => setState(() => _selectedType = _InventoryType.byCategory),
        ),
        ListTile(
          leading: const Icon(Icons.local_shipping),
          title: Text(l.inventoryTypeBySupplier),
          subtitle: Text(l.inventoryTypeBySupplierDesc),
          onTap: () => setState(() => _selectedType = _InventoryType.bySupplier),
        ),
        ListTile(
          leading: const Icon(Icons.factory),
          title: Text(l.inventoryTypeByManufacturer),
          subtitle: Text(l.inventoryTypeByManufacturerDesc),
          onTap: () => setState(() => _selectedType = _InventoryType.byManufacturer),
        ),
        ListTile(
          leading: const Icon(Icons.checklist),
          title: Text(l.inventoryTypeSelective),
          subtitle: Text(l.inventoryTypeSelectiveDesc),
          onTap: () => setState(() => _selectedType = _InventoryType.selective),
        ),
        const Divider(),
        CheckboxListTile(
          value: _blindMode,
          title: Text(l.inventoryBlindMode),
          subtitle: Text(l.inventoryBlindModeDesc),
          onChanged: (v) => setState(() => _blindMode = v ?? false),
        ),
      ],
    );
  }

  Widget _buildEntitySelection(dynamic l) {
    return PosDialogShell(
      title: l.inventoryTypeTitle,
      maxWidth: 480,
      maxHeight: 600,
      expandHeight: true,
      showCloseButton: true,
      bottomActions: PosDialogActions(
        actions: [
          FilledButton(
            onPressed: _selectedIds.isEmpty ? null : _onContinue,
            child: Text(l.inventoryTypeContinue),
          ),
        ],
      ),
      children: [
        Expanded(
          child: _buildEntityList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  bool? _categoryCheckboxValue(String id, List<CategoryModel> all) {
    final ids = CategoryTree.getAllDescendantIds(id, all);
    final selectedCount = ids.where(_selectedIds.contains).length;
    if (selectedCount == 0) return false;
    if (selectedCount == ids.length) return true;
    return null;
  }

  void _toggleCategory(String id, List<CategoryModel> all) {
    final ids = CategoryTree.getAllDescendantIds(id, all);
    final currentValue = _categoryCheckboxValue(id, all);
    setState(() {
      if (currentValue == true) {
        _selectedIds.removeAll(ids);
      } else {
        _selectedIds.addAll(ids);
      }
    });
  }

  Widget _buildEntityList() {
    switch (_selectedType!) {
      case _InventoryType.byCategory:
        return _buildCategoryList();
      case _InventoryType.bySupplier:
        return _buildSupplierList();
      case _InventoryType.byManufacturer:
        return _buildManufacturerList();
      case _InventoryType.selective:
        return _buildItemList();
      case _InventoryType.complete:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCategoryList() {
    return StreamBuilder<List<CategoryModel>>(
      stream: ref.watch(categoryRepositoryProvider).watchAll(widget.companyId),
      builder: (context, snap) {
        final categories = snap.data ?? [];
        if (categories.isEmpty) {
          return Center(child: Text(context.l10n.inventoryTypeNoItems));
        }
        final sorted = CategoryTree.getSortedDisplayList(categories);
        return ListView.builder(
          itemCount: sorted.length,
          itemBuilder: (context, i) {
            final item = sorted[i];
            return CheckboxListTile(
              tristate: true,
              value: _categoryCheckboxValue(item.category.id, categories),
              contentPadding: EdgeInsets.only(
                left: 16.0 + item.depth * 24.0,
                right: 16.0,
              ),
              title: Text(
                item.category.name,
                style: TextStyle(
                  fontWeight: item.depth == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onChanged: (_) => _toggleCategory(item.category.id, categories),
            );
          },
        );
      },
    );
  }

  Widget _buildSupplierList() {
    return StreamBuilder<List<SupplierModel>>(
      stream: ref.watch(supplierRepositoryProvider).watchAll(widget.companyId),
      builder: (context, snap) {
        final entities = snap.data ?? [];
        if (entities.isEmpty) {
          return Center(child: Text(context.l10n.inventoryTypeNoItems));
        }
        return ListView.builder(
          itemCount: entities.length,
          itemBuilder: (context, i) {
            final e = entities[i];
            return CheckboxListTile(
              value: _selectedIds.contains(e.id),
              title: Text(e.supplierName),
              onChanged: (v) => setState(() {
                v == true ? _selectedIds.add(e.id) : _selectedIds.remove(e.id);
              }),
            );
          },
        );
      },
    );
  }

  Widget _buildManufacturerList() {
    return StreamBuilder<List<ManufacturerModel>>(
      stream: ref.watch(manufacturerRepositoryProvider).watchAll(widget.companyId),
      builder: (context, snap) {
        final entities = snap.data ?? [];
        if (entities.isEmpty) {
          return Center(child: Text(context.l10n.inventoryTypeNoItems));
        }
        return ListView.builder(
          itemCount: entities.length,
          itemBuilder: (context, i) {
            final e = entities[i];
            return CheckboxListTile(
              value: _selectedIds.contains(e.id),
              title: Text(e.name),
              onChanged: (v) => setState(() {
                v == true ? _selectedIds.add(e.id) : _selectedIds.remove(e.id);
              }),
            );
          },
        );
      },
    );
  }

  Widget _buildItemList() {
    return StreamBuilder<List<ItemModel>>(
      stream: ref.watch(itemRepositoryProvider).watchAll(widget.companyId),
      builder: (context, snap) {
        final entities = (snap.data ?? []).where((i) => i.isStockTracked).toList();
        if (entities.isEmpty) {
          return Center(child: Text(context.l10n.inventoryTypeNoItems));
        }
        return ListView.builder(
          itemCount: entities.length,
          itemBuilder: (context, i) {
            final e = entities[i];
            return CheckboxListTile(
              value: _selectedIds.contains(e.id),
              title: Text(e.name),
              onChanged: (v) => setState(() {
                v == true ? _selectedIds.add(e.id) : _selectedIds.remove(e.id);
              }),
            );
          },
        );
      },
    );
  }

  Future<void> _onContinue() async {
    if (_selectedType == _InventoryType.selective) {
      Navigator.pop(context, (itemIds: _selectedIds, blindMode: _blindMode));
      return;
    }

    // Load items and filter by selected entity IDs
    final items = await ref
        .read(itemRepositoryProvider)
        .watchAll(widget.companyId)
        .first;

    final stockTracked = items.where((i) => i.isStockTracked);

    final Set<String> itemIds;
    switch (_selectedType!) {
      case _InventoryType.byCategory:
        itemIds = stockTracked
            .where((i) => i.categoryId != null && _selectedIds.contains(i.categoryId))
            .map((i) => i.id)
            .toSet();
      case _InventoryType.bySupplier:
        itemIds = stockTracked
            .where((i) => i.supplierId != null && _selectedIds.contains(i.supplierId))
            .map((i) => i.id)
            .toSet();
      case _InventoryType.byManufacturer:
        itemIds = stockTracked
            .where((i) => i.manufacturerId != null && _selectedIds.contains(i.manufacturerId))
            .map((i) => i.id)
            .toSet();
      case _InventoryType.complete:
      case _InventoryType.selective:
        itemIds = {};
    }

    if (!mounted) return;
    Navigator.pop(context, (itemIds: itemIds, blindMode: _blindMode));
  }
}

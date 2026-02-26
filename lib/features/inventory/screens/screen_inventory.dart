import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/stock_document_type.dart';
import '../../../core/data/enums/stock_movement_direction.dart';
import '../../../core/data/models/category_model.dart';
import '../../../core/data/models/stock_document_model.dart';
import '../../../core/data/models/supplier_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/permission_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/stock_level_repository.dart';
import '../../../core/data/repositories/stock_movement_repository.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/utils/unit_type_l10n.dart';
import '../../../core/widgets/highlighted_text.dart';
import '../../../core/widgets/pos_table.dart';
import '../../../l10n/app_localizations.dart';
import '../../bills/widgets/dialog_bill_detail.dart';
import '../widgets/dialog_inventory.dart';
import '../widgets/dialog_inventory_result.dart';
import '../widgets/dialog_inventory_type.dart';
import '../widgets/dialog_stock_document.dart';
import '../widgets/dialog_stock_document_detail.dart';

// --- Sort field enums ---

enum _LevelsSortField { name, quantity, price, value }

enum _DocumentsSortField { date, number, type, amount }

enum _MovementsSortField { date, item, quantity }

enum _MovementSourceFilter { all, sale, document }

// --- Shared helper ---

String _documentTypeLabel(AppLocalizations l, StockDocumentType type) {
  return switch (type) {
    StockDocumentType.receipt => l.documentTypeReceipt,
    StockDocumentType.waste => l.documentTypeWaste,
    StockDocumentType.inventory => l.documentTypeInventory,
    StockDocumentType.correction => l.documentTypeCorrection,
  };
}

class ScreenInventory extends ConsumerStatefulWidget {
  const ScreenInventory({super.key});

  @override
  ConsumerState<ScreenInventory> createState() => _ScreenInventoryState();
}

class _ScreenInventoryState extends ConsumerState<ScreenInventory> {
  String? _warehouseId;
  bool _initialized = false;

  // Tab
  int _tabIndex = 0;

  // Search
  final _searchController = TextEditingController();
  String _query = '';

  // Filters — Levels
  bool _filterBelowMin = false;
  bool _filterZeroStock = false;
  Set<String> _filterLevelCategoryIds = {};

  // Filters — Documents
  Set<StockDocumentType> _filterDocTypes = {};

  // Filters — Movements
  StockMovementDirection? _filterDirection;
  _MovementSourceFilter _filterMovementSource = _MovementSourceFilter.all;
  Set<String> _filterMovementCategoryIds = {};

  // Sort — Levels
  _LevelsSortField _levelsSortField = _LevelsSortField.name;
  bool _levelsSortAsc = true;

  // Sort — Documents
  _DocumentsSortField _documentsSortField = _DocumentsSortField.date;
  bool _documentsSortAsc = false;

  // Sort — Movements
  _MovementsSortField _movementsSortField = _MovementsSortField.date;
  bool _movementsSortAsc = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initWarehouse();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initWarehouse() async {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;
    final locale = ref.read(appLocaleProvider).value ?? 'cs';
    final warehouse = await ref.read(warehouseRepositoryProvider).getDefault(company.id, locale: locale);
    if (mounted) {
      setState(() {
        _warehouseId = warehouse.id;
        _initialized = true;
      });
    }
  }

  bool _hasActiveFilters(int originalIndex) {
    return switch (originalIndex) {
      0 => _filterBelowMin || _filterZeroStock || _filterLevelCategoryIds.isNotEmpty,
      1 => _filterDocTypes.isNotEmpty,
      2 => _filterDirection != null || _filterMovementSource != _MovementSourceFilter.all || _filterMovementCategoryIds.isNotEmpty,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final company = ref.watch(currentCompanyProvider);

    if (company == null || !_initialized || _warehouseId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.inventoryTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Permission-gated tabs
    final canLevels = ref.watch(hasPermissionProvider('stock.view_levels'));
    final canDocuments = ref.watch(hasPermissionProvider('stock.view_documents'));
    final canMovements = ref.watch(hasPermissionProvider('stock.view_movements'));

    final allTabs = <(int, String)>[
      if (canLevels) (0, l.inventoryTabLevels),
      if (canDocuments) (1, l.inventoryTabDocuments),
      if (canMovements) (2, l.inventoryTabMovements),
    ];

    if (allTabs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l.inventoryTitle)),
        body: const SizedBox.shrink(),
      );
    }

    final effectiveTab = _tabIndex.clamp(0, allTabs.length - 1);
    final originalIndex = allTabs[effectiveTab].$1;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.inventoryTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: () => _showNewDocumentDialog(context),
              icon: const Icon(Icons.add),
              label: Text(l.inventoryNewDocument),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Tab chips
                for (var i = 0; i < allTabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  FilterChip(
                    label: Text(allTabs[i].$2),
                    selected: effectiveTab == i,
                    onSelected: (_) => setState(() => _tabIndex = i),
                  ),
                ],
                const SizedBox(width: 16),
                // Search
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: l.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        isDense: true,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (v) => setState(() => _query = normalizeSearch(v)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Filter
                IconButton(
                  icon: const Icon(Icons.filter_alt_outlined),
                  onPressed: () => _showFilterDialog(originalIndex),
                  color: _hasActiveFilters(originalIndex) ? Theme.of(context).colorScheme.primary : null,
                ),
                // Sort
                PopupMenuButton<String>(
                  icon: const Icon(Icons.swap_vert),
                  onSelected: _onSortSelected,
                  itemBuilder: (_) => _buildSortMenuItems(l, originalIndex),
                ),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: switch (originalIndex) {
              0 => _StockLevelsTab(
                companyId: company.id,
                warehouseId: _warehouseId!,
                query: _query,
                filterBelowMin: _filterBelowMin,
                filterZeroStock: _filterZeroStock,
                filterCategoryIds: _filterLevelCategoryIds,
                sortField: _levelsSortField,
                sortAsc: _levelsSortAsc,
              ),
              1 => _StockDocumentsTab(
                companyId: company.id,
                warehouseId: _warehouseId!,
                query: _query,
                filterDocTypes: _filterDocTypes,
                sortField: _documentsSortField,
                sortAsc: _documentsSortAsc,
              ),
              2 => _StockMovementsTab(
                companyId: company.id,
                query: _query,
                filterDirection: _filterDirection,
                filterSource: _filterMovementSource,
                filterCategoryIds: _filterMovementCategoryIds,
                sortField: _movementsSortField,
                sortAsc: _movementsSortAsc,
              ),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    );
  }

  // --- Sort menu ---

  List<PopupMenuEntry<String>> _buildSortMenuItems(AppLocalizations l, int originalIndex) {
    return switch (originalIndex) {
      0 => [
        _sortMenuItem('levels_name', l.inventorySortName, _levelsSortField == _LevelsSortField.name, _levelsSortAsc),
        _sortMenuItem('levels_quantity', l.inventorySortQuantity, _levelsSortField == _LevelsSortField.quantity, _levelsSortAsc),
        _sortMenuItem('levels_price', l.inventorySortPrice, _levelsSortField == _LevelsSortField.price, _levelsSortAsc),
        _sortMenuItem('levels_value', l.inventorySortValue, _levelsSortField == _LevelsSortField.value, _levelsSortAsc),
      ],
      1 => [
        _sortMenuItem('docs_date', l.inventorySortDate, _documentsSortField == _DocumentsSortField.date, _documentsSortAsc),
        _sortMenuItem('docs_number', l.inventorySortNumber, _documentsSortField == _DocumentsSortField.number, _documentsSortAsc),
        _sortMenuItem('docs_type', l.inventorySortType, _documentsSortField == _DocumentsSortField.type, _documentsSortAsc),
        _sortMenuItem('docs_amount', l.inventorySortAmount, _documentsSortField == _DocumentsSortField.amount, _documentsSortAsc),
      ],
      2 => [
        _sortMenuItem('moves_date', l.inventorySortDate, _movementsSortField == _MovementsSortField.date, _movementsSortAsc),
        _sortMenuItem('moves_item', l.inventorySortItem, _movementsSortField == _MovementsSortField.item, _movementsSortAsc),
        _sortMenuItem('moves_quantity', l.inventorySortQuantity, _movementsSortField == _MovementsSortField.quantity, _movementsSortAsc),
      ],
      _ => [],
    };
  }

  PopupMenuItem<String> _sortMenuItem(String value, String label, bool isActive, bool isAsc) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (isActive)
            Icon(isAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 16)
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(label, style: isActive ? const TextStyle(fontWeight: FontWeight.bold) : null),
        ],
      ),
    );
  }

  void _onSortSelected(String value) {
    setState(() {
      switch (value) {
        case 'levels_name':
          if (_levelsSortField == _LevelsSortField.name) { _levelsSortAsc = !_levelsSortAsc; } else { _levelsSortField = _LevelsSortField.name; _levelsSortAsc = true; }
        case 'levels_quantity':
          if (_levelsSortField == _LevelsSortField.quantity) { _levelsSortAsc = !_levelsSortAsc; } else { _levelsSortField = _LevelsSortField.quantity; _levelsSortAsc = false; }
        case 'levels_price':
          if (_levelsSortField == _LevelsSortField.price) { _levelsSortAsc = !_levelsSortAsc; } else { _levelsSortField = _LevelsSortField.price; _levelsSortAsc = false; }
        case 'levels_value':
          if (_levelsSortField == _LevelsSortField.value) { _levelsSortAsc = !_levelsSortAsc; } else { _levelsSortField = _LevelsSortField.value; _levelsSortAsc = false; }
        case 'docs_date':
          if (_documentsSortField == _DocumentsSortField.date) { _documentsSortAsc = !_documentsSortAsc; } else { _documentsSortField = _DocumentsSortField.date; _documentsSortAsc = false; }
        case 'docs_number':
          if (_documentsSortField == _DocumentsSortField.number) { _documentsSortAsc = !_documentsSortAsc; } else { _documentsSortField = _DocumentsSortField.number; _documentsSortAsc = true; }
        case 'docs_type':
          if (_documentsSortField == _DocumentsSortField.type) { _documentsSortAsc = !_documentsSortAsc; } else { _documentsSortField = _DocumentsSortField.type; _documentsSortAsc = true; }
        case 'docs_amount':
          if (_documentsSortField == _DocumentsSortField.amount) { _documentsSortAsc = !_documentsSortAsc; } else { _documentsSortField = _DocumentsSortField.amount; _documentsSortAsc = false; }
        case 'moves_date':
          if (_movementsSortField == _MovementsSortField.date) { _movementsSortAsc = !_movementsSortAsc; } else { _movementsSortField = _MovementsSortField.date; _movementsSortAsc = false; }
        case 'moves_item':
          if (_movementsSortField == _MovementsSortField.item) { _movementsSortAsc = !_movementsSortAsc; } else { _movementsSortField = _MovementsSortField.item; _movementsSortAsc = true; }
        case 'moves_quantity':
          if (_movementsSortField == _MovementsSortField.quantity) { _movementsSortAsc = !_movementsSortAsc; } else { _movementsSortField = _MovementsSortField.quantity; _movementsSortAsc = false; }
      }
    });
  }

  // --- Filter dialogs ---

  void _showFilterDialog(int originalIndex) {
    final l = context.l10n;
    switch (originalIndex) {
      case 0:
        _showLevelsFilterDialog(l);
      case 1:
        _showDocumentsFilterDialog(l);
      case 2:
        _showMovementsFilterDialog(l);
    }
  }

  void _showLevelsFilterDialog(AppLocalizations l) {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    var belowMin = _filterBelowMin;
    var zeroStock = _filterZeroStock;
    var categoryIds = Set<String>.from(_filterLevelCategoryIds);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final hasFilters = belowMin || zeroStock || categoryIds.isNotEmpty;
          return AlertDialog(
            title: Text(l.filterTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: Text(l.inventoryFilterBelowMin),
                    value: belowMin,
                    onChanged: (v) => setDialogState(() => belowMin = v),
                  ),
                  SwitchListTile(
                    title: Text(l.inventoryFilterZeroStock),
                    value: zeroStock,
                    onChanged: (v) => setDialogState(() => zeroStock = v),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(l.inventoryFilterCategory, style: Theme.of(ctx).textTheme.titleSmall),
                    dense: true,
                  ),
                  StreamBuilder<List<CategoryModel>>(
                    stream: ref.read(categoryRepositoryProvider).watchAll(company.id),
                    builder: (ctx, snap) {
                      final categories = snap.data ?? [];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final cat in categories)
                            CheckboxListTile(
                              title: Text(cat.name),
                              value: categoryIds.contains(cat.id),
                              onChanged: (v) => setDialogState(() {
                                if (v == true) {
                                  categoryIds.add(cat.id);
                                } else {
                                  categoryIds.remove(cat.id);
                                }
                              }),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              if (hasFilters)
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _filterBelowMin = false;
                      _filterZeroStock = false;
                      _filterLevelCategoryIds = {};
                    });
                    Navigator.of(ctx).pop();
                  },
                  child: Text(l.filterReset),
                ),
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l.actionCancel),
              ),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _filterBelowMin = belowMin;
                    _filterZeroStock = zeroStock;
                    _filterLevelCategoryIds = categoryIds;
                  });
                  Navigator.of(ctx).pop();
                },
                child: Text(l.actionConfirm),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDocumentsFilterDialog(AppLocalizations l) {
    var docTypes = Set<StockDocumentType>.from(_filterDocTypes);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l.inventoryFilterDocType),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final type in StockDocumentType.values)
                CheckboxListTile(
                  title: Text(_documentTypeLabel(l, type)),
                  value: docTypes.contains(type),
                  onChanged: (v) => setDialogState(() {
                    if (v == true) {
                      docTypes.add(type);
                    } else {
                      docTypes.remove(type);
                    }
                  }),
                ),
            ],
          ),
          actions: [
            if (docTypes.isNotEmpty)
              OutlinedButton(
                onPressed: () {
                  setState(() => _filterDocTypes = {});
                  Navigator.of(ctx).pop();
                },
                child: Text(l.filterReset),
              ),
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.actionCancel),
            ),
            FilledButton(
              onPressed: () {
                setState(() => _filterDocTypes = docTypes);
                Navigator.of(ctx).pop();
              },
              child: Text(l.actionConfirm),
            ),
          ],
        ),
      ),
    );
  }

  void _showMovementsFilterDialog(AppLocalizations l) {
    final company = ref.read(currentCompanyProvider);
    if (company == null) return;

    var direction = _filterDirection;
    var source = _filterMovementSource;
    var categoryIds = Set<String>.from(_filterMovementCategoryIds);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final hasFilters = direction != null || source != _MovementSourceFilter.all || categoryIds.isNotEmpty;
          return AlertDialog(
            title: Text(l.filterTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioGroup<StockMovementDirection?>(
                    groupValue: direction,
                    onChanged: (v) => setDialogState(() => direction = v),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<StockMovementDirection?>(
                          title: Text(l.filterAll),
                          value: null,
                        ),
                        RadioListTile<StockMovementDirection?>(
                          title: Text(l.inventoryFilterInbound),
                          value: StockMovementDirection.inbound,
                        ),
                        RadioListTile<StockMovementDirection?>(
                          title: Text(l.inventoryFilterOutbound),
                          value: StockMovementDirection.outbound,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(l.inventoryFilterSource, style: Theme.of(ctx).textTheme.titleSmall),
                    dense: true,
                  ),
                  RadioGroup<_MovementSourceFilter>(
                    groupValue: source,
                    onChanged: (v) => setDialogState(() => source = v!),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<_MovementSourceFilter>(
                          title: Text(l.filterAll),
                          value: _MovementSourceFilter.all,
                        ),
                        RadioListTile<_MovementSourceFilter>(
                          title: Text(l.inventoryFilterSourceSale),
                          value: _MovementSourceFilter.sale,
                        ),
                        RadioListTile<_MovementSourceFilter>(
                          title: Text(l.inventoryFilterSourceDocument),
                          value: _MovementSourceFilter.document,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(l.inventoryFilterCategory, style: Theme.of(ctx).textTheme.titleSmall),
                    dense: true,
                  ),
                  StreamBuilder<List<CategoryModel>>(
                    stream: ref.read(categoryRepositoryProvider).watchAll(company.id),
                    builder: (ctx, snap) {
                      final categories = snap.data ?? [];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final cat in categories)
                            CheckboxListTile(
                              title: Text(cat.name),
                              value: categoryIds.contains(cat.id),
                              onChanged: (v) => setDialogState(() {
                                if (v == true) {
                                  categoryIds.add(cat.id);
                                } else {
                                  categoryIds.remove(cat.id);
                                }
                              }),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              if (hasFilters)
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _filterDirection = null;
                      _filterMovementSource = _MovementSourceFilter.all;
                      _filterMovementCategoryIds = {};
                    });
                    Navigator.of(ctx).pop();
                  },
                  child: Text(l.filterReset),
                ),
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l.actionCancel),
              ),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _filterDirection = direction;
                    _filterMovementSource = source;
                    _filterMovementCategoryIds = categoryIds;
                  });
                  Navigator.of(ctx).pop();
                },
                child: Text(l.actionConfirm),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Stock document & inventory dialogs ---

  void _showNewDocumentDialog(BuildContext context) {
    final l = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.inventoryNewDocumentTitle),
        children: [
          _DocumentTypeOption(
            icon: Icons.add_box_outlined,
            title: l.inventoryReceipt,
            subtitle: l.inventoryReceiptDesc,
            onTap: () {
              Navigator.of(ctx).pop();
              _openStockDocument(context, StockDocumentType.receipt);
            },
          ),
          _DocumentTypeOption(
            icon: Icons.remove_circle_outline,
            title: l.inventoryWaste,
            subtitle: l.inventoryWasteDesc,
            onTap: () {
              Navigator.of(ctx).pop();
              _openStockDocument(context, StockDocumentType.waste);
            },
          ),
          _DocumentTypeOption(
            icon: Icons.edit_outlined,
            title: l.inventoryCorrection,
            subtitle: l.inventoryCorrectionDesc,
            onTap: () {
              Navigator.of(ctx).pop();
              _openStockDocument(context, StockDocumentType.correction);
            },
          ),
          _DocumentTypeOption(
            icon: Icons.fact_check_outlined,
            title: l.inventoryInventory,
            subtitle: l.inventoryInventoryDesc,
            onTap: () {
              Navigator.of(ctx).pop();
              _openInventoryDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openStockDocument(BuildContext context, StockDocumentType type) async {
    final company = ref.read(currentCompanyProvider);
    if (company == null || _warehouseId == null) return;

    await showDialog(
      context: context,
      builder: (_) => DialogStockDocument(
        companyId: company.id,
        warehouseId: _warehouseId!,
        type: type,
      ),
    );
  }

  Future<void> _openInventoryDialog(BuildContext context) async {
    final company = ref.read(currentCompanyProvider);
    if (company == null || _warehouseId == null) return;

    // Step 1: Type selection
    final typeResult = await showDialog<InventoryTypeResult>(
      context: context,
      builder: (_) => DialogInventoryType(companyId: company.id),
    );
    if (typeResult == null || !context.mounted) return;

    // Step 2: Inventory counting
    final lines = await showDialog<List<InventoryLineWithName>>(
      context: context,
      builder: (_) => DialogInventory(
        companyId: company.id,
        warehouseId: _warehouseId!,
        itemIds: typeResult.itemIds.isEmpty ? null : typeResult.itemIds,
        blindMode: typeResult.blindMode,
      ),
    );
    if (lines == null || !context.mounted) return;

    // Step 3: Results (only if there are differences)
    if (!lines.any((l) => l.actualQuantity != l.currentQuantity)) return;

    await showDialog(
      context: context,
      builder: (_) => DialogInventoryResult(
        companyId: company.id,
        warehouseId: _warehouseId!,
        lines: lines,
      ),
    );
  }
}

// --- Stock Levels Tab ---

class _StockLevelsTab extends ConsumerWidget {
  const _StockLevelsTab({
    required this.companyId,
    required this.warehouseId,
    required this.query,
    required this.filterBelowMin,
    required this.filterZeroStock,
    required this.filterCategoryIds,
    required this.sortField,
    required this.sortAsc,
  });

  final String companyId;
  final String warehouseId;
  final String query;
  final bool filterBelowMin;
  final bool filterZeroStock;
  final Set<String> filterCategoryIds;
  final _LevelsSortField sortField;
  final bool sortAsc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return StreamBuilder<List<StockLevelWithItem>>(
      stream: ref.watch(stockLevelRepositoryProvider).watchByWarehouse(companyId, warehouseId),
      builder: (context, snap) {
        final allLevels = snap.data ?? [];
        var levels = allLevels;

        // Filter
        if (filterBelowMin) {
          levels = levels.where((item) {
            final minQty = item.minQuantity;
            return minQty != null && item.quantity < minQty;
          }).toList();
        }
        if (filterZeroStock) {
          levels = levels.where((item) => item.quantity <= 0).toList();
        }
        if (filterCategoryIds.isNotEmpty) {
          levels = levels.where((item) =>
            item.categoryId != null && filterCategoryIds.contains(item.categoryId),
          ).toList();
        }

        // Search
        if (query.isNotEmpty) {
          levels = levels.where((item) =>
            normalizeSearch(item.itemName).contains(query),
          ).toList();
        }

        // Sort
        levels = List.of(levels);
        levels.sort((a, b) {
          final cmp = switch (sortField) {
            _LevelsSortField.name => a.itemName.compareTo(b.itemName),
            _LevelsSortField.quantity => a.quantity.compareTo(b.quantity),
            _LevelsSortField.price => (a.purchasePrice ?? 0).compareTo(b.purchasePrice ?? 0),
            _LevelsSortField.value => ((a.purchasePrice ?? 0) * a.quantity).compareTo((b.purchasePrice ?? 0) * b.quantity),
          };
          return sortAsc ? cmp : -cmp;
        });

        int totalValue = 0;
        for (final item in levels) {
          if (item.purchasePrice != null) {
            totalValue += (item.purchasePrice! * item.quantity).round();
          }
        }

        return PosTable<StockLevelWithItem>(
          columns: [
            PosColumn(
              label: l.inventoryColumnItem,
              flex: 3,
              cellBuilder: (item) => HighlightedText(item.itemName, query: query, overflow: TextOverflow.ellipsis),
            ),
            PosColumn(label: l.inventoryColumnUnit, flex: 1, headerAlign: TextAlign.center, cellBuilder: (item) => Text(localizedUnitType(l, item.unit), textAlign: TextAlign.center)),
            PosColumn(
              label: l.inventoryColumnQuantity,
              flex: 1,
              headerAlign: TextAlign.center,
              cellBuilder: (item) {
                final qty = item.quantity;
                final minQty = item.minQuantity;
                final isBelowMin = minQty != null && qty < minQty;
                return Text(
                  ref.fmtQty(qty),
                  textAlign: TextAlign.center,
                  style: isBelowMin
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        )
                      : null,
                );
              },
            ),
            PosColumn(
              label: l.inventoryColumnMinQuantity,
              flex: 1,
              headerAlign: TextAlign.center,
              cellBuilder: (item) => Text(
                item.minQuantity != null ? ref.fmtQty(item.minQuantity!) : '-',
                textAlign: TextAlign.center,
              ),
            ),
            PosColumn(
              label: l.inventoryColumnPurchasePrice,
              flex: 1,
              numeric: true,
              cellBuilder: (item) => Text(
                item.purchasePrice != null ? ref.moneyValue(item.purchasePrice!) : '-',
                textAlign: TextAlign.right,
              ),
            ),
            PosColumn(
              label: l.inventoryColumnTotalValue,
              flex: 1,
              numeric: true,
              cellBuilder: (item) {
                final price = item.purchasePrice;
                final value = price != null ? (price * item.quantity).round() : 0;
                return Text(
                  price != null ? ref.moneyValue(value) : '-',
                  textAlign: TextAlign.right,
                );
              },
            ),
          ],
          items: levels,
          emptyMessage: l.inventoryNoItems,
          footer: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Text(
              '${l.inventoryTotalValue}: ${ref.moneyValue(totalValue)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        );
      },
    );
  }
}

// --- Stock Documents Tab ---

class _StockDocumentsTab extends ConsumerWidget {
  const _StockDocumentsTab({
    required this.companyId,
    required this.warehouseId,
    required this.query,
    required this.filterDocTypes,
    required this.sortField,
    required this.sortAsc,
  });

  final String companyId;
  final String warehouseId;
  final String query;
  final Set<StockDocumentType> filterDocTypes;
  final _DocumentsSortField sortField;
  final bool sortAsc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return StreamBuilder<List<StockDocumentModel>>(
      stream: ref.watch(stockDocumentRepositoryProvider).watchByWarehouse(companyId, warehouseId),
      builder: (context, docSnap) {
        final allDocuments = docSnap.data ?? [];

        // Resolve supplier names
        return StreamBuilder<List<SupplierModel>>(
          stream: ref.watch(supplierRepositoryProvider).watchAll(companyId),
          builder: (context, suppSnap) {
            final suppliers = suppSnap.data ?? [];
            final supplierMap = {for (final s in suppliers) s.id: s.supplierName};

            var documents = allDocuments;

            // Filter by doc type
            if (filterDocTypes.isNotEmpty) {
              documents = documents.where((doc) => filterDocTypes.contains(doc.type)).toList();
            }

            // Search
            if (query.isNotEmpty) {
              documents = documents.where((doc) {
                return normalizeSearch(doc.documentNumber).contains(query) ||
                    (doc.supplierId != null && normalizeSearch(supplierMap[doc.supplierId] ?? '').contains(query)) ||
                    (doc.note != null && normalizeSearch(doc.note!).contains(query));
              }).toList();
            }

            // Sort
            documents = List.of(documents);
            documents.sort((a, b) {
              final cmp = switch (sortField) {
                _DocumentsSortField.date => a.documentDate.compareTo(b.documentDate),
                _DocumentsSortField.number => a.documentNumber.compareTo(b.documentNumber),
                _DocumentsSortField.type => a.type.index.compareTo(b.type.index),
                _DocumentsSortField.amount => a.totalAmount.compareTo(b.totalAmount),
              };
              return sortAsc ? cmp : -cmp;
            });

            return PosTable<StockDocumentModel>(
              columns: [
                PosColumn(label: l.documentColumnDate, flex: 2, cellBuilder: (doc) => Text(ref.fmtDateTime(doc.documentDate), overflow: TextOverflow.ellipsis)),
                PosColumn(
                  label: l.documentColumnNumber,
                  flex: 2,
                  cellBuilder: (doc) => HighlightedText(doc.documentNumber, query: query, overflow: TextOverflow.ellipsis),
                ),
                PosColumn(label: l.documentColumnType, flex: 2, cellBuilder: (doc) => Text(_documentTypeLabel(l, doc.type), overflow: TextOverflow.ellipsis)),
                PosColumn(
                  label: l.documentColumnSupplier,
                  flex: 2,
                  cellBuilder: (doc) {
                    final name = doc.supplierId != null ? (supplierMap[doc.supplierId] ?? '-') : '-';
                    return HighlightedText(name, query: query, overflow: TextOverflow.ellipsis);
                  },
                ),
                PosColumn(
                  label: l.documentColumnNote,
                  flex: 2,
                  cellBuilder: (doc) => HighlightedText(doc.note ?? '-', query: query, overflow: TextOverflow.ellipsis),
                ),
                PosColumn(
                  label: l.documentColumnTotal,
                  flex: 1,
                  numeric: true,
                  cellBuilder: (doc) => Text(
                    doc.totalAmount != 0 ? ref.moneyValue(doc.totalAmount) : '-',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
              items: documents,
              emptyMessage: l.documentNoDocuments,
              onRowTap: (doc) {
                showDialog(
                  context: context,
                  builder: (_) => DialogStockDocumentDetail(
                    documentId: doc.id,
                    document: doc,
                    supplierName: doc.supplierId != null ? supplierMap[doc.supplierId] : null,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// --- Stock Movements Tab ---

class _StockMovementsTab extends ConsumerWidget {
  const _StockMovementsTab({
    required this.companyId,
    required this.query,
    required this.filterDirection,
    required this.filterSource,
    required this.filterCategoryIds,
    required this.sortField,
    required this.sortAsc,
  });

  final String companyId;
  final String query;
  final StockMovementDirection? filterDirection;
  final _MovementSourceFilter filterSource;
  final Set<String> filterCategoryIds;
  final _MovementsSortField sortField;
  final bool sortAsc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return StreamBuilder<List<StockMovementWithItem>>(
      stream: ref.watch(stockMovementRepositoryProvider).watchByCompany(companyId),
      builder: (context, snap) {
        final allMovements = snap.data ?? [];
        var movements = allMovements;

        // Filter by direction
        if (filterDirection != null) {
          movements = movements.where((m) => m.movement.direction == filterDirection).toList();
        }
        // Filter by source
        if (filterSource == _MovementSourceFilter.sale) {
          movements = movements.where((m) => m.billId != null).toList();
        } else if (filterSource == _MovementSourceFilter.document) {
          movements = movements.where((m) => m.movement.stockDocumentId != null).toList();
        }
        if (filterCategoryIds.isNotEmpty) {
          movements = movements.where((m) =>
            m.categoryId != null && filterCategoryIds.contains(m.categoryId),
          ).toList();
        }

        // Search
        if (query.isNotEmpty) {
          movements = movements.where((m) {
            return normalizeSearch(m.itemName).contains(query) ||
                (m.documentNumber != null && normalizeSearch(m.documentNumber!).contains(query)) ||
                (m.billNumber != null && normalizeSearch(m.billNumber!).contains(query));
          }).toList();
        }

        // Sort
        movements = List.of(movements);
        movements.sort((a, b) {
          final cmp = switch (sortField) {
            _MovementsSortField.date => a.movement.createdAt.compareTo(b.movement.createdAt),
            _MovementsSortField.item => a.itemName.compareTo(b.itemName),
            _MovementsSortField.quantity => a.movement.quantity.compareTo(b.movement.quantity),
          };
          return sortAsc ? cmp : -cmp;
        });

        return PosTable<StockMovementWithItem>(
          columns: [
            PosColumn(
              label: l.movementColumnDate,
              flex: 2,
              cellBuilder: (item) => Text(
                ref.fmtDateTime(item.movement.createdAt),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            PosColumn(
              label: l.movementColumnItem,
              flex: 3,
              cellBuilder: (item) => HighlightedText(
                item.itemName,
                query: query,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            PosColumn(
              label: l.movementColumnQuantity,
              flex: 1,
              headerAlign: TextAlign.center,
              cellBuilder: (item) {
                final isInbound = item.movement.direction == StockMovementDirection.inbound;
                final sign = isInbound ? '+' : '-';
                return Text(
                  '$sign${ref.fmtQty(item.movement.quantity)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isInbound
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            PosColumn(
              label: l.inventoryColumnPurchasePrice,
              flex: 2,
              numeric: true,
              cellBuilder: (item) {
                if (item.movement.purchasePrice == null) return const Text('-', textAlign: TextAlign.right);
                final isInbound = item.movement.direction == StockMovementDirection.inbound;
                final total = (item.movement.purchasePrice! * item.movement.quantity).round();
                final signed = isInbound ? total : -total;
                return Text(
                  ref.moneyValue(signed),
                  textAlign: TextAlign.right,
                );
              },
            ),
            PosColumn(
              label: l.movementColumnType,
              flex: 2,
              headerAlign: TextAlign.center,
              cellBuilder: (item) => Text(
                _movementTypeLabel(l, item),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            PosColumn(
              label: l.movementColumnDocument,
              flex: 2,
              cellBuilder: (item) => HighlightedText(
                item.documentNumber ?? item.billNumber ?? '-',
                query: query,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          items: movements,
          emptyMessage: l.movementNoMovements,
          onRowTap: (item) {
            if (item.movement.stockDocumentId != null) {
              showDialog(
                context: context,
                builder: (_) => DialogStockDocumentDetail(
                  documentId: item.movement.stockDocumentId!,
                ),
              );
            } else if (item.billId != null) {
              showDialog(
                context: context,
                builder: (_) => DialogBillDetail(billId: item.billId!),
              );
            }
          },
        );
      },
    );
  }

  String _movementTypeLabel(AppLocalizations l, StockMovementWithItem item) {
    if (item.documentType != null) {
      return switch (item.documentType!) {
        StockDocumentType.receipt => l.documentTypeReceipt,
        StockDocumentType.waste => l.documentTypeWaste,
        StockDocumentType.inventory => l.documentTypeInventory,
        StockDocumentType.correction => l.documentTypeCorrection,
      };
    }
    return item.movement.direction == StockMovementDirection.outbound
        ? l.movementTypeSale
        : l.movementTypeReversal;
  }
}

// --- Document type selection option ---

class _DocumentTypeOption extends StatelessWidget {
  const _DocumentTypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

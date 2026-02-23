import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/stock_document_type.dart';
import '../../../core/data/enums/stock_movement_direction.dart';
import '../../../core/data/models/stock_document_model.dart';
import '../../../core/data/models/supplier_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/stock_level_repository.dart';
import '../../../core/data/repositories/stock_movement_repository.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_table.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/dialog_inventory.dart';
import '../widgets/dialog_inventory_result.dart';
import '../widgets/dialog_inventory_type.dart';
import '../widgets/dialog_stock_document.dart';

class ScreenInventory extends ConsumerStatefulWidget {
  const ScreenInventory({super.key});

  @override
  ConsumerState<ScreenInventory> createState() => _ScreenInventoryState();
}

class _ScreenInventoryState extends ConsumerState<ScreenInventory>
    with SingleTickerProviderStateMixin {
  String? _warehouseId;
  bool _initialized = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initWarehouse();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(l.inventoryTitle),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 40,
                child: FilledButton.icon(
                  onPressed: () => _openStockDocument(context, StockDocumentType.receipt),
                  icon: const Icon(Icons.add_box_outlined),
                  label: Text(l.inventoryReceipt),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: FilledButton.tonalIcon(
                  onPressed: () => _openStockDocument(context, StockDocumentType.waste),
                  icon: const Icon(Icons.remove_circle_outline),
                  label: Text(l.inventoryWaste),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: FilledButton.tonalIcon(
                  onPressed: () => _openStockDocument(context, StockDocumentType.correction),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l.inventoryCorrection),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: FilledButton.tonalIcon(
                  onPressed: () => _openInventoryDialog(context),
                  icon: const Icon(Icons.fact_check_outlined),
                  label: Text(l.inventoryInventory),
                ),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l.inventoryTabLevels),
            Tab(text: l.inventoryTabDocuments),
            Tab(text: l.inventoryTabMovements),
          ],
        ),
      ),
      body: Column(
        children: [
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _StockLevelsTab(
                  companyId: company.id,
                  warehouseId: _warehouseId!,
                ),
                _StockDocumentsTab(
                  companyId: company.id,
                  warehouseId: _warehouseId!,
                ),
                _StockMovementsTab(
                  companyId: company.id,
                ),
              ],
            ),
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
  const _StockLevelsTab({required this.companyId, required this.warehouseId});
  final String companyId;
  final String warehouseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return StreamBuilder<List<StockLevelWithItem>>(
      stream: ref.watch(stockLevelRepositoryProvider).watchByWarehouse(companyId, warehouseId),
      builder: (context, snap) {
        final levels = snap.data ?? [];

        int totalValue = 0;
        for (final item in levels) {
          if (item.purchasePrice != null) {
            totalValue += (item.purchasePrice! * item.quantity).round();
          }
        }

        return PosTable<StockLevelWithItem>(
          columns: [
            PosColumn(label: l.inventoryColumnItem, flex: 3, cellBuilder: (item) => Text(item.itemName, overflow: TextOverflow.ellipsis)),
            PosColumn(label: l.inventoryColumnUnit, flex: 1, headerAlign: TextAlign.center, cellBuilder: (item) => Text(item.unit.name, textAlign: TextAlign.center)),
            PosColumn(
              label: l.inventoryColumnQuantity,
              flex: 1,
              headerAlign: TextAlign.center,
              cellBuilder: (item) {
                final qty = item.quantity;
                final minQty = item.minQuantity;
                final isBelowMin = minQty != null && qty < minQty;
                return Text(
                  _formatQuantity(qty),
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
                item.minQuantity != null ? _formatQuantity(item.minQuantity!) : '-',
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

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

}

// --- Stock Documents Tab ---

class _StockDocumentsTab extends ConsumerWidget {
  const _StockDocumentsTab({required this.companyId, required this.warehouseId});
  final String companyId;
  final String warehouseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return StreamBuilder<List<StockDocumentModel>>(
      stream: ref.watch(stockDocumentRepositoryProvider).watchByWarehouse(companyId, warehouseId),
      builder: (context, docSnap) {
        final documents = docSnap.data ?? [];

        // Resolve supplier names
        return StreamBuilder<List<SupplierModel>>(
          stream: ref.watch(supplierRepositoryProvider).watchAll(companyId),
          builder: (context, suppSnap) {
            final suppliers = suppSnap.data ?? [];
            final supplierMap = {for (final s in suppliers) s.id: s.supplierName};

            return PosTable<StockDocumentModel>(
              columns: [
                PosColumn(label: l.documentColumnNumber, flex: 2, cellBuilder: (doc) => Text(doc.documentNumber, overflow: TextOverflow.ellipsis)),
                PosColumn(label: l.documentColumnType, flex: 2, cellBuilder: (doc) => Text(_documentTypeLabel(l, doc.type), overflow: TextOverflow.ellipsis)),
                PosColumn(label: l.documentColumnDate, flex: 2, cellBuilder: (doc) => Text(ref.fmtDateTime(doc.documentDate), overflow: TextOverflow.ellipsis)),
                PosColumn(
                  label: l.documentColumnSupplier,
                  flex: 2,
                  cellBuilder: (doc) => Text(
                    doc.supplierId != null ? (supplierMap[doc.supplierId] ?? '-') : '-',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PosColumn(label: l.documentColumnNote, flex: 2, cellBuilder: (doc) => Text(doc.note ?? '-', overflow: TextOverflow.ellipsis)),
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
            );
          },
        );
      },
    );
  }

  String _documentTypeLabel(AppLocalizations l, StockDocumentType type) {
    return switch (type) {
      StockDocumentType.receipt => l.documentTypeReceipt,
      StockDocumentType.waste => l.documentTypeWaste,
      StockDocumentType.inventory => l.documentTypeInventory,
      StockDocumentType.correction => l.documentTypeCorrection,
    };
  }
}

// --- Stock Movements Tab ---

class _StockMovementsTab extends ConsumerStatefulWidget {
  const _StockMovementsTab({required this.companyId});
  final String companyId;

  @override
  ConsumerState<_StockMovementsTab> createState() => _StockMovementsTabState();
}

class _StockMovementsTabState extends ConsumerState<_StockMovementsTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            ),
            onChanged: (v) => setState(() => _query = v.toLowerCase()),
          ),
        ),
        // Movements table
        Expanded(
          child: StreamBuilder<List<StockMovementWithItem>>(
            stream: ref.watch(stockMovementRepositoryProvider).watchByCompany(
                  widget.companyId,
                ),
            builder: (context, snap) {
              var movements = snap.data ?? [];
              if (_query.isNotEmpty) {
                movements = movements.where((m) {
                  return m.itemName.toLowerCase().contains(_query) ||
                      (m.documentNumber?.toLowerCase().contains(_query) ?? false);
                }).toList();
              }

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
                    cellBuilder: (item) => Text(
                      item.itemName,
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
                        '$sign${_formatQuantity(item.movement.quantity)}',
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
                    label: l.movementColumnType,
                    flex: 2,
                    cellBuilder: (item) => Text(
                      _movementTypeLabel(l, item),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PosColumn(
                    label: l.movementColumnDocument,
                    flex: 2,
                    cellBuilder: (item) => Text(
                      item.documentNumber ?? '-',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                items: movements,
                emptyMessage: l.movementNoMovements,
              );
            },
          ),
        ),
      ],
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

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}

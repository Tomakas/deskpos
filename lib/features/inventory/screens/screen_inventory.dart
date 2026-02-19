import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/stock_document_type.dart';
import '../../../core/data/models/stock_document_model.dart';
import '../../../core/data/models/supplier_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/stock_level_repository.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/widgets/pos_table.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/dialog_inventory.dart';
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
    _tabController = TabController(length: 2, vsync: this);
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
        title: Text(l.inventoryTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l.inventoryTabLevels),
            Tab(text: l.inventoryTabDocuments),
          ],
        ),
      ),
      body: Column(
        children: [
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FilledButton.icon(
                  onPressed: () => _openStockDocument(context, StockDocumentType.receipt),
                  icon: const Icon(Icons.add_box_outlined),
                  label: Text(l.inventoryReceipt),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: () => _openStockDocument(context, StockDocumentType.waste),
                  icon: const Icon(Icons.remove_circle_outline),
                  label: Text(l.inventoryWaste),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: () => _openStockDocument(context, StockDocumentType.correction),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l.inventoryCorrection),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: () => _openInventoryDialog(context),
                  icon: const Icon(Icons.fact_check_outlined),
                  label: Text(l.inventoryInventory),
                ),
              ],
            ),
          ),
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

    await showDialog(
      context: context,
      builder: (_) => DialogInventory(
        companyId: company.id,
        warehouseId: _warehouseId!,
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
            totalValue += (item.purchasePrice! * item.stockLevel.quantity).round();
          }
        }

        return PosTable<StockLevelWithItem>(
          columns: [
            PosColumn(label: l.inventoryColumnItem, flex: 3, cellBuilder: (item) => Text(item.itemName, overflow: TextOverflow.ellipsis)),
            PosColumn(label: l.inventoryColumnUnit, flex: 1, cellBuilder: (item) => Text(item.unit.name)),
            PosColumn(
              label: l.inventoryColumnQuantity,
              flex: 1,
              numeric: true,
              cellBuilder: (item) {
                final qty = item.stockLevel.quantity;
                final minQty = item.stockLevel.minQuantity;
                final isBelowMin = minQty != null && qty < minQty;
                return Text(
                  _formatQuantity(qty),
                  textAlign: TextAlign.right,
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
              numeric: true,
              cellBuilder: (item) => Text(
                item.stockLevel.minQuantity != null ? _formatQuantity(item.stockLevel.minQuantity!) : '-',
                textAlign: TextAlign.right,
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
                final value = price != null ? (price * item.stockLevel.quantity).round() : 0;
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

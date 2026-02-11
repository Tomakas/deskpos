import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/data/enums/stock_document_type.dart';
import '../../../core/data/models/stock_document_model.dart';
import '../../../core/data/models/supplier_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/stock_level_repository.dart';
import '../../../core/l10n/app_localizations_ext.dart';
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
    final warehouse = await ref.read(warehouseRepositoryProvider).getDefault(company.id);
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

        if (levels.isEmpty) {
          return Center(child: Text(l.inventoryNoItems));
        }

        int totalValue = 0;
        for (final item in levels) {
          if (item.purchasePrice != null) {
            totalValue += (item.purchasePrice! * item.stockLevel.quantity).round();
          }
        }

        return Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        columnSpacing: 16,
                        columns: [
                          DataColumn(label: Text(l.inventoryColumnItem)),
                          DataColumn(label: Text(l.inventoryColumnUnit)),
                          DataColumn(label: Text(l.inventoryColumnQuantity), numeric: true),
                          DataColumn(label: Text(l.inventoryColumnMinQuantity), numeric: true),
                          DataColumn(label: Text(l.inventoryColumnPurchasePrice), numeric: true),
                          DataColumn(label: Text(l.inventoryColumnTotalValue), numeric: true),
                        ],
                        rows: levels.map((item) {
                          final qty = item.stockLevel.quantity;
                          final minQty = item.stockLevel.minQuantity;
                          final price = item.purchasePrice;
                          final value = price != null ? (price * qty).round() : 0;
                          final isBelowMin = minQty != null && qty < minQty;

                          return DataRow(
                            cells: [
                              DataCell(Text(item.itemName)),
                              DataCell(Text(item.unit.name)),
                              DataCell(Text(
                                _formatQuantity(qty),
                                style: isBelowMin
                                    ? TextStyle(
                                        color: Theme.of(context).colorScheme.error,
                                        fontWeight: FontWeight.bold,
                                      )
                                    : null,
                              )),
                              DataCell(Text(minQty != null ? _formatQuantity(minQty) : '-')),
                              DataCell(Text(price != null ? _formatPrice(price) : '-')),
                              DataCell(Text(price != null ? _formatPrice(value) : '-')),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Footer: total value
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Text(
                '${l.inventoryTotalValue}: ${_formatPrice(totalValue)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  String _formatPrice(int valueInCents) {
    return (valueInCents / 100).toStringAsFixed(2);
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
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return StreamBuilder<List<StockDocumentModel>>(
      stream: ref.watch(stockDocumentRepositoryProvider).watchByWarehouse(companyId, warehouseId),
      builder: (context, docSnap) {
        final documents = docSnap.data ?? [];

        if (documents.isEmpty) {
          return Center(child: Text(l.documentNoDocuments));
        }

        // Resolve supplier names
        return StreamBuilder<List<SupplierModel>>(
          stream: ref.watch(supplierRepositoryProvider).watchAll(companyId),
          builder: (context, suppSnap) {
            final suppliers = suppSnap.data ?? [];
            final supplierMap = {for (final s in suppliers) s.id: s.supplierName};

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: 16,
                      columns: [
                        DataColumn(label: Text(l.documentColumnNumber)),
                        DataColumn(label: Text(l.documentColumnType)),
                        DataColumn(label: Text(l.documentColumnDate)),
                        DataColumn(label: Text(l.documentColumnSupplier)),
                        DataColumn(label: Text(l.documentColumnNote)),
                        DataColumn(label: Text(l.documentColumnTotal), numeric: true),
                      ],
                      rows: documents.map((doc) {
                        return DataRow(cells: [
                          DataCell(Text(doc.documentNumber)),
                          DataCell(Text(_documentTypeLabel(l, doc.type))),
                          DataCell(Text(dateFormat.format(doc.documentDate))),
                          DataCell(Text(
                            doc.supplierId != null
                                ? (supplierMap[doc.supplierId] ?? '-')
                                : '-',
                          )),
                          DataCell(Text(doc.note ?? '-')),
                          DataCell(Text(
                            doc.totalAmount != 0
                                ? (doc.totalAmount / 100).toStringAsFixed(2)
                                : '-',
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _documentTypeLabel(dynamic l, StockDocumentType type) {
    return switch (type) {
      StockDocumentType.receipt => (l as dynamic).documentTypeReceipt as String,
      StockDocumentType.waste => (l as dynamic).documentTypeWaste as String,
      StockDocumentType.inventory => (l as dynamic).documentTypeInventory as String,
      StockDocumentType.correction => (l as dynamic).documentTypeCorrection as String,
    };
  }
}

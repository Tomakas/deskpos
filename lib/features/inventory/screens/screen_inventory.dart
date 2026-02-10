import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/stock_document_type.dart';
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

class _ScreenInventoryState extends ConsumerState<ScreenInventory> {
  String? _warehouseId;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initWarehouse();
    }
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
          // Stock levels table
          Expanded(
            child: StreamBuilder<List<StockLevelWithItem>>(
              stream: ref.watch(stockLevelRepositoryProvider).watchByWarehouse(
                    company.id,
                    _warehouseId!,
                  ),
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
                                            ? TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)
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

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String _formatPrice(int valueInCents) {
    return (valueInCents / 100).toStringAsFixed(2);
  }
}

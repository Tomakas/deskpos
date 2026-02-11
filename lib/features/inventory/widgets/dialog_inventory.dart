import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/stock_document_repository.dart';
import '../../../core/data/repositories/stock_level_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';

class DialogInventory extends ConsumerStatefulWidget {
  const DialogInventory({
    super.key,
    required this.companyId,
    required this.warehouseId,
  });

  final String companyId;
  final String warehouseId;

  @override
  ConsumerState<DialogInventory> createState() => _DialogInventoryState();
}

class _DialogInventoryState extends ConsumerState<DialogInventory> {
  final _controllers = <String, TextEditingController>{};
  bool _saving = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return PosDialogShell(
      title: l.inventoryDialogTitle,
      maxWidth: 700,
      maxHeight: 700,
      children: [
        Expanded(
          child: StreamBuilder<List<StockLevelWithItem>>(
            stream: ref
                .watch(stockLevelRepositoryProvider)
                .watchByWarehouse(widget.companyId, widget.warehouseId),
            builder: (context, snap) {
              final theme = Theme.of(context);
              final levels = snap.data ?? [];

              // Ensure controllers exist for all items
              for (final item in levels) {
                final itemId = item.stockLevel.itemId;
                _controllers.putIfAbsent(
                  itemId,
                  () => TextEditingController(
                    text: _formatQuantity(item.stockLevel.quantity),
                  ),
                );
              }

              return PosTable<StockLevelWithItem>(
                columns: [
                  PosColumn(
                    label: l.inventoryColumnItem,
                    flex: 3,
                    cellBuilder: (item) => Text(item.itemName),
                  ),
                  PosColumn(
                    label: l.inventoryColumnUnit,
                    width: 80,
                    cellBuilder: (item) => Text(item.unit.name),
                  ),
                  PosColumn(
                    label: l.inventoryColumnQuantity,
                    width: 80,
                    numeric: true,
                    cellBuilder: (item) => Text(
                      _formatQuantity(item.stockLevel.quantity),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  PosColumn(
                    label: l.inventoryDialogActualQuantity,
                    width: 100,
                    numeric: true,
                    cellBuilder: (item) {
                      final controller = _controllers[item.stockLevel.itemId]!;
                      return SizedBox(
                        width: 80,
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(isDense: true),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d.,-]'),
                            ),
                          ],
                          onChanged: (_) => setState(() {}),
                        ),
                      );
                    },
                  ),
                  PosColumn(
                    label: l.inventoryDialogDifference,
                    width: 80,
                    numeric: true,
                    cellBuilder: (item) {
                      final controller = _controllers[item.stockLevel.itemId]!;
                      final actual =
                          double.tryParse(
                            controller.text.replaceAll(',', '.'),
                          ) ??
                          item.stockLevel.quantity;
                      final diff = actual - item.stockLevel.quantity;
                      final diffText = diff == 0
                          ? '-'
                          : (diff > 0 ? '+' : '') + _formatQuantity(diff);
                      return Text(
                        diffText,
                        textAlign: TextAlign.right,
                        style: diff != 0
                            ? TextStyle(
                                color: diff > 0
                                    ? Colors.green
                                    : theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              )
                            : null,
                      );
                    },
                  ),
                ],
                items: levels,
                emptyMessage: l.inventoryNoItems,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionCancel),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _saving ? null : () => _save(context),
              child: Text(l.inventoryDialogSave),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _save(BuildContext context) async {
    final user = ref.read(activeUserProvider);
    if (user == null) return;

    // Build inventory lines from current stock levels
    final levels = await ref
        .read(stockLevelRepositoryProvider)
        .watchByWarehouse(widget.companyId, widget.warehouseId)
        .first;

    final inventoryLines = <InventoryLine>[];
    for (final item in levels) {
      final itemId = item.stockLevel.itemId;
      final controller = _controllers[itemId];
      if (controller == null) continue;

      final actualQty =
          double.tryParse(controller.text.replaceAll(',', '.')) ??
          item.stockLevel.quantity;
      inventoryLines.add(
        InventoryLine(
          itemId: itemId,
          currentQuantity: item.stockLevel.quantity,
          actualQuantity: actualQty,
          purchasePrice: item.purchasePrice,
        ),
      );
    }

    // Check if there are any differences
    final hasDifferences = inventoryLines.any(
      (l) => l.actualQuantity != l.currentQuantity,
    );
    if (!hasDifferences) {
      if (context.mounted) Navigator.pop(context);
      return;
    }

    setState(() => _saving = true);

    final result = await ref
        .read(stockDocumentRepositoryProvider)
        .createInventoryDocument(
          companyId: widget.companyId,
          warehouseId: widget.warehouseId,
          userId: user.id,
          inventoryLines: inventoryLines,
        );

    if (!context.mounted) return;
    setState(() => _saving = false);

    if (result is Success) {
      Navigator.pop(context);
    }
  }

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

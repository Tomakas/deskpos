import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/stock_document_repository.dart';
import '../../../core/data/repositories/stock_level_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';

class DialogInventory extends ConsumerStatefulWidget {
  const DialogInventory({
    super.key,
    required this.companyId,
    required this.warehouseId,
    this.itemIds,
  });

  final String companyId;
  final String warehouseId;
  final Set<String>? itemIds;

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
              var levels = snap.data ?? [];
              if (widget.itemIds != null) {
                levels = levels.where((l) => widget.itemIds!.contains(l.itemId)).toList();
              }

              // Ensure controllers exist for all items
              for (final item in levels) {
                final itemId = item.itemId;
                _controllers.putIfAbsent(
                  itemId,
                  () => TextEditingController(
                    text: _formatQuantity(item.quantity),
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
                    headerAlign: TextAlign.center,
                    cellBuilder: (item) => Text(item.unit.name, textAlign: TextAlign.center),
                  ),
                  PosColumn(
                    label: l.inventoryColumnQuantity,
                    width: 80,
                    headerAlign: TextAlign.center,
                    cellBuilder: (item) => Text(
                      _formatQuantity(item.quantity),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  PosColumn(
                    label: l.inventoryDialogActualQuantity,
                    width: 100,
                    headerAlign: TextAlign.center,
                    cellBuilder: (item) {
                      final controller = _controllers[item.itemId]!;
                      return SizedBox(
                        width: 80,
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(isDense: true),
                          textAlign: TextAlign.center,
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
                    headerAlign: TextAlign.center,
                    cellBuilder: (item) {
                      final controller = _controllers[item.itemId]!;
                      final actual =
                          double.tryParse(
                            controller.text.replaceAll(',', '.'),
                          ) ??
                          item.quantity;
                      final diff = actual - item.quantity;
                      final diffText = diff == 0
                          ? '-'
                          : (diff > 0 ? '+' : '') + _formatQuantity(diff);
                      return Text(
                        diffText,
                        textAlign: TextAlign.center,
                        style: diff != 0
                            ? TextStyle(
                                color: diff > 0
                                    ? context.appColors.positive
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

    final stockLevelRepo = ref.read(stockLevelRepositoryProvider);
    final stockDocRepo = ref.read(stockDocumentRepositoryProvider);

    // Build inventory lines from current stock levels
    var levels = await stockLevelRepo
        .watchByWarehouse(widget.companyId, widget.warehouseId)
        .first;
    if (widget.itemIds != null) {
      levels = levels.where((l) => widget.itemIds!.contains(l.itemId)).toList();
    }

    final inventoryLines = <InventoryLine>[];
    for (final item in levels) {
      final itemId = item.itemId;
      final controller = _controllers[itemId];
      if (controller == null) continue;

      final actualQty =
          double.tryParse(controller.text.replaceAll(',', '.')) ??
          item.quantity;
      inventoryLines.add(
        InventoryLine(
          itemId: itemId,
          currentQuantity: item.quantity,
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

    final result = await stockDocRepo
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

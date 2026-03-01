import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/permission_providers.dart';
import '../../../core/data/providers/printing_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/stock_level_repository.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/printing/inventory_pdf_builder.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_opener.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/utils/unit_type_l10n.dart';
import '../../../core/widgets/pos_table.dart';

class InventoryLineWithName {
  InventoryLineWithName({
    required this.itemId,
    required this.itemName,
    required this.unitName,
    required this.currentQuantity,
    required this.actualQuantity,
    this.purchasePrice,
  });

  final String itemId;
  final String itemName;
  final String unitName;
  final double currentQuantity;
  final double actualQuantity;
  final int? purchasePrice;
}

class DialogInventory extends ConsumerStatefulWidget {
  const DialogInventory({
    super.key,
    required this.companyId,
    required this.warehouseId,
    this.itemIds,
    this.blindMode = false,
  });

  final String companyId;
  final String warehouseId;
  final Set<String>? itemIds;
  final bool blindMode;

  @override
  ConsumerState<DialogInventory> createState() => _DialogInventoryState();
}

class _DialogInventoryState extends ConsumerState<DialogInventory> {
  final _controllers = <String, TextEditingController>{};
  bool _printing = false;

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
      bottomActions: PosDialogActions(
        leading: ref.watch(hasPermissionProvider('printing.inventory_report'))
            ? OutlinedButton.icon(
                onPressed: _printing ? null : () => _printTemplate(context),
                icon: const Icon(Icons.print_outlined),
                label: Text(l.inventoryPrintTemplate),
              )
            : null,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => _save(context),
            child: Text(l.inventoryDialogSave),
          ),
        ],
      ),
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
                    text: widget.blindMode ? '' : _formatQuantity(item.quantity),
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
                    cellBuilder: (item) => Text(localizedUnitType(l, item.unit), textAlign: TextAlign.center),
                  ),
                  if (!widget.blindMode)
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
                  if (!widget.blindMode)
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
      ],
    );
  }

  Future<void> _printTemplate(BuildContext context) async {
    setState(() => _printing = true);
    try {
      final l = context.l10n;
      final locale = ref.read(appLocaleProvider).value ?? 'cs';
      final currency = ref.read(currentCurrencyProvider).value;

      final levels = await ref
          .read(stockLevelRepositoryProvider)
          .watchByWarehouse(widget.companyId, widget.warehouseId)
          .first;
      final filtered = widget.itemIds != null
          ? levels.where((l) => widget.itemIds!.contains(l.itemId)).toList()
          : levels;

      final pdfLines = filtered.map((item) => InventoryPdfLine(
        itemName: item.itemName,
        unitName: localizedUnitType(l, item.unit),
        currentQuantity: item.quantity,
        actualQuantity: null,
        purchasePrice: item.purchasePrice,
      )).toList();

      final data = InventoryPdfData(
        title: l.inventoryPdfTemplateTitle,
        date: formatDateForPrint(DateTime.now(), locale),
        isTemplate: true,
        blindMode: widget.blindMode,
        lines: pdfLines,
        currency: currency,
      );

      final labels = InventoryPdfLabels(
        columnItem: l.inventoryColumnItem,
        columnUnit: l.inventoryColumnUnit,
        columnExpected: l.inventoryResultExpected,
        columnActual: l.inventoryResultActual,
        columnDifference: l.inventoryDialogDifference,
        surplus: l.inventoryResultSurplus,
        shortage: l.inventoryResultShortage,
        locale: locale,
      );

      final bytes = await ref.read(printingServiceProvider)
          .generateInventoryPdf(data, labels);
      await FileOpener.shareBytes(
        'inventory_template_${DateTime.now().millisecondsSinceEpoch}.pdf',
        bytes,
      );
    } catch (e, s) {
      AppLogger.error('Failed to print inventory template', error: e, stackTrace: s);
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  Future<void> _save(BuildContext context) async {
    final l = context.l10n;
    final stockLevelRepo = ref.read(stockLevelRepositoryProvider);

    var levels = await stockLevelRepo
        .watchByWarehouse(widget.companyId, widget.warehouseId)
        .first;
    if (widget.itemIds != null) {
      levels = levels.where((l) => widget.itemIds!.contains(l.itemId)).toList();
    }

    final lines = <InventoryLineWithName>[];
    for (final item in levels) {
      final itemId = item.itemId;
      final controller = _controllers[itemId];
      if (controller == null) continue;

      final actualQty =
          double.tryParse(controller.text.replaceAll(',', '.')) ??
          item.quantity;
      lines.add(
        InventoryLineWithName(
          itemId: itemId,
          itemName: item.itemName,
          unitName: localizedUnitType(l, item.unit),
          currentQuantity: item.quantity,
          actualQuantity: actualQty,
          purchasePrice: item.purchasePrice,
        ),
      );
    }

    if (!context.mounted) return;
    Navigator.pop(context, lines);
  }

  String _formatQuantity(double value) => ref.fmtQty(value);
}

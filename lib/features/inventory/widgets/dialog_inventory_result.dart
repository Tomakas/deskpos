import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/printing_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/stock_document_repository.dart';
import '../../../core/data/result.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/printing/inventory_pdf_builder.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_opener.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';
import 'dialog_inventory.dart';

class DialogInventoryResult extends ConsumerStatefulWidget {
  const DialogInventoryResult({
    super.key,
    required this.companyId,
    required this.warehouseId,
    required this.lines,
  });

  final String companyId;
  final String warehouseId;
  final List<InventoryLineWithName> lines;

  @override
  ConsumerState<DialogInventoryResult> createState() => _DialogInventoryResultState();
}

class _DialogInventoryResultState extends ConsumerState<DialogInventoryResult> {
  bool _applied = false;
  bool _applying = false;
  bool _printing = false;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _selectedTime = TimeOfDay.fromDateTime(now);
  }

  DateTime get _combinedDateTime => DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (result != null && mounted) {
      setState(() => _selectedDate = result);
    }
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (result != null && mounted) {
      setState(() => _selectedTime = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    final diffLines = widget.lines
        .where((line) => line.actualQuantity != line.currentQuantity)
        .toList();

    // Compute surplus/shortage
    int surplusCount = 0;
    int surplusValue = 0;
    int shortageCount = 0;
    int shortageValue = 0;

    for (final line in diffLines) {
      final diff = line.actualQuantity - line.currentQuantity;
      if (diff > 0) {
        surplusCount++;
        if (line.purchasePrice != null) {
          surplusValue += (diff * line.purchasePrice!).round();
        }
      } else {
        shortageCount++;
        if (line.purchasePrice != null) {
          shortageValue += ((line.currentQuantity - line.actualQuantity) * line.purchasePrice!).round();
        }
      }
    }

    return PosDialogShell(
      title: l.inventoryResultTitle,
      maxWidth: 700,
      maxHeight: 700,
      expandHeight: true,
      bottomActions: PosDialogActions(
        leading: OutlinedButton.icon(
          onPressed: _printing ? null : () => _printResults(context),
          icon: const Icon(Icons.print_outlined),
          label: Text(l.inventoryResultPrint),
        ),
        actions: [
          FilledButton(
            onPressed: (_applied || _applying) ? null : () => _applyToStock(context),
            child: Text(_applied ? l.inventoryResultApplied : l.inventoryResultApply),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.inventoryResultClose),
          ),
        ],
      ),
      children: [
        // Summary section
        if (surplusCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(
                  '${l.inventoryResultSurplus}: ${l.inventoryResultItemCount(surplusCount)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.appColors.positive,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${l.inventoryResultNcValue}: +${ref.moneyValue(surplusValue)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.appColors.positive,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        if (shortageCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(
                  '${l.inventoryResultShortage}: ${l.inventoryResultItemCount(shortageCount)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${l.inventoryResultNcValue}: -${ref.moneyValue(shortageValue)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        // Document date + time
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _applied ? null : _pickDate,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(ref.fmtDate(_selectedDate)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _applied ? null : _pickTime,
                icon: const Icon(Icons.access_time, size: 18),
                label: Text(_selectedTime.format(context)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Diff table
        Expanded(
          child: PosTable<InventoryLineWithName>(
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
                cellBuilder: (item) => Text(item.unitName, textAlign: TextAlign.center),
              ),
              PosColumn(
                label: l.inventoryResultExpected,
                width: 90,
                headerAlign: TextAlign.center,
                cellBuilder: (item) => Text(
                  _formatQuantity(item.currentQuantity),
                  textAlign: TextAlign.center,
                ),
              ),
              PosColumn(
                label: l.inventoryResultActual,
                width: 90,
                headerAlign: TextAlign.center,
                cellBuilder: (item) => Text(
                  _formatQuantity(item.actualQuantity),
                  textAlign: TextAlign.center,
                ),
              ),
              PosColumn(
                label: l.inventoryDialogDifference,
                width: 80,
                headerAlign: TextAlign.center,
                cellBuilder: (item) {
                  final diff = item.actualQuantity - item.currentQuantity;
                  final diffText = (diff > 0 ? '+' : '') + _formatQuantity(diff);
                  return Text(
                    diffText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: diff > 0
                          ? context.appColors.positive
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
            items: diffLines,
            emptyMessage: l.inventoryDialogNoDifferences,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _applyToStock(BuildContext context) async {
    final user = ref.read(activeUserProvider);
    if (user == null) return;

    setState(() => _applying = true);

    final stockDocRepo = ref.read(stockDocumentRepositoryProvider);
    final inventoryLines = widget.lines.map((line) => InventoryLine(
      itemId: line.itemId,
      currentQuantity: line.currentQuantity,
      actualQuantity: line.actualQuantity,
      purchasePrice: line.purchasePrice,
    )).toList();

    final result = await stockDocRepo.createInventoryDocument(
      companyId: widget.companyId,
      warehouseId: widget.warehouseId,
      userId: user.id,
      inventoryLines: inventoryLines,
      documentDate: _combinedDateTime,
    );

    if (!mounted) return;

    if (result is Success) {
      setState(() {
        _applied = true;
        _applying = false;
      });
    } else {
      setState(() => _applying = false);
    }
  }

  Future<void> _printResults(BuildContext context) async {
    setState(() => _printing = true);
    try {
      final l = context.l10n;
      final locale = ref.read(appLocaleProvider).value ?? 'cs';
      final currency = ref.read(currentCurrencyProvider).value;

      final diffLines = widget.lines
          .where((line) => line.actualQuantity != line.currentQuantity)
          .toList();

      int surplusCount = 0;
      int surplusValue = 0;
      int shortageCount = 0;
      int shortageValue = 0;

      for (final line in diffLines) {
        final diff = line.actualQuantity - line.currentQuantity;
        if (diff > 0) {
          surplusCount++;
          if (line.purchasePrice != null) {
            surplusValue += (diff * line.purchasePrice!).round();
          }
        } else {
          shortageCount++;
          if (line.purchasePrice != null) {
            shortageValue += ((line.currentQuantity - line.actualQuantity) * line.purchasePrice!).round();
          }
        }
      }

      final pdfLines = diffLines.map((line) => InventoryPdfLine(
        itemName: line.itemName,
        unitName: line.unitName,
        currentQuantity: line.currentQuantity,
        actualQuantity: line.actualQuantity,
        purchasePrice: line.purchasePrice,
      )).toList();

      final data = InventoryPdfData(
        title: l.inventoryPdfResultsTitle,
        date: formatDateForPrint(DateTime.now(), locale),
        isTemplate: false,
        blindMode: false,
        lines: pdfLines,
        currency: currency,
        surplusCount: surplusCount,
        surplusValue: surplusValue,
        shortageCount: shortageCount,
        shortageValue: shortageValue,
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
        'inventory_results_${DateTime.now().millisecondsSinceEpoch}.pdf',
        bytes,
      );
    } catch (e, s) {
      AppLogger.error('Failed to print inventory results', error: e, stackTrace: s);
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  String _formatQuantity(double value) => ref.fmtQty(value);
}

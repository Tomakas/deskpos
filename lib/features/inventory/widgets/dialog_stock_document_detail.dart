import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/enums/stock_document_type.dart';
import '../../../core/data/enums/stock_movement_direction.dart';
import '../../../core/data/models/stock_document_model.dart';
import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/printing_providers.dart';
import '../../../core/data/providers/repository_providers.dart';
import '../../../core/data/repositories/stock_movement_repository.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/printing/stock_document_pdf_builder.dart';
import '../../../core/utils/file_opener.dart';
import '../../../core/utils/formatting_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/unit_type_l10n.dart';
import '../../../core/widgets/pos_dialog_actions.dart';
import '../../../core/widgets/pos_dialog_shell.dart';
import '../../../core/widgets/pos_table.dart';
import '../../../l10n/app_localizations.dart';

class DialogStockDocumentDetail extends ConsumerStatefulWidget {
  const DialogStockDocumentDetail({
    super.key,
    required this.documentId,
    this.document,
    this.supplierName,
  });

  final String documentId;
  final StockDocumentModel? document;
  final String? supplierName;

  @override
  ConsumerState<DialogStockDocumentDetail> createState() =>
      _DialogStockDocumentDetailState();
}

class _DialogStockDocumentDetailState
    extends ConsumerState<DialogStockDocumentDetail> {
  bool _printing = false;
  String? _resolvedSupplierName;
  bool _supplierResolved = false;

  @override
  void initState() {
    super.initState();
    _resolvedSupplierName = widget.supplierName;
    if (widget.supplierName != null) {
      _supplierResolved = true;
    }
  }

  void _resolveSupplier(StockDocumentModel doc) {
    if (_supplierResolved || doc.supplierId == null) return;
    _supplierResolved = true;
    ref.read(supplierRepositoryProvider).getById(doc.supplierId!).then((s) {
      if (mounted && s != null) {
        setState(() => _resolvedSupplierName = s.supplierName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return StreamBuilder<StockDocumentModel?>(
      initialData: widget.document,
      stream: widget.document != null
          ? Stream.value(widget.document)
          : ref.watch(stockDocumentRepositoryProvider).watchById(widget.documentId),
      builder: (context, docSnap) {
        final doc = docSnap.data;
        if (doc == null) {
          return PosDialogShell(
            title: l.stockDocumentDetailTitle,
            maxWidth: 700,
            children: [
              const Center(child: CircularProgressIndicator()),
            ],
          );
        }

        _resolveSupplier(doc);

        return StreamBuilder<List<StockMovementWithItem>>(
          stream: ref
              .watch(stockMovementRepositoryProvider)
              .watchByDocumentWithItems(widget.documentId),
          builder: (context, movSnap) {
            final movements = movSnap.data ?? [];

            return PosDialogShell(
              showCloseButton: true,
              title: doc.documentNumber,
              maxWidth: 700,
              expandHeight: true,
              bottomActions: PosDialogActions(
                leading: OutlinedButton.icon(
                  onPressed: _printing
                      ? null
                      : () => _print(context, doc, movements),
                  icon: const Icon(Icons.print_outlined),
                  label: Text(l.billDetailPrint),
                ),
                actions: const [],
              ),
              children: [
                _buildHeader(context, doc, l),
                const SizedBox(height: 8),
                Expanded(
                  child: PosTable<StockMovementWithItem>(
                    columns: [
                      PosColumn(
                        label: l.inventoryColumnItem,
                        flex: 3,
                        cellBuilder: (item) => Text(
                          item.itemName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PosColumn(
                        label: l.inventoryColumnUnit,
                        flex: 1,
                        headerAlign: TextAlign.center,
                        cellBuilder: (item) => Text(
                          localizedUnitType(l, item.unit),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      PosColumn(
                        label: l.stockDocumentQuantity,
                        flex: 1,
                        headerAlign: TextAlign.center,
                        cellBuilder: (item) {
                          final isInbound = item.movement.direction ==
                              StockMovementDirection.inbound;
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
                        label: l.stockDocumentPrice,
                        flex: 1,
                        numeric: true,
                        cellBuilder: (item) => Text(
                          item.movement.purchasePrice != null
                              ? ref.moneyValue(item.movement.purchasePrice!)
                              : '-',
                          textAlign: TextAlign.right,
                        ),
                      ),
                      PosColumn(
                        label: l.documentColumnTotal,
                        flex: 1,
                        numeric: true,
                        cellBuilder: (item) {
                          if (item.movement.purchasePrice == null) {
                            return const Text('-', textAlign: TextAlign.right);
                          }
                          final total = (item.movement.purchasePrice! *
                                  item.movement.quantity)
                              .round();
                          return Text(
                            ref.moneyValue(total),
                            textAlign: TextAlign.right,
                          );
                        },
                      ),
                    ],
                    items: movements,
                    emptyMessage: l.movementNoMovements,
                    footer: doc.totalAmount != 0
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color:
                                          Theme.of(context).dividerColor)),
                            ),
                            child: Text(
                              '${l.documentColumnTotal}: ${ref.moneyValue(doc.totalAmount)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.end,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, StockDocumentModel doc, AppLocalizations l) {
    final theme = Theme.of(context);
    final typeLabel = _documentTypeLabel(l, doc.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(typeLabel,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            Text(ref.fmtDateTime(doc.documentDate),
                style: theme.textTheme.bodyMedium),
          ],
        ),
        if (_resolvedSupplierName != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${l.documentColumnSupplier}: $_resolvedSupplierName',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        if (doc.note != null && doc.note!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${l.documentColumnNote}: ${doc.note}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
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

  Future<void> _print(
    BuildContext context,
    StockDocumentModel doc,
    List<StockMovementWithItem> movements,
  ) async {
    setState(() => _printing = true);
    try {
      final l = context.l10n;
      final locale = ref.read(appLocaleProvider).value ?? 'cs';
      final currency = ref.read(currentCurrencyProvider).value;

      final pdfLines = movements
          .map((m) => StockDocumentPdfLine(
                itemName: m.itemName,
                unitName: localizedUnitType(l, m.unit),
                quantity: m.movement.quantity,
                purchasePrice: m.movement.purchasePrice,
              ))
          .toList();

      final data = StockDocumentPdfData(
        title: _documentTypeLabel(l, doc.type),
        documentNumber: doc.documentNumber,
        date: formatDateForPrint(doc.documentDate, locale),
        supplierName: _resolvedSupplierName,
        note: doc.note,
        lines: pdfLines,
        totalAmount: doc.totalAmount,
        currency: currency,
      );

      final labels = StockDocumentPdfLabels(
        columnItem: l.inventoryColumnItem,
        columnUnit: l.inventoryColumnUnit,
        columnQuantity: l.stockDocumentQuantity,
        columnPrice: l.stockDocumentPrice,
        columnTotal: l.documentColumnTotal,
        supplier: l.documentColumnSupplier,
        note: l.documentColumnNote,
        total: l.documentColumnTotal,
        locale: locale,
      );

      final bytes = await ref
          .read(printingServiceProvider)
          .generateStockDocumentPdf(data, labels);
      await FileOpener.shareBytes(
        'stock_document_${doc.documentNumber}.pdf',
        bytes,
      );
    } catch (e, s) {
      AppLogger.error('Failed to print stock document', error: e, stackTrace: s);
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }
}

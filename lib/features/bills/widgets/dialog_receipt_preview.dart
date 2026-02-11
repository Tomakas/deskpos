import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../core/data/providers/printing_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/printing/printing_service.dart';
import '../../../core/printing/receipt_data.dart';

class DialogReceiptPreview extends ConsumerWidget {
  const DialogReceiptPreview({super.key, required this.billId});
  final String billId;

  ReceiptLabels _buildLabels(BuildContext context) {
    final l = context.l10n;
    return ReceiptLabels(
      subtotal: l.receiptSubtotal,
      discount: l.receiptDiscount,
      total: l.receiptTotal,
      rounding: l.receiptRounding,
      taxTitle: l.receiptTaxTitle,
      taxRate: l.receiptTaxRate,
      taxNet: l.receiptTaxNet,
      taxAmount: l.receiptTaxAmount,
      taxGross: l.receiptTaxGross,
      payment: l.receiptPayment,
      tip: l.receiptTip,
      billNumber: l.receiptBillNumber,
      table: l.receiptTable,
      takeaway: l.receiptTakeaway,
      cashier: l.receiptCashier,
      date: l.receiptDate,
      thankYou: l.receiptThankYou,
      ico: l.receiptIco,
      dic: l.receiptDic,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final printingService = ref.watch(printingServiceProvider);
    final labels = _buildLabels(context);

    return Dialog(
      child: SizedBox(
        width: 400,
        height: 600,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l.receiptPreviewTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: FutureBuilder<Uint8List?>(
                future: _generatePdf(printingService, labels),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data == null) {
                    return const Center(child: Icon(Icons.error_outline));
                  }
                  return PdfPreview(
                    build: (_) => snapshot.data!,
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    canDebug: false,
                    pdfFileName: 'receipt_$billId.pdf',
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: FilledButton.tonal(
                onPressed: () => Navigator.pop(context),
                child: Text(l.actionClose),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> _generatePdf(
    PrintingService service,
    ReceiptLabels labels,
  ) async {
    final data = await service.buildReceiptData(billId);
    if (data == null) return null;
    return service.generateReceiptPdf(data, labels);
  }
}

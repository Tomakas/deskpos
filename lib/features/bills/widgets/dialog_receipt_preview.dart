import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../core/data/providers/printing_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/printing/receipt_data.dart';

class DialogReceiptPreview extends ConsumerStatefulWidget {
  const DialogReceiptPreview({super.key, required this.billId});
  final String billId;

  @override
  ConsumerState<DialogReceiptPreview> createState() => _DialogReceiptPreviewState();
}

class _DialogReceiptPreviewState extends ConsumerState<DialogReceiptPreview> {
  Future<Uint8List?>? _pdfFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pdfFuture ??= _generatePdf();
  }

  Future<Uint8List?> _generatePdf() async {
    try {
      final service = ref.read(printingServiceProvider);
      final l = context.l10n;
      final labels = ReceiptLabels(
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
      final data = await service.buildReceiptData(widget.billId);
      if (data == null) return null;
      return await service.generateReceiptPdf(data, labels);
    } catch (e, s) {
      AppLogger.error('Failed to generate receipt PDF', error: e, stackTrace: s);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

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
                future: _pdfFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return const Center(child: Icon(Icons.error_outline, size: 48));
                  }
                  return PdfPreview(
                    build: (_) => snapshot.data!,
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    canDebug: false,
                    pdfFileName: 'receipt_${widget.billId}.pdf',
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
}

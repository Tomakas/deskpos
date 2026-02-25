import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/providers/auth_providers.dart';
import '../../../core/data/providers/printing_providers.dart';
import '../../../core/l10n/app_localizations_ext.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/printing/receipt_data.dart';
import '../../../core/utils/file_opener.dart';
import '../../../core/utils/unit_type_l10n.dart';

/// Generates receipt PDF, saves to temp file, and opens with system viewer.
/// On macOS, Preview.app opens with built-in print (Cmd+P).
Future<void> showReceiptPrintDialog(
  BuildContext context,
  WidgetRef ref,
  String billId,
) async {
  final l = context.l10n;
  final service = ref.read(printingServiceProvider);
  final locale = ref.read(appLocaleProvider).value ?? 'cs';

  final labels = ReceiptLabels(
    subtotal: l.receiptSubtotal,
    discount: l.receiptDiscount,
    voucherDiscount: l.receiptVoucherDiscount,
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
    locale: locale,
  );

  try {
    final currency = ref.read(currentCurrencyProvider).value;
    final data = await service.buildReceiptData(billId, currency: currency, unitLocalizer: (u) => localizedUnitType(l, u));
    if (data == null) {
      AppLogger.error('showReceiptPrintDialog: no receipt data for bill $billId');
      return;
    }
    final pdfBytes = await service.generateReceiptPdf(data, labels);
    await FileOpener.shareBytes('receipt_$billId.pdf', pdfBytes);
  } catch (e, s) {
    AppLogger.error('Failed to print receipt', error: e, stackTrace: s);
  }
}

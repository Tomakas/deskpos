import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/bills/models/z_report_data.dart';
import '../data/models/currency_model.dart';
import '../utils/formatters.dart';
import 'receipt_data.dart';

class ZReportPdfBuilder {
  ZReportPdfBuilder({
    required this.data,
    required this.labels,
    required this.regular,
    required this.bold,
  });

  final ZReportData data;
  final ZReportLabels labels;
  final pw.Font regular;
  final pw.Font bold;

  String _fmtMoney(int amount) =>
      formatMoneyForPrint(amount, labels.currency, appLocale: labels.locale);

  String _fmtTaxRate(int basisPoints) {
    return formatPercent(basisPoints / 100, labels.locale);
  }

  Future<Uint8List> build() async {
    final doc = pw.Document();

    final baseStyle = pw.TextStyle(font: regular, fontSize: 10);
    final boldStyle = pw.TextStyle(font: bold, fontSize: 10);
    final headerStyle = pw.TextStyle(font: bold, fontSize: 16);
    final sectionStyle = pw.TextStyle(font: bold, fontSize: 12);
    final smallStyle = pw.TextStyle(font: regular, fontSize: 9);
    final smallBoldStyle = pw.TextStyle(font: bold, fontSize: 9);

    String fmtDate(DateTime dt) => formatDateOnlyForPrint(dt, labels.locale);
    String fmtTime(DateTime dt) => formatTimeForPrint(dt, labels.locale);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // --- Header ---
          pw.Center(
            child: pw.Text(labels.reportTitle, style: headerStyle),
          ),
          pw.SizedBox(height: 16),

          // --- Session info ---
          pw.Text(labels.session, style: sectionStyle),
          pw.SizedBox(height: 6),
          _row(labels.openedAt,
              '${fmtDate(data.openedAt)} ${fmtTime(data.openedAt)}',
              baseStyle),
          if (data.closedAt != null)
            _row(labels.closedAt,
                '${fmtDate(data.closedAt!)} ${fmtTime(data.closedAt!)}',
                baseStyle),
          _row(labels.duration, labels.formatDuration(data.duration), baseStyle),
          _row(labels.openedBy, data.openedByName, baseStyle),
          pw.Divider(),

          // --- Revenue by payment type ---
          pw.Text(labels.revenueTitle, style: sectionStyle),
          pw.SizedBox(height: 6),
          for (final ps in data.paymentSummaries)
            pw.Row(
              children: [
                pw.Expanded(child: pw.Text(ps.name, style: baseStyle)),
                pw.SizedBox(
                  width: 100,
                  child: pw.Text(_fmtMoney(ps.amount),
                      style: baseStyle, textAlign: pw.TextAlign.right),
                ),
                pw.SizedBox(
                  width: 50,
                  child: pw.Text('${ps.count}x',
                      style: smallStyle, textAlign: pw.TextAlign.right),
                ),
              ],
            ),
          pw.SizedBox(height: 4),
          _row(labels.revenueTotal, _fmtMoney(data.totalRevenue), boldStyle),
          pw.Divider(),

          // --- Tax breakdown ---
          if (data.taxBreakdown.isNotEmpty) ...[
            pw.Text(labels.taxTitle, style: sectionStyle),
            pw.SizedBox(height: 6),
            // Header row
            pw.Row(
              children: [
                pw.SizedBox(
                    width: 60,
                    child: pw.Text(labels.taxRate, style: smallBoldStyle)),
                pw.Expanded(
                    child: pw.Text(labels.taxNet,
                        style: smallBoldStyle,
                        textAlign: pw.TextAlign.right)),
                pw.Expanded(
                    child: pw.Text(labels.taxAmount,
                        style: smallBoldStyle,
                        textAlign: pw.TextAlign.right)),
                pw.Expanded(
                    child: pw.Text(labels.taxGross,
                        style: smallBoldStyle,
                        textAlign: pw.TextAlign.right)),
              ],
            ),
            for (final row in data.taxBreakdown)
              pw.Row(
                children: [
                  pw.SizedBox(
                      width: 60,
                      child: pw.Text(_fmtTaxRate(row.taxRatePercent),
                          style: baseStyle)),
                  pw.Expanded(
                      child: pw.Text(_fmtMoney(row.netAmount),
                          style: baseStyle, textAlign: pw.TextAlign.right)),
                  pw.Expanded(
                      child: pw.Text(_fmtMoney(row.taxAmount),
                          style: baseStyle, textAlign: pw.TextAlign.right)),
                  pw.Expanded(
                      child: pw.Text(_fmtMoney(row.grossAmount),
                          style: baseStyle, textAlign: pw.TextAlign.right)),
                ],
              ),
            pw.Divider(),
          ],

          // --- Tips ---
          if (data.totalTips > 0) ...[
            pw.Text(labels.tipsTitle, style: sectionStyle),
            pw.SizedBox(height: 6),
            _row(labels.tipsTotal, _fmtMoney(data.totalTips), boldStyle),
            if (data.tipsByUser.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(labels.tipsByUser, style: smallBoldStyle),
              for (final entry in data.tipsByUser.values)
                _row('  ${entry.$1}', _fmtMoney(entry.$2), baseStyle),
            ],
            pw.Divider(),
          ],

          // --- Discounts ---
          if (data.totalDiscounts > 0) ...[
            _row(labels.discountsTotal, _fmtMoney(data.totalDiscounts), baseStyle),
            pw.Divider(),
          ],

          // --- Bill counts ---
          pw.Text(labels.billCountsTitle, style: sectionStyle),
          pw.SizedBox(height: 6),
          _row(labels.billsPaid, '${data.billsPaid}', baseStyle),
          if (data.billsCancelled > 0)
            _row(labels.billsCancelled, '${data.billsCancelled}', baseStyle),
          if (data.billsRefunded > 0)
            _row(labels.billsRefunded, '${data.billsRefunded}', baseStyle),
          if (data.openBillsAtOpenCount > 0)
            _row(labels.openBillsAtOpen,
                '${data.openBillsAtOpenCount} (${_fmtMoney(data.openBillsAtOpenAmount)})',
                baseStyle),
          if (data.openBillsAtCloseCount > 0)
            _row(labels.openBillsAtClose,
                '${data.openBillsAtCloseCount} (${_fmtMoney(data.openBillsAtCloseAmount)})',
                baseStyle),
          pw.Divider(),

          // --- Cash reconciliation ---
          pw.Text(labels.cashTitle, style: sectionStyle),
          pw.SizedBox(height: 6),
          _row(labels.cashOpening, _fmtMoney(data.openingCash), baseStyle),
          _signedRow(labels.cashRevenue, data.cashRevenue, baseStyle),
          if (data.cashDeposits > 0)
            _signedRow(labels.cashDeposits, data.cashDeposits, baseStyle),
          if (data.cashWithdrawals > 0)
            _signedRow(
                labels.cashWithdrawals, -data.cashWithdrawals, baseStyle),
          pw.SizedBox(height: 4),
          _row(labels.cashExpected, _fmtMoney(data.expectedCash), boldStyle),
          _row(labels.cashClosing, _fmtMoney(data.closingCash), baseStyle),
          _row(
            labels.cashDifference,
            _fmtSigned(data.difference),
            boldStyle,
          ),


          // --- Foreign currency cash ---
          if (data.foreignCurrencyCash.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            for (final fc in data.foreignCurrencyCash) ...[
              pw.Text('${fc.currencyCode} (${fc.currencySymbol})', style: boldStyle),
              pw.SizedBox(height: 4),
              _row(labels.cashOpening, _fmtForeign(fc.openingCash, fc), baseStyle),
              _signedForeignRow(labels.cashRevenue, fc.cashRevenue, fc, baseStyle),
              pw.SizedBox(height: 2),
              _row(labels.cashExpected, _fmtForeign(fc.expectedCash, fc), boldStyle),
              _row(labels.cashClosing, _fmtForeign(fc.closingCash, fc), baseStyle),
              _row(labels.cashDifference, _fmtForeignSigned(fc.difference, fc), boldStyle),
              pw.SizedBox(height: 6),
            ],
          ],
          pw.Divider(),

          // --- Shift durations ---
          if (data.shiftDurations.isNotEmpty) ...[
            pw.Text(labels.shiftsTitle, style: sectionStyle),
            pw.SizedBox(height: 6),
            for (final entry in data.shiftDurations.values)
              _row(entry.$1, labels.formatDuration(entry.$2), baseStyle),
          ],
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _row(String label, String value, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(label, style: style)),
          pw.Text(value, style: style),
        ],
      ),
    );
  }

  String _fmtSigned(int amount) {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix${formatMoneyForPrint(amount, labels.currency)}';
  }

  pw.Widget _signedRow(String label, int amount, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(label, style: style)),
          pw.Text(_fmtSigned(amount), style: style),
        ],
      ),
    );
  }

  String _fmtForeign(int amount, ForeignCurrencyCashSummary fc) {
    final cur = CurrencyModel(
      id: '', code: fc.currencyCode, symbol: fc.currencySymbol,
      name: '', decimalPlaces: fc.decimalPlaces,
      createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );
    return formatMoneyForPrint(amount, cur);
  }

  String _fmtForeignSigned(int amount, ForeignCurrencyCashSummary fc) {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix${_fmtForeign(amount, fc)}';
  }

  pw.Widget _signedForeignRow(String label, int amount, ForeignCurrencyCashSummary fc, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(label, style: style)),
          pw.Text(_fmtForeignSigned(amount, fc), style: style),
        ],
      ),
    );
  }
}

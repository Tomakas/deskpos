import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'receipt_data.dart';

class ReceiptPdfBuilder {
  ReceiptPdfBuilder({
    required this.data,
    required this.labels,
    required this.regular,
    required this.bold,
  });

  final ReceiptData data;
  final ReceiptLabels labels;
  final pw.Font regular;
  final pw.Font bold;

  static const double _pageWidth = 226; // 80mm in points
  static const double _margin = 8;

  String _fmtKc(int halere) => '${halere ~/ 100} ${data.currencySymbol}';

  String _fmtTaxRate(int basisPoints) {
    final pct = basisPoints / 100;
    return pct == pct.roundToDouble()
        ? '${pct.round()}%'
        : '${pct.toStringAsFixed(1)}%';
  }

  Future<Uint8List> build() async {
    final doc = pw.Document();

    final baseStyle = pw.TextStyle(font: regular, fontSize: 9);
    final boldStyle = pw.TextStyle(font: bold, fontSize: 9);
    final smallStyle = pw.TextStyle(font: regular, fontSize: 7.5);
    final headerStyle = pw.TextStyle(font: bold, fontSize: 12);
    final totalStyle = pw.TextStyle(font: bold, fontSize: 13);

    final dateFormat = DateFormat('d.M.yyyy HH:mm', 'cs');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          _pageWidth,
          double.infinity,
          marginAll: _margin,
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // --- Header: company info ---
            pw.Center(
              child: pw.Text(data.companyName, style: headerStyle),
            ),
            if (data.companyAddress != null)
              pw.Center(
                child: pw.Text(data.companyAddress!, style: smallStyle),
              ),
            if (data.companyCity != null || data.companyPostalCode != null)
              pw.Center(
                child: pw.Text(
                  [data.companyPostalCode, data.companyCity]
                      .where((s) => s != null && s.isNotEmpty)
                      .join(' '),
                  style: smallStyle,
                ),
              ),
            if (data.companyBusinessId != null)
              pw.Center(
                child: pw.Text(
                  '${labels.ico}: ${data.companyBusinessId}',
                  style: smallStyle,
                ),
              ),
            if (data.companyVatNumber != null)
              pw.Center(
                child: pw.Text(
                  '${labels.dic}: ${data.companyVatNumber}',
                  style: smallStyle,
                ),
              ),
            if (data.companyPhone != null)
              pw.Center(
                child: pw.Text(data.companyPhone!, style: smallStyle),
              ),
            if (data.companyEmail != null)
              pw.Center(
                child: pw.Text(data.companyEmail!, style: smallStyle),
              ),

            _divider(),

            // --- Bill info ---
            _infoRow(
              '${labels.billNumber} ${data.billNumber}',
              baseStyle,
            ),
            if (data.isTakeaway)
              _infoRow(labels.takeaway, baseStyle)
            else if (data.tableName != null)
              _infoRow('${labels.table}: ${data.tableName}', baseStyle),
            _infoRow(
              '${labels.date}: ${dateFormat.format(data.closedAt ?? data.openedAt)}',
              baseStyle,
            ),
            _infoRow('${labels.cashier}: ${data.cashierName}', baseStyle),

            _divider(),

            // --- Items ---
            for (final item in data.items) ...[
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      '${_fmtQty(item.quantity)} ${item.name}',
                      style: baseStyle,
                    ),
                  ),
                  pw.Text(_fmtKc(item.totalHalere), style: baseStyle),
                ],
              ),
              if (item.discountHalere > 0)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 12),
                  child: pw.Text(
                    '${labels.discount}: -${_fmtKc(item.discountHalere)}',
                    style: smallStyle,
                  ),
                ),
              if (item.notes != null && item.notes!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 12),
                  child: pw.Text(
                    item.notes!,
                    style: pw.TextStyle(
                      font: regular,
                      fontSize: 7.5,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
            ],

            _divider(),

            // --- Subtotal (only if discount exists) ---
            if (data.discountAmount > 0) ...[
              _totalRow(labels.subtotal, _fmtKc(data.subtotalGross), baseStyle),
              _totalRow(
                labels.discount,
                '-${_fmtKc(data.discountAmount)}',
                baseStyle,
              ),
            ],

            // --- Rounding ---
            if (data.roundingAmount != 0)
              _totalRow(
                labels.rounding,
                '${data.roundingAmount >= 0 ? '+' : ''}${data.roundingAmount ~/ 100} ${data.currencySymbol}',
                baseStyle,
              ),

            // --- Total ---
            _totalRow(labels.total, _fmtKc(data.totalGross), totalStyle),

            _divider(),

            // --- Tax breakdown ---
            pw.Text(labels.taxTitle, style: boldStyle),
            pw.SizedBox(height: 2),
            // Header row
            pw.Row(
              children: [
                pw.SizedBox(
                  width: 40,
                  child: pw.Text(labels.taxRate, style: smallStyle),
                ),
                pw.Expanded(
                  child: pw.Text(
                    labels.taxNet,
                    style: smallStyle,
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    labels.taxAmount,
                    style: smallStyle,
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    labels.taxGross,
                    style: smallStyle,
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
            for (final row in data.taxRows)
              pw.Row(
                children: [
                  pw.SizedBox(
                    width: 40,
                    child: pw.Text(
                      _fmtTaxRate(row.taxRateBasisPoints),
                      style: smallStyle,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      _fmtKc(row.netHalere),
                      style: smallStyle,
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      _fmtKc(row.taxHalere),
                      style: smallStyle,
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      _fmtKc(row.grossHalere),
                      style: smallStyle,
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),

            _divider(),

            // --- Payments ---
            for (final p in data.payments) ...[
              _totalRow(
                '${labels.payment}: ${p.methodName}',
                _fmtKc(p.amountHalere),
                baseStyle,
              ),
              if (p.tipHalere > 0)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 12),
                  child: pw.Text(
                    '${labels.tip}: ${_fmtKc(p.tipHalere)}',
                    style: smallStyle,
                  ),
                ),
            ],

            pw.SizedBox(height: 12),

            // --- Footer ---
            pw.Center(
              child: pw.Text(labels.thankYou, style: boldStyle),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  String _fmtQty(double qty) {
    if (qty == qty.roundToDouble()) return '${qty.round()}x';
    return '${qty.toStringAsFixed(2)}x';
  }

  pw.Widget _divider() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Text(
        '----------------------------------------------',
        style: pw.TextStyle(font: regular, fontSize: 7),
      ),
    );
  }

  pw.Widget _infoRow(String text, pw.TextStyle style) {
    return pw.Text(text, style: style);
  }

  pw.Widget _totalRow(String label, String value, pw.TextStyle style) {
    return pw.Row(
      children: [
        pw.Expanded(child: pw.Text(label, style: style)),
        pw.Text(value, style: style),
      ],
    );
  }
}

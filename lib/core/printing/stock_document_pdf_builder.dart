import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/models/currency_model.dart';
import '../utils/formatters.dart';

class StockDocumentPdfData {
  StockDocumentPdfData({
    required this.title,
    required this.documentNumber,
    required this.date,
    this.supplierName,
    this.note,
    required this.lines,
    required this.totalAmount,
    this.currency,
  });

  final String title;
  final String documentNumber;
  final String date;
  final String? supplierName;
  final String? note;
  final List<StockDocumentPdfLine> lines;
  final int totalAmount;
  final CurrencyModel? currency;
}

class StockDocumentPdfLine {
  StockDocumentPdfLine({
    required this.itemName,
    required this.unitName,
    required this.quantity,
    this.purchasePrice,
  });

  final String itemName;
  final String unitName;
  final double quantity;
  final int? purchasePrice;
}

class StockDocumentPdfLabels {
  StockDocumentPdfLabels({
    required this.columnItem,
    required this.columnUnit,
    required this.columnQuantity,
    required this.columnPrice,
    required this.columnTotal,
    required this.supplier,
    required this.note,
    required this.total,
    required this.locale,
  });

  final String columnItem;
  final String columnUnit;
  final String columnQuantity;
  final String columnPrice;
  final String columnTotal;
  final String supplier;
  final String note;
  final String total;
  final String locale;
}

class StockDocumentPdfBuilder {
  StockDocumentPdfBuilder({
    required this.data,
    required this.labels,
    required this.regular,
    required this.bold,
  });

  final StockDocumentPdfData data;
  final StockDocumentPdfLabels labels;
  final pw.Font regular;
  final pw.Font bold;

  static const double _pageWidth = 226; // 80mm in points
  static const double _margin = 8;

  String _fmtMoney(int amount) =>
      formatMoneyForPrint(amount, data.currency, appLocale: labels.locale);

  String _fmtQty(double value) => formatQuantity(value, labels.locale);

  Future<Uint8List> build() async {
    final doc = pw.Document();

    final baseStyle = pw.TextStyle(font: regular, fontSize: 9);
    final boldStyle = pw.TextStyle(font: bold, fontSize: 9);
    final headerStyle = pw.TextStyle(font: bold, fontSize: 12);

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
            pw.Center(child: pw.Text(data.title, style: headerStyle)),
            pw.Center(child: pw.Text(data.documentNumber, style: boldStyle)),
            pw.Center(child: pw.Text(data.date, style: baseStyle)),
            if (data.supplierName != null) ...[
              pw.SizedBox(height: 2),
              pw.Text('${labels.supplier}: ${data.supplierName}', style: baseStyle),
            ],
            if (data.note != null && data.note!.isNotEmpty) ...[
              pw.SizedBox(height: 2),
              pw.Text('${labels.note}: ${data.note}', style: baseStyle),
            ],
            _divider(),
            // Column headers
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(labels.columnItem, style: boldStyle),
                ),
                pw.SizedBox(
                  width: 35,
                  child: pw.Text(
                    labels.columnQuantity,
                    style: boldStyle,
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.SizedBox(
                  width: 40,
                  child: pw.Text(
                    labels.columnPrice,
                    style: boldStyle,
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.SizedBox(
                  width: 45,
                  child: pw.Text(
                    labels.columnTotal,
                    style: boldStyle,
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
            _divider(),
            // Lines
            for (final line in data.lines) ...[
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      '${line.itemName} (${line.unitName})',
                      style: baseStyle,
                    ),
                  ),
                  pw.SizedBox(
                    width: 35,
                    child: pw.Text(
                      _fmtQty(line.quantity),
                      style: baseStyle,
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.SizedBox(
                    width: 40,
                    child: pw.Text(
                      line.purchasePrice != null ? _fmtMoney(line.purchasePrice!) : '-',
                      style: baseStyle,
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.SizedBox(
                    width: 45,
                    child: pw.Text(
                      line.purchasePrice != null
                          ? _fmtMoney((line.purchasePrice! * line.quantity).round())
                          : '-',
                      style: baseStyle,
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
            ],
            _divider(),
            // Total
            if (data.totalAmount != 0)
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(labels.total, style: boldStyle),
                  ),
                  pw.Text(_fmtMoney(data.totalAmount), style: boldStyle),
                ],
              ),
          ],
        ),
      ),
    );

    return doc.save();
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
}

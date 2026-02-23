import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/models/currency_model.dart';
import '../utils/formatters.dart';

class InventoryPdfData {
  InventoryPdfData({
    required this.title,
    required this.date,
    required this.isTemplate,
    required this.blindMode,
    required this.lines,
    this.currency,
    this.surplusCount = 0,
    this.surplusValue = 0,
    this.shortageCount = 0,
    this.shortageValue = 0,
  });

  final String title;
  final String date;
  final bool isTemplate;
  final bool blindMode;
  final List<InventoryPdfLine> lines;
  final CurrencyModel? currency;
  final int surplusCount;
  final int surplusValue;
  final int shortageCount;
  final int shortageValue;
}

class InventoryPdfLine {
  InventoryPdfLine({
    required this.itemName,
    required this.unitName,
    required this.currentQuantity,
    this.actualQuantity,
    this.purchasePrice,
  });

  final String itemName;
  final String unitName;
  final double currentQuantity;
  final double? actualQuantity;
  final int? purchasePrice;
}

class InventoryPdfLabels {
  InventoryPdfLabels({
    required this.columnItem,
    required this.columnUnit,
    required this.columnExpected,
    required this.columnActual,
    required this.columnDifference,
    required this.surplus,
    required this.shortage,
    required this.locale,
  });

  final String columnItem;
  final String columnUnit;
  final String columnExpected;
  final String columnActual;
  final String columnDifference;
  final String surplus;
  final String shortage;
  final String locale;
}

class InventoryPdfBuilder {
  InventoryPdfBuilder({
    required this.data,
    required this.labels,
    required this.regular,
    required this.bold,
  });

  final InventoryPdfData data;
  final InventoryPdfLabels labels;
  final pw.Font regular;
  final pw.Font bold;

  static const double _pageWidth = 226; // 80mm in points
  static const double _margin = 8;

  String _fmtMoney(int amount) => formatMoneyForPrint(amount, data.currency);

  String _fmtQty(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  Future<Uint8List> build() {
    if (data.isTemplate) {
      return _buildTemplate();
    }
    return _buildResults();
  }

  Future<Uint8List> _buildTemplate() async {
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
            pw.Center(child: pw.Text(data.date, style: baseStyle)),
            _divider(),
            // Column headers
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(labels.columnItem, style: boldStyle),
                ),
                if (!data.blindMode)
                  pw.SizedBox(
                    width: 45,
                    child: pw.Text(
                      labels.columnExpected,
                      style: boldStyle,
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                pw.SizedBox(
                  width: 45,
                  child: pw.Text(
                    labels.columnActual,
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
                  if (!data.blindMode)
                    pw.SizedBox(
                      width: 45,
                      child: pw.Text(
                        _fmtQty(line.currentQuantity),
                        style: baseStyle,
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  pw.SizedBox(
                    width: 45,
                    child: pw.Text(
                      '______',
                      style: baseStyle,
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
            ],
            _divider(),
          ],
        ),
      ),
    );

    return doc.save();
  }

  Future<Uint8List> _buildResults() async {
    final doc = pw.Document();

    final baseStyle = pw.TextStyle(font: regular, fontSize: 9);
    final boldStyle = pw.TextStyle(font: bold, fontSize: 9);
    final headerStyle = pw.TextStyle(font: bold, fontSize: 12);

    // Filter to only lines with differences
    final diffLines = data.lines.where((l) =>
        l.actualQuantity != null && l.actualQuantity != l.currentQuantity).toList();

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
            pw.Center(child: pw.Text(data.date, style: baseStyle)),
            _divider(),
            // Summary
            if (data.surplusCount > 0)
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      '${labels.surplus}: ${data.surplusCount}',
                      style: boldStyle,
                    ),
                  ),
                  pw.Text('+${_fmtMoney(data.surplusValue)}', style: baseStyle),
                ],
              ),
            if (data.shortageCount > 0)
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      '${labels.shortage}: ${data.shortageCount}',
                      style: boldStyle,
                    ),
                  ),
                  pw.Text('-${_fmtMoney(data.shortageValue)}', style: baseStyle),
                ],
              ),
            if (data.surplusCount > 0 || data.shortageCount > 0) _divider(),
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
                    labels.columnExpected,
                    style: boldStyle,
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.SizedBox(
                  width: 35,
                  child: pw.Text(
                    labels.columnActual,
                    style: boldStyle,
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.SizedBox(
                  width: 35,
                  child: pw.Text(
                    labels.columnDifference,
                    style: boldStyle,
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
            _divider(),
            // Lines
            for (final line in diffLines) ...[
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
                      _fmtQty(line.currentQuantity),
                      style: baseStyle,
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.SizedBox(
                    width: 35,
                    child: pw.Text(
                      _fmtQty(line.actualQuantity!),
                      style: baseStyle,
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.SizedBox(
                    width: 35,
                    child: pw.Text(
                      _fmtDiff(line.actualQuantity! - line.currentQuantity),
                      style: baseStyle,
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
            ],
            _divider(),
          ],
        ),
      ),
    );

    return doc.save();
  }

  String _fmtDiff(double diff) {
    final prefix = diff > 0 ? '+' : '';
    return '$prefix${_fmtQty(diff)}';
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

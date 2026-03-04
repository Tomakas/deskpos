import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/formatters.dart';
import 'order_ticket_data.dart';

class OrderTicketPdfBuilder {
  OrderTicketPdfBuilder({
    required this.data,
    required this.locale,
    required this.regular,
    required this.bold,
  });

  final OrderTicketData data;
  final String locale;
  final pw.Font regular;
  final pw.Font bold;

  static const double _pageWidth = 226; // 80mm in points
  static const double _margin = 8;

  Future<Uint8List> build() async {
    final doc = pw.Document();

    final baseStyle = pw.TextStyle(font: regular, fontSize: 10);
    final boldStyle = pw.TextStyle(font: bold, fontSize: 10);
    final smallStyle = pw.TextStyle(font: regular, fontSize: 8);
    final italicStyle = pw.TextStyle(
      font: regular,
      fontSize: 8,
      fontStyle: pw.FontStyle.italic,
    );
    final headerStyle = pw.TextStyle(font: bold, fontSize: 16);

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
            // --- Station label (large, bold, centered) ---
            pw.Center(
              child: pw.Text(data.stationLabel, style: headerStyle),
            ),

            _divider(),

            // --- Order number + time ---
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(data.orderNumber, style: boldStyle),
                ),
                pw.Text(
                  formatTimeForPrint(data.createdAt, locale),
                  style: baseStyle,
                ),
              ],
            ),

            // --- Table name ---
            if (data.tableName != null)
              pw.Text(data.tableName!, style: baseStyle),

            _divider(),

            // --- Items ---
            for (final item in data.items) ...[
              pw.Text(
                '${_fmtQty(item.quantity, item.unitLabel)} ${item.name}',
                style: boldStyle,
              ),
              for (final mod in item.modifiers)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 12),
                  child: pw.Text(
                    '+ ${_fmtQty(mod.quantity, '')}${mod.name}',
                    style: smallStyle,
                  ),
                ),
              if (item.notes != null && item.notes!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 12),
                  child: pw.Text('* ${item.notes}', style: italicStyle),
                ),
            ],

            pw.SizedBox(height: 8),
          ],
        ),
      ),
    );

    return doc.save();
  }

  String _fmtQty(double qty, String unitLabel) {
    final formatted = formatQuantity(qty, locale);
    if (unitLabel.isEmpty) return '$formatted\u00D7 ';
    return '$formatted $unitLabel ';
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

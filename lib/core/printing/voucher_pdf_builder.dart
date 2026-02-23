import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class VoucherPdfData {
  const VoucherPdfData({
    required this.code,
    required this.typeName,
    required this.valueLine,
    this.scopeLine,
    this.maxUses,
    this.expiresAt,
    this.note,
    this.companyName,
  });

  final String code;
  final String typeName;
  final String valueLine;
  final String? scopeLine;
  final String? maxUses;
  final String? expiresAt;
  final String? note;
  final String? companyName;
}

class VoucherPdfLabels {
  const VoucherPdfLabels({
    required this.type,
    required this.value,
    required this.scope,
    required this.maxUses,
    required this.expires,
    required this.note,
  });

  final String type;
  final String value;
  final String scope;
  final String maxUses;
  final String expires;
  final String note;
}

class VoucherPdfBuilder {
  VoucherPdfBuilder({
    required this.data,
    required this.labels,
    required this.regular,
    required this.bold,
  });

  final VoucherPdfData data;
  final VoucherPdfLabels labels;
  final pw.Font regular;
  final pw.Font bold;

  static const double _pageWidth = 226; // 80mm receipt width
  static const double _margin = 8;

  Future<Uint8List> build() async {
    final doc = pw.Document();

    final baseStyle = pw.TextStyle(font: regular, fontSize: 9);
    final boldStyle = pw.TextStyle(font: bold, fontSize: 9);
    final codeStyle = pw.TextStyle(font: bold, fontSize: 16);
    final headerStyle = pw.TextStyle(font: bold, fontSize: 11);

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat(_pageWidth, double.infinity, marginAll: _margin),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (data.companyName != null) ...[
            pw.Text(data.companyName!, style: headerStyle),
            pw.SizedBox(height: 6),
          ],
          pw.Divider(thickness: 0.5),
          pw.SizedBox(height: 4),
          pw.Text('VOUCHER', style: headerStyle),
          pw.SizedBox(height: 8),
          pw.Text(data.code, style: codeStyle),
          pw.SizedBox(height: 8),
          pw.Divider(thickness: 0.5),
          pw.SizedBox(height: 4),
          _row(labels.type, data.typeName, baseStyle, boldStyle),
          _row(labels.value, data.valueLine, baseStyle, boldStyle),
          if (data.scopeLine != null)
            _row(labels.scope, data.scopeLine!, baseStyle, boldStyle),
          if (data.maxUses != null)
            _row(labels.maxUses, data.maxUses!, baseStyle, boldStyle),
          if (data.expiresAt != null)
            _row(labels.expires, data.expiresAt!, baseStyle, boldStyle),
          if (data.note != null && data.note!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 4),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text('${labels.note}:', style: boldStyle),
            ),
            pw.SizedBox(height: 2),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(data.note!, style: baseStyle),
            ),
          ],
          pw.SizedBox(height: 4),
          pw.Divider(thickness: 0.5),
        ],
      ),
    ));

    return doc.save();
  }

  pw.Widget _row(String label, String value, pw.TextStyle base, pw.TextStyle boldS) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 70, child: pw.Text(label, style: base)),
          pw.Expanded(child: pw.Text(value, style: boldS)),
        ],
      ),
    );
  }
}

import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfFontLoader {
  PdfFontLoader._();
  static final PdfFontLoader instance = PdfFontLoader._();

  pw.Font? _regular;
  pw.Font? _bold;

  Future<pw.Font> get regular async {
    if (_regular != null) return _regular!;
    final data = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    _regular = pw.Font.ttf(data);
    return _regular!;
  }

  Future<pw.Font> get bold async {
    if (_bold != null) return _bold!;
    final data = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    _bold = pw.Font.ttf(data);
    return _bold!;
  }
}

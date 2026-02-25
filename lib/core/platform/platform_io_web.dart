import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> saveAndOpen(String filename, List<int> bytes) async {
  final data = Uint8List.fromList(bytes);
  final blob = web.Blob(
    [data.toJS].toJS,
    web.BlobPropertyBag(type: _mimeType(filename)),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = filename
    ..style.display = 'none';
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}

String _mimeType(String filename) {
  if (filename.endsWith('.pdf')) return 'application/pdf';
  if (filename.endsWith('.csv')) return 'text/csv';
  if (filename.endsWith('.txt')) return 'text/plain';
  return 'application/octet-stream';
}

Future<Uint8List?> readFileBytes(String path) async => null;

Future<void> writeFile(String path, String content) async {}

Future<void> appendToFile(String path, String content) async {}

Future<void> deleteFile(String path) async {}

Future<bool> fileExists(String path) async => false;

Future<String?> getDocumentsPath() async => null;

bool get hasFileSystem => false;

bool get canExitApp => false;

void exitApp() {}

Future<void> deleteDatabaseFiles(String name) async {
  // Delete IndexedDB databases used by Drift
  final factory = web.window.self.indexedDB;
  // Drift uses the database name directly as the IDB name
  factory.deleteDatabase(name);
  factory.deleteDatabase('${name}_lock');
}

Future<String?> readDeviceIdFromLegacyFile() async => null;

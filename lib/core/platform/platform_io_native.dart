import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveAndOpen(String filename, List<int> bytes) async {
  final dir = await getTemporaryDirectory();
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final file = File(p.join(dir.path, filename));
  await file.writeAsBytes(bytes);

  if (Platform.isMacOS) {
    await Process.run('open', [file.path]);
  } else {
    await Share.shareXFiles([XFile(file.path)]);
  }
}

Future<Uint8List?> readFileBytes(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  return file.readAsBytes();
}

Future<void> writeFile(String path, String content) async {
  await File(path).writeAsString(content);
}

Future<void> appendToFile(String path, String content) async {
  await File(path).writeAsString(content, mode: FileMode.append);
}

Future<void> deleteFile(String path) async {
  final file = File(path);
  if (await file.exists()) await file.delete();
}

Future<bool> fileExists(String path) async {
  return File(path).exists();
}

Future<String?> getDocumentsPath() async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

bool get hasFileSystem => true;

bool get canExitApp => true;

void exitApp() {
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    exit(0);
  } else {
    SystemNavigator.pop();
  }
}

Future<void> deleteDatabaseFiles(String name) async {
  final dir = await getApplicationSupportDirectory();
  final basePath = p.join(dir.path, '$name.sqlite');
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final file = File('$basePath$suffix');
    if (await file.exists()) await file.delete();
  }
}

Future<String?> readDeviceIdFromLegacyFile() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'epos_device_id.txt'));
  if (file.existsSync()) {
    return file.readAsStringSync().trim();
  }
  return null;
}

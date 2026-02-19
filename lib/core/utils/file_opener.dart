import 'dart:io';

import 'package:share_plus/share_plus.dart';

/// Cross-platform file opener/sharer.
///
/// On macOS: opens with the default system application.
/// On other platforms: uses the system share sheet.
abstract final class FileOpener {
  static Future<void> share(String filePath) async {
    if (Platform.isMacOS) {
      await Process.run('open', [filePath]);
    } else {
      await Share.shareXFiles([XFile(filePath)]);
    }
  }
}

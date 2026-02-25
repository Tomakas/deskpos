import '../platform/platform_io.dart';

/// Cross-platform file opener/sharer.
///
/// On macOS: opens with the default system application.
/// On other native platforms: uses the system share sheet.
/// On web: triggers a browser download.
abstract final class FileOpener {
  static Future<void> shareBytes(String filename, List<int> bytes) =>
      saveAndOpen(filename, bytes);
}

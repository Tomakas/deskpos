import 'log_file_writer_native.dart'
    if (dart.library.js_interop) 'log_file_writer_web.dart';

abstract class LogFileWriter {
  static final LogFileWriter instance = createLogFileWriter();

  /// Path to the current log file, or null if not yet initialized / not available.
  String? get filePath;

  /// Synchronously appends a line to the memory buffer.
  /// File I/O happens asynchronously via periodic flush (native only).
  void write(String line);
}

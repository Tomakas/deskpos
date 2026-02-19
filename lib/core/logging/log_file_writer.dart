import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Singleton that writes log lines to a local file with rotation.
///
/// Used exclusively by [AppLogger]. Not a service/provider — just an
/// internal helper with lazy initialization.
class LogFileWriter {
  LogFileWriter._();
  static final instance = LogFileWriter._();

  static const _fileName = 'epos_app.log';
  static const _oldFileName = 'epos_app.log.old';
  static const _maxFileSize = 1536 * 1024; // 1.5 MB
  static const _bufferFlushThreshold = 4096; // 4 KB
  static const _flushInterval = Duration(milliseconds: 500);

  final _buffer = StringBuffer();
  IOSink? _sink;
  String? _filePath;
  String? _dirPath;
  bool _initializing = false;

  /// Path to the current log file, or null if not yet initialized.
  String? get filePath => _filePath;

  /// Synchronously appends a line to the memory buffer.
  /// File I/O happens asynchronously via periodic flush.
  void write(String line) {
    _buffer.writeln(line);

    // Kick off lazy init on first write
    if (_sink == null && !_initializing) {
      _initializing = true;
      _init();
    }

    // Immediate flush if buffer exceeds threshold
    if (_buffer.length >= _bufferFlushThreshold && _sink != null) {
      _flush();
    }
  }

  Future<void> _init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _dirPath = dir.path;
      _filePath = '${dir.path}/$_fileName';
      final file = File(_filePath!);
      _sink = file.openWrite(mode: FileMode.append);
      _initializing = false;

      // Start periodic flush timer (singleton — never cancelled)
      Timer.periodic(_flushInterval, (_) => _flush());

      // Flush anything that accumulated during init
      _flush();
    } catch (_) {
      // Graceful degradation — console logging continues to work
      _initializing = false;
    }
  }

  void _flush() {
    if (_buffer.isEmpty || _sink == null) return;

    try {
      final data = _buffer.toString();
      _buffer.clear();
      _sink!.write(data);

      // Check rotation after flush
      _checkRotation();
    } catch (_) {
      // Graceful degradation
    }
  }

  Future<void> _checkRotation() async {
    if (_filePath == null) return;

    try {
      final file = File(_filePath!);
      final stat = await file.stat();
      if (stat.size < _maxFileSize) return;

      // Rotate: close current, rename, open new
      await _sink?.flush();
      await _sink?.close();

      final oldPath = '$_dirPath/$_oldFileName';
      final oldFile = File(oldPath);
      if (await oldFile.exists()) {
        await oldFile.delete();
      }
      await file.rename(oldPath);

      final newFile = File(_filePath!);
      _sink = newFile.openWrite(mode: FileMode.append);
    } catch (_) {
      // Graceful degradation — try to reopen
      try {
        _sink = File(_filePath!).openWrite(mode: FileMode.append);
      } catch (_) {
        // Give up on file logging
      }
    }
  }
}

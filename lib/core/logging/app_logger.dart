import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'log_file_writer.dart';

// debugPrint is guarded by kDebugMode — no production impact.
// Kept for Android Studio Run panel visibility during development.

abstract final class AppLogger {
  /// Path to the current log file, or null if not yet initialized.
  static String? get logFilePath => LogFileWriter.instance.filePath;

  static void debug(String message, {String? tag}) {
    final t = tag ?? 'DEBUG';
    if (kDebugMode) {
      final formatted = '[$t] $message';
      developer.log(message, name: t);
      debugPrint(formatted);
    }
    LogFileWriter.instance.write('${_timestamp()} [DEBUG] [$t] $message');
  }

  static void info(String message, {String? tag}) {
    final t = tag ?? 'INFO';
    final formatted = '[$t] $message';
    developer.log(message, name: t);
    if (kDebugMode) debugPrint(formatted);
    LogFileWriter.instance.write('${_timestamp()} [INFO] [$t] $message');
  }

  static void warn(String message, {String? tag, Object? error}) {
    final t = tag ?? 'WARN';
    final suffix = error != null ? ' | $error' : '';
    final formatted = '[$t] $message$suffix';
    developer.log(message, name: t, error: error);
    if (kDebugMode) debugPrint(formatted);
    LogFileWriter.instance.write('${_timestamp()} [WARN] [$t] $message$suffix');
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final t = tag ?? 'ERROR';
    final suffix = error != null ? ' | $error' : '';
    final formatted = '[$t] $message$suffix';
    developer.log(message, name: t, error: error, stackTrace: stackTrace);
    if (kDebugMode) {
      debugPrint(formatted);
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
    final fileLine = '${_timestamp()} [ERROR] [$t] $message$suffix';
    if (stackTrace != null) {
      LogFileWriter.instance.write('$fileLine\n$stackTrace');
    } else {
      LogFileWriter.instance.write(fileLine);
    }
  }

  /// ISO 8601 timestamp truncated to milliseconds (23 chars).
  static String _timestamp() {
    final now = DateTime.now().toIso8601String();
    return now.length > 23 ? now.substring(0, 23) : now;
  }
}

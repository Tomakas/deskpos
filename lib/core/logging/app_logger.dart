import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

// TODO(production): Remove debugPrint calls before production release.
// debugPrint is here only for Android Studio Run panel visibility during
// development. developer.log alone is sufficient for DevTools / production.

abstract final class AppLogger {
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final formatted = '[${tag ?? 'DEBUG'}] $message';
      developer.log(message, name: tag ?? 'DEBUG');
      debugPrint(formatted);
    }
  }

  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final formatted = '[${tag ?? 'INFO'}] $message';
      developer.log(message, name: tag ?? 'INFO');
      debugPrint(formatted);
    }
  }

  static void warn(String message, {String? tag, Object? error}) {
    final formatted = '[${tag ?? 'WARN'}] $message${error != null ? ' | $error' : ''}';
    developer.log(message, name: tag ?? 'WARN', error: error);
    if (kDebugMode) debugPrint(formatted);
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final formatted = '[${tag ?? 'ERROR'}] $message${error != null ? ' | $error' : ''}';
    developer.log(message, name: tag ?? 'ERROR', error: error, stackTrace: stackTrace);
    if (kDebugMode) {
      debugPrint(formatted);
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }
}

import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void info(String message) {
    if (kDebugMode) debugPrint('debug - [INFO] $message');
  }

  static void warning(String message) {
    if (kDebugMode) debugPrint('debug - [WARN] $message');
  }

  static void error(String message) {
    if (kDebugMode) debugPrint('debug - [ERROR] $message');
  }
}

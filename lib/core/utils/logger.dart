import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// 详细日志仅在开发调试时输出。
abstract final class Logger {
  static bool get _enabled => kDebugMode && AppConfig.isDev;
  static void d(String message) {
    if (_enabled) debugPrint('[D] $message');
  }

  static void i(String message) {
    if (_enabled) debugPrint('[I] $message');
  }

  static void w(String message) {
    if (_enabled) debugPrint('[W] $message');
  }

  static void e(String message, [Object? error, StackTrace? stack]) {
    debugPrint('[E] $message');
    if (_enabled) {
      if (error != null) debugPrint('$error');
      if (stack != null) debugPrint('$stack');
    }
  }
}

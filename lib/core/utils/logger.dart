import 'package:flutter/foundation.dart';

/// 详细日志仅在开发调试时输出。
abstract final class Logger {
  static bool get _enabled => kDebugMode;
  static void e(String message, [Object? error, StackTrace? stack]) {
    debugPrint('[E] $message');
    if (_enabled) {
      if (error != null) debugPrint('$error');
      if (stack != null) debugPrint('$stack');
    }
  }
}

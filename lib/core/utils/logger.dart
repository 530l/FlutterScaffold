import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// 分级日志封装:仅开发环境输出,生产静默
///
/// 扩展点:后续接入 Sentry/友盟等,在对应方法内追加上报即可
abstract final class Logger {
  /// 调试日志
  static void d(String message) {
    if (AppConfig.isDev) debugPrint('[D] $message');
  }

  /// 信息日志
  static void i(String message) {
    if (AppConfig.isDev) debugPrint('[I] $message');
  }

  /// 警告日志
  static void w(String message) {
    if (AppConfig.isDev) debugPrint('[W] $message');
  }

  /// 错误日志:生产环境也打印,便于排查线上问题
  static void e(String message, [Object? error, StackTrace? stack]) {
    debugPrint('[E] $message${error == null ? '' : ' | $error'}');
    if (stack != null && AppConfig.isDev) debugPrint('$stack');
  }
}

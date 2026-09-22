import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/utils/riverpod_logger.dart';

/// 应用入口:环境初始化 → ProviderScope → App
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 环境解析必须最先执行(网络层、日志开关都依赖它)
  // 运行方式:flutter run --dart-define=APP_ENV=prod
  AppConfig.init(appEnv: const String.fromEnvironment('APP_ENV'));

  // TODO 扩展点:崩溃收集、SharedPreferences 预热等启动初始化在此追加
  runApp(
    ProviderScope(
      observers: [RiverpodLogger()], // 仅开发环境输出 provider 生命周期日志
      child: const App(),
    ),
  );
}

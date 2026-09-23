import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'features/auth/auth_provider.dart';

/// 应用入口:环境初始化 → 登录态恢复 → App
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 环境解析必须最先执行(网络层、日志开关都依赖它)
  // 运行方式:flutter run --dart-define=APP_ENV=prod
  AppConfig.init(appEnv: const String.fromEnvironment('APP_ENV'));

  // 开发环境挂载信号日志观察者:打印信号读写,便于排查依赖关系
  if (kDebugMode) {
    SignalsObserver.instance = LoggingSignalsObserver();
  }

  // runApp 前恢复本地登录态(读 SharedPreferences 后写入 authState 信号)
  // 本地读耗时极短,直接等待不影响启动体验
  // TODO 扩展点:启动项变多后可改为闪屏页并行恢复
  await restoreAuth();

  // TODO 扩展点:崩溃收集等启动初始化在此追加
  runApp(const App());
}

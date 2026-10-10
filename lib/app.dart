import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/wellness/provider/wellness_provider.dart';

/// 应用入口组件。
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TDesign 从当前 Flutter 主题中读取颜色,让夜间模式即时覆盖所有组件。
    TDTheme.needMultiTheme();
    final darkMode = ref.watch(
      wellnessProvider.select((state) => state.darkMode),
    );
    return MaterialApp.router(
      title: '慢慢 · 好好生活',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: ref.watch(appRouterProvider),
      builder: FlutterSmartDialog.init(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// 应用根组件:路由 + 主题 + 全局弹窗接线
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FlutterScaffold',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
      // smart_dialog 唯一接线点:让 Toast/全局 Loading 脱离 context 可用
      builder: FlutterSmartDialog.init(),
      debugShowCheckedModeBanner: false,
    );
  }
}

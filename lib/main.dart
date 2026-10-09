import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/auth_repository.dart';

/// 初始化环境和会话后启动应用。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.init(appEnv: const String.fromEnvironment('APP_ENV'));

  final authRepository = AuthRepository();
  final initialAuthState = await restoreAuth(authRepository);

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        initialAuthStateProvider.overrideWithValue(initialAuthState),
      ],
      child: const App(),
    ),
  );
}

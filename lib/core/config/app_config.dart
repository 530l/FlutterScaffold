enum AppEnv { dev, prod }

/// 启动时通过 APP_ENV 配置运行环境。
abstract final class AppConfig {
  static AppEnv env = AppEnv.dev;

  static void init({String? appEnv}) {
    env = switch (appEnv) {
      'prod' => AppEnv.prod,
      _ => AppEnv.dev,
    };
  }

  static bool get isDev => env == AppEnv.dev;

  static String get apiBaseUrl => switch (env) {
    AppEnv.dev => 'https://www.wanandroid.com',
    // 示例生产地址,上线前替换。
    AppEnv.prod => 'https://www.wanandroid.com',
  };
}

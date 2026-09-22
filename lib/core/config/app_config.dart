/// 应用运行环境枚举
enum AppEnv { dev, prod }

/// 全局环境配置:启动时由 dart-define 初始化一次,之后只读
///
/// 用法:flutter run --dart-define=APP_ENV=prod(不传默认 dev)
abstract final class AppConfig {
  /// 当前环境,main 中最先初始化
  static AppEnv env = AppEnv.dev;

  /// 从 --dart-define=APP_ENV=dev|prod 解析环境
  static void init({String? appEnv}) {
    env = switch (appEnv) {
      'prod' => AppEnv.prod,
      _ => AppEnv.dev,
    };
  }

  /// 是否为开发环境(控制日志开关等)
  static bool get isDev => env == AppEnv.dev;

  /// 接口基础地址:换后端只改这里
  static String get apiBaseUrl => switch (env) {
        // 示例后端使用 WanAndroid,国内可直连免鉴权
        AppEnv.dev => 'https://www.wanandroid.com',
        AppEnv.prod => 'https://www.wanandroid.com', // TODO: 替换为生产域名
      };
}

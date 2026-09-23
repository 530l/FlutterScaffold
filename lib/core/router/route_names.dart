/// 路由名常量:跳转用 context.goNamed(RouteNames.main)
abstract final class RouteNames {
  /// 主壳页(底部 4 tab)
  static const main = 'main';

  /// 详情页(传值/回值示例)
  static const detail = 'detail';

  /// 登录页
  static const login = 'login';
}

/// 路由路径常量:重定向与 go() 跳转用
abstract final class RoutePaths {
  /// 主壳页(底部 4 tab)
  static const main = '/';

  /// 详情页(传值/回值示例)
  static const detail = '/detail';

  /// 登录页
  static const login = '/login';
}

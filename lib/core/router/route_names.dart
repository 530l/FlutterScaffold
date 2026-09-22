/// 路由名常量:跳转用 context.goNamed(RouteNames.home)
abstract final class RouteNames {
  /// 首页
  static const home = 'home';

  /// 登录页
  static const login = 'login';
}

/// 路由路径常量:重定向与 go() 跳转用
abstract final class RoutePaths {
  /// 首页
  static const home = '/';

  /// 登录页
  static const login = '/login';
}

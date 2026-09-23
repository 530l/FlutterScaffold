import 'package:flutterscaffold/features/auth/view/login_screen.dart';
import 'package:flutterscaffold/features/example/view/detail_page.dart';
import 'package:flutterscaffold/features/main/view/main_page.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

/// 全局路由:平铺路由表,新增页面在此追加一行 GoRoute 即可
///
/// TODO 扩展点(当前按需求从简,后续需要时再加):
/// - 登录守卫:redirect 里读登录态做未登录重定向
/// - 埋点:observers 传 NavigatorObserver 记录页面曝光
final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.main,
  routes: [
    GoRoute(
      path: RoutePaths.main,
      name: RouteNames.main,
      builder: (_, _) => const MainPage(),
    ),
    GoRoute(
      path: RoutePaths.detail,
      name: RouteNames.detail,
      // title 由跳转方通过 query 参数携带,如 /detail?title=创作
      builder: (_, state) =>
          DetailPage(title: state.uri.queryParameters['title'] ?? ''),
    ),
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      builder: (_, _) => const LoginScreen(),
    ),
  ],
);

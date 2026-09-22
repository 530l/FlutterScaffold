import 'package:flutterscaffold/features/auth/view/login_screen.dart';
import 'package:flutterscaffold/features/home/view/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'route_names.dart';

part 'app_router.g.dart';

/// 全局路由:平铺路由表,新增页面在此追加一行 GoRoute 即可
///
/// TODO 扩展点(当前按需求从简,后续需要时再加):
/// - 登录守卫:redirect 里读登录态做未登录重定向
/// - 埋点:observers 传 NavigatorObserver 记录页面曝光
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: RoutePaths.home,
    routes: [
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (_, _) => const HomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (_, _) => const LoginScreen(),
      ),
    ],
  );
}

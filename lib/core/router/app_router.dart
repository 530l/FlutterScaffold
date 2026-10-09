import 'package:flutterscaffold/features/auth/view/login_screen.dart';
import 'package:flutterscaffold/features/example/view/detail_page.dart';
import 'package:flutterscaffold/features/main/view/main_page.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'route_names.dart';

part 'app_router.g.dart';

/// 路由随应用作用域创建和释放。
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = GoRouter(
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
  ref.onDispose(router.dispose);
  return router;
}

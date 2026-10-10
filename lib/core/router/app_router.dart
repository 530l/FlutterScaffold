import 'package:flutterscaffold/features/main/view/main_page.dart';
import 'package:flutterscaffold/features/wellness/view/focus_page.dart';
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
        path: RoutePaths.focus,
        name: RouteNames.focus,
        builder: (_, _) => const FocusPage(),
      ),
      GoRoute(
        path: RoutePaths.main,
        name: RouteNames.main,
        builder: (_, _) => const MainPage(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

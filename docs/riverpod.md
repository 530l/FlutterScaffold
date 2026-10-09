# Riverpod 使用约定

本项目使用 Riverpod 3 的注解方式,与 Freezed、Retrofit 共用 `build_runner`。
每个定义 provider 的文件导入 `riverpod_annotation`,并声明对应的 `part '*.g.dart'`。
修改定义后运行:

```bash
dart run build_runner build
```

生成的 `*.g.dart` 随源码提交,不手动编辑。注解默认启用自动释放,
需要随应用作用域保留的依赖使用 `@Riverpod(keepAlive: true)`。

## 依赖与生命周期

| 类型 | 用途 |
|---|---|
| `@Riverpod(keepAlive: true)` 同步函数 | 注入仓库、客户端与路由 |
| `@riverpod` 异步函数 | 页面查询及请求取消 |
| `@Riverpod(keepAlive: true)` 类 | 登录等带操作方法的会话状态 |
| `ProviderScope` | 应用和测试的状态作用域 |

客户端、路由和登录状态随根作用域存活。首页查询在没有订阅一帧后释放,并取消请求。
首页在 `IndexedStack` 中常驻,切换 tab 不会释放查询,离开主壳后才释放。

## 查询

```dart
@Riverpod(keepAlive: true)
HomeRepository homeRepository(Ref ref) => HomeRepository(ref.watch(dioProvider));

@Riverpod(retry: _noRetry)
Future<List<BannerModel>> homeBanner(Ref ref) {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel('首页请求已取消'));
  return ref.watch(homeRepositoryProvider).getBanners(cancelToken: cancelToken);
}

// 业务失败后由用户显式重试。
Duration? _noRetry(int retryCount, Object error) => null;
```

页面通过 `ref.watch(homeBannerProvider)` 获取 `AsyncValue`,交给 `AsyncView` 展示。
手动刷新保留旧内容,依赖变化时显示加载态,请求失败后展示错误。

刷新等待本次请求结束,失败已保存在查询状态中,页面无需再次包装成 `Result`:

```dart
Future<void> onRefresh() async {
  try {
    await ref.refresh(homeBannerProvider.future);
  } catch (_) {
    // 失败由 AsyncView 展示。
  }
}
```

不需要等待结果时可以用 `ref.invalidate(provider)`。

## 操作

仓库处理接口和存储,控制器负责更新状态,页面负责提示与跳转。
网络查询用 `apiCall`,网络操作用 `resultGuard(() => apiCall(...))`,本地操作直接用 `resultGuard`。

会话类继承生成的基类,`FutureOr` 保留异步状态表达,同时同步读取启动初值:

```dart
@Riverpod(keepAlive: true)
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  FutureOr<AuthState> build() => ref.watch(initialAuthStateProvider);
}
```

默认命名规则移除类名末尾的 `Notifier`,生成 `authStateProvider`。
页面通过生成的 provider 调用操作:

```dart
final loading = ref.watch(authStateProvider).isLoading;
final result = await ref.read(authStateProvider.notifier).login(username, password);

if (!mounted) return;
switch (result) {
  case Success():
    context.go(RoutePaths.main);
  case Failure(:final error):
    AppToast.error(error.message);
}
```

控制器用 `AsyncLoading` 防止重复操作,成功写入 `AsyncData`,登录失败写入 `AsyncError`。
登出失败恢复原状态。异步操作结束后检查 `ref.mounted`,避免作用域销毁后写状态。

启动前通过仓库恢复 token,同时预热请求头的内存缓存。恢复后的会话作为
`initialAuthStateProvider` 的覆盖值传入根作用域;读取失败时以未登录态启动。

## 页面与测试

无页面控制器时使用 `ConsumerWidget`;需要控制器或生命周期时使用
`ConsumerStatefulWidget` + `ConsumerState`。只在局部读取状态时用 `Consumer`。
纯页面内部的简单状态继续用 `setState`。

每个测试创建独立作用域并覆盖仓库,不修改全局变量:

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [homeRepositoryProvider.overrideWithValue(fakeRepository)],
    child: const App(),
  ),
);
```

登录仓库可以覆盖 `authRepositoryProvider`。手动创建的 `ProviderContainer` 在结束时释放。

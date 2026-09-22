// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 全局路由:平铺路由表,新增页面在此追加一行 GoRoute 即可
///
/// TODO 扩展点(当前按需求从简,后续需要时再加):
/// - 登录守卫:redirect 里读登录态做未登录重定向
/// - 埋点:observers 传 NavigatorObserver 记录页面曝光

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// 全局路由:平铺路由表,新增页面在此追加一行 GoRoute 即可
///
/// TODO 扩展点(当前按需求从简,后续需要时再加):
/// - 登录守卫:redirect 里读登录态做未登录重定向
/// - 埋点:observers 传 NavigatorObserver 记录页面曝光

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// 全局路由:平铺路由表,新增页面在此追加一行 GoRoute 即可
  ///
  /// TODO 扩展点(当前按需求从简,后续需要时再加):
  /// - 登录守卫:redirect 里读登录态做未登录重定向
  /// - 埋点:observers 传 NavigatorObserver 记录页面曝光
  GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$goRouterHash() => r'9d0668098e45f442880b9b43e46e3454bcc46404';

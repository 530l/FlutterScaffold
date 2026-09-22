// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 全局 Dio 实例 provider:仓库层统一注入此实例发请求
///
/// - baseUrl 默认取 [AppConfig.apiBaseUrl]
/// - tokenReader 同步读 [TokenStorage.currentToken] 注入 Authorization 头
///   (冷启动后由 AuthNotifier.build 调 getToken 恢复内存缓存)
/// - onUnauthorized 预留 401 全局登出回调(需要时在此接入)

@ProviderFor(dioClient)
final dioClientProvider = DioClientProvider._();

/// 全局 Dio 实例 provider:仓库层统一注入此实例发请求
///
/// - baseUrl 默认取 [AppConfig.apiBaseUrl]
/// - tokenReader 同步读 [TokenStorage.currentToken] 注入 Authorization 头
///   (冷启动后由 AuthNotifier.build 调 getToken 恢复内存缓存)
/// - onUnauthorized 预留 401 全局登出回调(需要时在此接入)

final class DioClientProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// 全局 Dio 实例 provider:仓库层统一注入此实例发请求
  ///
  /// - baseUrl 默认取 [AppConfig.apiBaseUrl]
  /// - tokenReader 同步读 [TokenStorage.currentToken] 注入 Authorization 头
  ///   (冷启动后由 AuthNotifier.build 调 getToken 恢复内存缓存)
  /// - onUnauthorized 预留 401 全局登出回调(需要时在此接入)
  DioClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioClientHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dioClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioClientHash() => r'd0d9ed6e971352a06c05a8f10713d7c544a1b3d0';

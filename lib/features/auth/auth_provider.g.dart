// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 全局登录态 Notifier
///
/// 状态为 `AsyncValue<AuthState>`:
/// - AsyncLoading:build 恢复 token 中,或 login 请求进行中(登录中)
/// - AsyncData:未登录 / 已登录
/// - AsyncError:登录失败,error 为 AppException

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

/// 全局登录态 Notifier
///
/// 状态为 `AsyncValue<AuthState>`:
/// - AsyncLoading:build 恢复 token 中,或 login 请求进行中(登录中)
/// - AsyncData:未登录 / 已登录
/// - AsyncError:登录失败,error 为 AppException
final class AuthNotifierProvider
    extends $AsyncNotifierProvider<AuthNotifier, AuthState> {
  /// 全局登录态 Notifier
  ///
  /// 状态为 `AsyncValue<AuthState>`:
  /// - AsyncLoading:build 恢复 token 中,或 login 请求进行中(登录中)
  /// - AsyncData:未登录 / 已登录
  /// - AsyncError:登录失败,error 为 AppException
  AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();
}

String _$authNotifierHash() => r'dea5c2785eca1a8090f6e558c01d510e7333db37';

/// 全局登录态 Notifier
///
/// 状态为 `AsyncValue<AuthState>`:
/// - AsyncLoading:build 恢复 token 中,或 login 请求进行中(登录中)
/// - AsyncData:未登录 / 已登录
/// - AsyncError:登录失败,error 为 AppException

abstract class _$AuthNotifier extends $AsyncNotifier<AuthState> {
  FutureOr<AuthState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthState>, AuthState>,
              AsyncValue<AuthState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

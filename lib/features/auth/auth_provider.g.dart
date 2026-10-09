// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 启动恢复的初值,由根作用域覆盖。

@ProviderFor(initialAuthState)
final initialAuthStateProvider = InitialAuthStateProvider._();

/// 启动恢复的初值,由根作用域覆盖。

final class InitialAuthStateProvider
    extends $FunctionalProvider<AuthState, AuthState, AuthState>
    with $Provider<AuthState> {
  /// 启动恢复的初值,由根作用域覆盖。
  InitialAuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialAuthStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialAuthStateHash();

  @$internal
  @override
  $ProviderElement<AuthState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthState create(Ref ref) {
    return initialAuthState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$initialAuthStateHash() => r'139068e65d39b4fd797107119824e6f807cf1293';

/// 登录仓库注入入口。

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// 登录仓库注入入口。

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// 登录仓库注入入口。
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'b1845c21e89227820af003689c9437f06a070ee3';

/// 会话跨页面保留,操作结果交给页面处理。

@ProviderFor(AuthStateNotifier)
final authStateProvider = AuthStateNotifierProvider._();

/// 会话跨页面保留,操作结果交给页面处理。
final class AuthStateNotifierProvider
    extends $AsyncNotifierProvider<AuthStateNotifier, AuthState> {
  /// 会话跨页面保留,操作结果交给页面处理。
  AuthStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateNotifierHash();

  @$internal
  @override
  AuthStateNotifier create() => AuthStateNotifier();
}

String _$authStateNotifierHash() => r'3dd06404174e8c54f235b8afb25ea13be72b87d4';

/// 会话跨页面保留,操作结果交给页面处理。

abstract class _$AuthStateNotifier extends $AsyncNotifier<AuthState> {
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

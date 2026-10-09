import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/app_exception.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import 'auth_repository.dart';

part 'auth_provider.g.dart';

/// 会话状态,登录中由 AsyncValue 表达。
class AuthState {
  const AuthState({this.token});

  final String? token;

  bool get isLoggedIn => token?.isNotEmpty ?? false;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          token == other.token;

  @override
  int get hashCode => token.hashCode;
}

/// 启动恢复的初值,由根作用域覆盖。
@Riverpod(keepAlive: true)
AuthState initialAuthState(Ref ref) => const AuthState();

/// 登录仓库注入入口。
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository();

/// 恢复失败时以未登录态启动。
Future<AuthState> restoreAuth(AuthRepository repository) async {
  final result = await repository.restore();
  return switch (result) {
    Success(:final value) when value != null && value.isNotEmpty => AuthState(
      token: value,
    ),
    _ => const AuthState(),
  };
}

/// 会话跨页面保留,操作结果交给页面处理。
@Riverpod(keepAlive: true)
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  FutureOr<AuthState> build() => ref.watch(initialAuthStateProvider);

  Future<Result<String>> login(String username, String password) async {
    if (state.isLoading) {
      return const Result.failure(BizException('正在处理中,请勿重复提交', code: -1));
    }

    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    final result = await repository.login(username, password);
    if (!ref.mounted) return result;

    switch (result) {
      case Success(:final value):
        state = AsyncData(AuthState(token: value));
      case Failure(:final error):
        state = AsyncError(error, StackTrace.current);
        Logger.w('登录失败: ${error.message}');
    }
    return result;
  }

  Future<Result<void>> logout() async {
    if (state.isLoading) {
      return const Result.failure(BizException('正在处理中,请勿重复提交', code: -1));
    }
    final previous = state;
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).logout();
    if (!ref.mounted) return result;
    switch (result) {
      case Success():
        state = const AsyncData(AuthState());
      case Failure(:final error):
        state = previous;
        Logger.w('登出失败: ${error.message}');
    }
    return result;
  }
}

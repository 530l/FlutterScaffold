import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../core/utils/token_storage.dart';
import 'auth_repository.dart';

part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

/// 登录态数据:仅表达 未登录/已登录
///
/// 「登录中」由外层 AsyncValue 的 loading 表达,不落在本状态里。
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    /// 是否已登录
    @Default(false) bool isLoggedIn,

    /// 登录成功后保存的 token
    String? token,
  }) = _AuthState;
}

/// 全局登录态 Notifier
///
/// 状态为 `AsyncValue<AuthState>`:
/// - AsyncLoading:build 恢复 token 中,或 login 请求进行中(登录中)
/// - AsyncData:未登录 / 已登录
/// - AsyncError:登录失败,error 为 AppException
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  final AuthRepository _repository = AuthRepository();

  /// 初始构建:从 TokenStorage 恢复登录态
  ///
  /// 恢复期间为 AsyncLoading;本地已有 token 则直接进入已登录态,
  /// 否则返回未登录初始态。
  @override
  Future<AuthState> build() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return const AuthState();
    }
    return AuthState(isLoggedIn: true, token: token);
  }

  /// 登录:成功写入已登录态;失败写入 AsyncError 并重新抛出,由 UI 捕获提示
  Future<void> login(String username, String password) async {
    // 防重复提交:登录中直接忽略本次调用
    if (state.isLoading) return;

    state = const AsyncLoading();

    final result = await _repository.login(username, password);

    switch (result) {
      case Success(:final value):
        state = AsyncData(AuthState(isLoggedIn: true, token: value));
      case Failure(:final error):
        // 失败态保留错误对象,便于其他监听方(如路由守卫)感知
        state = AsyncError(error, StackTrace.current);
        Logger.w('登录失败: ${error.message}');
        // 重新抛出,登录按钮回调处 catch 后 toast 提示
        throw error;
    }
  }

  /// 登出:清除本地 token 并回到未登录态
  Future<void> logout() async {
    await TokenStorage.clearToken();
    state = const AsyncData(AuthState());
  }
}

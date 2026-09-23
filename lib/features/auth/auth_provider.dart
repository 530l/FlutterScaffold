import 'package:signals/signals.dart';

import '../../core/network/app_exception.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../core/utils/token_storage.dart';
import 'auth_repository.dart';

/// 登录态数据:仅表达 未登录/已登录
///
/// 「登录中」由外层异步态的 loading 表达,不落在本状态里。
class AuthState {
  const AuthState({
    this.isLoggedIn = false,
    this.token,
  });

  /// 是否已登录
  final bool isLoggedIn;

  /// 登录成功后保存的 token
  final String? token;

  AuthState copyWith({
    bool? isLoggedIn,
    String? token,
  }) =>
      AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        token: token ?? this.token,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          isLoggedIn == other.isLoggedIn &&
          token == other.token;

  @override
  int get hashCode => Object.hash(isLoggedIn, token);
}

/// 仓库实例(模块私有,不搞注入)
final AuthRepository _authRepository = AuthRepository();

/// 全局登录态信号(手动驱动)
///
/// 状态为 `AsyncState<AuthState>`:
/// - AsyncLoading:启动恢复 token 中,或 login 请求进行中(登录中)
/// - AsyncData:未登录 / 已登录
/// - AsyncError:登录失败,error 为 AppException
final authState = asyncSignal<AuthState>(
  const AsyncLoading(),
  // signals 7.x 中 debugLabel 参数已废弃,名称统一走 options.name
  options: AsyncSignalOptions(name: 'authState'),
);

/// 启动时恢复登录态:main 在 runApp 前调用
///
/// 本地已有 token 则直接进入已登录态,否则回到未登录初始态。
Future<void> restoreAuth() async {
  final token = await TokenStorage.getToken();
  if (token == null || token.isEmpty) {
    authState.setValue(const AuthState());
    return;
  }
  authState.setValue(AuthState(isLoggedIn: true, token: token));
}

/// 登录:成功写入已登录态并原样返回 [Result.success];失败写入错误态并原样返回 [Result.failure]
Future<Result<String>> login(String username, String password) async {
  // 防重复提交:登录中直接忽略本次调用
  if (authState.value.isLoading) {
    return const Result.failure(BizException('正在处理中,请勿重复提交', code: -1));
  }

  authState.setLoading();

  final result = await _authRepository.login(username, password);

  switch (result) {
    case Success(:final value):
      authState.setValue(AuthState(isLoggedIn: true, token: value));
      return result;
    case Failure(:final error):
      // 错误态保留错误对象,便于其他监听方(如路由守卫)感知
      authState.setError(error);
      Logger.w('登录失败: ${error.message}');
      return result;
  }
}

/// 登出:清除本地 token 并回到未登录态
Future<void> logout() async {
  await TokenStorage.clearToken();
  authState.setValue(const AuthState());
}

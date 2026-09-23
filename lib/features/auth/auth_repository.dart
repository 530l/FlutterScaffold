import '../../core/network/app_exception.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../core/utils/token_storage.dart';

/// 登录仓库(本地假登录,验证 token 存取与登录跳转链路)
///
/// 真实项目替换为 retrofit 接口调用:
/// ```dart
/// @RestApi()
/// abstract class AuthApi {
///   @POST('/login')
///   Future<LoginEntity> login(@Field() String username, @Field() String password);
/// }
/// ```
class AuthRepository {
  /// 假登录:用户名与密码均非空即成功
  ///
  /// 成功生成 'fake_token_' + 时间戳 并写入 [TokenStorage];
  /// 任一为空返回 Failure(UnauthorizedException)。
  Future<Result<String>> login(String username, String password) async {
    // 模拟网络请求耗时
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (username.trim().isEmpty || password.isEmpty) {
      return const Result<String>.failure(
        UnauthorizedException('用户名或密码错误'),
      );
    }

    // 生成假 token 并持久化
    final token = 'fake_token_${DateTime.now().millisecondsSinceEpoch}';
    await TokenStorage.saveToken(token);
    Logger.i('假登录成功: $token');

    return Result<String>.success(token);
  }
}

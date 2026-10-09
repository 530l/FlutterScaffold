import '../../core/network/app_exception.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../core/utils/token_storage.dart';

/// 示例登录与会话存储,真实业务替换登录接口。
class AuthRepository {
  Future<Result<String?>> restore() => resultGuard(TokenStorage.getToken);

  Future<Result<void>> logout() => resultGuard(TokenStorage.clearToken);

  Future<Result<String>> login(String username, String password) =>
      resultGuard(() async {
        await Future<void>.delayed(const Duration(milliseconds: 800));

        if (username.trim().isEmpty || password.isEmpty) {
          throw const UnauthorizedException('用户名或密码错误');
        }

        final token = 'fake_token_${DateTime.now().millisecondsSinceEpoch}';
        await TokenStorage.saveToken(token);
        Logger.i('假登录成功');

        return token;
      });
}

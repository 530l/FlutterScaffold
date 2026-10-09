import 'package:shared_preferences/shared_preferences.dart';

import 'logger.dart';

/// 保存 token,并缓存到内存供请求头读取。
abstract final class TokenStorage {
  static const String _tokenKey = 'auth_token';

  static String? _cachedToken;

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      if (!await prefs.setString(_tokenKey, token)) {
        throw StateError('token 保存失败');
      }
    } catch (_) {
      // 恢复插件在写入前就已修改的内部缓存。
      await prefs.reload();
      rethrow;
    }
    _cachedToken = token;
    Logger.d('token 已保存');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return _cachedToken ??= prefs.getString(_tokenKey);
  }

  /// 启动恢复后可同步读取。
  static String? get currentToken => _cachedToken;

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      if (!await prefs.remove(_tokenKey)) {
        throw StateError('token 清除失败');
      }
    } catch (_) {
      await prefs.reload();
      rethrow;
    }
    _cachedToken = null;
    Logger.d('token 已清除');
  }
}

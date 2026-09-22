import 'package:shared_preferences/shared_preferences.dart';

import 'logger.dart';

/// 基于 SharedPreferences 的 token 存取(静态工具类,不实例化)
///
/// 首次访问时异步获取 [SharedPreferences.getInstance] 并缓存实例,
/// 后续读写不再重复初始化;同时维护一份内存缓存,
/// 供网络层 [tokenReader] 同步读取注入请求头。
abstract final class TokenStorage {
  /// token 在本地存储中的 key
  static const String _tokenKey = 'auth_token';

  /// 缓存的 SharedPreferences 单例
  static SharedPreferences? _prefs;

  /// 内存缓存的 token:登录/恢复后即可同步读取
  static String? _cachedToken;

  /// 获取(并缓存)SharedPreferences 实例
  static Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// 保存 token(同时刷新内存缓存)
  static Future<void> saveToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(_tokenKey, token);
    _cachedToken = token;
    Logger.d('token 已保存');
  }

  /// 读取 token(首次读取会落内存缓存),不存在时返回 null
  static Future<String?> getToken() async {
    final prefs = await _instance;
    return _cachedToken ??= prefs.getString(_tokenKey);
  }

  /// 当前 token 的同步读取:供网络层注入 Authorization 头
  ///
  /// 说明:应用冷启动后需等 [getToken](如 AuthNotifier.build)恢复过一次才有值。
  static String? get currentToken => _cachedToken;

  /// 清除 token(登出时调用)
  static Future<void> clearToken() async {
    final prefs = await _instance;
    await prefs.remove(_tokenKey);
    _cachedToken = null;
    Logger.d('token 已清除');
  }
}

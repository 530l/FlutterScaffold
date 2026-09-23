import 'package:dio/dio.dart';

import '../utils/token_storage.dart';
import 'app_dio_client.dart';

/// 全局 Dio 实例:仓库层统一注入此实例发请求
///
/// - baseUrl 默认取 [AppConfig.apiBaseUrl]
/// - tokenReader 同步读 [TokenStorage.currentToken] 注入 Authorization 头
///   (冷启动由 main 的 restoreAuth 恢复逻辑预热内存缓存)
/// - onUnauthorized 预留 401 全局登出回调(需要时在此接入)
final Dio dioClient = AppDioClient.create(
  tokenReader: () => TokenStorage.currentToken,
);

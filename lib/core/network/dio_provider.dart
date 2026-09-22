import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../utils/token_storage.dart';
import 'app_dio_client.dart';

part 'dio_provider.g.dart';

/// 全局 Dio 实例 provider:仓库层统一注入此实例发请求
///
/// - baseUrl 默认取 [AppConfig.apiBaseUrl]
/// - tokenReader 同步读 [TokenStorage.currentToken] 注入 Authorization 头
///   (冷启动后由 AuthNotifier.build 调 getToken 恢复内存缓存)
/// - onUnauthorized 预留 401 全局登出回调(需要时在此接入)
@riverpod
Dio dioClient(Ref ref) => AppDioClient.create(
      tokenReader: () => TokenStorage.currentToken,
    );

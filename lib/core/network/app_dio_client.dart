import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'app_exception.dart';

/// 装配超时、鉴权和响应解包,不依赖业务状态。
class AppDioClient {
  AppDioClient._();

  static Dio create({
    String? baseUrl,
    String? Function()? tokenReader,
    void Function()? onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: <String, dynamic>{'Accept': 'application/json'},
      ),
    );

    dio.interceptors.addAll(<Interceptor>[
      _AuthInterceptor(
        tokenReader: tokenReader,
        onUnauthorized: onUnauthorized,
      ),
      const _EnvelopeInterceptor(),
    ]);

    if (kDebugMode && AppConfig.isDev) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          error: false,
        ),
      );
    }
    return dio;
  }
}

/// 注入 token,通过回调通知 HTTP 401。
class _AuthInterceptor extends Interceptor {
  const _AuthInterceptor({this.tokenReader, this.onUnauthorized});

  final String? Function()? tokenReader;

  final void Function()? onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenReader?.call();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}

/// 解包示例后端的响应壳,非壳响应原样返回。
class _EnvelopeInterceptor extends Interceptor {
  const _EnvelopeInterceptor();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is Map && data.containsKey('errorCode')) {
      final code = int.tryParse('${data['errorCode']}');
      if (code == 0) {
        response.data = data['data'];
        handler.next(response);
        return;
      }
      final msg = data['errorMsg'];
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.unknown,
          error: BizException(
            msg is String && msg.isNotEmpty ? msg : '请求失败',
            code: code ?? -1,
            debugDetail: '响应壳 errorCode != 0: $data',
          ),
        ),
      );
      return;
    }
    handler.next(response);
  }
}

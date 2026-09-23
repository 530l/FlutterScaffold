import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../utils/logger.dart';
import '../utils/result.dart';
import 'app_exception.dart';
import 'app_exception_mapper.dart';

/// 全局 Dio 客户端工厂:统一超时 / 请求头 / 拦截器装配
///
/// ```dart
/// final dio = AppDioClient.create(
///   tokenReader: () => TokenStore.accessToken,
///   onUnauthorized: () => AuthController.logout(),
/// );
/// ```
class AppDioClient {
  /// 禁止实例化
  AppDioClient._();

  /// 创建装配完毕的 [Dio] 实例
  ///
  /// - [baseUrl]:接口基础地址,默认取 [AppConfig.apiBaseUrl]
  /// - [tokenReader]:token 读取函数,返回非空则注入 Authorization 头
  /// - [onUnauthorized]:收到 401 时的回调(通常用来跳登录页)
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

    // 顺序:先鉴权(注入头)再解包(处理响应壳)
    dio.interceptors.addAll(<Interceptor>[
      _AuthInterceptor(tokenReader: tokenReader, onUnauthorized: onUnauthorized),
      const _EnvelopeInterceptor(),
    ]);

    // 开发环境追加请求/响应体日志
    if (AppConfig.isDev) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
    return dio;
  }
}

/// 鉴权拦截器:注入 Bearer token + 401 统一处理
class _AuthInterceptor extends Interceptor {
  const _AuthInterceptor({this.tokenReader, this.onUnauthorized});

  /// token 读取函数(延迟求值,每次请求时读取最新值)
  final String? Function()? tokenReader;

  /// 401 回调:由外部决定如何登出 / 跳转
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
    // 仅 HTTP 层 401 触发(业务壳里的失败由 _EnvelopeInterceptor 处理,不会走到这)
    if (err.response?.statusCode == 401) {
      // TODO: token 刷新队列扩展点 —— 后续可在此挂「并发请求等待刷新完成后重放」的逻辑
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}

/// 响应壳解包拦截器:把 { errorCode, errorMsg, data } 壳拆掉
///
/// - errorCode == 0:把 response.data 替换为壳内的 data 字段,
///   retrofit 生成代码即可直接解析业务模型(data 为 null 时保持 null 透传)
/// - errorCode != 0:reject 一个携带 [BizException] 的 DioException,
///   由 AppExceptionMapper 透传给上层
/// - data 不是 Map 或不含 errorCode 键:原样放行(兼容文件下载等非壳接口)
class _EnvelopeInterceptor extends Interceptor {
  const _EnvelopeInterceptor();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    // 仅处理 Map 形态的响应壳
    if (data is Map && data.containsKey('errorCode')) {
      // 兼容后端把 errorCode 序列化成字符串的情况
      final code = int.tryParse('${data['errorCode']}');
      if (code == 0) {
        // 壳解包:业务方直接拿到 data 字段(可能为 null,保持透传)
        response.data = data['data'];
        handler.next(response);
        return;
      }
      final msg = data['errorMsg'];
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
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

/// 执行网络请求并确保抛出的异常均收敛为 [AppException]
///
/// 适用于 Query 查询类请求(供 futureSignal/AsyncSignal 自然消费):
/// ```dart
/// Future<List<Banner>> fetchBanners() =>
///     apiCall(() => api.getBanners());
/// ```
Future<T> apiCall<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on DioException catch (e) {
    Logger.w('apiCall 捕获网络异常: ${e.type.name} ${e.requestOptions.uri}');
    throw AppExceptionMapper.fromDio(e);
  }
}

/// 执行操作并返回 [Result<T>],UI 层可通过 switch/模式匹配穷举处理
///
/// 适用于 Action/Mutation 操作类请求(如提交表单、登录等):
/// ```dart
/// Future<Result<void>> submitForm() =>
///     resultGuard(() => api.submit());
/// ```
Future<Result<T>> resultGuard<T>(Future<T> Function() action) async {
  try {
    return Result.success(await action());
  } on DioException catch (e) {
    Logger.w('resultGuard 捕获网络异常: ${e.type.name} ${e.requestOptions.uri}');
    return Result.failure(AppExceptionMapper.fromDio(e));
  } on AppException catch (e) {
    // 非 dio 链路抛出的业务异常直接透传
    return Result.failure(e);
  } catch (e, s) {
    Logger.e('resultGuard 捕获未知异常', e, s);
    return Result.failure(UnknownException('出了点问题,请稍后重试', e.toString()));
  }
}

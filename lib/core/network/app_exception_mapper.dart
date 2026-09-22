import 'package:dio/dio.dart';

import 'app_exception.dart';

/// DioException 到统一异常体系的映射器
///
/// 网络层的任何 [DioException] 最终都收敛为 sealed [AppException],
/// UI 层只需 switch 穷举处理,不再感知 dio 的存在
abstract final class AppExceptionMapper {
  /// 将 [DioException] 翻译为面向用户的 [AppException]
  ///
  /// [e] 由 dio 抛出或由拦截器 reject,统一在这里兜底翻译
  static AppException fromDio(DioException e) {
    // EnvelopeInterceptor reject 出来的业务异常:error 字段已是 AppException,直接透传
    final inner = e.error;
    if (inner is AppException) {
      return inner;
    }

    // 拼装调试信息:异常类型 + 请求地址 + dio message + 底层 error,仅用于日志排查
    final detail = [
      'type: ${e.type.name}',
      'uri: ${e.requestOptions.uri}',
      if (e.message != null) 'message: ${e.message}',
      if (e.error != null) 'error: ${e.error}',
    ].join(' | ');

    // 穷举所有 DioExceptionType(dio 5.11.1 共 9 个枚举值)
    return switch (e.type) {
      // 超时类:建连 / 发送 / 接收 / 转换阶段超时
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout =>
        TimeoutException('请求超时,请稍后重试', detail),
      // 连接类:无网络 / DNS 失败 / 证书错误
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate =>
        NetworkException('网络连接不可用,请检查网络设置', detail),
      // badResponse:按 HTTP 状态码细分
      DioExceptionType.badResponse => _fromBadResponse(e, detail),
      // 请求被主动取消
      DioExceptionType.cancel => CancelException('请求已取消', detail),
      // 兜底
      DioExceptionType.unknown => UnknownException('出了点问题,请稍后重试', detail),
    };
  }

  /// badResponse 细分:401 未授权 / 5xx 服务器错误 / 其他按请求错误处理
  static AppException _fromBadResponse(DioException e, String detail) {
    final statusCode = e.response?.statusCode;
    return switch (statusCode) {
      401 => UnauthorizedException('登录已过期,请重新登录', detail),
      final code? when code >= 500 => ServerException(
          '服务器开小差了,请稍后重试',
          statusCode: code,
          debugDetail: detail,
        ),
      _ => BadRequestException('请求失败,请稍后重试', detail),
    };
  }
}

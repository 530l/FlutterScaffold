import 'package:dio/dio.dart';

import 'app_exception.dart';

/// 将 Dio 异常映射为应用异常。
abstract final class AppExceptionMapper {
  static AppException fromDio(DioException e) {
    final inner = e.error;
    if (inner is AppException) {
      return inner;
    }

    final detail = [
      'type: ${e.type.name}',
      'uri: ${e.requestOptions.uri}',
      if (e.message != null) 'message: ${e.message}',
      if (e.error != null) 'error: ${e.error}',
    ].join(' | ');

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => TimeoutException(
        '请求超时,请稍后重试',
        detail,
      ),
      DioExceptionType.connectionError || DioExceptionType.badCertificate =>
        NetworkException('网络连接不可用,请检查网络设置', detail),
      DioExceptionType.badResponse => _fromBadResponse(e, detail),
      DioExceptionType.cancel => CancelException('请求已取消', detail),
      DioExceptionType.unknown => UnknownException('出了点问题,请稍后重试', detail),
    };
  }

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

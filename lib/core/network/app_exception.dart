/// 应用统一异常体系:sealed 保证 UI 层可穷举 switch 处理
///
/// [message] 为面向用户的中文文案,[debugDetail] 供日志排查(不打给用户)
sealed class AppException implements Exception {
  const AppException(this.message, [this.debugDetail]);

  /// 面向用户的中文提示文案
  final String message;

  /// 调试用详细信息(原始错误/URL 等)
  final String? debugDetail;

  @override
  String toString() => '$runtimeType(message: $message, debugDetail: $debugDetail)';
}

/// 无网络 / DNS 解析失败
final class NetworkException extends AppException {
  const NetworkException(super.message, [super.debugDetail]);
}

/// 连接 / 收发超时
final class TimeoutException extends AppException {
  const TimeoutException(super.message, [super.debugDetail]);
}

/// 服务器错误(5xx)
final class ServerException extends AppException {
  const ServerException(String message, {this.statusCode, String? debugDetail})
      : super(message, debugDetail);

  /// HTTP 状态码
  final int? statusCode;
}

/// 请求错误(4xx,不含 401)
final class BadRequestException extends AppException {
  const BadRequestException(super.message, [super.debugDetail]);
}

/// 未授权(401):登录过期 / token 无效
final class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, [super.debugDetail]);
}

/// 业务错误:后端返回 errorCode != 0
final class BizException extends AppException {
  const BizException(String message, {required this.code, String? debugDetail})
      : super(message, debugDetail);

  /// 后端业务错误码
  final int code;
}

/// 请求被主动取消
final class CancelException extends AppException {
  const CancelException(super.message, [super.debugDetail]);
}

/// 未知错误兜底
final class UnknownException extends AppException {
  const UnknownException(super.message, [super.debugDetail]);
}

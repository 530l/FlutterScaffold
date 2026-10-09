/// message 用于界面提示,debugDetail 仅用于排查。
sealed class AppException implements Exception {
  const AppException(this.message, [this.debugDetail]);

  final String message;

  final String? debugDetail;

  @override
  String toString() =>
      '$runtimeType(message: $message, debugDetail: $debugDetail)';
}

/// 连接失败或无网络。
final class NetworkException extends AppException {
  const NetworkException(super.message, [super.debugDetail]);
}

/// 请求超时。
final class TimeoutException extends AppException {
  const TimeoutException(super.message, [super.debugDetail]);
}

/// 服务端错误。
final class ServerException extends AppException {
  const ServerException(String message, {this.statusCode, String? debugDetail})
    : super(message, debugDetail);

  final int? statusCode;
}

/// 请求被拒绝。
final class BadRequestException extends AppException {
  const BadRequestException(super.message, [super.debugDetail]);
}

/// 登录失效。
final class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, [super.debugDetail]);
}

/// 后端业务错误。
final class BizException extends AppException {
  const BizException(String message, {required this.code, String? debugDetail})
    : super(message, debugDetail);

  final int code;
}

/// 请求主动取消。
final class CancelException extends AppException {
  const CancelException(super.message, [super.debugDetail]);
}

/// 未分类异常。
final class UnknownException extends AppException {
  const UnknownException(super.message, [super.debugDetail]);
}

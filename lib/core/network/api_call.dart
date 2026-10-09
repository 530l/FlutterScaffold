import 'package:dio/dio.dart';

import '../utils/logger.dart';
import 'app_exception.dart';
import 'app_exception_mapper.dart';

/// 将网络和模型解析异常统一为 AppException。
Future<T> apiCall<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on DioException catch (error) {
    Logger.w('请求失败: ${error.type.name}');
    throw AppExceptionMapper.fromDio(error);
  } on AppException {
    rethrow;
  } catch (error, stackTrace) {
    Logger.e('响应解析失败', error, stackTrace);
    throw UnknownException('出了点问题,请稍后重试', error.toString());
  }
}

import '../network/app_exception.dart';
import 'logger.dart';

/// 操作结果,供调用方穷举处理成功与失败。
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;

  const factory Result.failure(AppException error) = Failure<T>;
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppException error;
}

/// 捕获操作异常;网络操作先通过 apiCall 映射异常。
Future<Result<T>> resultGuard<T>(Future<T> Function() action) async {
  try {
    return Result.success(await action());
  } on AppException catch (error) {
    return Result.failure(error);
  } catch (error, stackTrace) {
    Logger.e('操作失败', error, stackTrace);
    return Result.failure(UnknownException('出了点问题,请稍后重试', error.toString()));
  }
}

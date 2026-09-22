import '../network/app_exception.dart';

/// 通用结果包装:仓库层统一返回类型,UI 层 switch 穷举处理
///
/// ```dart
/// switch (result) {
///   Success(:final value) => print(value),
///   Failure(:final error) => print(error.message),
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// 成功结果
  const factory Result.success(T value) = Success<T>;

  /// 失败结果,携带统一的 AppException
  const factory Result.failure(AppException error) = Failure<T>;
}

/// 成功分支
final class Success<T> extends Result<T> {
  const Success(this.value);

  /// 业务数据
  final T value;
}

/// 失败分支
final class Failure<T> extends Result<T> {
  const Failure(this.error);

  /// 统一异常(message 为面向用户的中文文案)
  final AppException error;
}

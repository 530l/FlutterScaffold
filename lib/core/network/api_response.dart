import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// 后端统一响应壳:{ "errorCode": 0, "errorMsg": "", "data": {...} }
///
/// - errorCode == 0 视为成功(见 [isSuccess])
/// - data 为业务数据,泛型 [T] 由调用方决定如何反序列化
///
/// 说明:正常链路下 EnvelopeInterceptor 已把壳解包,retrofit 直接拿到 data;
/// 本类用于需要手动解析响应壳的场景(如本地 mock、特殊接口、单元测试)
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  /// 统一构造
  const ApiResponse({required this.errorCode, this.errorMsg, this.data});

  /// 泛型反序列化工厂,委托给生成的 _$ApiResponseFromJson
  ///
  /// [fromJsonT] 由调用方传入 T 的具体解析逻辑,例如:
  /// `ApiResponse<Banner>.fromJson(json, (j) => Banner.fromJson(j! as Map<String, dynamic>))`
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  /// 泛型序列化,[toJsonT] 由调用方传入 T 的具体序列化逻辑
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  /// 业务错误码:0 表示成功
  final int errorCode;

  /// 后端返回的错误描述(成功时可能为空)
  final String? errorMsg;

  /// 业务数据本体
  final T? data;

  /// 是否成功
  bool get isSuccess => errorCode == 0;
}

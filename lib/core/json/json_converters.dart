/// 通用 JsonConverter 集合:模型字段按需注解取用
///
/// 用法(标注在字段上,生成代码会自动插入转换调用):
/// ```dart
/// @JsonSerializable()
/// class Model {
///   @EpochSecondDateTimeConverter()
///   final DateTime createdAt;
///
///   @DefaultStringConverter() // 后端可能回 null 的字符串字段
///   final String nickname;
/// }
/// ```
library;

import 'package:json_annotation/json_annotation.dart';

/// 秒级时间戳转换器:10 位 Unix 秒 ↔ [DateTime]
class EpochSecondDateTimeConverter extends JsonConverter<DateTime, int> {
  const EpochSecondDateTimeConverter();

  @override
  DateTime fromJson(int json) =>
      DateTime.fromMillisecondsSinceEpoch(json * 1000);

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch ~/ 1000;
}

/// 毫秒级时间戳转换器:13 位 Unix 毫秒 ↔ [DateTime]
class EpochMilliDateTimeConverter extends JsonConverter<DateTime, int> {
  const EpochMilliDateTimeConverter();

  @override
  DateTime fromJson(int json) => DateTime.fromMillisecondsSinceEpoch(json);

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch;
}

/// ISO 8601 字符串转换器:'2024-01-15T10:30:00' ↔ [DateTime]
class IsoDateTimeConverter extends JsonConverter<DateTime, String> {
  const IsoDateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}

/// 字符串默认值转换器:JSON 值为 null 时兜底为空串
///
/// 注:S 取 Object? 使 null 能流入本转换器(生成代码做 `as Object?` 转型不抛错)
class DefaultStringConverter extends JsonConverter<String, Object?> {
  const DefaultStringConverter();

  @override
  String fromJson(Object? json) => json?.toString() ?? '';

  @override
  Object? toJson(String object) => object;
}

/// 整型默认值转换器:JSON 值为 null 时兜底为 0
class DefaultIntConverter extends JsonConverter<int, Object?> {
  const DefaultIntConverter();

  @override
  int fromJson(Object? json) => json is int ? json : 0;

  @override
  Object? toJson(int object) => object;
}

/// 弱类型整型转换器:后端返回 String '123' / double 123.0 时也能解析为 int
///
/// 兜底顺序:int 直接用 → num 取整 → String 尝试解析 → 其余(含 null)归 0
class LenientIntConverter extends JsonConverter<int, Object?> {
  const LenientIntConverter();

  @override
  int fromJson(Object? json) {
    if (json is int) return json;
    if (json is num) return json.toInt();
    if (json is String) return int.tryParse(json) ?? 0;
    return 0;
  }

  @override
  Object? toJson(int object) => object;
}

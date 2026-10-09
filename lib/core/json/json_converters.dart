import 'package:json_annotation/json_annotation.dart';

/// 秒级时间戳转换。
class EpochSecondDateTimeConverter extends JsonConverter<DateTime, int> {
  const EpochSecondDateTimeConverter();

  @override
  DateTime fromJson(int json) =>
      DateTime.fromMillisecondsSinceEpoch(json * 1000);

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch ~/ 1000;
}

/// 毫秒级时间戳转换。
class EpochMilliDateTimeConverter extends JsonConverter<DateTime, int> {
  const EpochMilliDateTimeConverter();

  @override
  DateTime fromJson(int json) => DateTime.fromMillisecondsSinceEpoch(json);

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch;
}

/// ISO 8601 时间转换。
class IsoDateTimeConverter extends JsonConverter<DateTime, String> {
  const IsoDateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}

/// null 兜底为空字符串。
class DefaultStringConverter extends JsonConverter<String, Object?> {
  const DefaultStringConverter();

  @override
  String fromJson(Object? json) => json?.toString() ?? '';

  @override
  Object? toJson(String object) => object;
}

/// 非整型值兜底为 0。
class DefaultIntConverter extends JsonConverter<int, Object?> {
  const DefaultIntConverter();

  @override
  int fromJson(Object? json) => json is int ? json : 0;

  @override
  Object? toJson(int object) => object;
}

/// 兼容数字字符串和浮点数,无效值兜底为 0。
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

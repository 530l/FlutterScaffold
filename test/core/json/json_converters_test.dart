// JsonConverter 集合单元测试:解析与弱类型兜底断言
//
// 说明:被测文件为纯手写实现,不依赖任何生成产物
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterscaffold/core/json/json_converters.dart';

void main() {
  group('EpochSecondDateTimeConverter 秒级时间戳', () {
    const converter = EpochSecondDateTimeConverter();

    test('10 位秒级时间戳解析为 DateTime', () {
      expect(
        converter.fromJson(1700000000),
        DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );
    });

    test('DateTime 序列化回 10 位秒级时间戳', () {
      expect(
        converter.toJson(DateTime.fromMillisecondsSinceEpoch(1700000000500)),
        1700000000,
      );
    });
  });

  group('EpochMilliDateTimeConverter 毫秒级时间戳', () {
    const converter = EpochMilliDateTimeConverter();

    test('13 位毫秒时间戳解析为 DateTime', () {
      expect(
        converter.fromJson(1700000000500),
        DateTime.fromMillisecondsSinceEpoch(1700000000500),
      );
    });

    test('DateTime 序列化回 13 位毫秒时间戳', () {
      final now = DateTime.now();
      expect(converter.toJson(now), now.millisecondsSinceEpoch);
    });
  });

  group('IsoDateTimeConverter ISO 8601 字符串', () {
    const converter = IsoDateTimeConverter();

    test('ISO 字符串解析为 DateTime', () {
      expect(
        converter.fromJson('2024-01-15T10:30:00'),
        DateTime(2024, 1, 15, 10, 30),
      );
    });

    test('DateTime 序列化回 ISO 字符串', () {
      expect(
        converter.toJson(DateTime(2024, 1, 15, 10, 30)),
        '2024-01-15T10:30:00.000',
      );
    });
  });

  group('DefaultStringConverter 字符串默认值', () {
    const converter = DefaultStringConverter();

    test('null 兜底为空串', () {
      expect(converter.fromJson(null), '');
    });

    test('正常字符串原样返回', () {
      expect(converter.fromJson('标题'), '标题');
    });
  });

  group('DefaultIntConverter 整型默认值', () {
    const converter = DefaultIntConverter();

    test('null 兜底为 0', () {
      expect(converter.fromJson(null), 0);
    });

    test('正常整型原样返回', () {
      expect(converter.fromJson(42), 42);
    });
  });

  group('LenientIntConverter 弱类型整型', () {
    const converter = LenientIntConverter();

    test('int 直接返回', () {
      expect(converter.fromJson(7), 7);
    });

    test("String '123' 解析为 123", () {
      expect(converter.fromJson('123'), 123);
    });

    test('double 123.0 取整为 123', () {
      expect(converter.fromJson(123.0), 123);
    });

    test('null 兜底为 0', () {
      expect(converter.fromJson(null), 0);
    });

    test("无法解析的 String 'abc' 兜底为 0", () {
      expect(converter.fromJson('abc'), 0);
    });
  });
}

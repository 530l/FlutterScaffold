// Result 单元测试:构造、工厂重定向与 switch 模式匹配
//
// 说明:不依赖任何生成代码,生成前即可运行
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterscaffold/core/network/app_exception.dart';
import 'package:flutterscaffold/core/utils/result.dart';

void main() {
  group('Result 构造', () {
    test('Success 携带业务数据', () {
      const result = Success<int>(42);
      expect(result.value, 42);
      expect(result, isA<Success<int>>());
    });

    test('Failure 携带统一异常', () {
      const failure = Failure<String>(NetworkException('网络连接不可用,请检查网络设置'));
      expect(failure.error, isA<NetworkException>());
      expect(failure.error.message, '网络连接不可用,请检查网络设置');
    });
  });

  group('Result 工厂重定向', () {
    test('Result.success 重定向到 Success', () {
      final result = Result.success('hello');
      expect(result, isA<Success<String>>());
      expect((result as Success<String>).value, 'hello');
    });

    test('Result.failure 重定向到 Failure', () {
      final result = Result<int>.failure(const TimeoutException('请求超时,请稍后重试'));
      expect(result, isA<Failure<int>>());
      expect((result as Failure<int>).error, isA<TimeoutException>());
    });
  });

  group('Result switch 模式匹配', () {
    test('成功分支解构出 value', () {
      const Result<int> result = Success(1);
      final text = switch (result) {
        Success(:final value) => '成功:$value',
        Failure(:final error) => '失败:${error.message}',
      };
      expect(text, '成功:1');
    });

    test('失败分支解构出 error 并穷举子类型', () {
      const Result<int> result = Failure(BizException('积分不足', code: 10086));
      final text = switch (result) {
        Success(:final value) => '成功:$value',
        Failure(:final error) => switch (error) {
            BizException(:final code) => '业务错误:$code',
            _ => '其他错误:${error.message}',
          },
      };
      expect(text, '业务错误:10086');
    });
  });

  group('AppException sealed 穷举', () {
    test('各子类 message 与附加字段正确', () {
      expect(const ServerException('服务器开小差了', statusCode: 500).statusCode, 500);
      expect(const BizException('请求失败', code: -1).code, -1);
      expect(const UnauthorizedException('登录已过期').message, '登录已过期');
      expect(const CancelException('请求已取消').message, '请求已取消');
      expect(
        const UnknownException('出了点问题').debugDetail,
        isNull,
      );
    });
  });
}

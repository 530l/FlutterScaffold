// AppExceptionMapper 单元测试:穷举 DioExceptionType 全部枚举值与状态码映射
//
// 说明:全程手工构造 DioException,不发起真实网络请求,也不依赖任何生成代码
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterscaffold/core/network/app_exception.dart';
import 'package:flutterscaffold/core/network/app_exception_mapper.dart';

void main() {
  // 复用的请求选项
  final requestOptions = RequestOptions(path: '/test');

  // 按类型 + 可选响应构造 DioException 的便捷函数
  DioException build(DioExceptionType type, {Response? response, Object? error}) =>
      DioException(
        requestOptions: requestOptions,
        type: type,
        response: response,
        error: error,
      );

  group('AppExceptionMapper.fromDio 业务异常透传', () {
    test('error 字段已是 AppException 时直接透传同一实例', () {
      final biz = const BizException('积分不足', code: 10086);
      final mapped = AppExceptionMapper.fromDio(build(
        DioExceptionType.unknown,
        error: biz,
      ));
      expect(mapped, same(biz));
    });
  });

  group('AppExceptionMapper.fromDio 超时类映射', () {
    test('connectionTimeout → TimeoutException', () {
      final mapped =
          AppExceptionMapper.fromDio(build(DioExceptionType.connectionTimeout));
      expect(mapped, isA<TimeoutException>());
      expect(mapped.message, '请求超时,请稍后重试');
    });

    test('sendTimeout → TimeoutException', () {
      expect(
        AppExceptionMapper.fromDio(build(DioExceptionType.sendTimeout)),
        isA<TimeoutException>(),
      );
    });

    test('receiveTimeout → TimeoutException', () {
      expect(
        AppExceptionMapper.fromDio(build(DioExceptionType.receiveTimeout)),
        isA<TimeoutException>(),
      );
    });

    test('transformTimeout → TimeoutException', () {
      expect(
        AppExceptionMapper.fromDio(build(DioExceptionType.transformTimeout)),
        isA<TimeoutException>(),
      );
    });
  });

  group('AppExceptionMapper.fromDio 连接类映射', () {
    test('connectionError → NetworkException', () {
      final mapped =
          AppExceptionMapper.fromDio(build(DioExceptionType.connectionError));
      expect(mapped, isA<NetworkException>());
      expect(mapped.message, '网络连接不可用,请检查网络设置');
    });

    test('badCertificate → NetworkException', () {
      expect(
        AppExceptionMapper.fromDio(build(DioExceptionType.badCertificate)),
        isA<NetworkException>(),
      );
    });
  });

  group('AppExceptionMapper.fromDio badResponse 按状态码细分', () {
    // 按状态码构造 badResponse 异常的便捷函数
    DioException badResponse(int statusCode) => build(
          DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: statusCode,
          ),
        );

    test('401 → UnauthorizedException', () {
      final mapped = AppExceptionMapper.fromDio(badResponse(401));
      expect(mapped, isA<UnauthorizedException>());
      expect(mapped.message, '登录已过期,请重新登录');
    });

    test('500 → ServerException 且携带状态码', () {
      final mapped = AppExceptionMapper.fromDio(badResponse(500));
      expect(mapped, isA<ServerException>());
      expect((mapped as ServerException).statusCode, 500);
      expect(mapped.message, '服务器开小差了,请稍后重试');
    });

    test('503 → ServerException', () {
      final mapped = AppExceptionMapper.fromDio(badResponse(503));
      expect(mapped, isA<ServerException>());
      expect((mapped as ServerException).statusCode, 503);
    });

    test('400 → BadRequestException', () {
      expect(
        AppExceptionMapper.fromDio(badResponse(400)),
        isA<BadRequestException>(),
      );
    });

    test('404 → BadRequestException', () {
      expect(
        AppExceptionMapper.fromDio(badResponse(404)),
        isA<BadRequestException>(),
      );
    });

    test('无状态码的 badResponse → BadRequestException 兜底', () {
      expect(
        AppExceptionMapper.fromDio(build(DioExceptionType.badResponse)),
        isA<BadRequestException>(),
      );
    });
  });

  group('AppExceptionMapper.fromDio 其他类型', () {
    test('cancel → CancelException', () {
      final mapped = AppExceptionMapper.fromDio(build(DioExceptionType.cancel));
      expect(mapped, isA<CancelException>());
      expect(mapped.message, '请求已取消');
    });

    test('unknown → UnknownException 兜底', () {
      final mapped = AppExceptionMapper.fromDio(build(DioExceptionType.unknown));
      expect(mapped, isA<UnknownException>());
      expect(mapped.message, '出了点问题,请稍后重试');
    });
  });

  group('AppExceptionMapper.fromDio 调试信息', () {
    test('debugDetail 携带原始信息(类型 / uri / message / error)', () {
      final mapped = AppExceptionMapper.fromDio(DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
        error: const FormatException('dns 失败'),
        message: '原始 message',
      ));
      expect(mapped.debugDetail, contains('connectionError'));
      expect(mapped.debugDetail, contains('/test'));
      expect(mapped.debugDetail, contains('原始 message'));
      expect(mapped.debugDetail, contains('dns 失败'));
    });
  });
}

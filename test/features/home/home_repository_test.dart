// HomeRepository 单元测试:手写 MockHttpClientAdapter 打桩响应壳 JSON
//
// 链路:Dio(AppDioClient.create,含 EnvelopeInterceptor)→ mock 适配器返回
// 响应体 → 解包 → retrofit 解析模型 → apiCall 透出异常
//
// 说明:本文件依赖 build_runner 生成代码(home_api.g.dart / banner.g.dart),
// 生成产物就绪后即可运行
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterscaffold/core/network/app_dio_client.dart';
import 'package:flutterscaffold/core/network/app_exception.dart';
import 'package:flutterscaffold/features/home/repository/home_repository.dart';

/// 打桩适配器:忽略请求内容,固定返回构造好的响应体(HTTP 200)
class _MockHttpClientAdapter implements HttpClientAdapter {
  _MockHttpClientAdapter(this.body);

  /// 预置的 JSON 响应体
  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      // 必须声明 JSON content-type,dio 默认转换器才会对响应体做 JSON 解码
      ResponseBody.fromString(
        body,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

void main() {
  // 用真实装配链路(含响应壳解包拦截器)构建 Dio,仅替换底层传输为打桩
  Dio buildDio(String body) {
    final dio = AppDioClient.create();
    dio.httpClientAdapter = _MockHttpClientAdapter(body);
    return dio;
  }

  group('HomeRepository.getBanners', () {
    test('errorCode == 0 时解包并解析出模型列表', () async {
      const body = '''
      {
        "errorCode": 0,
        "errorMsg": "",
        "data": [
          {"id": 1, "title": "轮播一", "url": "https://example.com/a", "imagePath": "https://example.com/img1.png"},
          {"id": 2, "title": "轮播二", "url": "https://example.com/b", "imagePath": "https://example.com/img2.png"},
          {"id": 3}
        ]
      }
      ''';
      final repository = HomeRepository(buildDio(body));

      final banners = await repository.getBanners();

      expect(banners, hasLength(3));
      expect(banners.first.id, 1);
      expect(banners.first.title, '轮播一');
      expect(banners.first.imagePath, 'https://example.com/img1.png');
      // 缺省字段走 @Default('') 兜底
      expect(banners.last.title, '');
      expect(banners.last.imagePath, '');
    });

    test('errorCode != 0 时抛出 BizException', () async {
      const body = '''
      {
        "errorCode": -1,
        "errorMsg": "请求参数错误",
        "data": null
      }
      ''';
      final repository = HomeRepository(buildDio(body));

      expect(
        () => repository.getBanners(),
        throwsA(
          isA<BizException>()
              .having((e) => e.code, 'code', -1)
              .having((e) => e.message, 'message', '请求参数错误'),
        ),
      );
    });
  });
}

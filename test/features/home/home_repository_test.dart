import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterscaffold/core/network/app_dio_client.dart';
import 'package:flutterscaffold/core/network/app_exception.dart';
import 'package:flutterscaffold/features/home/repository/home_repository.dart';

/// 模拟 JSON 响应,保留真实解包和解析链路。
class _MockHttpClientAdapter implements HttpClientAdapter {
  _MockHttpClientAdapter(this.body);

  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
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

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../utils/token_storage.dart';
import 'app_dio_client.dart';

part 'dio_client.g.dart';

/// 由作用域管理客户端生命周期。
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final client = AppDioClient.create(
    tokenReader: () => TokenStorage.currentToken,
  );
  ref.onDispose(() => client.close(force: true));
  return client;
}

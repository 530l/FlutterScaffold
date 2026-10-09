import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../model/banner.dart';
import '../repository/home_repository.dart';

part 'home_banner_provider.g.dart';

/// 首页仓库注入入口。
@Riverpod(keepAlive: true)
HomeRepository homeRepository(Ref ref) =>
    HomeRepository(ref.watch(dioProvider));

/// 主壳销毁后释放查询,重新进入时重新请求。
@Riverpod(retry: _noRetry)
Future<List<BannerModel>> homeBanner(Ref ref) {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel('首页请求已取消'));
  return ref.watch(homeRepositoryProvider).getBanners(cancelToken: cancelToken);
}

// 失败后等待用户重试。
Duration? _noRetry(int retryCount, Object error) => null;

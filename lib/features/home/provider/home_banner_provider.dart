import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/utils/result.dart';
import '../model/banner.dart';
import '../repository/home_repository.dart';

part 'home_banner_provider.g.dart';

/// 首页仓库 provider:注入全局 Dio 实例
@riverpod
HomeRepository homeRepository(Ref ref) =>
    HomeRepository(ref.watch(dioClientProvider));

/// 首页轮播状态:notifier 驱动的异步三态(加载中 / 数据 / 错误)
@riverpod
class HomeBannerNotifier extends _$HomeBannerNotifier {
  @override
  Future<List<BannerModel>> build() async {
    // 在途请求取消令牌:provider 销毁时自动取消,避免泄漏与过期结果写入
    final cancelToken = CancelToken();
    ref.onDispose(cancelToken.cancel);

    final result = await ref
        .watch(homeRepositoryProvider)
        .getBanners(cancelToken: cancelToken);
    // 仓库层已兜住所有异常:Success 出数据,Failure 抛给 AsyncValue 的错误态
    switch (result) {
      case Success(:final value):
        return value;
      case Failure(:final error):
        throw error;
    }
  }

  /// 下拉刷新:回到加载态并重建自身,等待新数据就绪
  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidateSelf();
    await future;
  }
}

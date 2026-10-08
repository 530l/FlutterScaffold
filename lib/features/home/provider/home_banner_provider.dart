import 'package:signals/signals.dart';

import '../../../core/network/dio_client.dart';
import '../model/banner.dart';
import '../repository/home_repository.dart';

/// 首页仓库实例:widget 测试直接重新赋值为假实现,这是唯一的注入缝
HomeRepository homeRepository = HomeRepository(dioClient);

/// 首页轮播状态:futureSignal 驱动的异步三态(加载中 / 数据 / 错误)
///
/// - refresh():下拉刷新与错误重试的统一入口,保留旧数据/旧错误置 loading
///   (keepPrevious;有数据 → AsyncDataRefreshing,有错误 → AsyncErrorRefreshing)
/// - reload():实际行为与 refresh() 相同(同样保留旧值,只是状态类换成
///   *Reloading,语义上表示「查询条件已变化」),本项目未用到;
///   signals 7.1.0 源码注释称其「回到纯加载态」,与实现不符,勿被误导
/// - 信号全局常驻无 dispose 时机,CancelToken 语义由仓库可选参数保留
/// - 与迁移前 Riverpod autoDispose provider 的行为差异:离开首页信号不销毁、
///   缓存跨页面保留;重进首页不会自动重新求值,由 HomeScreen 的 initState
///   主动 refresh 补齐「重进即拉新」语义(见 home_screen.dart)
final homeBanner = futureSignal<List<BannerModel>>(
  () => homeRepository.getBanners(),
  // signals 7.x:debugLabel 已废弃改用 name;lazy 默认 true(不读不请求),无需显式指定
  options: AsyncSignalOptions(name: 'homeBanner'),
);

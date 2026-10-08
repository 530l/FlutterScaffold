import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';

import '../../../core/router/route_names.dart';
import '../../../core/widget/app_network_image.dart';
import '../../../core/widget/async_view.dart';
import '../../auth/auth_provider.dart';
import '../model/banner.dart';
import '../provider/home_banner_provider.dart';

/// 首页:轮播列表(AppNetworkImage + 标题),支持下拉刷新,AppBar 提供登出入口
class HomeScreen extends SignalStatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 信号是全局常驻的,重挂载页面不会自动重新求值,这里在已有数据/错误(非首次
    // 进入)时主动 refresh 一次:保留旧数据的同时拉取最新。
    // 注意:本页嵌在主壳 MainPage 的 IndexedStack 里,切 tab 不会卸载/重挂载,
    // 因此「重进刷新」只在整壳重建时触发(登出 → 再登录 go('/') 这条路径),
    // 登录会话内切回本 tab 不重新请求,只能靠下拉刷新。
    // TODO 扩展点:产品上需要「切回 tab 即拉新」时,再引入基于可见性的刷新
    final bannerState = homeBanner.peek();
    if (bannerState is AsyncData || bannerState is AsyncError) {
      homeBanner.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = homeBanner.value;
    // 下拉 / 重试统一走信号的 refresh
    Future<void> onRefresh() => homeBanner.refresh();

    return Scaffold(
      appBar: AppBar(
        title: const Text('探索'),
        // 登出入口:清 token 回未登录态,并手动跳回登录页
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '登出',
            onPressed: () async {
              await logout();
              if (context.mounted) context.go(RoutePaths.login);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: AsyncView<List<BannerModel>>(
          value: bannersAsync,
          onRetry: onRefresh,
          dataBuilder: (banners) => ListView.builder(
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return ListTile(
                leading: AppNetworkImage(
                  imageUrl: banner.imagePath,
                  width: 96,
                  height: 56,
                  fit: BoxFit.cover,
                  borderRadius: 4,
                ),
                title: Text(banner.title),
              );
            },
          ),
        ),
      ),
    );
  }
}

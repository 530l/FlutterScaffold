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
    // 迁移前的 Riverpod provider 是 autoDispose:离开首页即销毁,重进必然重新请求。
    // 信号是全局常驻的,重进不会自动重新求值,这里在已有数据/错误(非首次进入)时
    // 主动 refresh 一次:保留旧数据的同时拉取最新,对齐「重进首页即刷新」的旧行为
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

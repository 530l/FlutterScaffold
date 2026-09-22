import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/widget/app_network_image.dart';
import '../../../core/widget/async_view.dart';
import '../../auth/auth_provider.dart';
import '../model/banner.dart';
import '../provider/home_banner_provider.dart';

/// 首页:轮播列表(AppNetworkImage + 标题),支持下拉刷新,AppBar 提供登出入口
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(homeBannerProvider);
    // 下拉 / 重试统一走 notifier 的 refresh
    Future<void> onRefresh() =>
        ref.read(homeBannerProvider.notifier).refresh();

    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        // 登出入口:清 token 回未登录态,并手动跳回登录页
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '登出',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/dialog/app_toast.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/result.dart';
import '../../../core/widget/app_network_image.dart';
import '../../../core/widget/async_view.dart';
import '../../auth/auth_provider.dart';
import '../model/banner.dart';
import '../provider/home_banner_provider.dart';

/// 首页列表与下拉刷新。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(homeBannerProvider);
    Future<void> onRefresh() async {
      try {
        await ref.refresh(homeBannerProvider.future);
      } catch (_) {
        // 失败已由 AsyncView 展示。
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('探索'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '登出',
            onPressed: () async {
              final result = await ref
                  .read(authStateProvider.notifier)
                  .logout();
              if (!context.mounted) return;
              switch (result) {
                case Success():
                  context.go(RoutePaths.login);
                case Failure(:final error):
                  AppToast.error(error.message);
              }
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
            physics: const AlwaysScrollableScrollPhysics(),
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

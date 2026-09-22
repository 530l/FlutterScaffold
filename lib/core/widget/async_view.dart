import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/app_exception.dart';
import '../utils/logger.dart';
import 'state_views.dart';

/// AsyncValue 驱动的三态通用视图:统一处理 加载中 / 错误 / 数据
///
/// ```dart
/// AsyncView<List<Item>>(
///   value: ref.watch(itemListProvider),
///   onRetry: () => ref.invalidate(itemListProvider),
///   dataBuilder: (items) => ListView(children: [for (final e in items) ItemTile(e)]),
/// )
/// ```
///
/// 关于 skipLoadingOnReload / keepPrevious(从简处理):
/// - 内部使用 riverpod 3 的 `AsyncValue.when` 默认策略:
///   `skipLoadingOnRefresh = true`:Ref.refresh / Ref.invalidate 触发的刷新
///   不回到加载态,直接沿用上一次数据(即 keepPrevious 效果);
///   `skipLoadingOnReload = false`:Ref.watch 依赖变化触发的重新加载
///   会回到加载态。
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.dataBuilder,
    this.onRetry,
  });

  /// riverpod 异步快照(来自 ref.watch 某 provider)
  final AsyncValue<T> value;

  /// 数据就绪时的内容构建函数
  final Widget Function(T data) dataBuilder;

  /// 失败重试回调,非空时错误态展示"重试"按钮
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const LoadingView(),
      error: (error, stackTrace) {
        // 错误详情进日志,界面只展示面向用户的文案
        Logger.w('AsyncView 加载失败: $error');
        return ErrorView(
          message: error is AppException ? error.message : '加载失败',
          onRetry: onRetry,
        );
      },
      data: dataBuilder,
    );
  }
}

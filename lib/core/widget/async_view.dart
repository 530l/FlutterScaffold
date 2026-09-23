import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

import '../network/app_exception.dart';
import '../utils/logger.dart';
import 'state_views.dart';

/// AsyncState(signals)驱动的四态通用视图:统一处理 加载中 / 空数据 / 错误 / 数据
///
/// ```dart
/// AsyncView<List<Item>>(
///   value: itemListSignal.value,
///   onRetry: () => itemListSignal.reload(),
///   dataBuilder: (items) => ListView(children: [for (final e in items) ItemTile(e)]),
/// )
/// ```
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.dataBuilder,
    this.onRetry,
    this.isEmpty,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  /// signals 异步状态(来自某信号的 .value)
  final AsyncState<T> value;

  /// 数据就绪且非空时的内容构建函数
  final Widget Function(T data) dataBuilder;

  /// 失败或空态重试回调,非空时错误/空态展示"重试/刷新"按钮
  final VoidCallback? onRetry;

  /// 自定义判空函数;若不传且 [T] 为 [Iterable],默认检查 `data.isEmpty`
  final bool Function(T data)? isEmpty;

  /// 自定义空态构建函数,默认使用 [EmptyView]
  final Widget Function()? emptyBuilder;

  /// 自定义加载态构建函数,默认使用 [LoadingView]
  final Widget Function()? loadingBuilder;

  /// 自定义错误态构建函数,默认使用 [ErrorView]
  final Widget Function(Object error)? errorBuilder;

  /// 辅助包裹:确保占位状态支持下拉刷新手势(兼容外层 RefreshIndicator)
  Widget _wrapScrollable(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 注意:AsyncData / AsyncError 必须写在 AsyncLoading 之前匹配,
    // 否则 Refreshing/Reloading 子类(同时实现了 AsyncLoading)会先命中
    // loading 分支,导致刷新期间丢失旧数据/旧错误
    return switch (value) {
      AsyncData<T>(:final value) => _buildData(value),
      AsyncError<T>(:final error) => _buildError(error),
      _ => _wrapScrollable(loadingBuilder?.call() ?? const LoadingView()),
    };
  }

  /// 数据态构建:内部判空,空走 [EmptyView],非空走 [dataBuilder]
  Widget _buildData(T data) {
    final isDataEmpty =
        isEmpty?.call(data) ?? (data is Iterable && data.isEmpty);
    if (isDataEmpty) {
      return _wrapScrollable(
        emptyBuilder?.call() ?? EmptyView(onRetry: onRetry),
      );
    }
    return dataBuilder(data);
  }

  /// 错误态构建:错误详情进日志,界面只展示面向用户的文案
  Widget _buildError(Object error) {
    Logger.w('AsyncView 加载失败: $error');
    return _wrapScrollable(
      errorBuilder?.call(error) ??
          ErrorView(
            message: error is AppException ? error.message : '加载失败',
            onRetry: onRetry,
          ),
    );
  }
}

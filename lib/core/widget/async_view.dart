import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/app_exception.dart';
import 'state_views.dart';

/// 统一展示加载、空数据、错误和内容。
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

  final AsyncValue<T> value;

  final Widget Function(T data) dataBuilder;

  final VoidCallback? onRetry;

  final bool Function(T data)? isEmpty;

  final Widget Function()? emptyBuilder;

  final Widget Function()? loadingBuilder;

  final Widget Function(Object error)? errorBuilder;

  /// 让占位状态也支持下拉刷新。
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
    return value.when(
      // 手动刷新保留旧内容,依赖变化时重新显示加载态。
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: false,
      data: _buildData,
      error: (error, stackTrace) => _buildError(error),
      loading: () =>
          _wrapScrollable(loadingBuilder?.call() ?? const LoadingView()),
    );
  }

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

  Widget _buildError(Object error) {
    return _wrapScrollable(
      errorBuilder?.call(error) ??
          ErrorView(
            message: error is AppException ? error.message : '加载失败',
            onRetry: onRetry,
          ),
    );
  }
}

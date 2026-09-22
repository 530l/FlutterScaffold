/// 全局状态占位组件:加载中 / 空数据 / 加载失败
///
/// 三个组件均占满父容器可用空间并居中展示,
/// 视觉直接复用 TDesign 原生组件(TDLoading / TDEmpty),不做二次封装。
library;

import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 加载中占位视图
///
/// ```dart
/// if (loading) const LoadingView(),
/// ```
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.text = '加载中…'});

  /// 加载文案,传 null 时仅展示加载图标
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TDLoading(
        size: TDLoadingSize.large,
        icon: TDLoadingIcon.circle,
        text: text,
      ),
    );
  }
}

/// 空数据占位视图
///
/// 传入 [onRetry] 时展示"刷新"操作按钮(TDEmpty 内置 TDButton)。
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.message = '暂无数据',
    this.retryText = '刷新',
    this.onRetry,
  });

  /// 空态描述文案
  final String message;

  /// 操作按钮文案,仅 [onRetry] 非空时展示
  final String retryText;

  /// 重试回调,为 null 时不展示操作按钮
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TDEmpty(
        type:
            onRetry == null ? TDEmptyType.plain : TDEmptyType.operation,
        icon: TDIcons.info_circle_filled,
        emptyText: message,
        operationText: retryText,
        onTapEvent: onRetry,
      ),
    );
  }
}

/// 加载失败占位视图
///
/// 传入 [onRetry] 时展示"重试"操作按钮(TDEmpty 内置 TDButton)。
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.message = '加载失败',
    this.retryText = '重试',
    this.onRetry,
  });

  /// 错误描述文案
  final String message;

  /// 操作按钮文案,仅 [onRetry] 非空时展示
  final String retryText;

  /// 重试回调,为 null 时不展示操作按钮
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TDEmpty(
        type:
            onRetry == null ? TDEmptyType.plain : TDEmptyType.operation,
        icon: TDIcons.error_circle_filled,
        emptyText: message,
        operationText: retryText,
        onTapEvent: onRetry,
      ),
    );
  }
}

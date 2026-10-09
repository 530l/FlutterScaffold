import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 加载占位。
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.text = '加载中…'});

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

/// 空数据占位。
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.message = '暂无数据',
    this.retryText = '刷新',
    this.onRetry,
  });

  final String message;

  final String retryText;

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TDEmpty(
        type: onRetry == null ? TDEmptyType.plain : TDEmptyType.operation,
        icon: TDIcons.info_circle_filled,
        emptyText: message,
        operationText: retryText,
        onTapEvent: onRetry,
      ),
    );
  }
}

/// 错误占位。
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.message = '加载失败',
    this.retryText = '重试',
    this.onRetry,
  });

  final String message;

  final String retryText;

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TDEmpty(
        type: onRetry == null ? TDEmptyType.plain : TDEmptyType.operation,
        icon: TDIcons.error_circle_filled,
        emptyText: message,
        operationText: retryText,
        onTapEvent: onRetry,
      ),
    );
  }
}

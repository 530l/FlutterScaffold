import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 统一底部弹层样式,默认最高为屏幕的 85%。
abstract final class AppBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    double? maxHeight,
  }) {
    final theme = TDTheme.of(context);
    final effectiveMaxHeight =
        maxHeight ?? MediaQuery.sizeOf(context).height * 0.85;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: effectiveMaxHeight),
      backgroundColor: theme.bgColorContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(theme.radiusExtraLarge),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => SafeArea(top: false, child: child),
    );
  }
}

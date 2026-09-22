import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 全局底部弹层统一入口
///
/// 基于 [showModalBottomSheet] 包装,统一圆角、背景色与最大高度约束,
/// 取色走 TDTheme 令牌,自动适配明暗主题。
abstract final class AppBottomSheet {
  /// 底部弹层
  ///
  /// [maxHeight] 内容最大高度,不传时默认取屏幕高度的 85%;
  /// 内容超出时由调用方在 child 内部自行处理滚动。
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    double? maxHeight,
  }) {
    final theme = TDTheme.of(context);
    // 默认最大高度:屏幕 85%,避免内容把弹层撑成全屏
    final effectiveMaxHeight =
        maxHeight ?? MediaQuery.sizeOf(context).height * 0.85;
    return showModalBottomSheet<T>(
      context: context,
      // 打开高度限制开关,让高度完全由我们传入的 constraints 接管
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: effectiveMaxHeight),
      backgroundColor: theme.bgColorContainer,
      // 统一顶部大圆角
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(theme.radiusExtraLarge),
        ),
      ),
      // 裁剪越界内容,防止子内容盖过圆角
      clipBehavior: Clip.antiAlias,
      builder: (_) => SafeArea(
        // 弹层贴底,只需避开底部安全区(手势条等)
        top: false,
        child: child,
      ),
    );
  }
}

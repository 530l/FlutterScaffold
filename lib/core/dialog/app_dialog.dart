import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 确认弹窗与自定义弹窗。
abstract final class AppDialog {
  /// 确认返回 true,取消或关闭返回 false。
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? content,
    String confirmText = '确定',
    String cancelText = '取消',
    bool danger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = TDTheme.of(dialogContext);
        return TDAlertDialog(
          title: title,
          titleColor: theme.fontGyColor1,
          content: content,
          contentColor: theme.fontGyColor2,
          backgroundColor: theme.bgColorContainer,
          radius: theme.radiusExtraLarge,
          leftBtn: TDDialogButtonOptions(
            title: cancelText,
            theme: TDButtonTheme.light,
            action: () => Navigator.pop(dialogContext, false),
          ),
          rightBtn: TDDialogButtonOptions(
            title: confirmText,
            theme: danger ? TDButtonTheme.danger : TDButtonTheme.primary,
            action: () => Navigator.pop(dialogContext, true),
          ),
        );
      },
    );
    return result ?? false;
  }

  static Future<T?> show<T>(BuildContext context, {required Widget child}) {
    return showDialog<T>(context: context, builder: (_) => child);
  }
}

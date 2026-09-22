import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 全局 Toast 统一入口
///
/// 基于 SmartDialog.showToast 实现,不依赖 BuildContext,
/// 任意层级(包括网络层、ViewModel)都能直接调用。
/// 前提:App 根节点已通过 FlutterSmartDialog.init() 完成接线。
abstract final class AppToast {
  /// 纯文本提示
  static Future<void> show(String msg) => SmartDialog.showToast(msg);

  /// 成功提示:绿色对勾图标 + 文案
  static Future<void> success(String msg) => SmartDialog.showToast(
        msg,
        builder: (_) =>
            _IconToast(msg: msg, icon: TDIcons.check_circle_filled, isSuccess: true),
      );

  /// 错误提示:红色叉形图标 + 文案
  static Future<void> error(String msg) => SmartDialog.showToast(
        msg,
        builder: (_) => _IconToast(
            msg: msg, icon: TDIcons.close_circle_filled, isSuccess: false),
      );
}

/// 带图标的 toast 内容(成功/失败共用)
class _IconToast extends StatelessWidget {
  const _IconToast({
    required this.msg,
    required this.icon,
    required this.isSuccess,
  });

  /// 提示文案
  final String msg;

  /// 图标
  final IconData icon;

  /// 是否成功样式:决定图标取成功色还是错误色
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final theme = TDTheme.of(context);
    // 在 overlay 的 context 下取主题色,保证明暗主题取色正确
    final iconColor =
        isSuccess ? theme.successNormalColor : theme.errorNormalColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        // 深色半透明底,明暗主题下观感一致
        color: theme.grayColor14.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(theme.radiusExtraLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: iconColor),
          const SizedBox(height: 12),
          Text(
            msg,
            textAlign: TextAlign.center,
            // overlay 场景下显式指定样式,避免继承 Material 默认字体样式
            style: TextStyle(
              color: theme.whiteColor1,
              fontSize: 15,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

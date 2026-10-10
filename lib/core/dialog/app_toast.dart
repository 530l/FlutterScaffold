import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 无需 context 的全局消息提示。
abstract final class AppToast {
  static Future<void> success(String msg) => SmartDialog.showToast(
    msg,
    builder: (_) => _IconToast(
      msg: msg,
      icon: TDIcons.check_circle_filled,
      isSuccess: true,
    ),
  );

  static Future<void> error(String msg) => SmartDialog.showToast(
    msg,
    builder: (_) => _IconToast(
      msg: msg,
      icon: TDIcons.close_circle_filled,
      isSuccess: false,
    ),
  );
}

class _IconToast extends StatelessWidget {
  const _IconToast({
    required this.msg,
    required this.icon,
    required this.isSuccess,
  });

  final String msg;

  final IconData icon;

  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final theme = TDTheme.of(context);
    final iconColor = isSuccess
        ? theme.successNormalColor
        : theme.errorNormalColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
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

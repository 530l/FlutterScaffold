import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 全局弹窗统一入口:中部模态弹窗
///
/// 基于 Flutter 原生 [showDialog] 做路由与语义包装,
/// 内容组件优先复用 TDesign 现成的 [TDAlertDialog](自带标题/内容/双按钮布局),
/// 取色全部走 TDTheme 令牌,自动适配明暗主题。
abstract final class AppDialog {
  /// 通用确认弹窗(签名是其他模块的依赖契约,禁止改动)
  ///
  /// 返回 true 表示用户点击了确认按钮;
  /// 取消按钮、点击遮罩、系统返回键统一返回 false。
  ///
  /// [danger] 为 true 时确认按钮使用错误色(红色),适用于删除等危险操作。
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? content,
    String confirmText = '确定',
    String cancelText = '取消',
    bool danger = false,
  }) async {
    final theme = TDTheme.of(context);
    // 复用 show 弹出;遮罩关闭/返回键得到 null,按"取消"处理
    final result = await show<bool>(
      context,
      child: TDAlertDialog(
        title: title,
        titleColor: theme.fontGyColor1,
        content: content,
        contentColor: theme.fontGyColor2,
        backgroundColor: theme.bgColorContainer,
        radius: theme.radiusExtraLarge,
        // 左侧弱按钮:取消
        leftBtn: TDDialogButtonOptions(
          title: cancelText,
          theme: TDButtonTheme.light,
          action: () => Navigator.pop(context, false),
        ),
        // 右侧强按钮:危险操作用红色,普通操作用品牌主色
        rightBtn: TDDialogButtonOptions(
          title: confirmText,
          theme: danger ? TDButtonTheme.danger : TDButtonTheme.primary,
          action: () => Navigator.pop(context, true),
        ),
      ),
    );
    return result ?? false;
  }

  /// 自定义内容弹窗:原生 showDialog 的语义化包装
  ///
  /// [child] 为任意自定义内容,返回值由 child 内部 Navigator.pop(context, value) 决定。
  static Future<T?> show<T>(BuildContext context, {required Widget child}) {
    return showDialog<T>(
      context: context,
      builder: (_) => child,
    );
  }
}

import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

/// 全局 Loading 统一入口
///
/// 基于 SmartDialog 实现,不依赖 BuildContext,
/// 网络请求拦截器、任意 ViewModel 都能直接调用。
/// 前提:App 根节点已通过 FlutterSmartDialog.init() 完成接线。
abstract final class AppLoading {
  /// 展示全局加载弹窗
  ///
  /// [text] 不传时默认显示"加载中..."。
  static Future<void> show({String? text}) {
    return SmartDialog.showLoading(msg: text ?? '加载中...');
  }

  /// 关闭全局加载弹窗
  ///
  /// 只定向关闭 loading,不影响同时存在的 toast / 自定义弹窗。
  static Future<void> dismiss() {
    return SmartDialog.dismiss(status: SmartStatus.loading);
  }
}

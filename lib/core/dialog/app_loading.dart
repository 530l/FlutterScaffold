import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

/// 无需 context 的全局加载提示。
abstract final class AppLoading {
  static Future<void> show({String? text}) {
    return SmartDialog.showLoading(msg: text ?? '加载中...');
  }

  static Future<void> dismiss() {
    return SmartDialog.dismiss(status: SmartStatus.loading);
  }
}

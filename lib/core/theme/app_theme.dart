import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 全局主题:以 TDesign 为设计基座,色彩/字体令牌统一走 TDTheme
///
/// 说明:TDesign 自带完整设计令牌,不再单独维护 AppColors,
/// 业务侧需要取色时用 `TDTheme.of(context).brandColor` 等即可。
abstract final class AppTheme {
  static final TDThemeData _td = TDThemeData.defaultData();

  /// 亮色主题(TD 侧为可空 getter,兜底 Material 亮色,实际不会走到)
  static ThemeData get light => _td.systemThemeDataLight ?? ThemeData.light();

  /// 暗色主题
  static ThemeData get dark => _td.systemThemeDataDark ?? ThemeData.dark();
}

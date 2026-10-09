import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 使用 TDesign 的明暗主题。
abstract final class AppTheme {
  static final TDThemeData _td = TDThemeData.defaultData();

  static ThemeData get light => _td.systemThemeDataLight ?? ThemeData.light();

  static ThemeData get dark => _td.systemThemeDataDark ?? ThemeData.dark();
}

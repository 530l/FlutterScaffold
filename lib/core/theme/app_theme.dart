import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 用同一套语义色定制 TDesign 和 Material,让输入、弹窗与页面保持一致。
abstract final class AppTheme {
  static final TDThemeData _td = TDThemeData.fromJson(
    'slow',
    jsonEncode({
      'slow': {'color': _colors(false)},
      'slowDark': {'color': _colors(true)},
    }),
  )!;

  static Map<String, String> _colors(bool dark) => {
    'brandNormalColor': dark ? '#9BBBA7' : '#426B57',
    'brandHoverColor': dark ? '#B5CFBF' : '#365B49',
    'brandClickColor': dark ? '#86A991' : '#2D4D3C',
    'brandLightColor': dark ? '#283D32' : '#EAF0E8',
    'brandFocusColor': dark ? '#344D3D' : '#DBE7D9',
    'brandDisabledColor': dark ? '#425A48' : '#BCD0BE',
    'bgColorPage': dark ? '#171E1A' : '#F5F6F0',
    'bgColorContainer': dark ? '#222C25' : '#FFFFFF',
    'bgColorSecondaryContainer': dark ? '#2C382F' : '#EFF2EB',
    'bgColorContainerHover': dark ? '#2C382F' : '#EFF2EB',
    'bgColorContainerActive': dark ? '#344338' : '#E2E9DD',
    'textColorPrimary': dark ? '#E8EEE8' : '#263B30',
    'textColorSecondary': dark ? '#B2BFB4' : '#6D7B70',
    'textColorPlaceholder': dark ? '#829488' : '#879489',
    'textDisabledColor': dark ? '#5A6C5F' : '#BCC4BC',
    'textColorAnti': dark ? '#171E1A' : '#FFFFFF',
    'fontWhColor1': dark ? '#171E1A' : '#FFFFFF',
    'fontGyColor1': dark ? '#E8EEE8' : '#263B30',
    'fontGyColor2': dark ? '#B2BFB4' : '#6D7B70',
    'fontGyColor3': dark ? '#829488' : '#879489',
    'fontGyColor4': dark ? '#5A6C5F' : '#BCC4BC',
    'componentBorderColor': dark ? '#3B493F' : '#E3E8DE',
    'componentStrokeColor': dark ? '#3B493F' : '#E3E8DE',
    'successNormalColor': dark ? '#9BBBA7' : '#426B57',
    'successLightColor': dark ? '#283D32' : '#EAF0E8',
    'errorNormalColor': dark ? '#E69C8B' : '#B95F50',
    'warningNormalColor': dark ? '#D5B783' : '#A9783D',
  };

  static ThemeData _material(bool dark) {
    final td = dark ? _td.dark! : _td;
    final scheme = ColorScheme.fromSeed(
      seedColor: td.brandNormalColor,
      brightness: dark ? Brightness.dark : Brightness.light,
      surface: td.bgColorContainer,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: [td],
      scaffoldBackgroundColor: td.bgColorPage,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: td.textColorPrimary,
        displayColor: td.textColorPrimary,
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: td.bgColorPage,
        foregroundColor: td.textColorPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerColor: td.componentBorderColor,
      iconTheme: IconThemeData(color: td.brandNormalColor),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: td.bgColorContainer,
      ),
    );
  }

  // 主题不可变，复用实例，切换模式时无需重新装配整套主题。
  static final ThemeData light = _material(false);
  static final ThemeData dark = _material(true);
}

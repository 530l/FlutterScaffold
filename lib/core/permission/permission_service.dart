import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show BuildContext;
// 说明:status / request 定义在 PermissionActions 扩展上,
// isGranted / isLimited / isPermanentlyDenied 定义在 PermissionStatusGetters 扩展上,
// 用 show 限定可见名称,防止 permission_handler 的类型泄漏到本文件之外
import 'package:permission_handler/permission_handler.dart'
    show Permission, PermissionActions, PermissionStatusGetters, openAppSettings;

import '../dialog/app_dialog.dart';
import '../utils/logger.dart';

/// 业务侧权限枚举:对外隔离 permission_handler 的类型,
/// 业务代码只依赖此枚举,后续替换权限库时仅需改动 [PermissionService]
enum AppPermission {
  /// 相机(拍照 / 扫码)
  camera,

  /// 相册(读取照片,Android 13+ 对应 READ_MEDIA_IMAGES)
  photos,

  /// 定位(仅使用期间)
  locationWhenInUse,

  /// 麦克风(录音 / 语音输入)
  microphone,
}

/// 权限封装服务:统一处理"已授权 / 首次请求 / 永久拒绝"三种流程
///
/// 用法:
/// ```dart
/// final ok = await PermissionService.request(
///   context,
///   AppPermission.camera,
///   rationale: '需要使用相机进行拍照,请允许',
/// );
/// ```
abstract final class PermissionService {
  /// 业务枚举 → permission_handler 权限的映射(集中收口,禁止业务直接触碰)
  static Permission _map(AppPermission permission) => switch (permission) {
        AppPermission.camera => Permission.camera,
        AppPermission.photos => Permission.photos,
        AppPermission.locationWhenInUse => Permission.locationWhenInUse,
        AppPermission.microphone => Permission.microphone,
      };

  /// 各权限的中文名称(用于弹窗文案与日志)
  static String _label(AppPermission permission) => switch (permission) {
        AppPermission.camera => '相机',
        AppPermission.photos => '相册',
        AppPermission.locationWhenInUse => '定位',
        AppPermission.microphone => '麦克风',
      };

  /// 当前是否已授权(granted 或 limited 均视为可用)
  ///
  /// Web 端无系统权限概念,直接返回 true
  static Future<bool> isGranted(AppPermission permission) async {
    if (kIsWeb) return true;
    final status = await _map(permission).status;
    return status.isGranted || status.isLimited;
  }

  /// 请求权限,返回是否可用于业务(granted / limited 视为可用)
  ///
  /// 流程:
  /// 1. Web 端直接放行;
  /// 2. 已授权直接通过;
  /// 3. 已永久拒绝 → 弹窗引导前往系统设置开启;
  /// 4. [rationale] 非空且非永久拒绝 → 先弹说明确认,用户同意后再发起系统请求;
  /// 5. 请求后若变为永久拒绝(Android 二次拒绝场景)→ 同样引导前往设置
  static Future<bool> request(
    BuildContext context,
    AppPermission permission, {
    String? rationale,
  }) async {
    // Web 端无系统权限弹窗,直接视为可用
    if (kIsWeb) return true;

    final handler = _map(permission);

    // 第一步:已授权(granted / limited)直接通过
    final status = await handler.status;
    if (status.isGranted || status.isLimited) return true;

    // 第二步:永久拒绝(iOS 查询即返回该状态)→ 引导去系统设置
    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      return _guideToSettings(context, permission);
    }

    // 第三步:请求前先弹说明(非永久拒绝且 rationale 非空)
    if (rationale != null && rationale.isNotEmpty) {
      if (!context.mounted) return false;
      final confirmed = await AppDialog.confirm(
        context,
        title: '权限申请说明',
        content: rationale,
      );
      if (!confirmed) return false;
    }

    // 第四步:发起系统权限请求
    final result = await handler.request();
    if (result.isGranted || result.isLimited) return true;

    // 第五步:请求结果为永久拒绝(Android 上二次拒绝后才会出现)→ 引导去设置
    if (result.isPermanentlyDenied) {
      if (!context.mounted) return false;
      return _guideToSettings(context, permission);
    }

    Logger.d('权限请求被拒绝: ${_label(permission)}($result)');
    return false;
  }

  /// 永久拒绝后的引导:确认弹窗 → 跳转系统应用设置页
  ///
  /// 返回值表示"是否成功打开设置页"(不代表权限已授予,用户开启后返回应用需自行复查)
  static Future<bool> _guideToSettings(
    BuildContext context,
    AppPermission permission,
  ) async {
    final go = await AppDialog.confirm(
      context,
      title: '需要在系统设置中开启权限',
      content:
          '「${_label(permission)}」权限已被拒绝且无法再次弹出系统申请,请前往系统设置手动开启后返回应用重试。',
    );
    if (!go) return false;

    // openAppSettings 返回设置页是否成功拉起
    final opened = await openAppSettings();
    if (!opened) {
      Logger.w('打开系统设置页失败: ${_label(permission)}');
    }
    return opened;
  }
}

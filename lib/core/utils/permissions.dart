import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

/// 权限工具类:只做「检查 / 申请」两件事,granted 与 limited 均视为可用
///
/// 用法:
/// ```dart
/// if (!await Permissions.request(Permission.camera)) {
///   // 未拿到权限,业务自行提示或降级处理
/// }
/// ```
///
/// TODO 扩展点:需要「申请前说明弹窗 / 永久拒绝后引导去系统设置」等流程时,再在此补充。
abstract final class Permissions {
  /// 检查权限是否已授权(不弹系统申请框)
  ///
  /// Web 端无系统权限概念,直接放行
  static Future<bool> isGranted(Permission permission) async {
    if (kIsWeb) return true;
    final status = await permission.status;
    return status.isGranted || status.isLimited;
  }

  /// 申请权限,返回是否可用于业务
  static Future<bool> request(Permission permission) async {
    if (kIsWeb) return true;
    final status = await permission.request();
    return status.isGranted || status.isLimited;
  }
}

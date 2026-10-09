import 'package:permission_handler/permission_handler.dart';

/// 检查或申请权限,limited 视为可用。
abstract final class Permissions {
  static Future<bool> isGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted || status.isLimited;
  }

  static Future<bool> request(Permission permission) async {
    final status = await permission.request();
    return status.isGranted || status.isLimited;
  }
}

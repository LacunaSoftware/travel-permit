import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travel_permit_reader/api/notification_api.dart';
import 'package:travel_permit_reader/util/page_util.dart';

class PermissionUtil {
  static Future<bool> checkCameraPermission(BuildContext context, String requiredMessage) async {
    var status = await Permission.camera.status;
    if (!status.isGranted && !await Permission.camera.request().isGranted) {
      PageUtil.showAppDialog(
        context,
        'Câmera necessária',
        requiredMessage,
        positiveButton: ButtonAction('Ir para configurações', () => openAppSettings()),
      );
      return false;
    }
    return true;
  }

  static Future<bool> checkStoragePermission() async {
    final hasPerms = await Permission.storage.status.isGranted || await _isStoragePermissionUnnecessary() || await Permission.storage.request().isGranted;

    if (!hasPerms) {
      NotificationApi.showNotification(
        title: 'Permission failure.',
        body: 'Failed to download file. The app doesn\'t have file managing privileges.',
      );
    }

    return hasPerms;
  }

  static Future<bool> _isStoragePermissionUnnecessary() async {
    if (!Platform.isAndroid) {
      return false;
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    return androidInfo.version.sdkInt >= 29;
  }
}

import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travel_permit_reader/util/page_util.dart';

class PermissionUtil {
  static Future<bool> checkCameraPermission(
      BuildContext context, String requiredMessage) async {
    var status = await Permission.camera.status;
    if (!status.isGranted && await Permission.camera.request().isGranted) {
      PageUtil.showAppDialog(context, 'Câmera necessária', requiredMessage,
          positiveButton:
              ButtonAction('Ir para configurações', () => openAppSettings()));
      return false;
    }
    return true;
  }
}

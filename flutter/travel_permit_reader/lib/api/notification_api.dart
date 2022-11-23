import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class PendingNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  PendingNotification(this.id, this.title, this.body, this.payload);
}

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final _settings = NotificationDetails(
    android: AndroidNotificationDetails(
      'cnb-aev',
      'Colégio Notarial do Brasil',
      channelDescription: 'AEV - Autorização Eletrônica de Viagem',
      importance: Importance.max,
    ),
    iOS: IOSNotificationDetails(threadIdentifier: 'cnb-aev'),
  );

  static final List<PendingNotification> toNotify = [];
  static PermissionStatus _permissionStatus;

  static Future init({bool initScheduled = false}) async {
    final settings = InitializationSettings(android: AndroidInitializationSettings('@drawable/notif_icon'), iOS: IOSInitializationSettings());

    await _notifications.initialize(settings, onSelectNotification: (payload) async => onClickedNotification(payload));

    updatePermissionState(isReleasePending: false);
  }

  static void onClickedNotification(String payload) {
    if (payload != null) OpenFilex.open(payload);
  }

  static Future updatePermissionState({bool isReleasePending = true}) async {
    _permissionStatus = await Permission.notification.status;

    if (isReleasePending) tryReleasePending();
  }

  static void tryReleasePending() {
    if (_permissionStatus == PermissionStatus.granted || _permissionStatus == PermissionStatus.limited) {
      for (var i = 0; i < toNotify.length; i++) {
        final notif = toNotify.removeAt(0);
        _notifications.show(notif.id, notif.title, notif.body, _settings, payload: notif.payload);
      }
    }
  }

  static Future showNotification({
    int id = 0,
    String title,
    String body,
    String payload,
  }) async {
    if (_permissionStatus != PermissionStatus.granted && _permissionStatus != PermissionStatus.limited) {
      toNotify.add(PendingNotification(id, title, body, payload));
      // TODO: Show something?;
    } else {
      _notifications.show(id, title, body, _settings, payload: payload);
    }
  }
}

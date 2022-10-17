import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:open_file/open_file.dart';

class PendingNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  PendingNotification({this.id, this.title, this.body, this.payload});
}

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final _settings = NotificationDetails(
      AndroidNotificationDetails('0', 'Colégio Notarial do Brasil',
          'AEV - Autorização Eletrônica de Viagem',
          importance: Importance.Max),
      IOSNotificationDetails());

  static final List<PendingNotification> toNotify = [];
  static PermissionStatus _permissionStatus;

  static Future init({bool initScheduled = false}) async {
    final settings = InitializationSettings(
        AndroidInitializationSettings('@mipmap/ic_launcher'),
        IOSInitializationSettings());

    await _notifications.initialize(settings,
        onSelectNotification: (payload) async =>
            onClickedNotification(payload));

    updatePermissionState(isReleasePending: false);
  }

  static void onClickedNotification(String payload) {
    if (payload != null) OpenFile.open(payload);
  }

  static Future updatePermissionState({bool isReleasePending = true}) async {
    _permissionStatus =
        await NotificationPermissions.getNotificationPermissionStatus();

    if (isReleasePending) tryReleasePending();
  }

  static void tryReleasePending() {
    if (_permissionStatus == PermissionStatus.granted ||
        _permissionStatus == PermissionStatus.provisional) {
      for (var i = 0; i < toNotify.length; i++) {
        final notif = toNotify.removeAt(0);
        _notifications.show(notif.id, notif.title, notif.body, _settings,
            payload: notif.payload);
      }
    }
  }

  static Future showNotification({
    int id = 0,
    String title,
    String body,
    String payload,
  }) async {
    if (_permissionStatus == PermissionStatus.denied ||
        _permissionStatus == PermissionStatus.unknown) {
      toNotify.add(PendingNotification(
          id: id, title: title, body: body, payload: payload));

      await NotificationPermissions.requestNotificationPermissions(
          iosSettings: const NotificationSettingsIos(
              sound: true, badge: true, alert: true));
    } else {
      _notifications.show(id, title, body, _settings, payload: payload);
    }
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:open_filex/open_filex.dart';
import 'package:travel_permit_reader/util/page_util.dart';

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
    _permissionStatus = await NotificationPermissions.getNotificationPermissionStatus();

    if (isReleasePending) tryReleasePending();
  }

  static void tryReleasePending() {
    if (_permissionStatus == PermissionStatus.granted || _permissionStatus == PermissionStatus.provisional) {
      for (var i = 0; i < toNotify.length; i++) {
        final notif = toNotify.removeAt(0);
        _notifications.show(notif.id, notif.title, notif.body, _settings, payload: notif.payload);
      }
    }
  }

  static Future ensureHasPermissions(BuildContext context, Future<dynamic> Function() then) async {
    if (_permissionStatus != PermissionStatus.denied && _permissionStatus != PermissionStatus.unknown) {
      await then();
      return;
    }

    final positiveButton = () async {
      await NotificationPermissions.requestNotificationPermissions(iosSettings: const NotificationSettingsIos(sound: true, badge: true, alert: true));
      await then();
    };

    PageUtil.showAppDialog(context, "Permissão de notificação necessária.", "Para funcionar corretamente, o aplicativo precisa de permissões para notificar. Clique no botão abaixo para ser redirecionada(o) para as configurações.", positiveButton: ButtonAction("Redirecionar", positiveButton));
  }

  static Future showNotification({
    int id = 0,
    String title,
    String body,
    String payload,
  }) async {
    if (_permissionStatus == PermissionStatus.denied || _permissionStatus == PermissionStatus.unknown) {
      toNotify.add(PendingNotification(id, title, body, payload));
      await NotificationPermissions.requestNotificationPermissions(iosSettings: const NotificationSettingsIos(sound: true, badge: true, alert: true));
    } else {
      _notifications.show(id, title, body, _settings, payload: payload);
    }
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationServices {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final onNotifications = BehaviorSubject<String?>();

  AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings("notificationicon");
  var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {});

  Future init({bool initSchedule = false}) async {
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {
      onNotifications.add(payload.payload);
    });
  }

  NotificationDetails notificationDetails() {
    // final styleInformation = ();

    return NotificationDetails(
      android: AndroidNotificationDetails(
        "tasks",
        'Tasks',
        importance: Importance.max,
        // styleInformation: styleInformation,
      ),
    );
  }

  Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    print("showNotification");

    return notificationsPlugin.show(
      id,
      title,
      body,
      payload: payload,
      notificationDetails(),
    );
  }

  Future scheduleNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required DateTime dateTime,
  }) async {
    print("scheduleNotification");

    return notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        dateTime,
        tz.local,
      ),
      notificationDetails(),
      payload: payload,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future cancelScheduledNotification({
    required int id,
  }) async {
    print("cancelScheduledNotification");
    notificationsPlugin.cancel(
      id,
    );
  }
}

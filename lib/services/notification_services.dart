import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:task_app/services/shared_preferences.dart';

class NotificationServices {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final onNotifications = BehaviorSubject<String?>();

  AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings("notificationicon");
  var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {});

  Future init({bool initSchedule = false}) async {
    var status = Permission.notification.status;

    if (await status.isDenied) {
      Permission.notification.request();
    }
    if (await status.isPermanentlyDenied || await status.isRestricted) {
      openAppSettings();
    }

    if (await status.isGranted) {
      var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await notificationsPlugin.initialize(initializationSettings,
          onDidReceiveNotificationResponse: (payload) async {
        onNotifications.add(payload.payload);
      });
    }
  }

  // NotificationDetails notificationDetails({required String text}) {
  //   // final styleInformation = ();
  //
  //   return NotificationDetails(
  //     android: AndroidNotificationDetails(
  //       "tasks",
  //       'Tasks',
  //       importance: Importance.max,
  //       enableLights: true,
  //       enableVibration: true,
  //       styleInformation: BigTextStyleInformation(text),
  //     ),
  //   );
  // }

  // Future showNotification({
  //   int id = 0,
  //   String? title,
  //   String? body,
  //   String? payload,
  // }) async {
  //   return notificationsPlugin.show(
  //     id,
  //     title,
  //     body,
  //     payload: payload,
  //     notificationDetails(
  //       text: body!,
  //     ),
  //   );
  // }

  // Future scheduleNotification({
  //   required int id,
  //   required String title,
  //   required String body,
  //   required String payload,
  //   required DateTime dateTime,
  // }) async {
  //   return notificationsPlugin.zonedSchedule(
  //     id,
  //     title,
  //     body,
  //     tz.TZDateTime.from(
  //       dateTime,
  //       tz.local,
  //     ),
  //     notificationDetails(text: body),
  //     payload: payload,
  //     androidAllowWhileIdle: true,
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //   );
  // }

  // Future cancelScheduledNotification({
  //   required int id,
  // }) async {
  //   notificationsPlugin.cancel(
  //     id,
  //   );
  // }

  // Future cancelNotification() async {
  //   await notificationsPlugin.cancelAll();
  // }

  Future createScheduledTaskNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required DateTime dateTime,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: Keys.tasksInstantChannelKey,
        title: title,
        body: body,
        wakeUpScreen: true,
        locked: true,
        notificationLayout: NotificationLayout.BigText,
        autoDismissible: true,
        displayOnBackground: true,
        displayOnForeground: true,
      ),
      schedule: NotificationCalendar.fromDate(
        date: dateTime,
        repeats: false,
      ),
    );
  }

  Future cancelTaskScheduledNotification({
    required int id,
  }) async {
    AwesomeNotifications().cancelSchedule(id);
  }

  Future cancelTasksNotification() async {
    await AwesomeNotifications().cancelAllSchedules();
  }
}

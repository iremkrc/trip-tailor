import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

//Based on: https://pub.dev/packages/flutter_local_notifications/example
class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  int id = 0;

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  final notificationDetails = const NotificationDetails(
    android: AndroidNotificationDetails('channelId', 'channelName',
        importance: Importance.max, icon: '@mipmap/ic_launcher'),
    iOS: DarwinNotificationDetails(),
    macOS: null,
  );

  Future showNotification(
      {int id = 0, String? title, String? body, String? payload}) async {
    return notificationsPlugin.show(id++, title, body, notificationDetails);
  }

  Future<void> scheduleDailyNotification(
      {int id = 0,
      String? hourAndMinute /*Like 10:30*/,
      String? title,
      String? body,
      String? payload}) async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    int? hour = int.tryParse(hourAndMinute!.substring(0, 2));
    int? minute = int.tryParse(hourAndMinute.substring(3, 5));
    if (hour == null || minute == null) {
      return;
    }

    tz.TZDateTime nextTimeToRun = _nextInstanceOfTimeOfDay(hour, minute);
    await notificationsPlugin.zonedSchedule(
        id++, title, body, nextTimeToRun, notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _nextInstanceOfTimeOfDay(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> _cancelNotification(int id) async {
    await notificationsPlugin.cancel(--id);
  }

  Future<void> _cancelNotificationWithTag(int id, tag) async {
    await notificationsPlugin.cancel(--id, tag: tag);
  }

  Future<void> _cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  Future<void> scheduleDailyNotifications(
      {List<String>? hourAndMinuteList /*Like 10:30*/,
      String? title,
      String? body,
      String? payload}) async {
    hourAndMinuteList?.forEach((hourAndMinute) {
      NotificationService().scheduleDailyNotification(
          hourAndMinute: hourAndMinute,
          title: title,
          body: body,
          payload: payload);
    });
  }

  pendingNotifications() {
    return notificationsPlugin.pendingNotificationRequests();
  }

  activeNotifications() {
    return notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.getActiveNotifications();
  }
}

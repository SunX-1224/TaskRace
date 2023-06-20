import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart';

class NotificationApi {
  static final _notification = FlutterLocalNotificationsPlugin();

  static final onNotification = BehaviorSubject<String?>();

  static Future<NotificationDetails> _notificationDetails() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
            'default_notification_channel_id', 'taskrace app notification',
            channelDescription: 'android notification channel desc',
            playSound: true,
            sound: RawResourceAndroidNotificationSound("notification"),
            importance: Importance.max,
            priority: Priority.high));
  }

  static Future init({bool initScheduled = false}) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _notification.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) async {
        onNotification.add(details.payload);
      },
    );
  }

  static Future<bool> cancelTaskNotification(int taskId) async {
    bool eligible = false;
    final notifications = await _notification.pendingNotificationRequests();
    for (var notification in notifications) {
      if ((notification.id >> 8) == taskId) {
        _notification.cancel(notification.id);
        eligible = true;
      }
    }
    return eligible;
  }

  static int generateID(int taskID, int iter) {
    return taskID << 8 | iter;
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? description,
  }) async =>
      _notification.show(id, title, description, await _notificationDetails());

  static Future showScheduledNotification({
    int id = 0,
    String? title,
    String? description,
    required DateTime scheduledDate,
  }) async {
    tz.initializeTimeZones();
    return _notification.zonedSchedule(
        id,
        title,
        description,
        TZDateTime.from(scheduledDate, getLocation('America/Detroit')),
        await _notificationDetails(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}

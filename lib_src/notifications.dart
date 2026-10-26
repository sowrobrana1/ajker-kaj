import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'models.dart';

class NotifyService {
  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    } catch (_) {}
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(
      const InitializationSettings(android: android),
    );
    final androidImpl = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  static Future<void> scheduleTask(Task task) async {
    if (task.time.isEmpty || task.done) return;
    try {
      final d = parseKey(task.date);
      final parts = task.time.split(':');
      final hh = int.parse(parts[0]);
      final mm = int.parse(parts[1]);
      var when = tz.TZDateTime(
          tz.local, d.year, d.month, d.day, hh, mm);
      if (when.isBefore(tz.TZDateTime.now(tz.local))) return;
      await plugin.zonedSchedule(
        task.id.hashCode & 0x7fffffff,
        'Ajker Kaj',
        task.title,
        when,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'ajker_kaj_tasks',
            'Task reminders',
            channelDescription: 'Reminders for scheduled tasks',
            importance: Importance.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }

  static Future<void> cancelTask(Task task) async {
    try {
      await plugin.cancel(task.id.hashCode & 0x7fffffff);
    } catch (_) {}
  }

  static Future<void> rescheduleAll(List<Task> tasks) async {
    for (final t in tasks) {
      await scheduleTask(t);
    }
  }
}

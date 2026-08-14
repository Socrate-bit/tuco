import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Schedules the daily study reminder local notification.
class ReminderService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> _init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('[ReminderService] timezone error: $e');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _initialized = true;
  }

  /// Ask the OS for notification permission (iOS prompt). Returns granted.
  static Future<bool> requestPermission() async {
    try {
      await _init();
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted =
          await ios?.requestPermissions(alert: true, badge: true, sound: true);
      debugPrint('[ReminderService] Notification permission granted: $granted');
      return granted ?? true;
    } catch (e) {
      debugPrint('[ReminderService] requestPermission error: $e');
      return false;
    }
  }

  /// Schedule (or reschedule) the daily reminder at [hour]:[minute].
  static Future<void> schedule(
      {required int hour,
      required int minute,
      required String title,
      required String body}) async {
    try {
      await _init();
      await _plugin.cancelAll();
      var when = tz.TZDateTime(
          tz.local,
          tz.TZDateTime.now(tz.local).year,
          tz.TZDateTime.now(tz.local).month,
          tz.TZDateTime.now(tz.local).day,
          hour,
          minute);
      if (when.isBefore(tz.TZDateTime.now(tz.local))) {
        when = when.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        id: 0,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: const NotificationDetails(
          iOS: DarwinNotificationDetails(),
          android: AndroidNotificationDetails('reminder', 'Daily reminder'),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('[ReminderService] Scheduled daily reminder $hour:$minute');
    } catch (e) {
      debugPrint('[ReminderService] schedule error: $e');
    }
  }

  static Future<void> cancel() async {
    try {
      await _init();
      await _plugin.cancelAll();
      debugPrint('[ReminderService] Reminder cancelled');
    } catch (e) {
      debugPrint('[ReminderService] cancel error: $e');
    }
  }
}

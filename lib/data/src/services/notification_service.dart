import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:colabhealth/core/src/utils/app_logger.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const int sleepReminderId = 1001;
  static const int wakeAlarmId = 2001;

  static const AndroidNotificationChannel _reminderChannel = AndroidNotificationChannel(
    'reminders',
    'Reminders',
    description: 'Daily sleep & activity reminders',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _alarmChannel = AndroidNotificationChannel(
    'alarms',
    'Alarms',
    description: 'Wake-up alarms',
    importance: Importance.max,
    playSound: true,
  );

  Future<void> init() async {
    try {
      tz.initializeTimeZones();

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));

      final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.createNotificationChannel(_reminderChannel);
      await androidImpl?.createNotificationChannel(_alarmChannel);
    } catch (e) {
      AppLogger.error('NotificationService.init', error: e);
    }
  }

  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    try {
      await _plugin.zonedSchedule(
        sleepReminderId,
        'Time to wind down 😴',
        'Log your sleep and get ready for bed.',
        _nextInstanceOf(time),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders',
            'Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      AppLogger.error('scheduleDailyReminder', error: e);
    }
  }

  Future<void> cancelReminder() => _plugin.cancel(sleepReminderId);

  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> showRemote({required String title, required String body}) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showWakeNotification() async {
    await _plugin.show(
      wakeAlarmId,
      '⏰ Wake up!',
      "It's time to start your day.",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarms',
          'Alarms',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: DarwinNotificationDetails(interruptionLevel: InterruptionLevel.critical),
      ),
    );
  }
}

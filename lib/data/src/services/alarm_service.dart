import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:colabhealth/core/src/utils/app_logger.dart';
import 'package:colabhealth/data/src/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> wakeAlarmCallback() async {
  await NotificationService.instance.init();
  await NotificationService.instance.showWakeNotification();
}

class AlarmService {
  AlarmService._();

  static final AlarmService instance = AlarmService._();

  Future<void> init() async {
    if (Platform.isAndroid) {
      try {
        await AndroidAlarmManager.initialize();
      } catch (e) {
        AppLogger.error('AndroidAlarmManager.initialize', error: e);
      }
    }
  }

  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) {
      return NotificationService.instance.requestPermission();
    }
    final notif = await Permission.notification.request();
    final exact = await Permission.scheduleExactAlarm.request();
    return notif.isGranted && (exact.isGranted || exact.isLimited);
  }

  Future<bool> scheduleWakeAlarm(TimeOfDay time) async {
    final when = _nextOccurrence(time);
    if (Platform.isAndroid) {
      try {
        return await AndroidAlarmManager.oneShotAt(
          when,
          NotificationService.wakeAlarmId,
          wakeAlarmCallback,
          exact: true,
          wakeup: true,
          alarmClock: true,
          rescheduleOnReboot: true,
        );
      } catch (e) {
        AppLogger.error('scheduleWakeAlarm', error: e);
        return false;
      }
    } else {

      await NotificationService.instance.scheduleDailyReminder(time);
      return true;
    }
  }

  Future<void> cancelWakeAlarm() async {
    if (Platform.isAndroid) {
      await AndroidAlarmManager.cancel(NotificationService.wakeAlarmId);
    } else {
      await NotificationService.instance.cancelReminder();
    }
  }

  DateTime _nextOccurrence(TimeOfDay time) {
    final now = DateTime.now();
    var when = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (when.isBefore(now)) when = when.add(const Duration(days: 1));
    return when;
  }
}

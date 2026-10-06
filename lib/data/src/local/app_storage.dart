import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'package:colabhealth/data/src/local/app_storage_keys.dart';

class AppStorage {
  AppStorage._();

  static final GetStorage _box = GetStorage();

  static Future<void> init() => GetStorage.init();

  static T? read<T>(String key) => _box.read<T>(key);
  static Future<void> write(String key, dynamic value) => _box.write(key, value);
  static Future<void> remove(String key) => _box.remove(key);

  static Map<String, dynamic>? readJson(String key) {
    final raw = _box.read<String>(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static List<dynamic> readJsonList(String key) {
    final raw = _box.read<String>(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  static Future<void> writeJson(String key, Object value) =>
      _box.write(key, jsonEncode(value));

  static String get uid => _box.read(AppStorageKeys.uid) ?? '';
  static bool get isLoggedIn => _box.read(AppStorageKeys.isLoggedIn) ?? false;
  static bool get onboardingDone => _box.read(AppStorageKeys.onboardingDone) ?? false;

  static Future<void> setLoggedIn(bool value) =>
      _box.write(AppStorageKeys.isLoggedIn, value);
  static Future<void> setOnboardingDone(bool value) =>
      _box.write(AppStorageKeys.onboardingDone, value);

  static int get stepTarget => _box.read(AppStorageKeys.stepTarget) ?? 8000;
  static Future<void> setStepTarget(int value) =>
      _box.write(AppStorageKeys.stepTarget, value);

  static int? get stepBaseline => _box.read<int>(AppStorageKeys.stepBaseline);

  static DateTime? get stepBaselineDate {
    final ms = _box.read<int>(AppStorageKeys.stepBaselineDate);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  static Future<void> setStepBaseline(int baseline, DateTime date) async {
    await _box.write(AppStorageKeys.stepBaseline, baseline);
    await _box.write(AppStorageKeys.stepBaselineDate, date.millisecondsSinceEpoch);
  }

  static bool get remindersOn => _box.read(AppStorageKeys.remindersOn) ?? false;
  static Future<void> setRemindersOn(bool value) =>
      _box.write(AppStorageKeys.remindersOn, value);

  static String? get avatarId => _box.read(AppStorageKeys.avatarId);
  static Future<void> setAvatarId(String id) =>
      _box.write(AppStorageKeys.avatarId, id);

  static TimeOfDay? _readTime(String key) {
    final v = _box.read<String>(key);
    if (v == null) return null;
    final parts = v.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 22,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  static TimeOfDay get bedTime =>
      _readTime(AppStorageKeys.bedTime) ?? const TimeOfDay(hour: 22, minute: 0);
  static TimeOfDay get wakeTime =>
      _readTime(AppStorageKeys.wakeTime) ?? const TimeOfDay(hour: 6, minute: 30);

  static Future<void> setBedTime(TimeOfDay t) =>
      _box.write(AppStorageKeys.bedTime, '${t.hour}:${t.minute}');
  static Future<void> setWakeTime(TimeOfDay t) =>
      _box.write(AppStorageKeys.wakeTime, '${t.hour}:${t.minute}');

  static DateTime? get lastSyncTime {
    final ms = _box.read<int>(AppStorageKeys.lastSyncTime);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  static Future<void> setLastSyncTime(DateTime t) =>
      _box.write(AppStorageKeys.lastSyncTime, t.millisecondsSinceEpoch);

  static Future<void> clearUserData() async {
    for (final key in [
      AppStorageKeys.uid,
      AppStorageKeys.userProfile,
      AppStorageKeys.isLoggedIn,
      AppStorageKeys.onboardingDone,
      AppStorageKeys.cachedSteps,
      AppStorageKeys.cachedCalories,
      AppStorageKeys.cachedSleepLogs,
      AppStorageKeys.lastSyncTime,
    ]) {
      await _box.remove(key);
    }
  }
}

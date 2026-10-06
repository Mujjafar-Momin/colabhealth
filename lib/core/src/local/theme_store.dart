import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeStore {
  ThemeStore._();

  static const String _key = 'theme_mode';
  static final GetStorage _box = GetStorage();

  static ThemeMode get themeMode {
    final value = _box.read(_key) as String?;
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    await _box.write(_key, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
    Get.changeThemeMode(mode);
    await Get.forceAppUpdate();
  }
}

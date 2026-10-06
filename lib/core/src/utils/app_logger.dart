import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void print(Object? message, {String name = 'ColabHealth'}) {
    if (kDebugMode) {
      dev.log('🔵 $message', name: name);
    }
  }

  static void error(Object? message, {Object? error, StackTrace? stack, String name = 'ColabHealth'}) {
    if (kDebugMode) {
      dev.log('🔴 $message', name: name, error: error, stackTrace: stack);
    }
  }
}

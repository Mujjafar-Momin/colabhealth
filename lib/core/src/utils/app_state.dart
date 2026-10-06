import 'package:get/get.dart';

import 'package:colabhealth/core/src/utils/app_enums.dart';

class AppState {
  AppState._();

  static final AppState _instance = AppState._();
  factory AppState() => _instance;

  static Flavor flavor = Flavor.dev;
  static bool get isProduction => flavor == Flavor.prod;

  static String appVersion = '';

  static double get screenHeight => Get.context?.height ?? 800;
  static double get screenWidth => Get.context?.width ?? 400;

  static const double kcalPerStep = 0.04;

  static const int defaultStepTarget = 8000;
}

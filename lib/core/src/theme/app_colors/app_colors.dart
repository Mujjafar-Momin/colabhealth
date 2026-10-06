import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:colabhealth/core/src/theme/app_colors/app_dark_colors.dart';
import 'package:colabhealth/core/src/theme/app_colors/app_light_colors.dart';
import 'package:colabhealth/core/src/local/theme_store.dart';

class AppColors {
  const AppColors._();

  static const AppColors _light = AppColors._();
  static const _AppDarkColorsImpl _dark = _AppDarkColorsImpl._();

  static AppColors get current => isDark ? _dark : _light;

  static bool get isDark {
    final mode = ThemeStore.themeMode;
    if (mode == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return mode == ThemeMode.dark;
  }

  Color get primary => AppLightColors.primary;
  Color get primaryContainer => AppLightColors.primaryContainer;
  Color get secondary => AppLightColors.secondary;
  Color get secondaryContainer => AppLightColors.secondaryContainer;

  Color get scaffold => AppLightColors.scaffold;
  Color get surface => AppLightColors.surface;
  Color get secondarySurface => AppLightColors.secondarySurface;
  Color get appBarSurface => AppLightColors.appBarSurface;
  Color get surfaceVariant => AppLightColors.surfaceVariant;
  Color get tileBackground => AppLightColors.tileBackground;
  Color get bottomSheet => AppLightColors.bottomSheet;
  Color get lightGrey => AppLightColors.lightGrey;
  Color get darkGrey => AppLightColors.darkGrey;

  Color get textPrimary => AppLightColors.textPrimary;
  Color get textSecondary => AppLightColors.textSecondary;
  Color get textInverse => AppLightColors.textInverse;

  Color get border => AppLightColors.border;
  Color get divider => AppLightColors.divider;
  Color get buttonDisabled => AppLightColors.buttonDisabled;

  Color get error => AppLightColors.error;
  Color get errorContainer => AppLightColors.errorContainer;
  Color get success => AppLightColors.success;
  Color get warning => AppLightColors.warning;
  Color get info => AppLightColors.info;

  Color get steps => AppLightColors.steps;
  Color get calories => AppLightColors.calories;
  Color get sleep => AppLightColors.sleep;
  Color get heart => AppLightColors.heart;

  Color get awake => AppLightColors.awake;
  Color get light => AppLightColors.light;
  Color get deep => AppLightColors.deep;
  Color get rem => AppLightColors.rem;

  Color get iconGrey => AppLightColors.iconGrey;
}

class _AppDarkColorsImpl implements AppColors {
  const _AppDarkColorsImpl._();

  @override
  Color get primary => AppDarkColors.primary;
  @override
  Color get primaryContainer => AppDarkColors.primaryContainer;
  @override
  Color get secondary => AppDarkColors.secondary;
  @override
  Color get secondaryContainer => AppDarkColors.secondaryContainer;

  @override
  Color get scaffold => AppDarkColors.scaffold;
  @override
  Color get surface => AppDarkColors.surface;
  @override
  Color get secondarySurface => AppDarkColors.secondarySurface;
  @override
  Color get appBarSurface => AppDarkColors.appBarSurface;
  @override
  Color get surfaceVariant => AppDarkColors.surfaceVariant;
  @override
  Color get tileBackground => AppDarkColors.tileBackground;
  @override
  Color get bottomSheet => AppDarkColors.bottomSheet;
  @override
  Color get lightGrey => AppDarkColors.lightGrey;
  @override
  Color get darkGrey => AppDarkColors.darkGrey;

  @override
  Color get textPrimary => AppDarkColors.textPrimary;
  @override
  Color get textSecondary => AppDarkColors.textSecondary;
  @override
  Color get textInverse => AppDarkColors.textInverse;

  @override
  Color get border => AppDarkColors.border;
  @override
  Color get divider => AppDarkColors.divider;
  @override
  Color get buttonDisabled => AppDarkColors.buttonDisabled;

  @override
  Color get error => AppDarkColors.error;
  @override
  Color get errorContainer => AppDarkColors.errorContainer;
  @override
  Color get success => AppDarkColors.success;
  @override
  Color get warning => AppDarkColors.warning;
  @override
  Color get info => AppDarkColors.info;

  @override
  Color get steps => AppDarkColors.steps;
  @override
  Color get calories => AppDarkColors.calories;
  @override
  Color get sleep => AppDarkColors.sleep;
  @override
  Color get heart => AppDarkColors.heart;

  @override
  Color get awake => AppDarkColors.awake;
  @override
  Color get light => AppDarkColors.light;
  @override
  Color get deep => AppDarkColors.deep;
  @override
  Color get rem => AppDarkColors.rem;

  @override
  Color get iconGrey => AppDarkColors.iconGrey;
}

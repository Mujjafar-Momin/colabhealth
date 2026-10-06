import 'package:flutter/material.dart';

import 'package:colabhealth/core/src/theme/app_colors/app_dark_colors.dart';
import 'package:colabhealth/core/src/theme/app_colors/app_light_colors.dart';
import 'package:colabhealth/core/src/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static const String fontFamily = AppTextStyles.fontFamily;

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: AppLightColors.scaffold,
    dividerColor: AppLightColors.divider,
    hintColor: AppLightColors.textSecondary,
    colorScheme: const ColorScheme.light(
      primary: AppLightColors.primary,
      primaryContainer: AppLightColors.primaryContainer,
      secondary: AppLightColors.secondary,
      secondaryContainer: AppLightColors.secondaryContainer,
      surface: AppLightColors.surface,
      error: AppLightColors.error,
      onPrimary: AppLightColors.textInverse,
      onSecondary: AppLightColors.textInverse,
      onSurface: AppLightColors.textPrimary,
      onError: AppLightColors.textInverse,
      outline: AppLightColors.border,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppLightColors.appBarSurface,
      foregroundColor: AppLightColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: AppDarkColors.scaffold,
    dividerColor: AppDarkColors.divider,
    hintColor: AppDarkColors.textSecondary,
    colorScheme: const ColorScheme.dark(
      primary: AppDarkColors.primary,
      primaryContainer: AppDarkColors.primaryContainer,
      secondary: AppDarkColors.secondary,
      secondaryContainer: AppDarkColors.secondaryContainer,
      surface: AppDarkColors.surface,
      error: AppDarkColors.error,
      onPrimary: AppDarkColors.textInverse,
      onSecondary: AppDarkColors.textInverse,
      onSurface: AppDarkColors.textPrimary,
      onError: AppDarkColors.textInverse,
      outline: AppDarkColors.border,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppDarkColors.appBarSurface,
      foregroundColor: AppDarkColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}

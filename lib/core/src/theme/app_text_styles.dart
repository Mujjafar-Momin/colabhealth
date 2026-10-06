import 'package:flutter/material.dart';

import 'package:colabhealth/core/src/theme/app_colors/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Poppins';

  static Color get _primary => AppColors.current.textPrimary;

  static TextStyle _base(double size, FontWeight weight) => TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        color: _primary,
      );

  static TextStyle get regular10 => _base(10, FontWeight.w400);
  static TextStyle get regular12 => _base(12, FontWeight.w400);
  static TextStyle get regular14 => _base(14, FontWeight.w400);
  static TextStyle get regular16 => _base(16, FontWeight.w400);

  static TextStyle get medium10 => _base(10, FontWeight.w500);
  static TextStyle get medium12 => _base(12, FontWeight.w500);
  static TextStyle get medium14 => _base(14, FontWeight.w500);
  static TextStyle get medium16 => _base(16, FontWeight.w500);
  static TextStyle get medium18 => _base(18, FontWeight.w500);

  static TextStyle get semiBold12 => _base(12, FontWeight.w600);
  static TextStyle get semiBold14 => _base(14, FontWeight.w600);
  static TextStyle get semiBold16 => _base(16, FontWeight.w600);
  static TextStyle get semiBold18 => _base(18, FontWeight.w600);
  static TextStyle get semiBold20 => _base(20, FontWeight.w600);
  static TextStyle get semiBold24 => _base(24, FontWeight.w600);

  static TextStyle get bold16 => _base(16, FontWeight.w700);
  static TextStyle get bold18 => _base(18, FontWeight.w700);
  static TextStyle get bold20 => _base(20, FontWeight.w700);
  static TextStyle get bold24 => _base(24, FontWeight.w700);
  static TextStyle get bold28 => _base(28, FontWeight.w700);
  static TextStyle get bold32 => _base(32, FontWeight.w700);
  static TextStyle get bold40 => _base(40, FontWeight.w700);

  static TextStyle custom({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        color: color ?? _primary,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      );
}

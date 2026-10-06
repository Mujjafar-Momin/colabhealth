import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();

  static const SizedBox zero = SizedBox.shrink();

  static SizedBox custom({double? height, double? width}) =>
      SizedBox(height: height, width: width);

  static const SizedBox h4 = SizedBox(height: 4);
  static const SizedBox h6 = SizedBox(height: 6);
  static const SizedBox h8 = SizedBox(height: 8);
  static const SizedBox h10 = SizedBox(height: 10);
  static const SizedBox h12 = SizedBox(height: 12);
  static const SizedBox h16 = SizedBox(height: 16);
  static const SizedBox h20 = SizedBox(height: 20);
  static const SizedBox h24 = SizedBox(height: 24);
  static const SizedBox h28 = SizedBox(height: 28);
  static const SizedBox h32 = SizedBox(height: 32);
  static const SizedBox h40 = SizedBox(height: 40);
  static const SizedBox h48 = SizedBox(height: 48);

  static const SizedBox w4 = SizedBox(width: 4);
  static const SizedBox w6 = SizedBox(width: 6);
  static const SizedBox w8 = SizedBox(width: 8);
  static const SizedBox w10 = SizedBox(width: 10);
  static const SizedBox w12 = SizedBox(width: 12);
  static const SizedBox w16 = SizedBox(width: 16);
  static const SizedBox w20 = SizedBox(width: 20);
  static const SizedBox w24 = SizedBox(width: 24);
  static const SizedBox w32 = SizedBox(width: 32);
}

class AppPadding {
  AppPadding._();

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets card = EdgeInsets.all(16);
  static const EdgeInsets sheet = EdgeInsets.fromLTRB(20, 16, 20, 24);

  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
}

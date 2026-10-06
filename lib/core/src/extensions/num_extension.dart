import 'package:intl/intl.dart';

extension IntX on int {

  String get grouped => NumberFormat('#,###').format(this);
}

extension DoubleX on double {

  String get asKcal => toStringAsFixed(2);

  String get rounded => round().toString();
}

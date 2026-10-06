import 'package:intl/intl.dart';

extension DateTimeX on DateTime {

  String get dashboardDate => DateFormat('EEE, d MMMM').format(this);

  String get dayMonth => DateFormat('d MMMM').format(this);

  String get weekday => DateFormat('EEEE').format(this);

  String get timeOfDay => DateFormat('hh:mm a').format(this);

  String get dateKey => DateFormat('yyyy-MM-dd').format(this);

  String get shortDate => DateFormat('dd-MM-yyyy').format(this);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime get startOfDay => DateTime(year, month, day);
}

extension DurationX on Duration {

  String get hhmm {
    final h = inHours.abs().toString().padLeft(2, '0');
    final m = (inMinutes.abs() % 60).toString().padLeft(2, '0');
    return '${h}h ${m}m';
  }

  String get compact {
    final h = inHours.abs();
    final m = inMinutes.abs() % 60;
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }

  String get minutesLabel => '${inMinutes.abs()} min';
}

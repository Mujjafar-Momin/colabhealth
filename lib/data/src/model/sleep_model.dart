import 'package:uuid/uuid.dart';

class AwakePeriod {
  final DateTime start;
  final DateTime end;
  const AwakePeriod(this.start, this.end);

  Duration get duration => end.difference(start);

  factory AwakePeriod.fromJson(Map<String, dynamic> json) => AwakePeriod(
        DateTime.parse(json['start']),
        DateTime.parse(json['end']),
      );
  Map<String, dynamic> toJson() => {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };
}

class SleepStageInterval {
  final DateTime start;
  final DateTime end;
  const SleepStageInterval(this.start, this.end);

  Duration get duration => end.difference(start);

  factory SleepStageInterval.fromJson(Map<String, dynamic> json) => SleepStageInterval(
        DateTime.parse(json['start']),
        DateTime.parse(json['end']),
      );
  Map<String, dynamic> toJson() => {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };
}

class SleepModel {
  final String id;
  final DateTime sleepStart;
  final DateTime sleepEnd;
  final List<SleepStageInterval> deep;
  final List<SleepStageInterval> rem;
  final List<SleepStageInterval> light;
  final List<AwakePeriod> awakePeriods;
  final String source;

  SleepModel({
    String? id,
    required this.sleepStart,
    required this.sleepEnd,
    this.deep = const [],
    this.rem = const [],
    this.light = const [],
    this.awakePeriods = const [],
    this.source = 'manual',
  }) : id = id ?? const Uuid().v4();

  DateTime get date => DateTime(sleepEnd.year, sleepEnd.month, sleepEnd.day);

  Duration get awakeTime =>
      awakePeriods.fold(Duration.zero, (sum, p) => sum + p.duration);

  Duration get totalSleep => (sleepEnd.difference(sleepStart)) - awakeTime;

  Duration get deepSleep =>
      deep.fold(Duration.zero, (sum, s) => sum + s.duration);

  Duration get remSleep =>
      rem.fold(Duration.zero, (sum, s) => sum + s.duration);

  Duration get lightSleep =>
      light.fold(Duration.zero, (sum, s) => sum + s.duration);

  double _fraction(Duration d) {
    final inBed = sleepEnd.difference(sleepStart).inSeconds;
    if (inBed <= 0) return 0;
    return (d.inSeconds / inBed).clamp(0, 1).toDouble();
  }

  double get deepFraction => _fraction(deepSleep);
  double get remFraction => _fraction(remSleep);
  double get lightFraction => _fraction(lightSleep);
  double get awakeFraction => _fraction(awakeTime);

  factory SleepModel.fromJson(Map<String, dynamic> json) => SleepModel(
        id: json['id'],
        sleepStart: DateTime.parse(json['sleepStart']),
        sleepEnd: DateTime.parse(json['sleepEnd']),
        deep: (json['deep'] as List?)
                ?.map((e) => SleepStageInterval.fromJson(e))
                .toList() ??
            const [],
        rem: (json['rem'] as List?)
                ?.map((e) => SleepStageInterval.fromJson(e))
                .toList() ??
            const [],
        light: (json['light'] as List?)
                ?.map((e) => SleepStageInterval.fromJson(e))
                .toList() ??
            const [],
        awakePeriods: (json['awakePeriods'] as List?)
                ?.map((e) => AwakePeriod.fromJson(e))
                .toList() ??
            const [],
        source: json['source'] ?? 'manual',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sleepStart': sleepStart.toIso8601String(),
        'sleepEnd': sleepEnd.toIso8601String(),
        'deep': deep.map((e) => e.toJson()).toList(),
        'rem': rem.map((e) => e.toJson()).toList(),
        'light': light.map((e) => e.toJson()).toList(),
        'awakePeriods': awakePeriods.map((e) => e.toJson()).toList(),
        'source': source,
      };
}

class StepsModel {
  final int steps;
  final DateTime date;
  final int target;

  final List<int> hourly;

  const StepsModel({
    required this.steps,
    required this.date,
    this.target = 8000,
    this.hourly = const [],
  });

  double get caloriesBurned => steps * 0.04;

  double get progress => target == 0 ? 0 : (steps / target).clamp(0, 1).toDouble();

  factory StepsModel.fromJson(Map<String, dynamic> json) => StepsModel(
        steps: json['steps'] ?? 0,
        date: json['date'] != null
            ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
            : DateTime.now(),
        target: json['target'] ?? 8000,
        hourly: (json['hourly'] as List?)?.map((e) => e as int).toList() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'steps': steps,
        'date': date.toIso8601String(),
        'target': target,
        'hourly': hourly,
      };

  StepsModel copyWith({int? steps, int? target, List<int>? hourly}) => StepsModel(
        steps: steps ?? this.steps,
        date: date,
        target: target ?? this.target,
        hourly: hourly ?? this.hourly,
      );
}

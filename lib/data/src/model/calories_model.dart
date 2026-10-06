class CaloriesModel {
  final double totalCalories;
  final DateTime date;
  final List<CalorieActivity> activities;

  const CaloriesModel({
    required this.totalCalories,
    required this.date,
    this.activities = const [],
  });

  factory CaloriesModel.fromApiList(List<dynamic> list, {DateTime? date}) {
    final activities = list
        .whereType<Map<String, dynamic>>()
        .map(CalorieActivity.fromJson)
        .toList();
    final total = activities.fold<double>(0, (sum, a) => sum + a.totalCalories);
    return CaloriesModel(
      totalCalories: total,
      date: date ?? DateTime.now(),
      activities: activities,
    );
  }

  factory CaloriesModel.fromJson(Map<String, dynamic> json) => CaloriesModel(
        totalCalories: (json['totalCalories'] ?? 0).toDouble(),
        date: json['date'] != null
            ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
            : DateTime.now(),
        activities: (json['activities'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map(CalorieActivity.fromJson)
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'totalCalories': totalCalories,
        'date': date.toIso8601String(),
        'activities': activities.map((a) => a.toJson()).toList(),
      };
}

class CalorieActivity {
  final String name;
  final double totalCalories;
  final double caloriesPerHour;
  final int durationMinutes;

  const CalorieActivity({
    required this.name,
    required this.totalCalories,
    this.caloriesPerHour = 0,
    this.durationMinutes = 0,
  });

  factory CalorieActivity.fromJson(Map<String, dynamic> json) => CalorieActivity(
        name: json['name'] ?? '',
        totalCalories: (json['total_calories'] ?? json['totalCalories'] ?? 0).toDouble(),
        caloriesPerHour: (json['calories_per_hour'] ?? json['caloriesPerHour'] ?? 0).toDouble(),
        durationMinutes: json['duration_minutes'] ?? json['durationMinutes'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'total_calories': totalCalories,
        'calories_per_hour': caloriesPerHour,
        'duration_minutes': durationMinutes,
      };
}

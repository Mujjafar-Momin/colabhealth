import 'package:flutter/material.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String? photoUrl;
  final String? avatarId;
  final int stepTarget;
  final TimeOfDayData bedTime;
  final TimeOfDayData wakeTime;
  final bool remindersOn;
  final String themeMode;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.fullName = '',
    this.photoUrl,
    this.avatarId,
    this.stepTarget = 8000,
    this.bedTime = const TimeOfDayData(22, 0),
    this.wakeTime = const TimeOfDayData(6, 30),
    this.remindersOn = false,
    this.themeMode = 'system',
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] ?? '',
        email: json['email'] ?? '',
        fullName: json['fullName'] ?? '',
        photoUrl: json['photoUrl'],
        avatarId: json['avatarId'],
        stepTarget: json['stepTarget'] ?? 8000,
        bedTime: TimeOfDayData.fromString(json['bedTime']) ?? const TimeOfDayData(22, 0),
        wakeTime: TimeOfDayData.fromString(json['wakeTime']) ?? const TimeOfDayData(6, 30),
        remindersOn: json['remindersOn'] ?? false,
        themeMode: json['themeMode'] ?? 'system',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'photoUrl': photoUrl,
        'avatarId': avatarId,
        'stepTarget': stepTarget,
        'bedTime': bedTime.toString(),
        'wakeTime': wakeTime.toString(),
        'remindersOn': remindersOn,
        'themeMode': themeMode,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  UserModel copyWith({
    String? fullName,
    String? photoUrl,
    String? avatarId,
    int? stepTarget,
    TimeOfDayData? bedTime,
    TimeOfDayData? wakeTime,
    bool? remindersOn,
    String? themeMode,
  }) =>
      UserModel(
        uid: uid,
        email: email,
        fullName: fullName ?? this.fullName,
        photoUrl: photoUrl ?? this.photoUrl,
        avatarId: avatarId ?? this.avatarId,
        stepTarget: stepTarget ?? this.stepTarget,
        bedTime: bedTime ?? this.bedTime,
        wakeTime: wakeTime ?? this.wakeTime,
        remindersOn: remindersOn ?? this.remindersOn,
        themeMode: themeMode ?? this.themeMode,
        createdAt: createdAt,
      );
}

class TimeOfDayData {
  final int hour;
  final int minute;
  const TimeOfDayData(this.hour, this.minute);

  factory TimeOfDayData.fromTimeOfDay(TimeOfDay t) => TimeOfDayData(t.hour, t.minute);
  TimeOfDay get toTimeOfDay => TimeOfDay(hour: hour, minute: minute);

  static TimeOfDayData? fromString(dynamic value) {
    if (value is! String) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    return TimeOfDayData(int.tryParse(parts[0]) ?? 0, int.tryParse(parts[1]) ?? 0);
  }

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

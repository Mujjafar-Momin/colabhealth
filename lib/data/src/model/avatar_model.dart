import 'package:flutter/material.dart';

class AvatarModel {
  final String id;
  final String emoji;
  final List<Color> gradient;

  const AvatarModel(this.id, this.emoji, this.gradient);

  static const List<AvatarModel> all = [
    AvatarModel('fox', '🦊', [Color(0xFFFF8A4C), Color(0xFFE8572A)]),
    AvatarModel('panda', '🐼', [Color(0xFF8E8E93), Color(0xFF3A3A3C)]),
    AvatarModel('owl', '🦉', [Color(0xFF7C6CFF), Color(0xFF4A3CCB)]),
    AvatarModel('cat', '🐱', [Color(0xFFFFB020), Color(0xFFFF7A59)]),
    AvatarModel('koala', '🐨', [Color(0xFF5B8DEF), Color(0xFF3A5BCB)]),
    AvatarModel('tiger', '🐯', [Color(0xFFFFA726), Color(0xFFEF6C00)]),
    AvatarModel('robot', '🤖', [Color(0xFF00C2A8), Color(0xFF009E8A)]),
    AvatarModel('alien', '👽', [Color(0xFF9C6CFF), Color(0xFF6C3CCB)]),
    AvatarModel('ninja', '🥷', [Color(0xFF2E2E3C), Color(0xFF14121F)]),
    AvatarModel('dragon', '🐲', [Color(0xFF17C964), Color(0xFF0F9E4C)]),
  ];

  static AvatarModel byId(String? id) =>
      all.firstWhere((a) => a.id == id, orElse: () => all.first);
}

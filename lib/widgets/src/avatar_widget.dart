import 'package:flutter/material.dart';

import 'package:colabhealth/data/src/model/avatar_model.dart';

class AvatarView extends StatelessWidget {
  const AvatarView({super.key, required this.avatar, this.size = 56, this.selected = false});

  final AvatarModel avatar;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: avatar.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: selected
            ? Border.all(color: Colors.white, width: 3)
            : null,
        boxShadow: selected
            ? [BoxShadow(color: avatar.gradient.last.withValues(alpha: 0.5), blurRadius: 12)]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(avatar.emoji, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}

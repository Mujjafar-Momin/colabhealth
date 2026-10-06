import 'package:flutter/material.dart';

import 'package:colabhealth/core/core.dart';

class Label extends StatelessWidget {
  const Label(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final base = style ?? AppTextStyles.medium14;
    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      style: color != null ? base.copyWith(color: color) : base,
    );
  }
}

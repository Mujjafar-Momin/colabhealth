import 'package:flutter/material.dart';

import 'package:colabhealth/core/core.dart';
import 'package:colabhealth/widgets/src/label.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
    this.maxLength,
    this.textCapitalization = TextCapitalization.sentences,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Label(label!, style: AppTextStyles.medium14.copyWith(color: colors.textSecondary)),
          AppSpacing.h8,
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLength: maxLength,
          textCapitalization: textCapitalization,
          style: AppTextStyles.medium16,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            hintStyle: AppTextStyles.medium16.copyWith(color: colors.textSecondary),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: colors.iconGrey, size: 20) : null,
            suffixIcon: suffix,
            filled: true,
            fillColor: colors.secondarySurface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.primary, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'package:colabhealth/core/core.dart';
import 'package:colabhealth/widgets/src/app_card.dart';
import 'package:colabhealth/widgets/src/label.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accent,
    this.subtitle,
    this.progress,
    this.onTap,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color accent;
  final String? subtitle;
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              if (progress != null)
                SizedBox(
                  width: 34,
                  height: 34,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress!.clamp(0, 1),
                        strokeWidth: 3.5,
                        backgroundColor: colors.lightGrey,
                        valueColor: AlwaysStoppedAnimation(accent),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          AppSpacing.h16,
          Label(title, style: AppTextStyles.medium12.copyWith(color: colors.textSecondary)),
          AppSpacing.h4,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(child: Label(value, style: AppTextStyles.bold24, maxLines: 1)),
              AppSpacing.w4,
              Label(unit, style: AppTextStyles.medium12.copyWith(color: colors.textSecondary)),
            ],
          ),
          if (subtitle != null) ...[
            AppSpacing.h4,
            Label(subtitle!, style: AppTextStyles.regular12.copyWith(color: colors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

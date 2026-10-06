import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import 'package:colabhealth/core/core.dart';
import 'package:colabhealth/widgets/src/app_button.dart';
import 'package:colabhealth/widgets/src/label.dart';

class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = LucideIcons.cloudOff,
  });

  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colors.textSecondary),
            AppSpacing.h16,
            Label(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.medium14.copyWith(color: colors.textSecondary),
            ),
            AppSpacing.h20,
            SizedBox(
              width: 160,
              child: AppButton(
                title: 'Retry',
                height: 46,
                onPressed: onRetry,
                prefix: const Icon(LucideIcons.refreshCw, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.message = 'Offline — showing last saved data'});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.cloudOff, size: 16, color: colors.warning),
          AppSpacing.w8,
          Expanded(
            child: Label(message,
                style: AppTextStyles.medium12.copyWith(color: colors.warning)),
          ),
        ],
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.height = 120, this.width = double.infinity, this.radius = 20});
  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Shimmer.fromColors(
      baseColor: colors.lightGrey,
      highlightColor: colors.surface,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: colors.lightGrey,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key, required this.message, this.icon = LucideIcons.inbox});
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: colors.iconGrey),
          AppSpacing.h12,
          Label(message,
              textAlign: TextAlign.center,
              style: AppTextStyles.medium14.copyWith(color: colors.textSecondary)),
        ],
      ),
    );
  }
}

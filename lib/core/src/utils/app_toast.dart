import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:colabhealth/core/src/theme/app_colors/app_colors.dart';
import 'package:colabhealth/core/src/theme/app_text_styles.dart';
import 'package:colabhealth/core/src/utils/app_enums.dart';

class AppToast {
  AppToast._();

  static void show({
    required String message,
    ToastType type = ToastType.general,
    int durationMs = 2800,
    bool isTop = true,
  }) {

    if (Get.isSnackbarOpen) {
      try {
        Get.closeAllSnackbars();
      } catch (_) {

      }
    }

    final colors = AppColors.current;
    final (icon, accent) = _style(type, colors);

    Get.showSnackbar(
      GetSnackBar(
        snackPosition: isTop ? SnackPosition.TOP : SnackPosition.BOTTOM,
        backgroundColor: colors.surface,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: Duration(milliseconds: durationMs),
        isDismissible: true,
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        titleText: const SizedBox.shrink(),
        messageText: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: accent.withValues(alpha: 0.12),
              child: Icon(icon, size: 18, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.medium14.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static (IconData, Color) _style(ToastType type, AppColors c) {
    switch (type) {
      case ToastType.success:
        return (LucideIcons.circleCheck, c.success);
      case ToastType.error:
        return (LucideIcons.circleX, c.error);
      case ToastType.warning:
        return (LucideIcons.triangleAlert, c.warning);
      case ToastType.general:
        return (LucideIcons.info, c.primary);
    }
  }
}

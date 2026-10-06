import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:colabhealth/core/core.dart';
import 'package:colabhealth/widgets/src/label.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
  });

  final Widget child;
  final String? title;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Container(
      decoration: BoxDecoration(
        color: colors.bottomSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHandle)
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors.darkGrey,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          if (title != null) ...[
            Label(title!, style: AppTextStyles.semiBold18),
            AppSpacing.h16,
          ],
          child,
        ],
      ),
    );
  }

  static Future<T?> show<T>({
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
  }) {
    return Get.bottomSheet<T>(
      child,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
    );
  }
}

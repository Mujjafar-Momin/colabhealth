import 'package:flutter/material.dart';

import 'package:colabhealth/core/core.dart';
import 'package:colabhealth/widgets/src/label.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.title,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.isSecondary = false,
    this.backgroundColor,
    this.textColor,
    this.height = 54,
    this.width,
    this.borderRadius = 16,
    this.prefix,
  });

  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool isSecondary;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? width;
  final double borderRadius;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    final disabled = isDisabled || isLoading;

    final bg = isSecondary
        ? Colors.transparent
        : (backgroundColor ?? colors.primary);
    final fg = isSecondary
        ? (textColor ?? colors.primary)
        : (textColor ?? Colors.white);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: disabled && !isSecondary ? colors.buttonDisabled : bg,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: disabled ? null : onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: isSecondary
                  ? Border.all(color: colors.border, width: 1.4)
                  : null,
            ),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(fg),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (prefix != null) ...[prefix!, AppSpacing.w10],
                      Label(title, style: AppTextStyles.semiBold16.copyWith(color: fg)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

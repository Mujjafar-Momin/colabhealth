import 'package:colabhealth/colabhealth.dart';

class ThemeBottomSheet extends StatelessWidget {
  const ThemeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SettingsController>();
    final colors = AppColors.current;
    final options = [
      (ThemeMode.system, 'System default', LucideIcons.smartphone),
      (ThemeMode.light, 'Light', LucideIcons.sun),
      (ThemeMode.dark, 'Dark', LucideIcons.moon),
    ];

    return AppBottomSheet(
      title: 'Appearance',
      child: Obx(
        () => Column(
          children: options.map((o) {
            final selected = c.themeMode.value == o.$1;
            return GestureDetector(
              onTap: () {
                c.setTheme(o.$1);
                Get.back();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected ? colors.primary.withValues(alpha: 0.1) : colors.secondarySurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: selected ? colors.primary : Colors.transparent, width: 1.4),
                ),
                child: Row(
                  children: [
                    Icon(o.$3, color: selected ? colors.primary : colors.textSecondary, size: 20),
                    AppSpacing.w12,
                    Expanded(child: Label(o.$2, style: AppTextStyles.semiBold14)),
                    if (selected) Icon(LucideIcons.check, color: colors.primary, size: 20),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

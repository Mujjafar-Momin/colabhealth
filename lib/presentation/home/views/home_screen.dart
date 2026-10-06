import 'package:colabhealth/colabhealth.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});
  static const route = '/home';

  static const _tabs = [
    DashboardView(),
    StepsView(),
    SleepView(),
    CaloriesView(),
    SettingsView(),
  ];

  static const _items = [
    (LucideIcons.layoutDashboard, 'Home'),
    (LucideIcons.footprints, 'Steps'),
    (LucideIcons.moon, 'Sleep'),
    (LucideIcons.flame, 'Calories'),
    (LucideIcons.settings, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Scaffold(
      backgroundColor: colors.scaffold,
      body: Obx(() => IndexedStack(index: controller.tabIndex.value, children: _tabs)),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: colors.surface,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20)],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 0; i < _items.length; i++)
                    _navItem(colors, i, _items[i].$1, _items[i].$2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(AppColors colors, int index, IconData icon, String label) {
    final selected = controller.tabIndex.value == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.changeTab(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: selected ? colors.primary : colors.iconGrey),
            AppSpacing.h4,
            Label(label,
                style: (selected ? AppTextStyles.medium10 : AppTextStyles.regular10).copyWith(
                  color: selected ? colors.primary : colors.iconGrey,
                )),
          ],
        ),
      ),
    );
  }
}

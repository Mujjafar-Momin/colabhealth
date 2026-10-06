import 'package:colabhealth/colabhealth.dart';
import 'package:colabhealth/presentation/dashboard/widgets/calendar_bottom_sheet.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshAll,
          color: colors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _header(colors),
              AppSpacing.h20,
              SectionHeader(
                'Today',
                trailing: Icon(LucideIcons.calendar, color: colors.primary, size: 22),
                onTrailingTap: () => AppBottomSheet.show(
                  child: CalendarBottomSheet(
                    selected: controller.selectedDate.value,
                    onSelected: controller.selectDate,
                  ),
                ),
              ),
              AppSpacing.h6,
              Obx(() => Label(controller.selectedDate.value.dashboardDate,
                  style: AppTextStyles.bold24)),
              AppSpacing.h16,
              _metrics(),
              AppSpacing.h24,
              const SectionHeader('Today Information'),
              AppSpacing.h12,
              _caloriesInfoCard(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Label('Halo, Honey 👋',
                style: AppTextStyles.medium14.copyWith(color: colors.textSecondary)),
            AppSpacing.h4,
            Label("Let's check your health", style: AppTextStyles.semiBold18),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(LucideIcons.bell, color: colors.textPrimary, size: 22),
        ),
      ],
    );
  }

  Widget _metrics() {
    final steps = Get.find<StepsController>();
    final calories = Get.find<CaloriesController>();
    final sleep = Get.find<SleepController>();
    final colors = AppColors.current;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(() {
                final s = steps.today.value;
                return MetricCard(
                  title: 'Steps',
                  value: (s?.steps ?? 0).grouped,
                  unit: 'steps',
                  icon: LucideIcons.footprints,
                  accent: colors.steps,
                  progress: s?.progress ?? 0,
                  onTap: () => Get.find<HomeController>().changeTab(1),
                );
              }),
            ),
            AppSpacing.w12,
            Expanded(
              child: Obx(() {
                final c = calories.data.value;
                return MetricCard(
                  title: 'Calories',
                  value: (c?.totalCalories ?? 0).rounded,
                  unit: 'Kcal',
                  icon: LucideIcons.flame,
                  accent: colors.calories,
                  onTap: () => Get.find<HomeController>().changeTab(3),
                );
              }),
            ),
          ],
        ),
        AppSpacing.h12,
        Obx(() {
          final last = sleep.latest;
          return MetricCard(
            title: 'Sleep',
            value: last == null ? '--' : last.totalSleep.compact,
            unit: last == null ? 'tap to log' : 'last night',
            icon: LucideIcons.moon,
            accent: colors.sleep,
            onTap: () {
              if (last == null) {
                Get.find<HomeController>().changeTab(2);
              } else {
                Get.to(() => SleepDetailScreen(log: last));
              }
            },
          );
        }),
      ],
    );
  }

  Widget _caloriesInfoCard(AppColors colors) {
    final calories = Get.find<CaloriesController>();
    return Obx(() {
      if (calories.state.value.isError) {
        return AppCard(
          child: ErrorRetryView(
            message: calories.error.value,
            onRetry: () => calories.retry(
                steps: Get.find<StepsController>().today.value?.steps ?? 0),
          ),
        );
      }
      final c = calories.data.value;
      return AppCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.calories.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(LucideIcons.flame, color: colors.calories),
            ),
            AppSpacing.w16,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Label('Calories burned',
                    style: AppTextStyles.medium12.copyWith(color: colors.textSecondary)),
                AppSpacing.h4,
                Label('${(c?.totalCalories ?? 0).asKcal} Kcal', style: AppTextStyles.bold20),
              ],
            ),
            const Spacer(),
            if (calories.isOffline.value)
              Icon(LucideIcons.cloudOff, color: colors.warning, size: 18),
          ],
        ),
      );
    });
  }
}

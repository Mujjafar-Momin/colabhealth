import 'package:colabhealth/colabhealth.dart';

class CaloriesView extends GetView<CaloriesController> {
  const CaloriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Scaffold(
      backgroundColor: colors.scaffold,
      appBar: AppBar(title: Label('Calories', style: AppTextStyles.semiBold18)),
      body: Obx(() {
        final steps = Get.find<StepsController>().today.value?.steps ?? 0;

        if (controller.state.value.isLoading && controller.data.value == null) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Column(children: [ShimmerBox(height: 160), SizedBox(height: 16), ShimmerBox(height: 220)]),
          );
        }
        if (controller.state.value.isError && controller.data.value == null) {
          return ErrorRetryView(
            message: controller.error.value,
            icon: LucideIcons.flame,
            onRetry: () => controller.retry(steps: steps),
          );
        }

        final c = controller.data.value;
        return RefreshIndicator(
          onRefresh: () => controller.retry(steps: steps),
          color: colors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              if (controller.isOffline.value) ...[
                const OfflineBanner(message: 'Offline — showing last fetched calories'),
                AppSpacing.h12,
              ],
              AppCard(
                padding: const EdgeInsets.all(24),
                color: colors.calories,
                child: Column(
                  children: [
                    const Icon(LucideIcons.flame, color: Colors.white, size: 40),
                    AppSpacing.h12,
                    Label((c?.totalCalories ?? 0).asKcal,
                        style: AppTextStyles.bold40.copyWith(color: Colors.white)),
                    Label('Kcal burned today',
                        style: AppTextStyles.medium14.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
              AppSpacing.h20,
              Label('Breakdown', style: AppTextStyles.semiBold18),
              AppSpacing.h12,
              if (c == null || c.activities.isEmpty)
                const EmptyStateView(message: 'No activity breakdown available', icon: LucideIcons.activity)
              else
                ...c.activities.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colors.calories.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(LucideIcons.activity, color: colors.calories, size: 20),
                            ),
                            AppSpacing.w12,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Label(a.name.capitalizeFirst ?? a.name, style: AppTextStyles.semiBold14),
                                  Label('${a.durationMinutes} min',
                                      style: AppTextStyles.regular12
                                          .copyWith(color: colors.textSecondary)),
                                ],
                              ),
                            ),
                            Label('${a.totalCalories.rounded} Kcal', style: AppTextStyles.bold16),
                          ],
                        ),
                      ),
                    )),
            ],
          ),
        );
      }),
    );
  }
}

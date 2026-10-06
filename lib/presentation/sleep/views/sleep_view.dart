import 'package:colabhealth/colabhealth.dart';
import 'package:colabhealth/presentation/sleep/widgets/add_sleep_bottom_sheet.dart';

class SleepView extends GetView<SleepController> {
  const SleepView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Scaffold(
      backgroundColor: colors.scaffold,
      appBar: AppBar(
        title: Label('Sleep', style: AppTextStyles.semiBold18),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.heartPulse, color: colors.secondary),
            tooltip: 'Import from Health',
            onPressed: controller.importFromHealth,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.primary,
        onPressed: () => AppBottomSheet.show(child: const AddSleepBottomSheet()),
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: Label('Log sleep', style: AppTextStyles.semiBold14.copyWith(color: Colors.white)),
      ),
      body: Obx(() {
        if (controller.state.value.isLoading && controller.logs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Column(children: [ShimmerBox(height: 180), SizedBox(height: 16), ShimmerBox(height: 160)]),
          );
        }
        if (controller.logs.isEmpty) {
          return const EmptyStateView(
            message: 'No sleep logged yet.\nTap "Log sleep" to add your first entry.',
            icon: LucideIcons.moon,
          );
        }

        final latest = controller.latest!;
        return RefreshIndicator(
          onRefresh: controller.load,
          color: colors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              _summaryCard(colors, latest),
              AppSpacing.h20,
              Label('Last night', style: AppTextStyles.semiBold18),
              AppSpacing.h12,
              AppCard(child: SleepStageChart(points: _points(latest))),
              AppSpacing.h12,
              _stageLegend(colors, latest),
              AppSpacing.h20,
              Label('History', style: AppTextStyles.semiBold18),
              AppSpacing.h12,
              ...controller.logs.map((log) => _historyTile(colors, log)),
            ],
          ),
        );
      }),
    );
  }

  Widget _summaryCard(AppColors colors, SleepModel latest) {
    return AppCard(
      color: colors.sleep,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label('Total sleep',
                      style: AppTextStyles.medium14.copyWith(color: Colors.white70)),
                  AppSpacing.h4,
                  Label(latest.totalSleep.hhmm,
                      style: AppTextStyles.bold32.copyWith(color: Colors.white)),
                ],
              ),
              const Icon(LucideIcons.moonStar, color: Colors.white, size: 36),
            ],
          ),
          AppSpacing.h16,
          Row(
            children: [
              _inline('Bedtime', latest.sleepStart.timeOfDay),
              AppSpacing.w24,
              _inline('Wake up', latest.sleepEnd.timeOfDay),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inline(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(label, style: AppTextStyles.regular12.copyWith(color: Colors.white70)),
          Label(value, style: AppTextStyles.semiBold16.copyWith(color: Colors.white)),
        ],
      );

  Widget _stageLegend(AppColors colors, SleepModel latest) {
    final items = [
      ('Deep', latest.deepSleep, colors.deep),
      ('REM', latest.remSleep, colors.rem),
      ('Light', latest.lightSleep, colors.light),
      ('Awake', latest.awakeTime, colors.awake),
    ];
    return Row(
      children: items
          .map((e) => Expanded(
                child: Column(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: e.$3, shape: BoxShape.circle)),
                    AppSpacing.h6,
                    Label(e.$2.compact, style: AppTextStyles.semiBold12),
                    Label(e.$1, style: AppTextStyles.regular10.copyWith(color: colors.textSecondary)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _historyTile(AppColors colors, SleepModel log) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => Get.to(() => SleepDetailScreen(log: log)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.sleep.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(LucideIcons.moon, color: colors.sleep, size: 20),
            ),
            AppSpacing.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(log.date.dashboardDate, style: AppTextStyles.semiBold14),
                  Label('${log.sleepStart.timeOfDay} – ${log.sleepEnd.timeOfDay}',
                      style: AppTextStyles.regular12.copyWith(color: colors.textSecondary)),
                ],
              ),
            ),
            Label(log.totalSleep.compact, style: AppTextStyles.bold16),
            AppSpacing.w8,
            Icon(LucideIcons.chevronRight, size: 18, color: colors.iconGrey),
          ],
        ),
      ),
    );
  }

  List<double> _points(SleepModel log) {
    final total = log.sleepEnd.difference(log.sleepStart).inMinutes.clamp(1, 1440);
    const buckets = 24;
    final per = total / buckets;
    final deep = log.deepSleep.inMinutes;
    final light = log.lightSleep.inMinutes;
    final rem = log.remSleep.inMinutes;
    final pts = <double>[];
    for (int i = 0; i < buckets; i++) {
      final e = i * per;
      if (e < deep) {
        pts.add(0);
      } else if (e < deep + light) {
        pts.add(1);
      } else if (e < deep + light + rem) {
        pts.add(2);
      } else {
        pts.add(3);
      }
    }
    return pts;
  }
}

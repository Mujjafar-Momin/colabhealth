import 'package:colabhealth/colabhealth.dart';

class SleepDetailScreen extends StatelessWidget {
  const SleepDetailScreen({super.key, required this.log});
  static const route = '/sleep-detail';

  final SleepModel log;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Scaffold(
      backgroundColor: colors.scaffold,
      appBar: AppBar(title: Label('Sleep details', style: AppTextStyles.semiBold18)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(LucideIcons.moon, color: colors.sleep, size: 32),
                AppSpacing.h12,
                Label(log.totalSleep.hhmm, style: AppTextStyles.bold40),
                Label('Total sleep · ${log.date.dayMonth}',
                    style: AppTextStyles.medium14.copyWith(color: colors.textSecondary)),
                AppSpacing.h12,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _chip('Bedtime', log.sleepStart.timeOfDay, LucideIcons.moon, colors),
                    _chip('Wake up', log.sleepEnd.timeOfDay, LucideIcons.sun, colors),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.h20,
          Label('Sleep stages', style: AppTextStyles.semiBold18),
          AppSpacing.h12,
          AppCard(child: SleepStageChart(points: _stagePoints(log))),
          AppSpacing.h20,
          Label('Breakdown', style: AppTextStyles.semiBold18),
          AppSpacing.h12,
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _row('Total Sleep', log.totalSleep, colors.sleep, colors,
                    formula: 'End − Start − Awake'),
                _divider(colors),
                _row('Deep Sleep', log.deepSleep, colors.deep, colors,
                    formula: 'Σ Deep End − Deep Start'),
                _divider(colors),
                _row('REM Sleep', log.remSleep, colors.rem, colors,
                    formula: 'Σ REM End − REM Start'),
                _divider(colors),
                _row('Light Sleep', log.lightSleep, colors.light, colors,
                    formula: 'Σ Light End − Light Start'),
                _divider(colors),
                _row('Awake Time', log.awakeTime, colors.awake, colors,
                    formula: 'Σ awake periods'),
              ],
            ),
          ),
          if (log.source == 'health') ...[
            AppSpacing.h12,
            Row(
              children: [
                Icon(LucideIcons.heartPulse, size: 16, color: colors.secondary),
                AppSpacing.w6,
                Label('Imported from Health',
                    style: AppTextStyles.regular12.copyWith(color: colors.textSecondary)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, String value, IconData icon, AppColors colors) {
    return Column(
      children: [
        Icon(icon, size: 18, color: colors.primary),
        AppSpacing.h4,
        Label(value, style: AppTextStyles.semiBold16),
        Label(label, style: AppTextStyles.regular12.copyWith(color: colors.textSecondary)),
      ],
    );
  }

  Widget _row(String title, Duration value, Color accent, AppColors colors, {required String formula}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
          AppSpacing.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Label(title, style: AppTextStyles.semiBold14),
                AppSpacing.h4,
                Label(formula, style: AppTextStyles.regular10.copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
          Label(value.hhmm, style: AppTextStyles.bold16),
        ],
      ),
    );
  }

  Widget _divider(AppColors colors) => Divider(height: 1, color: colors.divider);

  List<double> _stagePoints(SleepModel log) {

    final total = log.sleepEnd.difference(log.sleepStart).inMinutes.clamp(1, 1440);
    const buckets = 24;
    final perBucket = total / buckets;
    final deepMin = log.deepSleep.inMinutes;
    final remMin = log.remSleep.inMinutes;
    final lightMin = log.lightSleep.inMinutes;

    final points = <double>[];
    for (int i = 0; i < buckets; i++) {
      final elapsed = i * perBucket;
      if (elapsed < deepMin) {
        points.add(0);
      } else if (elapsed < deepMin + lightMin) {
        points.add(1);
      } else if (elapsed < deepMin + lightMin + remMin) {
        points.add(2);
      } else {
        points.add(3);
      }
    }
    return points;
  }
}

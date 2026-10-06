import 'package:colabhealth/colabhealth.dart';
import 'package:colabhealth/presentation/steps/widgets/step_target_bottom_sheet.dart';

class StepsView extends GetView<StepsController> {
  const StepsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Scaffold(
      backgroundColor: colors.scaffold,
      appBar: AppBar(
        title: Label('Steps', style: AppTextStyles.semiBold18),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.target, color: colors.primary),
            onPressed: () => AppBottomSheet.show(child: const StepTargetBottomSheet()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.state.value.isLoading && controller.today.value == null) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Column(children: [ShimmerBox(height: 160), SizedBox(height: 16), ShimmerBox(height: 200)]),
          );
        }
        if (controller.state.value.isError && controller.today.value == null) {
          return ErrorRetryView(
            message: controller.error.value,
            icon: LucideIcons.footprints,
            onRetry: controller.retry,
          );
        }
        final s = controller.today.value;
        return RefreshIndicator(
          onRefresh: controller.retry,
          color: colors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              if (controller.dataStatus.value == StepsDataStatus.needsInstall) ...[
                _healthPrompt(
                  colors,
                  icon: LucideIcons.download,
                  title: 'Connect your step data',
                  message:
                      'Install Health Connect to sync your full daily step count from Google Fit and other apps.',
                  action: 'Install Health Connect',
                  onTap: controller.installHealthConnect,
                ),
                AppSpacing.h12,
              ] else if (controller.dataStatus.value == StepsDataStatus.needsPermission) ...[
                _healthPrompt(
                  colors,
                  icon: LucideIcons.shieldCheck,
                  title: 'Allow step access',
                  message:
                      'Grant permission to read your steps for an accurate daily total. Without it, only live steps are counted.',
                  action: 'Grant permission',
                  onTap: controller.requestHealthPermission,
                ),
                AppSpacing.h12,
              ] else if (controller.permissionDenied.value) ...[
                const OfflineBanner(message: 'Activity permission denied — showing saved steps'),
                AppSpacing.h12,
              ],
              _ring(colors, s),
              AppSpacing.h20,
              Label("Today's activity", style: AppTextStyles.semiBold18),
              AppSpacing.h12,
              AppCard(
                child: StepBarChart(
                  values: (s?.hourly ?? List.filled(24, 0)).map((e) => e.toDouble()).toList(),
                  labels: const ['12AM', '', '', '', '', '', '6', '', '', '', '', '', '12PM', '', '', '', '', '', '6', '', '', '', '', '2'],
                ),
              ),
              AppSpacing.h20,
              _statsRow(colors, s),
            ],
          ),
        );
      }),
    );
  }

  Widget _ring(AppColors colors, StepsModel? s) {
    final steps = s?.steps ?? 0;
    final target = s?.target ?? controller.target;
    final progress = s?.progress ?? 0;
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: colors.lightGrey,
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.footprints, color: colors.primary),
                    AppSpacing.h4,
                    Label(steps.grouped, style: AppTextStyles.bold32),
                    Label('of ${target.grouped}',
                        style: AppTextStyles.medium12.copyWith(color: colors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.h12,
          Label('${(progress * 100).round()}% of daily goal',
              style: AppTextStyles.medium14.copyWith(color: colors.textSecondary)),
        ],
      ),
    );
  }

  Widget _healthPrompt(
    AppColors colors, {
    required IconData icon,
    required String title,
    required String message,
    required String action,
    required VoidCallback onTap,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                child: Icon(icon, size: 18, color: colors.primary),
              ),
              AppSpacing.w12,
              Expanded(child: Label(title, style: AppTextStyles.semiBold16)),
            ],
          ),
          AppSpacing.h8,
          Label(message,
              style: AppTextStyles.regular12.copyWith(color: colors.textSecondary)),
          AppSpacing.h12,
          AppButton(title: action, onPressed: onTap),
        ],
      ),
    );
  }

  Widget _statsRow(AppColors colors, StepsModel? s) {
    return Row(
      children: [
        Expanded(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.flame, color: colors.calories, size: 20),
                AppSpacing.h8,
                Label('${(s?.caloriesBurned ?? 0).rounded} Kcal', style: AppTextStyles.bold18),
                Label('Burned',
                    style: AppTextStyles.medium12.copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
        ),
        AppSpacing.w12,
        Expanded(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.ruler, color: colors.secondary, size: 20),
                AppSpacing.h8,
                Label('${(((s?.steps ?? 0) * 0.762) / 1000).toStringAsFixed(2)} km',
                    style: AppTextStyles.bold18),
                Label('Distance',
                    style: AppTextStyles.medium12.copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

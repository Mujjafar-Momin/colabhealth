import 'package:colabhealth/colabhealth.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});
  static const route = '/onboarding';

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
              child: Row(
                children: [
                  Obx(() => controller.page.value > 0
                      ? IconButton(
                          onPressed: controller.back,
                          icon: Icon(LucideIcons.chevronLeft, color: colors.textPrimary))
                      : const SizedBox(width: 48)),
                  Expanded(
                    child: Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            OnboardingController.lastPage + 1,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: controller.page.value == i ? 22 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: controller.page.value >= i ? colors.primary : colors.darkGrey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => controller.page.value = i,
                children: [
                  _welcomePage(colors),
                  _permissionsPage(colors),
                  _avatarPage(colors),
                  _targetPage(colors),
                  _sleepPage(colors),
                ],
              ),
            ),
            Padding(
              padding: AppPadding.screen.add(const EdgeInsets.only(bottom: 20)),
              child: Obx(() => AppButton(
                    title: controller.page.value == OnboardingController.lastPage
                        ? 'Get started'
                        : 'Continue',
                    isDisabled: !controller.canContinue,
                    onPressed: controller.next,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageScaffold(IconData icon, Color accent, String title, String subtitle, Widget body) {
    final colors = AppColors.current;
    return Padding(
      padding: AppPadding.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.h24,
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: accent, size: 30),
          ),
          AppSpacing.h20,
          Label(title, style: AppTextStyles.bold28),
          AppSpacing.h8,
          Label(subtitle, style: AppTextStyles.medium14.copyWith(color: colors.textSecondary)),
          AppSpacing.h32,
          Expanded(child: SingleChildScrollView(child: body)),
        ],
      ),
    );
  }

  Widget _welcomePage(AppColors colors) => _pageScaffold(
        LucideIcons.heartPulse,
        colors.primary,
        'Welcome to Colab Health',
        'Your steps, calories and sleep — tracked beautifully in one place.',
        Column(
          children: [
            _bullet(colors, LucideIcons.footprints, 'Automatic step tracking'),
            _bullet(colors, LucideIcons.flame, 'Daily calories from live data'),
            _bullet(colors, LucideIcons.moon, 'Sleep logging with smart alarm'),
          ],
        ),
      );

  Widget _permissionsPage(AppColors colors) => _pageScaffold(
        LucideIcons.shieldCheck,
        colors.secondary,
        'Permissions',
        'We need a couple of permissions to track your activity and remind you.',
        Column(
          children: [
            Obx(() => _permTile(colors, LucideIcons.footprints, 'Activity recognition',
                'Count your daily steps', controller.activityGranted.value,
                controller.requestActivityPermission)),
            AppSpacing.h12,
            Obx(() => _permTile(colors, LucideIcons.bell, 'Notifications',
                'Reminders & wake alarm', controller.notificationGranted.value,
                controller.requestNotificationPermission)),
          ],
        ),
      );

  Widget _avatarPage(AppColors colors) => _pageScaffold(
        LucideIcons.venetianMask,
        colors.primary,
        'Pick your mask',
        'Choose an avatar that represents you.',
        Obx(() => Wrap(
              spacing: 16,
              runSpacing: 16,
              children: AvatarModel.all
                  .map((a) => GestureDetector(
                        onTap: () => controller.avatarId.value = a.id,
                        child: AvatarView(
                            avatar: a, size: 66, selected: controller.avatarId.value == a.id),
                      ))
                  .toList(),
            )),
      );

  Widget _targetPage(AppColors colors) => _pageScaffold(
        LucideIcons.target,
        colors.steps,
        'Daily step goal',
        'Set a target that keeps you moving.',
        Obx(() => Column(
              children: [
                Label('${controller.stepTarget.value.grouped} steps',
                    style: AppTextStyles.bold32.copyWith(color: colors.primary)),
                Slider(
                  value: controller.stepTarget.value.toDouble(),
                  min: 2000,
                  max: 20000,
                  divisions: 36,
                  activeColor: colors.primary,
                  onChanged: (v) => controller.stepTarget.value = v.round(),
                ),
              ],
            )),
      );

  Widget _sleepPage(AppColors colors) => _pageScaffold(
        LucideIcons.moonStar,
        colors.sleep,
        'Sleep schedule',
        'When do you usually sleep and wake up?',
        Column(
          children: [
            Obx(() => _timeRow(colors, 'Bedtime', controller.bedTime.value, (t) => controller.bedTime.value = t)),
            AppSpacing.h12,
            Obx(() => _timeRow(colors, 'Wake up', controller.wakeTime.value, (t) => controller.wakeTime.value = t)),
            AppSpacing.h20,
            Obx(() => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: controller.remindersOn.value,
                  activeThumbColor: colors.primary,
                  title: Label('Daily sleep reminder', style: AppTextStyles.semiBold14),
                  onChanged: (v) => controller.remindersOn.value = v,
                )),
          ],
        ),
      );

  Widget _bullet(AppColors colors, IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(children: [
          Icon(icon, color: colors.primary, size: 22),
          AppSpacing.w12,
          Label(text, style: AppTextStyles.medium16),
        ]),
      );

  Widget _permTile(AppColors colors, IconData icon, String title, String subtitle, bool granted, VoidCallback onTap) {
    return AppCard(
      onTap: granted ? null : onTap,
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          AppSpacing.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Label(title, style: AppTextStyles.semiBold14),
                Label(subtitle, style: AppTextStyles.regular12.copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
          Icon(granted ? LucideIcons.circleCheck : LucideIcons.circlePlus,
              color: granted ? colors.success : colors.primary),
        ],
      ),
    );
  }

  Widget _timeRow(AppColors colors, String label, TimeOfDay time, ValueChanged<TimeOfDay> onPick) {
    return AppCard(
      onTap: () async {
        final picked = await CupertinoTimePickerSheet.show(time, title: label);
        if (picked != null) onPick(picked);
      },
      child: Row(
        children: [
          Icon(LucideIcons.clock, color: colors.primary),
          AppSpacing.w12,
          Expanded(child: Label(label, style: AppTextStyles.semiBold14)),
          Label(time.format(Get.context!), style: AppTextStyles.bold16),
        ],
      ),
    );
  }
}

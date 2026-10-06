import 'package:colabhealth/colabhealth.dart';
import 'package:colabhealth/presentation/settings/widgets/theme_bottom_sheet.dart';
import 'package:colabhealth/presentation/settings/widgets/avatar_picker_bottom_sheet.dart';
import 'package:colabhealth/presentation/steps/widgets/step_target_bottom_sheet.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Scaffold(
      backgroundColor: colors.scaffold,
      appBar: AppBar(title: Label('Settings', style: AppTextStyles.semiBold18)),
      body: Obx(() {
        final user = controller.user.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppCard(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: AvatarView(avatar: controller.avatar, size: 64),
                  ),
                  AppSpacing.w16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Label(user?.fullName.isNotEmpty == true ? user!.fullName : 'Your name',
                            style: AppTextStyles.semiBold18),
                        AppSpacing.h4,
                        Label(user?.email ?? '',
                            style: AppTextStyles.regular12.copyWith(color: colors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _editName,
                    icon: Icon(LucideIcons.pencil, color: colors.primary, size: 20),
                  ),
                ],
              ),
            ),
            AppSpacing.h20,
            Label('Preferences', style: AppTextStyles.semiBold16.copyWith(color: colors.textSecondary)),
            AppSpacing.h12,
            _tile(colors, LucideIcons.palette, 'Appearance',
                trailing: Obx(() => Label(_themeLabel(controller.themeMode.value),
                    style: AppTextStyles.medium12.copyWith(color: colors.textSecondary))),
                onTap: () => AppBottomSheet.show(child: const ThemeBottomSheet())),
            _tile(colors, LucideIcons.bell, 'Sleep reminders',
                trailing: Obx(() => Switch(
                      value: controller.remindersOn.value,
                      activeThumbColor: colors.primary,
                      onChanged: controller.toggleReminders,
                    ))),
            _tile(colors, LucideIcons.target, 'Daily step target',
                onTap: () => AppBottomSheet.show(child: const StepTargetBottomSheet()),
                trailing: Obx(() => Label(
                    Get.find<StepsController>().targetRx.value.grouped,
                    style: AppTextStyles.medium12.copyWith(color: colors.textSecondary)))),
            AppSpacing.h20,
            _tile(colors, LucideIcons.logOut, 'Sign out',
                color: colors.error, onTap: controller.signOut),
          ],
        );
      }),
    );
  }

  Widget _tile(AppColors colors, IconData icon, String title,
      {Widget? trailing, VoidCallback? onTap, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color ?? colors.textPrimary, size: 20),
            AppSpacing.w16,
            Expanded(child: Label(title, style: AppTextStyles.semiBold14.copyWith(color: color))),
            ?trailing,
          ],
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode m) => switch (m) {
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
        ThemeMode.system => 'System',
      };

  void _pickAvatar() {
    AppBottomSheet.show(
      child: AvatarPickerBottomSheet(
        selectedId: controller.avatar.id,
        onSelected: (a) => controller.updateProfile(avatarId: a.id),
      ),
    );
  }

  void _editName() {
    final ctrl = TextEditingController(text: controller.user.value?.fullName ?? '');
    AppBottomSheet.show(
      child: AppBottomSheet(
        title: 'Edit name',
        child: Column(
          children: [
            AppTextField(controller: ctrl, hint: 'Full name', prefixIcon: LucideIcons.user),
            AppSpacing.h20,
            AppButton(
              title: 'Save',
              onPressed: () {
                controller.updateProfile(fullName: ctrl.text.trim());
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}

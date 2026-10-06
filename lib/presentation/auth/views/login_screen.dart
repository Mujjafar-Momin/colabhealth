import 'package:colabhealth/colabhealth.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  static const route = '/login';

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                ),
              ),
              AppSpacing.h32,
              Label('Colab Health', style: AppTextStyles.bold32),
              AppSpacing.h8,
              Label(
                'Track your steps, calories and sleep —\nall in one calm place.',
                textAlign: TextAlign.center,
                style: AppTextStyles.medium16.copyWith(color: colors.textSecondary),
              ),
              const Spacer(flex: 3),
              Obx(
                () => AppButton(
                  title: 'Continue with Google',
                  isLoading: controller.state.value.isLoading,
                  onPressed: controller.signInWithGoogle,
                  backgroundColor: colors.surface,
                  textColor: colors.textPrimary,
                  prefix: _googleGlyph(),
                ),
              ),
              AppSpacing.h16,
              Center(
                child: Label(
                  'By continuing you agree to our Terms & Privacy',
                  style: AppTextStyles.regular12.copyWith(color: colors.textSecondary),
                ),
              ),
              AppSpacing.h24,
            ],
          ),
        ),
      ),
    );
  }

  Widget _googleGlyph() => Container(
    width: 22,
    height: 22,
    alignment: Alignment.center,
    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
    child: Text('G', style: AppTextStyles.bold16.copyWith(color: const Color(0xFF4285F4))),
  );
}

import 'package:colabhealth/colabhealth.dart';
import 'package:firebase_core/firebase_core.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const route = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    await AppStorage.init();
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (e) {
      AppLogger.error('Firebase.initializeApp', error: e);
    }
    ApiClient.initialize();
    await NotificationService.instance.init();
    await PushNotificationService.instance.init();
    await AlarmService.instance.init();

    final loggedIn = AuthService.instance.isLoggedIn && AppStorage.isLoggedIn;
    if (!loggedIn) {
      Get.offAllNamed(LoginScreen.route);
    } else if (!AppStorage.onboardingDone) {
      Get.offAllNamed(OnboardingScreen.route);
    } else {
      Get.offAllNamed(HomeScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Scaffold(
      backgroundColor: colors.scaffold,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
            ),
            AppSpacing.h20,
            Label('Colab Health', style: AppTextStyles.bold24),
          ],
        ),
      ),
    );
  }
}

import 'package:colabhealth/colabhealth.dart';

class AppPages {
  AppPages._();

  static const initial = SplashScreen.route;

  static final routes = <GetPage>[
    GetPage(name: SplashScreen.route, page: () => const SplashScreen()),
    GetPage(
      name: LoginScreen.route,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: OnboardingScreen.route,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: HomeScreen.route,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
  ];
}

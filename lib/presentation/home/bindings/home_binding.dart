import 'package:colabhealth/colabhealth.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
    Get.put<DashboardController>(DashboardController());
    Get.put<StepsController>(StepsController());
    Get.put<SleepController>(SleepController());
    Get.put<CaloriesController>(CaloriesController());
    Get.put<SettingsController>(SettingsController());
  }
}

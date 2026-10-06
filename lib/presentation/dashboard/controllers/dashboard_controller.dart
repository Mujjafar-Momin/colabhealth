import 'package:colabhealth/colabhealth.dart';

class DashboardController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  StepsController get steps => Get.find<StepsController>();
  CaloriesController get calories => Get.find<CaloriesController>();
  SleepController get sleep => Get.find<SleepController>();

  Future<void> refreshAll() async {
    await steps.retry();
    await calories.retry(steps: steps.today.value?.steps ?? 0);
    await sleep.load();
  }

  void selectDate(DateTime date) => selectedDate.value = date;

  DateTime get lastSync => AppStorage.lastSyncTime ?? DateTime.now();
}

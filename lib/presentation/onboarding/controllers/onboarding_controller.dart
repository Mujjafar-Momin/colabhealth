import 'package:colabhealth/colabhealth.dart';

class OnboardingController extends GetxController {
  final ProfileRepository _profileRepo = ProfileRepository();

  final PageController pageController = PageController();
  final RxInt page = 0.obs;
  static const int lastPage = 4;

  final RxString avatarId = AvatarModel.all.first.id.obs;
  final RxInt stepTarget = AppState.defaultStepTarget.obs;
  final Rx<TimeOfDay> bedTime = const TimeOfDay(hour: 22, minute: 0).obs;
  final Rx<TimeOfDay> wakeTime = const TimeOfDay(hour: 6, minute: 30).obs;
  final RxBool remindersOn = true.obs;

  final RxBool activityGranted = false.obs;
  final RxBool notificationGranted = false.obs;

  static const int permissionsPage = 1;

  bool get canContinue =>
      page.value != permissionsPage ||
      (activityGranted.value && notificationGranted.value);

  void next() {
    if (page.value >= lastPage) {
      finish();
      return;
    }
    pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void back() {
    if (page.value == 0) return;
    pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Future<void> requestActivityPermission() async {
    final result = await PedometerService.instance.requestPermission();
    activityGranted.value = result == TrackingPermission.granted;
    if (!activityGranted.value) {
      AppToast.show(
          message: 'Step tracking needs activity permission.', type: ToastType.warning);
    }
  }

  Future<void> requestNotificationPermission() async {
    notificationGranted.value = await NotificationService.instance.requestPermission();
  }

  Future<void> finish() async {

    await AppStorage.setAvatarId(avatarId.value);
    await AppStorage.setStepTarget(stepTarget.value);
    await AppStorage.setBedTime(bedTime.value);
    await AppStorage.setWakeTime(wakeTime.value);
    await AppStorage.setRemindersOn(remindersOn.value);
    await AppStorage.setOnboardingDone(true);

    if (remindersOn.value) {
      await NotificationService.instance.scheduleDailyReminder(bedTime.value);
    }

    final uid = AppStorage.uid;
    if (uid.isNotEmpty) {
      final existing = _profileRepo.cached;
      final updated = (existing ??
              UserModel(uid: uid, email: AuthService.instance.currentUser?.email ?? ''))
          .copyWith(
        avatarId: avatarId.value,
        stepTarget: stepTarget.value,
        bedTime: TimeOfDayData.fromTimeOfDay(bedTime.value),
        wakeTime: TimeOfDayData.fromTimeOfDay(wakeTime.value),
        remindersOn: remindersOn.value,
      );
      await _profileRepo.save(updated);
    }

    Get.offAllNamed(HomeScreen.route);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

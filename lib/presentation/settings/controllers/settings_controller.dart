import 'package:colabhealth/colabhealth.dart';

class SettingsController extends GetxController {
  final ProfileRepository _profileRepo = ProfileRepository();
  final AuthRepository _authRepo = AuthRepository();

  final Rxn<UserModel> user = Rxn<UserModel>();
  final Rx<ThemeMode> themeMode = ThemeStore.themeMode.obs;
  final RxBool remindersOn = AppStorage.remindersOn.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = _profileRepo.cached;
    _load();
  }

  Future<void> _load() async {
    final loaded = await _profileRepo.load();
    if (loaded != null) user.value = loaded;
  }

  AvatarModel get avatar => AvatarModel.byId(user.value?.avatarId ?? AppStorage.avatarId);

  Future<void> setTheme(ThemeMode mode) async {
    themeMode.value = mode;
    await ThemeStore.setThemeMode(mode);
    final u = user.value;
    if (u != null) {
      final updated = u.copyWith(themeMode: mode.name);
      user.value = updated;
      await _profileRepo.save(updated);
    }
  }

  Future<void> updateProfile({String? fullName, String? avatarId}) async {
    final u = user.value;
    if (u == null) return;
    final updated = u.copyWith(fullName: fullName, avatarId: avatarId);
    user.value = updated;
    if (avatarId != null) await AppStorage.setAvatarId(avatarId);
    await _profileRepo.save(updated);
    AppToast.show(message: 'Profile updated', type: ToastType.success);
  }

  Future<void> toggleReminders(bool value) async {
    remindersOn.value = value;
    await AppStorage.setRemindersOn(value);
    if (value) {
      await NotificationService.instance.requestPermission();
      await NotificationService.instance.scheduleDailyReminder(AppStorage.bedTime);
    } else {
      await NotificationService.instance.cancelReminder();
    }
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    Get.offAllNamed(LoginScreen.route);
  }
}

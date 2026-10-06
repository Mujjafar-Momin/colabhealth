import 'package:colabhealth/colabhealth.dart';

class SleepController extends GetxController {
  final SleepRepository _repo = SleepRepository();

  final Rx<ViewState> state = ViewState.idle.obs;
  final RxList<SleepModel> logs = <SleepModel>[].obs;
  final RxString error = ''.obs;

  SleepModel? get latest => logs.isEmpty ? null : logs.first;

  @override
  void onInit() {
    super.onInit();
    _loadCached();
    load();
  }

  void _loadCached() {
    final cached = _repo.cachedLogs;
    if (cached.isNotEmpty) {
      logs.assignAll(cached);
      state.value = ViewState.success;
    }
  }

  Future<void> load() async {
    if (logs.isEmpty) state.value = ViewState.loading;
    try {
      final loaded = await _repo.loadLogs();
      logs.assignAll(loaded);
      state.value = ViewState.success;
    } catch (e) {
      if (logs.isEmpty) {
        state.value = ViewState.error;
        error.value = 'Could not load sleep data.';
      }
    }
  }

  Future<void> saveLog(SleepModel log, {bool setAlarm = true}) async {
    final updated = await _repo.saveLog(log);
    logs.assignAll(updated);
    state.value = ViewState.success;

    if (setAlarm) {
      final ok = await AlarmService.instance.scheduleWakeAlarm(
        TimeOfDay(hour: log.sleepEnd.hour, minute: log.sleepEnd.minute),
      );
      AppToast.show(
        message: ok
            ? 'Sleep logged. Wake alarm set for ${log.sleepEnd.timeOfDay}'
            : 'Sleep logged. Could not set the alarm.',
        type: ok ? ToastType.success : ToastType.warning,
      );
    } else {
      AppToast.show(message: 'Sleep logged', type: ToastType.success);
    }
  }

  Future<void> deleteLog(String id) async {
    final updated = await _repo.deleteLog(id);
    logs.assignAll(updated);
  }

  Future<void> importFromHealth() async {
    AppToast.show(message: 'Checking Health data…');
    final imported = await _repo.importFromHealth();
    if (imported == null) {
      AppToast.show(
        message: 'No sleep-stage data found. Log it manually instead.',
        type: ToastType.warning,
      );
      return;
    }
    await saveLog(imported, setAlarm: false);
    AppToast.show(message: 'Imported last night from Health', type: ToastType.success);
  }
}

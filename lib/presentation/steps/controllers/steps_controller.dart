import 'package:colabhealth/colabhealth.dart';

class StepsController extends GetxController {
  final StepsRepository _repo = StepsRepository();

  final Rx<ViewState> state = ViewState.idle.obs;
  final Rxn<StepsModel> today = Rxn<StepsModel>();
  final RxList<StepsModel> weekly = <StepsModel>[].obs;
  final RxString error = ''.obs;
  final RxBool permissionDenied = false.obs;
  final RxBool isOffline = false.obs;

  final Rx<StepsDataStatus> dataStatus = StepsDataStatus.ok.obs;

  final RxBool healthActive = false.obs;

  late final RxInt targetRx = _repo.target.obs;

  int? _healthBaseTotal;
  int? _cumulativeAtHealthRead;

  @override
  void onInit() {
    super.onInit();
    _loadCached();
    init();
  }

  void _loadCached() {
    final cached = _repo.cached;
    if (cached != null && cached.date.isSameDay(DateTime.now())) {
      today.value = cached;
      state.value = ViewState.success;
    }
  }

  Future<void> init() async {
    if (today.value == null) state.value = ViewState.loading;
    await _initHealth();
    await _initPedometer();
    _loadWeekly();

    if (today.value == null) _applySteps(0);
  }

  Future<void> _initHealth() async {
    final availability = await _repo.stepsAvailability();

    if (availability == HealthStepsAvailability.needsInstall) {
      healthActive.value = false;
      dataStatus.value = StepsDataStatus.needsInstall;
      return;
    }
    if (availability == HealthStepsAvailability.notSupported) {

      healthActive.value = false;
      return;
    }

    var granted = await _repo.hasStepsPermission();
    if (!granted) granted = await _repo.requestStepsAuthorization();
    if (!granted) {
      healthActive.value = false;
      dataStatus.value = StepsDataStatus.needsPermission;
      return;
    }

    healthActive.value = true;
    dataStatus.value = StepsDataStatus.ok;
    await _readHealthSteps();
  }

  Future<void> _readHealthSteps() async {
    final total = await _repo.healthTodaySteps();
    if (total != null) {
      _healthBaseTotal = total;
      _cumulativeAtHealthRead = null;
      _applySteps(total);
    }
  }

  Future<void> _initPedometer() async {
    final granted = await PedometerService.instance.requestPermission();
    if (granted != TrackingPermission.granted) {

      permissionDenied.value = !healthActive.value;
      return;
    }
    permissionDenied.value = false;
    _startListening();
  }

  void _startListening() {
    PedometerService.instance.listenStepCount(
      onData: _onStepCount,
      onError: (_) {
        if (today.value == null && !healthActive.value) {
          isOffline.value = true;
          error.value = 'Step sensor unavailable on this device.';
        }
      },
    );
  }

  void _onStepCount(int cumulative) {
    if (healthActive.value && _healthBaseTotal != null) {

      _cumulativeAtHealthRead ??= cumulative;
      final delta = (cumulative - _cumulativeAtHealthRead!).clamp(0, 1 << 30);
      _applySteps(_healthBaseTotal! + delta);
    } else {

      _applySteps(_resolveTodaySteps(cumulative, DateTime.now()));
    }
  }

  void _applySteps(int steps) {
    final model = StepsModel(
      steps: steps,
      date: DateTime.now(),
      target: _repo.target,
      hourly: _syntheticHourly(steps),
    );
    today.value = model;
    state.value = ViewState.success;
    _repo.cacheSteps(model);
    _repo.syncToCloud(model);
  }

  Future<void> installHealthConnect() async {
    await _repo.installHealthConnect();
    AppToast.show(
      message: 'Install Health Connect, then pull down to refresh.',
      type: ToastType.general,
    );
    await init();
  }

  Future<void> requestHealthPermission() async {
    final granted = await _repo.requestStepsAuthorization();
    if (granted) {
      healthActive.value = true;
      dataStatus.value = StepsDataStatus.ok;
      await _readHealthSteps();
    } else {
      AppToast.show(
        message: 'Permission denied. Enable it in Health Connect settings.',
        type: ToastType.warning,
      );
    }
  }

  int _resolveTodaySteps(int cumulative, DateTime now) {
    final storedDate = AppStorage.stepBaselineDate;
    var baseline = AppStorage.stepBaseline;

    final isNewDay = storedDate == null || !storedDate.isSameDay(now);
    final rebooted = baseline != null && cumulative < baseline;

    if (baseline == null || isNewDay || rebooted) {
      final alreadyToday =
          (!isNewDay && (today.value?.date.isSameDay(now) ?? false))
              ? today.value!.steps
              : 0;
      baseline = cumulative - alreadyToday;
      AppStorage.setStepBaseline(baseline, now);
    }

    return (cumulative - baseline).clamp(0, 1 << 30);
  }

  List<int> _syntheticHourly(int total) {
    const weights = [1, 1, 0, 0, 0, 1, 3, 6, 5, 4, 3, 4, 5, 4, 3, 4, 6, 7, 6, 4, 3, 2, 1, 1];
    final sum = weights.fold<int>(0, (a, b) => a + b);
    return weights.map((w) => (total * w / sum).round()).toList();
  }

  Future<void> _loadWeekly() async {
    final history = await _repo.weeklyHistory();
    if (history.isNotEmpty) weekly.assignAll(history);
  }

  Future<void> retry() async {
    permissionDenied.value = false;
    isOffline.value = false;
    _healthBaseTotal = null;
    _cumulativeAtHealthRead = null;
    await init();
  }

  Future<void> setTarget(int value) async {
    await _repo.setTarget(value);
    targetRx.value = value;
    final current = today.value;
    if (current != null) {
      today.value = current.copyWith(target: value);
      _repo.cacheSteps(today.value!);
    }
    AppToast.show(message: 'Daily target set to ${value.grouped} steps', type: ToastType.success);
  }

  int get target => targetRx.value;
}

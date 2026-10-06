import 'package:colabhealth/colabhealth.dart';

class CaloriesController extends GetxController {
  final CaloriesRepository _repo = CaloriesRepository();

  final Rx<ViewState> state = ViewState.idle.obs;
  final Rxn<CaloriesModel> data = Rxn<CaloriesModel>();
  final RxString error = ''.obs;
  final RxBool isOffline = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCached();
    fetch();
  }

  void _loadCached() {
    final cached = _repo.cached;
    if (cached != null) {
      data.value = cached;
      state.value = ViewState.success;
    }
  }

  Future<void> fetch({int steps = 0}) async {
    if (data.value == null) state.value = ViewState.loading;
    error.value = '';

    final res = await _repo.fetchCalories(steps: steps);
    if (res.success && res.data != null) {
      data.value = res.data;
      isOffline.value = false;
      state.value = ViewState.success;
    } else {

      if (data.value != null) {
        isOffline.value = true;
        state.value = ViewState.success;
      } else {
        state.value = ViewState.error;
        error.value = res.error ?? 'Could not load calories.';
      }
    }
  }

  Future<void> retry({int steps = 0}) => fetch(steps: steps);
}

import 'package:colabhealth/core/src/utils/app_enums.dart';
import 'package:colabhealth/data/src/local/app_storage.dart';
import 'package:colabhealth/data/src/local/app_storage_keys.dart';
import 'package:colabhealth/data/src/model/steps_model.dart';
import 'package:colabhealth/data/src/services/firestore_service.dart';
import 'package:colabhealth/data/src/services/health_service.dart';

class StepsRepository {
  final FirestoreService _firestore = FirestoreService.instance;
  final HealthService _health = HealthService.instance;

  Future<HealthStepsAvailability> stepsAvailability() => _health.stepsAvailability();
  Future<void> installHealthConnect() => _health.installHealthConnect();
  Future<bool> hasStepsPermission() => _health.hasStepsPermission();
  Future<bool> requestStepsAuthorization() => _health.requestStepsAuthorization();
  Future<int?> healthTodaySteps() => _health.todaySteps();

  StepsModel? get cached {
    final json = AppStorage.readJson(AppStorageKeys.cachedSteps);
    return json == null ? null : StepsModel.fromJson(json);
  }

  Future<void> cacheSteps(StepsModel model) async {
    await AppStorage.writeJson(AppStorageKeys.cachedSteps, model.toJson());
    await AppStorage.setLastSyncTime(DateTime.now());
  }

  Future<void> syncToCloud(StepsModel model) async {
    final uid = AppStorage.uid;
    if (uid.isEmpty) return;
    await _firestore.saveStepsDaily(uid, model);
  }

  Future<List<StepsModel>> weeklyHistory() async {
    final uid = AppStorage.uid;
    if (uid.isEmpty) return [];
    return _firestore.getStepsRange(uid, days: 7);
  }

  int get target => AppStorage.stepTarget;

  Future<void> setTarget(int value) => AppStorage.setStepTarget(value);
}

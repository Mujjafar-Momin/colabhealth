import 'package:colabhealth/data/src/local/app_storage.dart';
import 'package:colabhealth/data/src/local/app_storage_keys.dart';
import 'package:colabhealth/data/src/model/sleep_model.dart';
import 'package:colabhealth/data/src/services/firestore_service.dart';
import 'package:colabhealth/data/src/services/health_service.dart';

class SleepRepository {
  final FirestoreService _firestore = FirestoreService.instance;
  final HealthService _health = HealthService.instance;

  List<SleepModel> get cachedLogs {
    final list = AppStorage.readJsonList(AppStorageKeys.cachedSleepLogs);
    return list
        .whereType<Map<String, dynamic>>()
        .map(SleepModel.fromJson)
        .toList();
  }

  Future<void> _cache(List<SleepModel> logs) =>
      AppStorage.writeJson(
        AppStorageKeys.cachedSleepLogs,
        logs.map((e) => e.toJson()).toList(),
      );

  Future<List<SleepModel>> loadLogs() async {
    final uid = AppStorage.uid;
    if (uid.isNotEmpty) {
      final remote = await _firestore.getSleepLogs(uid);
      if (remote.isNotEmpty) {
        await _cache(remote);
        return remote;
      }
    }
    return cachedLogs;
  }

  Future<List<SleepModel>> saveLog(SleepModel log) async {
    final logs = cachedLogs..removeWhere((e) => e.id == log.id);
    logs.insert(0, log);
    logs.sort((a, b) => b.sleepEnd.compareTo(a.sleepEnd));
    await _cache(logs);

    final uid = AppStorage.uid;
    if (uid.isNotEmpty) await _firestore.saveSleepLog(uid, log);
    return logs;
  }

  Future<List<SleepModel>> deleteLog(String id) async {
    final logs = cachedLogs..removeWhere((e) => e.id == id);
    await _cache(logs);
    final uid = AppStorage.uid;
    if (uid.isNotEmpty) await _firestore.deleteSleepLog(uid, id);
    return logs;
  }

  Future<SleepModel?> importFromHealth() async {
    final ok = await _health.requestAuthorization();
    if (!ok) return null;
    return _health.importLastNight();
  }

  SleepModel? get latest {
    final logs = cachedLogs;
    return logs.isEmpty ? null : logs.first;
  }
}

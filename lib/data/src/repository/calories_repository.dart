import 'package:colabhealth/data/src/local/app_storage.dart';
import 'package:colabhealth/data/src/local/app_storage_keys.dart';
import 'package:colabhealth/data/src/model/calories_model.dart';
import 'package:colabhealth/data/src/model/res_base_model.dart';
import 'package:colabhealth/data/src/network/api_client.dart';
import 'package:colabhealth/data/src/network/api_config.dart';
import 'package:colabhealth/data/src/network/endpoint_constants.dart';

class CaloriesRepository {

  Future<ResBaseModel<CaloriesModel>> fetchCalories({int steps = 0}) async {
    if (!ApiConfig.hasKey) {
      final cached = _readCache();
      return ResBaseModel(
        success: cached != null,
        statusCode: cached != null ? 200 : 0,
        data: cached,
        error: cached == null
            ? 'No API key set. Pass --dart-define=API_NINJAS_KEY=...'
            : null,
      );
    }

    final minutes = steps > 0 ? (steps / 100).round().clamp(1, 1440) : 30;

    final res = await ApiClient.get<CaloriesModel>(
      url: '${ApiConfig.caloriesBaseUrl}${EndpointConstants.caloriesBurned}',
      query: {'activity': 'walking', 'duration': minutes},
      fromJson: (data) =>
          CaloriesModel.fromApiList(data is List ? data : const []),
    );

    if (res.success && res.data != null) {
      _writeCache(res.data!);
      return res;
    }

    final cached = _readCache();
    if (cached != null) {
      return ResBaseModel(success: true, statusCode: 200, data: cached);
    }
    return res;
  }

  CaloriesModel? _readCache() {
    final json = AppStorage.readJson(AppStorageKeys.cachedCalories);
    return json == null ? null : CaloriesModel.fromJson(json);
  }

  void _writeCache(CaloriesModel model) {
    AppStorage.writeJson(AppStorageKeys.cachedCalories, model.toJson());
    AppStorage.setLastSyncTime(DateTime.now());
  }

  CaloriesModel? get cached => _readCache();
}

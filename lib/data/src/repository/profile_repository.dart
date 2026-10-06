import 'package:colabhealth/data/src/local/app_storage.dart';
import 'package:colabhealth/data/src/local/app_storage_keys.dart';
import 'package:colabhealth/data/src/model/user_model.dart';
import 'package:colabhealth/data/src/services/firestore_service.dart';

class ProfileRepository {
  final FirestoreService _firestore = FirestoreService.instance;

  UserModel? get cached {
    final json = AppStorage.readJson(AppStorageKeys.userProfile);
    return json == null ? null : UserModel.fromJson(json);
  }

  Future<UserModel?> load() async {
    final uid = AppStorage.uid;
    if (uid.isEmpty) return cached;
    final remote = await _firestore.getUser(uid);
    if (remote != null) {
      await AppStorage.writeJson(AppStorageKeys.userProfile, remote.toJson());
      return remote;
    }
    return cached;
  }

  Future<void> save(UserModel user) async {
    await AppStorage.writeJson(AppStorageKeys.userProfile, user.toJson());
    await _firestore.upsertUser(user);
  }
}

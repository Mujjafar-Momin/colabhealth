import 'package:firebase_auth/firebase_auth.dart';

import 'package:colabhealth/data/src/local/app_storage.dart';
import 'package:colabhealth/data/src/model/user_model.dart';
import 'package:colabhealth/data/src/services/auth_service.dart';
import 'package:colabhealth/data/src/services/firestore_service.dart';

class AuthRepository {
  final AuthService _auth = AuthService.instance;
  final FirestoreService _firestore = FirestoreService.instance;

  bool get isLoggedIn => _auth.isLoggedIn;
  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signInWithGoogle() async {
    final user = await _auth.signInWithGoogle();
    if (user == null) return null;

    var profile = await _firestore.getUser(user.uid);
    profile ??= UserModel(
      uid: user.uid,
      email: user.email ?? '',
      fullName: user.displayName ?? '',
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );
    await _firestore.upsertUser(profile);

    await AppStorage.write('uid', user.uid);
    await AppStorage.setLoggedIn(true);
    return profile;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await AppStorage.clearUserData();
  }
}

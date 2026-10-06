import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:colabhealth/core/src/utils/app_logger.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  Stream<User?> get authState => _auth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _google.signIn();
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: auth.accessToken, idToken: auth.idToken);

      final userCred = await _auth.signInWithCredential(credential);
      return userCred.user;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('signInWithGoogle Firebase', error: e);
      rethrow;
    } catch (e) {
      AppLogger.error('signInWithGoogle', error: e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _google.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}

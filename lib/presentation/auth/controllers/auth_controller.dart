import 'package:firebase_auth/firebase_auth.dart';

import 'package:colabhealth/colabhealth.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepo = AuthRepository();

  final Rx<ViewState> state = ViewState.idle.obs;
  final RxString error = ''.obs;

  Future<void> signInWithGoogle() async {
    state.value = ViewState.loading;
    error.value = '';
    try {
      final user = await _authRepo.signInWithGoogle();
      if (user == null) {
        state.value = ViewState.idle;
        return;
      }
      state.value = ViewState.success;
      _routeAfterLogin();
    } on FirebaseAuthException catch (e) {
      state.value = ViewState.error;
      error.value = e.message ?? 'Sign-in failed. Please try again.';
      AppToast.show(message: error.value, type: ToastType.error);
    } catch (e) {
      state.value = ViewState.error;
      error.value = 'Sign-in failed. Please try again.';
      AppToast.show(message: error.value, type: ToastType.error);
    }
  }

  void _routeAfterLogin() {
    if (AppStorage.onboardingDone) {
      Get.offAllNamed(HomeScreen.route);
    } else {
      Get.offAllNamed(OnboardingScreen.route);
    }
  }
}

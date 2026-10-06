import 'package:colabhealth/colabhealth.dart';

class HomeController extends GetxController {
  final RxInt tabIndex = 0.obs;

  void changeTab(int index) => tabIndex.value = index;
}

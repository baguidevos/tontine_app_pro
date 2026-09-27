import 'package:get/get.dart';
import '../../core/services/update_service.dart';

class MainLayoutController extends GetxController {
  var currentIndex = 0.obs;

  @override
  void onReady() {
    super.onReady();
    // Vérification silencieuse de mise à jour au démarrage de l'app
    Future.delayed(const Duration(seconds: 3), () {
      if (Get.isRegistered<UpdateService>()) {
        UpdateService.to.checkForUpdate(silent: true);
      }
    });
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }
}

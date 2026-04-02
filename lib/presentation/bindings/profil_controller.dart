import 'package:get/get.dart';
import 'package:paya_app/presentation/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}

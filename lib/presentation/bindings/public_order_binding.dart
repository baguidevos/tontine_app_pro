import 'package:get/get.dart';
import '../controllers/public_order_controller.dart';

class PublicOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PublicOrderController>(() => PublicOrderController());
  }
}

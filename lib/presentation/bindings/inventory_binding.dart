import 'package:get/get.dart';
import '../controllers/wave_controller.dart';
import '../controllers/product_controller.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WaveController>(() => WaveController());
    Get.lazyPut<ProductController>(() => ProductController());
  }
}

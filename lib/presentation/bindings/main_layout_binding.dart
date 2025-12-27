import 'package:get/get.dart';
import '../controllers/main_layout_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/wave_controller.dart';
import '../controllers/customer_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/profile_controller.dart';

class MainLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainLayoutController>(() => MainLayoutController());
    Get.lazyPut<WaveController>(() => WaveController());
    Get.lazyPut<OrderController>(() => OrderController());
    Get.lazyPut<CustomerController>(() => CustomerController());
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}

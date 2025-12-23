import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/wave_controller.dart';
import '../controllers/customer_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure dependent controllers are initialized first
    Get.lazyPut<WaveController>(() => WaveController());
    Get.lazyPut<OrderController>(() => OrderController());
    Get.lazyPut<CustomerController>(() => CustomerController());

    // Initialize DashboardController
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}

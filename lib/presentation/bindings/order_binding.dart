import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../controllers/payment_controller.dart';
import '../controllers/customer_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderController>(() => OrderController());
    Get.lazyPut<PaymentController>(() => PaymentController());
    Get.lazyPut<CustomerController>(() => CustomerController());
  }
}

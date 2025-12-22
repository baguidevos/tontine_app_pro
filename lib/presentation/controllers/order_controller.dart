import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();
  final AuthService _authService = Get.find<AuthService>();

  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadOrders();
  }

  void _loadOrders() {
    final vendorId = _authService.currentVendorId;
    if (vendorId != null) {
      _orderRepository.watchOrdersByVendor(vendorId).listen((orderList) {
        orders.value = orderList;
      });
    }
  }

  Future<void> createOrder({
    required String customerId,
    required List<OrderItemModel> items,
  }) async {
    final vendorId = _authService.currentVendorId;
    if (vendorId == null) return;

    try {
      isLoading.value = true;

      // Calculate totals
      final totalAmount = items.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

      final order = OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vendorId: vendorId,
        customerId: customerId,
        items: items,
        totalAmount: totalAmount,
        totalPaid: 0.0,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _orderRepository.createOrder(order);

      Get.snackbar('Succès', 'Commande créée avec succès');
      Get.back();
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la création: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrder(OrderModel order) async {
    try {
      await _orderRepository.updateOrder(order);
      Get.snackbar('Succès', 'Commande mise à jour');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la mise à jour: $e');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _orderRepository.deleteOrder(orderId);
      Get.snackbar('Succès', 'Commande supprimée');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la suppression: $e');
    }
  }

  // Helper to get order by ID
  Future<OrderModel?> getOrder(String orderId) async {
    return await _orderRepository.getOrder(orderId);
  }
}

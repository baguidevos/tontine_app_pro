import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tontine_app/core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();
  final AuthService _authService = Get.find<AuthService>();

  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;

  // Expose repository for direct access
  OrderRepository get orderRepository => _orderRepository;

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
    String? waveId,
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
        waveId: waveId,
        items: items,
        totalAmount: totalAmount,
        totalPaid: 0.0,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _orderRepository.createOrder(order);

      Get.back();
      Get.snackbar(
        'Succès',
        'Commande créée avec succès',
        backgroundColor: AppTheme.successGreen,
      );
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

  Future<void> cancelOrder(String orderId) async {
    try {
      final order = await getOrder(orderId);
      if (order != null) {
        final updatedOrder = order.copyWith(status: 'cancelled');
        await _orderRepository.updateOrder(updatedOrder);
        Get.snackbar(
          'Succès',
          'Commande annulée',
          backgroundColor: AppTheme.softRed,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de l\'annulation: $e');
    }
  }

  Future<void> removeItemFromOrder(String orderId, String itemId) async {
    try {
      final order = await getOrder(orderId);
      if (order != null) {
        final updatedItems = order.items
            .where((item) => item.id != itemId)
            .toList();

        if (updatedItems.isEmpty) {
          // If no items left, maybe delete the order or just mark it empty?
          // For now, let's keep it but with 0 totals.
          final updatedOrder = order.copyWith(
            items: [],
            totalAmount: 0,
            totalPaid: 0,
            status: 'cancelled', // Or maybe stay pending but it's empty
          );
          await _orderRepository.updateOrder(updatedOrder);
        } else {
          final newTotalAmount = updatedItems.fold<double>(
            0,
            (sum, it) => sum + it.totalPrice,
          );
          final newTotalPaid = updatedItems.fold<double>(
            0,
            (sum, it) => sum + it.paidAmount,
          );

          final updatedOrder = order.copyWith(
            items: updatedItems,
            totalAmount: newTotalAmount,
            totalPaid: newTotalPaid,
            status: newTotalPaid >= newTotalAmount ? 'completed' : order.status,
          );
          await _orderRepository.updateOrder(updatedOrder);
        }
        Get.snackbar(
          'Succès',
          'Article supprimé',
          backgroundColor: AppTheme.successGreen,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la suppression: $e');
    }
  }

  // Helper to get order by ID
  Future<OrderModel?> getOrder(String orderId) async {
    return await _orderRepository.getOrder(orderId);
  }

  /// Charge les commandes associées à une vague spécifique
  void loadOrdersByWave(String waveId) {
    _orderRepository.watchOrdersByWave(waveId).listen((orderList) {
      orders.value = orderList;
    });
  }
}

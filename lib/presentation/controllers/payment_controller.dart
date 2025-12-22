import 'package:get/get.dart';
import '../../data/models/payment_transaction_model.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/order_repository.dart';

class PaymentController extends GetxController {
  final PaymentRepository _paymentRepository = PaymentRepository();
  final OrderRepository _orderRepository = OrderRepository();

  var isLoading = false.obs;
  var transactions = <PaymentTransactionModel>[].obs;

  // Add a payment to a specific order item
  Future<void> recordPayment({
    required String orderId,
    required String orderItemId,
    required double amount,
    required String method,
  }) async {
    try {
      isLoading.value = true;

      // Create the transaction
      final transaction = PaymentTransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        orderId: orderId,
        orderItemId: orderItemId,
        amount: amount,
        method: method,
        date: DateTime.now(),
      );

      await _paymentRepository.createTransaction(transaction);

      // Update the order item's paid amount
      final order = await _orderRepository.getOrder(orderId);
      if (order != null) {
        final updatedItems = order.items.map((item) {
          if (item.id == orderItemId) {
            return OrderItemModel(
              id: item.id,
              productId: item.productId,
              name: item.name,
              unitPrice: item.unitPrice,
              quantity: item.quantity,
              paidAmount: item.paidAmount + amount,
            );
          }
          return item;
        }).toList();

        // Calculate new total paid
        final newTotalPaid = updatedItems.fold<double>(
          0.0,
          (sum, item) => sum + item.paidAmount,
        );

        final updatedOrder = OrderModel(
          id: order.id,
          vendorId: order.vendorId,
          customerId: order.customerId,
          items: updatedItems,
          totalAmount: order.totalAmount,
          totalPaid: newTotalPaid,
          status: order.status,
          createdAt: order.createdAt,
        );

        await _orderRepository.updateOrder(updatedOrder);
      }

      Get.snackbar('Succès', 'Paiement enregistré avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de l\'enregistrement: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get transaction history for an order item
  Future<void> loadTransactionHistory(String orderItemId) async {
    try {
      isLoading.value = true;
      final history = await _paymentRepository.getTransactionsByOrderItem(
        orderItemId,
      );
      transactions.value = history;
    } catch (e) {
      Get.snackbar('Erreur', 'Échec du chargement: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Watch transaction history in real-time
  void watchTransactionHistory(String orderItemId) {
    _paymentRepository.watchTransactionsByOrderItem(orderItemId).listen((
      history,
    ) {
      transactions.value = history;
    });
  }

  // Delete a transaction (if needed for corrections)
  Future<void> deleteTransaction(
    String transactionId,
    String orderId,
    String orderItemId,
    double amount,
  ) async {
    try {
      await _paymentRepository.deleteTransaction(transactionId);

      // Update the order item's paid amount (subtract)
      final order = await _orderRepository.getOrder(orderId);
      if (order != null) {
        final updatedItems = order.items.map((item) {
          if (item.id == orderItemId) {
            return OrderItemModel(
              id: item.id,
              productId: item.productId,
              name: item.name,
              unitPrice: item.unitPrice,
              quantity: item.quantity,
              paidAmount: (item.paidAmount - amount).clamp(
                0.0,
                double.infinity,
              ),
            );
          }
          return item;
        }).toList();

        final newTotalPaid = updatedItems.fold<double>(
          0.0,
          (sum, item) => sum + item.paidAmount,
        );

        final updatedOrder = OrderModel(
          id: order.id,
          vendorId: order.vendorId,
          customerId: order.customerId,
          items: updatedItems,
          totalAmount: order.totalAmount,
          totalPaid: newTotalPaid,
          status: order.status,
          createdAt: order.createdAt,
        );

        await _orderRepository.updateOrder(updatedOrder);
      }

      Get.snackbar('Succès', 'Transaction supprimée');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la suppression: $e');
    }
  }
}

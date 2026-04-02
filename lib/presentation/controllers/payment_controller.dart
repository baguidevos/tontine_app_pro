import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
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

      // Update the order item's paid amount
      final order = await _orderRepository.getOrder(orderId);
      if (order == null) {
        Get.snackbar(
          'Erreur',
          'Commande introuvable',
          backgroundColor: AppTheme.softRed,
          colorText: Colors.white,
        );
        return;
      }

      final itemIndex = order.items.indexWhere(
        (item) => item.id == orderItemId,
      );
      if (itemIndex == -1) {
        Get.snackbar(
          'Erreur',
          'Article introuvable',
          backgroundColor: AppTheme.softRed,
          colorText: Colors.white,
        );
        return;
      }

      final item = order.items[itemIndex];
      final remainingBalance = item.totalPrice - item.paidAmount;

      if (amount > remainingBalance) {
        Get.snackbar(
          'Paiement refusé',
          'Le montant (${amount.toStringAsFixed(0)} FCFA) dépasse le reste à payer sur cet article (${remainingBalance.toStringAsFixed(0)} FCFA)',
          backgroundColor: AppTheme.softRed,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }

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

      final updatedItems = order.items.map((it) {
        if (it.id == orderItemId) {
          return it.copyWith(paidAmount: it.paidAmount + amount);
        }
        return it;
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
        waveId: order.waveId, // ✅ Préserver le waveId
        items: updatedItems,
        totalAmount: order.totalAmount,
        totalPaid: newTotalPaid,
        status: newTotalPaid >= order.totalAmount ? 'completed' : order.status,
        createdAt: order.createdAt,
      );

      await _orderRepository.updateOrder(updatedOrder);

      Get.snackbar(
        'Succès',
        'Paiement enregistré avec succès',
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de l\'enregistrement: $e',
        backgroundColor: AppTheme.softRed,
        colorText: Colors.white,
      );
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
            return item.copyWith(
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
          waveId: order.waveId, // ✅ Préserver le waveId
          items: updatedItems,
          totalAmount: order.totalAmount,
          totalPaid: newTotalPaid,
          status: newTotalPaid < order.totalAmount ? 'pending' : order.status,
          createdAt: order.createdAt,
        );

        await _orderRepository.updateOrder(updatedOrder);
      }

      Get.snackbar(
        'Succès',
        'Transaction supprimée',
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la suppression: $e',
        backgroundColor: AppTheme.softRed,
        colorText: Colors.white,
      );
    }
  }
}

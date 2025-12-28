import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/customer_controller.dart';
import '../../../data/models/order_model.dart';
import '../../widgets/confirmation_dialog.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({super.key});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final OrderController _orderController = Get.find<OrderController>();
  final PaymentController _paymentController = Get.find<PaymentController>();
  final CustomerController _customerController = Get.find<CustomerController>();

  String? orderId;
  Rx<OrderModel?> order = Rx<OrderModel?>(null);

  @override
  void initState() {
    super.initState();
    try {
      final args = Get.arguments;
      print('DEBUG: OrderDetailsPage initState args: $args');

      if (args is OrderModel) {
        order.value = args;
        orderId = args.id;
        print('DEBUG: Order loaded from args. ID: $orderId');
        // Refresh to ensure up to date?
        // _loadOrder();
      } else if (Get.parameters['id'] != null) {
        orderId = Get.parameters['id'];
        print('DEBUG: Order ID from params: $orderId');
        _loadOrder();
      } else {
        print('ERROR: No order ID found');
      }
    } catch (e, stack) {
      print('ERROR in initState: $e\n$stack');
    }
  }

  Future<void> _loadOrder() async {
    if (orderId == null) return;
    try {
      print('DEBUG: Loading order $orderId...');
      final loaded = await _orderController.getOrder(orderId!);
      if (loaded != null) {
        order.value = loaded;
        print('DEBUG: Order loaded successfully: ${loaded.id}');
      } else {
        print('ERROR: Order not found');
      }
    } catch (e, stack) {
      print('ERROR loading order: $e\n$stack');
    }
  }

  String _getCustomerName(String? customerId) {
    if (customerId == null) return 'ID Client manquant';
    try {
      final customer = _customerController.customers.firstWhereOrNull(
        (c) => c.id == customerId,
      );
      return customer?.name ?? 'Client Inconnu';
    } catch (e) {
      print('ERROR fetching customer name: $e');
      return 'Erreur Client';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        title: const Text(
          'Détails Commande',
          style: TextStyle(color: AppTheme.deepBlue),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepBlue),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            final currentOrder = order.value;
            if (currentOrder != null && currentOrder.status != 'cancelled') {
              return TextButton.icon(
                onPressed: () => _confirmCancelOrder(currentOrder.id),
                icon: const Icon(Icons.cancel, color: AppTheme.softRed),
                label: const Text(
                  'Annuler',
                  style: TextStyle(color: AppTheme.softRed),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        final currentOrder = order.value;
        if (currentOrder == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final customerName = _getCustomerName(currentOrder.customerId);
        final items = currentOrder.items;

        final String orderIdDisplay = currentOrder.id.length > 6
            ? currentOrder.id.substring(currentOrder.id.length - 6)
            : currentOrder.id;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Header Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Commande #$orderIdDisplay',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          _buildStatusChip(currentOrder.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            customerName,
                            style: const TextStyle(
                              color: AppTheme.deepBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 16)),
                          Text(
                            '${currentOrder.totalAmount.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: currentOrder.totalAmount > 0
                            ? currentOrder.totalPaid / currentOrder.totalAmount
                            : 0,
                        backgroundColor: Colors.grey.shade200,
                        color: AppTheme.deepBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Payé: ${currentOrder.totalPaid.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Articles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepBlue,
                ),
              ),
              const SizedBox(height: 16),

              // List of items
              ...(items ?? []).map((item) {
                final double totalPrice = item.unitPrice * item.quantity;
                final double balance = totalPrice - item.paidAmount;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: const Icon(Icons.shopping_bag, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity} x ${item.unitPrice.toStringAsFixed(0)} FCFA',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${totalPrice.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (currentOrder.status != 'cancelled' &&
                                currentOrder.status != 'completed')
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppTheme.softRed,
                                  size: 20,
                                ),
                                onPressed: () => _confirmRemoveItem(
                                  currentOrder.id,
                                  item.id,
                                  item.name,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Supprimer l\'article',
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reste: ${balance.toStringAsFixed(0)} FCFA',
                              style: TextStyle(
                                color: balance > 0 ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.history, size: 20),
                                  color: Colors.grey.shade700,
                                  onPressed: () =>
                                      _showHistory(item, currentOrder.id),
                                  tooltip: 'Historique',
                                ),
                                if (balance > 0)
                                  SizedBox(
                                    width: 100,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () => _showPaymentDialog(
                                        item,
                                        currentOrder.id,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.deepBlue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                      ),
                                      child: const Text('Payer'),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.orange;
    if (status == 'completed') color = Colors.green;
    if (status == 'cancelled') color = Colors.red;

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  void _showPaymentDialog(OrderItemModel item, String orderId) {
    final amountController = TextEditingController(
      text: item.balance.toStringAsFixed(0),
    );

    Get.defaultDialog(
      title: 'Nouveau Paiement',
      content: Column(
        children: [
          Text('Article: ${item.name}'),
          Text('Reste à payer: ${item.balance.toStringAsFixed(0)} FCFA'),
          const SizedBox(height: 16),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Montant',
              border: OutlineInputBorder(),
              suffixText: 'FCFA',
            ),
          ),
        ],
      ),
      textConfirm: 'Confirmer',
      textCancel: 'Annuler',
      confirmTextColor: Colors.white,
      buttonColor: AppTheme.deepBlue,
      onConfirm: () async {
        final amount = double.tryParse(amountController.text);
        if (amount != null && amount > 0) {
          if (amount > item.balance + 1) {
            // Tolerance for float
            Get.snackbar('Erreur', 'Le montant dépasse le reste à payer');
            return;
          }

          Get.back(); // Close dialog first
          await _paymentController.recordPayment(
            orderId: orderId,
            orderItemId: item.id,
            amount: amount,
            method: 'cash', // Default for now
          );

          // Reload order
          _loadOrder();
        }
      },
    );
  }

  void _showHistory(OrderItemModel item, String orderId) {
    // Better: open a bottom sheet with a list watching controller
    _paymentController.loadTransactionHistory(item.id);

    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Historique - ${item.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (_paymentController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final transactions = _paymentController.transactions;

                if (transactions.isEmpty) {
                  return const Center(child: Text('Aucun paiement enregistré'));
                }

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return ListTile(
                      leading: const Icon(Icons.payment, color: Colors.green),
                      title: Text('${tx.amount.toStringAsFixed(0)} FCFA'),
                      subtitle: Text(tx.date.toString().substring(0, 16)),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          // Confirm delete
                          Get.defaultDialog(
                            title: 'Supprimer',
                            middleText: 'Voulez-vous supprimer ce paiement ?',
                            onConfirm: () async {
                              Get.back(); // close confirm
                              await _paymentController.deleteTransaction(
                                tx.id,
                                orderId,
                                item.id,
                                tx.amount,
                              );
                              Get.back(); // close sheet (simpler to reload)
                              _loadOrder();
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancelOrder(String id) {
    Get.dialog(
      ConfirmationDialog(
        title: 'Annuler la commande',
        message:
            'Voulez-vous vraiment annuler cette commande ? Cette action est irréversible.',
        confirmText: 'Oui, annuler',
        cancelText: 'Non',
        isDanger: true,
        onConfirm: () async {
          Get.back(); // Close dialog
          await _orderController.cancelOrder(id);
          _loadOrder();
        },
      ),
    );
  }

  void _confirmRemoveItem(String orderId, String itemId, String itemName) {
    Get.dialog(
      ConfirmationDialog(
        title: 'Supprimer l\'article',
        message: 'Voulez-vous supprimer "$itemName" de cette commande ?',
        confirmText: 'Supprimer',
        cancelText: 'Annuler',
        isDanger: true,
        icon: Icons.delete_outline,
        onConfirm: () async {
          Get.back(); // Close dialog
          await _orderController.removeItemFromOrder(orderId, itemId);
          _loadOrder();
        },
      ),
    );
  }
}

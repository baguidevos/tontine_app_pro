import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/order_model.dart';
import 'package:paya_app/presentation/controllers/customer_controller.dart';
import 'package:paya_app/presentation/controllers/order_controller.dart';
import 'package:paya_app/presentation/controllers/payment_controller.dart';
import 'package:paya_app/presentation/controllers/wave_controller.dart';
import 'package:paya_app/presentation/widgets/confirmation_dialog.dart';
import 'widgets/payment_entry_dialog.dart';
import 'widgets/order_tracking_timeline.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({super.key});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final OrderController _orderController = Get.find<OrderController>();
  final PaymentController _paymentController = Get.find<PaymentController>();
  final CustomerController _customerController = Get.find<CustomerController>();
  final WaveController _waveController = Get.put(WaveController());

  String? orderId;
  Rx<OrderModel?> order = Rx<OrderModel?>(null);

  @override
  void initState() {
    super.initState();
    try {
      final args = Get.arguments;
      if (args is OrderModel) {
        order.value = args;
        orderId = args.id;
      } else {
        final paramId = Get.parameters['id'] ?? Get.parameters['orderId'];
        if (paramId != null && paramId.isNotEmpty) {
          orderId = paramId;
          _loadOrder();
        }
      }
    } catch (e) {
      debugPrint('Error loading order args: $e');
    }
  }

  Future<void> _loadOrder() async {
    if (orderId == null) return;
    try {
      final loaded = await _orderController.getOrder(orderId!);
      if (loaded != null) {
        order.value = loaded;
      }
    } catch (e) {
      debugPrint('Error loading order: $e');
    }
  }

  String _getCustomerName(String? customerId) {
    if (customerId == null) return 'Client non spécifié';
    final customer = _customerController.customers.firstWhereOrNull(
      (c) => c.id == customerId,
    );
    return customer?.name ?? 'Client Inconnu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.payaCream,
      appBar: AppBar(
        title: const Text(
          'Détails de la commande',
          style: TextStyle(
            color: AppTheme.darkerBlue,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.slate200, width: 1),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppTheme.payaBlue),
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            final currentOrder = order.value;
            if (currentOrder != null && currentOrder.status != 'cancelled') {
              return TextButton.icon(
                onPressed: () => _confirmCancelOrder(currentOrder.id),
                icon: const Icon(Icons.cancel_outlined, color: AppTheme.payaRed, size: 18),
                label: const Text(
                  'Annuler',
                  style: TextStyle(color: AppTheme.payaRed, fontWeight: FontWeight.w600),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final currentOrder = order.value;
        if (currentOrder == null) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.payaBlue));
        }

        final customerName = _getCustomerName(currentOrder.customerId);
        final customer = _customerController.customers.firstWhereOrNull(
          (c) => c.id == currentOrder.customerId,
        );
        final items = currentOrder.items;

        final String orderIdDisplay = currentOrder.id.length > 6
            ? currentOrder.id.substring(currentOrder.id.length - 6).toUpperCase()
            : currentOrder.id.toUpperCase();

        final double remainingTotal = (currentOrder.totalAmount - currentOrder.totalPaid).clamp(0, double.infinity);
        final double progress = currentOrder.totalAmount > 0
            ? (currentOrder.totalPaid / currentOrder.totalAmount).clamp(0.0, 1.0)
            : 0.0;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Invoice Overview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.modernCardDecoration(
                  borderRadius: 22,
                  hasShadow: true,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Commande #$orderIdDisplay',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: AppTheme.darkerBlue,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Client: $customerName',
                              style: const TextStyle(
                                color: AppTheme.slate600,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        _buildStatusBadge(currentOrder.status),
                      ],
                    ),

                    if (currentOrder.waveId != null) ...[
                      const SizedBox(height: 10),
                      Obx(() {
                        final wave = _waveController.waves.firstWhereOrNull(
                          (w) => w.id == currentOrder.waveId,
                        );
                        if (wave == null) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.orangeLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.campaign_rounded, size: 14, color: AppTheme.payaOrange),
                              const SizedBox(width: 6),
                              Text(
                                'Campagne: ${wave.name}',
                                style: const TextStyle(
                                  color: AppTheme.payaOrange,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: AppTheme.slate100, height: 1),
                    ),

                    // Financial metrics row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricBox(
                          label: 'Montant Total',
                          value: '${currentOrder.totalAmount.toStringAsFixed(0)} F',
                          color: AppTheme.payaBlue,
                        ),
                        _buildMetricBox(
                          label: 'Déjà Encaissé',
                          value: '${currentOrder.totalPaid.toStringAsFixed(0)} F',
                          color: AppTheme.payaGreen,
                        ),
                        _buildMetricBox(
                          label: 'Reste à Payer',
                          value: '${remainingTotal.toStringAsFixed(0)} F',
                          color: remainingTotal > 0 ? AppTheme.payaOrange : AppTheme.slate500,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: AppTheme.slate100,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0 ? AppTheme.payaGreen : AppTheme.payaBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progression du règlement',
                          style: TextStyle(fontSize: 11, color: AppTheme.slate500),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.slate700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Suivi de Commande & Actions WhatsApp
              OrderTrackingTimeline(
                order: currentOrder,
                customer: customer,
                onOrderUpdated: () => _loadOrder(),
              ),

              const SizedBox(height: 20),

              // Articles Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Articles commandés',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkerBlue,
                    ),
                  ),
                  Text(
                    '${items.length} article(s)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.slate500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Items List
              ...items.map((item) {
                final double totalPrice = item.unitPrice * item.quantity;
                final double balance = (totalPrice - item.paidAmount).clamp(0, double.infinity);
                final double itemProgress = totalPrice > 0 ? (item.paidAmount / totalPrice).clamp(0.0, 1.0) : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.slate200.withValues(alpha: 0.8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.payaBlue.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.inventory_2_rounded,
                              size: 22,
                              color: AppTheme.payaBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppTheme.slate900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.quantity} x ${item.unitPrice.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.slate500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${totalPrice.toStringAsFixed(0)} F',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppTheme.darkerBlue,
                                ),
                              ),
                              if (currentOrder.status != 'cancelled' &&
                                  currentOrder.status != 'completed')
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppTheme.payaRed,
                                    size: 18,
                                  ),
                                  onPressed: () => _confirmRemoveItem(
                                    currentOrder.id,
                                    item.id,
                                    item.name,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Supprimer',
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: itemProgress,
                          minHeight: 4,
                          backgroundColor: AppTheme.slate100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            itemProgress >= 1.0 ? AppTheme.payaGreen : AppTheme.payaOrange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            balance > 0
                                ? 'Reste: ${balance.toStringAsFixed(0)} FCFA'
                                : 'Totalement payé ✓',
                            style: TextStyle(
                              color: balance > 0 ? AppTheme.payaOrange : AppTheme.payaGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.slate100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_rounded,
                                    size: 16,
                                    color: AppTheme.slate700,
                                  ),
                                ),
                                onPressed: () => _showHistory(item, currentOrder.id),
                                tooltip: 'Historique',
                              ),
                              if (balance > 0 && currentOrder.status != 'cancelled') ...[
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _showPaymentDialog(
                                    item,
                                    currentOrder.id,
                                  ),
                                  icon: const Icon(Icons.add_rounded, size: 16),
                                  label: const Text('Encaisser'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.payaBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.slate500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;
    String label;

    switch (status) {
      case 'completed':
        color = AppTheme.payaGreen;
        bgColor = AppTheme.greenLight;
        label = 'Soldée';
        break;
      case 'cancelled':
        color = AppTheme.payaRed;
        bgColor = AppTheme.redLight;
        label = 'Annulée';
        break;
      case 'pending':
      default:
        color = AppTheme.payaOrange;
        bgColor = AppTheme.orangeLight;
        label = 'En cours';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _showPaymentDialog(OrderItemModel item, String orderId) {
    Get.dialog(
      PaymentEntryDialog(
        item: item,
        onConfirm: (amount) async {
          Get.back();
          await _paymentController.recordPayment(
            orderId: orderId,
            orderItemId: item.id,
            amount: amount,
            method: 'cash',
          );
          _loadOrder();
        },
      ),
    );
  }

  void _showHistory(OrderItemModel item, String orderId) {
    _paymentController.loadTransactionHistory(item.id);

    Get.bottomSheet(
      Container(
        height: Get.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.slate200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Paiements : ${item.name}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkerBlue,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (_paymentController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.payaBlue));
                }
                final transactions = _paymentController.transactions;

                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded, size: 40, color: AppTheme.slate300),
                        const SizedBox(height: 12),
                        const Text(
                          'Aucun paiement enregistré pour cet article',
                          style: TextStyle(color: AppTheme.slate500, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.slate50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.slate200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.greenLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: AppTheme.payaGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '+ ${tx.amount.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppTheme.darkerBlue,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tx.date.toString().substring(0, 16),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.slate500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppTheme.payaRed,
                              size: 18,
                            ),
                            onPressed: () {
                              Get.defaultDialog(
                                title: 'Supprimer le paiement',
                                middleText: 'Voulez-vous supprimer ce versement de ${tx.amount.toStringAsFixed(0)} FCFA ?',
                                textConfirm: 'Supprimer',
                                textCancel: 'Annuler',
                                buttonColor: AppTheme.payaRed,
                                confirmTextColor: Colors.white,
                                onConfirm: () async {
                                  Get.back();
                                  await _paymentController.deleteTransaction(
                                    tx.id,
                                    orderId,
                                    item.id,
                                    tx.amount,
                                  );
                                  Get.back();
                                  _loadOrder();
                                },
                              );
                            },
                          ),
                        ],
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
        message: 'Voulez-vous vraiment annuler cette commande ? Cette action est irréversible.',
        confirmText: 'Oui, annuler',
        cancelText: 'Non, garder',
        isDanger: true,
        onConfirm: () async {
          Get.back();
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
        icon: Icons.delete_outline_rounded,
        onConfirm: () async {
          Get.back();
          await _orderController.removeItemFromOrder(orderId, itemId);
          _loadOrder();
        },
      ),
    );
  }
}

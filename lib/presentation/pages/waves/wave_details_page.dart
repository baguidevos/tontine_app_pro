import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/wave_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/customer_controller.dart';
import '../../../data/models/wave_model.dart';
import '../../../data/models/order_model.dart';

class WaveDetailsPage extends StatefulWidget {
  const WaveDetailsPage({super.key});

  @override
  State<WaveDetailsPage> createState() => _WaveDetailsPageState();
}

class _WaveDetailsPageState extends State<WaveDetailsPage> {
  late final WaveModel wave;
  late final OrderController orderController;
  late final WaveController waveController;
  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    orderController = Get.find<OrderController>();
    waveController = Get.find<WaveController>();

    // Récupérer la vague passée en argument
    try {
      final args = Get.arguments;
      if (args is WaveModel) {
        wave = args;
        _loadOrders();
      } else {
        Get.snackbar(
          'Erreur',
          'Aucune vague sélectionnée',
          backgroundColor: AppTheme.softRed,
          colorText: Colors.white,
        );
        Future.delayed(Duration.zero, () => Get.back());
      }
    } catch (e) {
      print('ERROR: Failed to get wave from arguments: $e');
      Get.snackbar(
        'Erreur',
        'Erreur de chargement de la vague',
        backgroundColor: AppTheme.softRed,
        colorText: Colors.white,
      );
      Future.delayed(Duration.zero, () => Get.back());
    }
  }

  void _loadOrders() {
    setState(() {
      _isLoading.value = true;
    });

    // Utiliser le stream pour écouter les commandes de cette vague
    orderController.orderRepository.watchOrdersByWave(wave.id).listen((
      orderList,
    ) {
      _orders.value = orderList;
      _isLoading.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        title: Text(
          wave.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.deepBlue,
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: AppTheme.deepBlue.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune commande',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cette vague n\'a pas encore de commandes',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/orders/create'),
                  icon: const Icon(Icons.add),
                  label: const Text('Créer une commande'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deepBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        // Calculer les statistiques
        final totalOrders = _orders.length;
        final completedOrders = _orders
            .where((o) => o.status == 'completed')
            .length;
        final pendingOrders = _orders
            .where((o) => o.status == 'pending')
            .length;
        final cancelledOrders = _orders
            .where((o) => o.status == 'cancelled')
            .length;
        final totalRevenue = _orders.fold<double>(
          0.0,
          (sum, order) => sum + order.totalPaid,
        );
        final totalDebt = _orders.fold<double>(
          0.0,
          (sum, order) => sum + (order.totalAmount - order.totalPaid),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de la vague
              _buildWaveHeader(wave),

              const SizedBox(height: 24),

              // Statistiques
              _buildStatsCard(
                totalOrders,
                completedOrders,
                pendingOrders,
                cancelledOrders,
                totalRevenue,
                totalDebt,
              ),

              const SizedBox(height: 24),

              // Liste des commandes
              Text(
                'Commandes ($totalOrders)',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orders.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return _buildOrderTile(order, waveController);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWaveHeader(WaveModel wave) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.deepBlue, AppTheme.softBlue],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.waves, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wave.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Créée le ${_formatDate(wave.createdAt)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(wave.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(WaveStatus status) {
    Color color;
    String label;

    switch (status) {
      case WaveStatus.active:
        color = Colors.green;
        label = 'Active';
        break;
      case WaveStatus.closed:
        color = Colors.grey;
        label = 'Clôturée';
        break;
      case WaveStatus.draft:
        color = Colors.orange;
        label = 'Brouillon';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    int totalOrders,
    int completedOrders,
    int pendingOrders,
    int cancelledOrders,
    double totalRevenue,
    double totalDebt,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatItem(
                icon: Icons.shopping_cart,
                label: 'Total',
                value: totalOrders.toString(),
                color: AppTheme.deepBlue,
              ),
              _buildStatItem(
                icon: Icons.check_circle,
                label: 'Payées',
                value: completedOrders.toString(),
                color: Colors.green,
              ),
              _buildStatItem(
                icon: Icons.pending_actions,
                label: 'En attente',
                value: pendingOrders.toString(),
                color: Colors.orange,
              ),
              _buildStatItem(
                icon: Icons.cancel,
                label: 'Annulées',
                value: cancelledOrders.toString(),
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMoneyStat(
                  label: 'Encaissé',
                  value: totalRevenue.toStringAsFixed(0),
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMoneyStat(
                  label: 'Reste à percevoir',
                  value: totalDebt.toStringAsFixed(0),
                  icon: Icons.money_off,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value FCFA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTile(OrderModel order, WaveController waveController) {
    final customerController = Get.find<CustomerController>();
    final customer = customerController.customers.firstWhereOrNull(
      (c) => c.id == order.customerId,
    );
    final customerName = customer?.name ?? 'Client Inconnu';

    return InkWell(
      onTap: () => Get.toNamed('/orders/details', arguments: order),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.deepBlue.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.warmCream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.receipt_long,
                color: AppTheme.deepBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.items.length} article(s) • ${order.totalAmount.toStringAsFixed(0)} FCFA',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildOrderStatusChip(order.status),
                const SizedBox(height: 4),
                Text(
                  _formatDate(order.createdAt),
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'completed':
        color = Colors.green;
        label = 'Payé';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'En attente';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Annulé';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

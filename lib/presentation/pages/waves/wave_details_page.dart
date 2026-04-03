import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/wave_model.dart';
import 'package:paya_app/data/models/order_model.dart';
import 'package:paya_app/data/models/product_model.dart';
import 'package:paya_app/presentation/controllers/customer_controller.dart';
import 'package:paya_app/presentation/controllers/order_controller.dart';
import 'package:paya_app/presentation/controllers/product_controller.dart';
import 'package:paya_app/presentation/controllers/wave_controller.dart';
import 'widgets/product_selection_sheet.dart';
import 'widgets/create_wave_dialog.dart';

class WaveDetailsPage extends StatefulWidget {
  const WaveDetailsPage({super.key});

  @override
  State<WaveDetailsPage> createState() => _WaveDetailsPageState();
}

class _WaveDetailsPageState extends State<WaveDetailsPage> {
  late WaveModel wave;
  late final OrderController orderController;
  late final WaveController waveController;
  late final ProductController productController;
  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final RxList<ProductModel> _products = <ProductModel>[].obs;
  final _isLoading = true.obs;
  final _isRefreshingProducts = false.obs;

  @override
  void initState() {
    super.initState();
    orderController = Get.find<OrderController>();
    waveController = Get.find<WaveController>();

    // Initialize ProductController if not already registered
    if (!Get.isRegistered<ProductController>()) {
      Get.put(ProductController());
    }
    productController = Get.find<ProductController>();

    // Récupérer la vague passée en argument
    try {
      final args = Get.arguments;
      if (args is WaveModel) {
        wave = args;
        _loadProducts();
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

  Future<void> _loadProducts() async {
    // Set refreshing state (only if already loaded once)
    if (!_isLoading.value) {
      _isRefreshingProducts.value = true;
    }

    try {
      // Refresh wave data from Firestore to get latest productIds
      final updatedWave = await waveController.waveRepository.getWave(wave.id);
      if (updatedWave != null) {
        wave = updatedWave;
      }

      // Load products specific to this wave using productIds
      if (wave.productIds.isNotEmpty) {
        final products = await productController.productRepository
            .getProductsByIds(wave.productIds);
        _products.value = products;
      } else {
        _products.value = [];
      }
    } finally {
      _isRefreshingProducts.value = false;
      _isLoading.value = false;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.dialog(CreateWaveDialog(wave: wave));
            },
          ),
        ],
      ),
      body: Obx(() {
        // Check loading state
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
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

              // Produits liés
              _buildProductsSection(),

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

  Widget _buildProductsSection() {
    return Obx(() {
      final products = _products;
      final isRefreshing = _isRefreshingProducts.value;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Produits liés',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      '${products.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (isRefreshing) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.deepBlue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isRefreshing && products.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (products.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.warmCream.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.grey.shade400,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aucun produit lié',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ajoutez des produits pour les associer à cette vague',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warmCream.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.deepBlue.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.warmCream,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: AppTheme.deepBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${product.price.toStringAsFixed(0)} FCFA • ${product.stock} en stock',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppTheme.softRed,
                            size: 22,
                          ),
                          onPressed: () {
                            _confirmRemoveProduct(product);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.bottomSheet(
                    ProductSelectionSheet(
                      initialProductIds: _products.map((p) => p.id).toList(),
                      waveId: wave.id,
                      onProductsUpdated: _loadProducts,
                    ),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    ignoreSafeArea: true,
                  );
                },
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppTheme.deepBlue,
                ),
                label: const Text(
                  'Ajouter un produit',
                  style: TextStyle(
                    color: AppTheme.deepBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.deepBlue,
                  side: const BorderSide(color: AppTheme.deepBlue),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _confirmRemoveProduct(ProductModel product) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Retirer le produit'),
        content: Text(
          'Voulez-vous vraiment retirer "${product.name}" de cette vague ?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              waveController.removeProductFromWave(wave.id, product.id);
              _products.remove(product);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.softRed),
            child: const Text('Retirer'),
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
        border: Border.all(color: AppTheme.payaGray.withOpacity(0.5)),
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
        border: Border.all(color: color.withOpacity(0.2)),
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
        border: Border.all(color: color.withOpacity(0.2)),
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
      splashColor: AppTheme.payaLightBlue,
      onTap: () => Get.toNamed('/orders/details', arguments: order),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.payaGray.withOpacity(0.5)),
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

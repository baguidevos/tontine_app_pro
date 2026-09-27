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

    if (!Get.isRegistered<ProductController>()) {
      Get.put(ProductController());
    }
    productController = Get.find<ProductController>();

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
    if (!_isLoading.value) {
      _isRefreshingProducts.value = true;
    }

    try {
      final updatedWave = await waveController.waveRepository.getWave(wave.id);
      if (updatedWave != null) {
        wave = updatedWave;
      }

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
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppTheme.deepBlue,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.deepBlue),
          onPressed: () => Get.back(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.slate200),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppTheme.deepBlue, size: 20),
              tooltip: 'Modifier la vague',
              onPressed: () {
                Get.dialog(CreateWaveDialog(wave: wave));
              },
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.deepBlue),
            ),
          );
        }

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

        return RefreshIndicator(
          onRefresh: _loadProducts,
          color: AppTheme.deepBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWaveHeader(wave),
                const SizedBox(height: 20),
                _buildProductsSection(),
                const SizedBox(height: 20),
                _buildStatsCard(
                  totalOrders,
                  completedOrders,
                  pendingOrders,
                  cancelledOrders,
                  totalRevenue,
                  totalDebt,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Commandes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.deepBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$totalOrders',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_orders.isEmpty)
                  _buildEmptyOrders()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _orders.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return _buildOrderTile(order, waveController);
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWaveHeader(WaveModel wave) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.deepBlue, Color(0xFF283593), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepBlue.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.waves_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wave.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Créée le ${_formatDate(wave.createdAt)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(wave.status),
            ],
          ),
          if (wave.openDate != null || wave.closeDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  if (wave.openDate != null) ...[
                    const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Début: ${_formatDate(wave.openDate!)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (wave.openDate != null && wave.closeDate != null)
                    Container(
                      height: 12,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.white30,
                    ),
                  if (wave.closeDate != null) ...[
                    const Icon(Icons.event_available_rounded, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Fin: ${_formatDate(wave.closeDate!)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    return Obx(() {
      final products = _products;
      final isRefreshing = _isRefreshingProducts.value;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.slate200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 20, color: AppTheme.deepBlue),
                    const SizedBox(width: 8),
                    const Text(
                      'Produits associés',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.slate900,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.slate100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${products.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.slate600,
                        ),
                      ),
                    ),
                    if (isRefreshing) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.deepBlue),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (isRefreshing && products.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ] else if (products.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.slate50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.slate200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: AppTheme.slate400, size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      'Aucun produit lié pour le moment',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.slate700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ajoutez des produits pour permettre les commandes sur cette vague',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.slate500,
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.slate50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.slate200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.deepBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: AppTheme.deepBlue,
                            size: 20,
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
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.slate900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${product.price.toStringAsFixed(0)} FCFA • ${product.stock} en stock',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.slate500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppTheme.softRed,
                            size: 20,
                          ),
                          tooltip: 'Retirer',
                          onPressed: () => _confirmRemoveProduct(product),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 14),
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
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: const Text('Gérer les produits de la vague'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.deepBlue,
                  side: const BorderSide(color: AppTheme.deepBlue, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Retirer le produit', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment retirer "${product.name}" de cette vague ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler', style: TextStyle(color: AppTheme.slate600)),
          ),
          ElevatedButton(
            onPressed: () {
              waveController.removeProductFromWave(wave.id, product.id);
              _products.remove(product);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.softRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(WaveStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case WaveStatus.active:
        bg = AppTheme.payaGreen;
        fg = Colors.white;
        label = 'Active';
        break;
      case WaveStatus.closed:
        bg = Colors.white.withValues(alpha: 0.25);
        fg = Colors.white;
        label = 'Clôturée';
        break;
      case WaveStatus.draft:
        bg = AppTheme.payaOrange;
        fg = Colors.white;
        label = 'Brouillon';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.insights_rounded, size: 20, color: AppTheme.deepBlue),
              SizedBox(width: 8),
              Text(
                'Statistiques de performance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.slate900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.8,
            children: [
              _buildStatItem(
                icon: Icons.receipt_long_rounded,
                label: 'Total commandes',
                value: totalOrders.toString(),
                color: AppTheme.deepBlue,
              ),
              _buildStatItem(
                icon: Icons.check_circle_rounded,
                label: 'Soldées',
                value: completedOrders.toString(),
                color: AppTheme.payaGreen,
              ),
              _buildStatItem(
                icon: Icons.schedule_rounded,
                label: 'En attente',
                value: pendingOrders.toString(),
                color: AppTheme.payaOrange,
              ),
              _buildStatItem(
                icon: Icons.cancel_rounded,
                label: 'Annulées',
                value: cancelledOrders.toString(),
                color: AppTheme.softRed,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMoneyStat(
                  label: 'Total encaissé',
                  value: totalRevenue.toStringAsFixed(0),
                  icon: Icons.arrow_upward_rounded,
                  color: AppTheme.payaGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMoneyStat(
                  label: 'Reste à percevoir',
                  value: totalDebt.toStringAsFixed(0),
                  icon: Icons.hourglass_top_rounded,
                  color: AppTheme.payaOrange,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.slate500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value F',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.slate500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.slate100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined, size: 36, color: AppTheme.slate400),
          ),
          const SizedBox(height: 14),
          const Text(
            'Aucune commande enregistrée',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.slate800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Les commandes créées pour cette vague s\'afficheront ici',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.slate500),
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
    final initials = customerName.trim().isNotEmpty
        ? customerName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Get.toNamed('/orders/details', arguments: order),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.slate200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.deepBlue.withValues(alpha: 0.08),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppTheme.deepBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.slate900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.items.length} article(s) • ${order.totalAmount.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(color: AppTheme.slate500, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildOrderStatusChip(order.status),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(order.createdAt),
                    style: const TextStyle(color: AppTheme.slate400, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.slate400, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'completed':
        color = AppTheme.payaGreen;
        label = 'Soldée';
        break;
      case 'pending':
        color = AppTheme.payaOrange;
        label = 'En cours';
        break;
      case 'cancelled':
        color = AppTheme.softRed;
        label = 'Annulée';
        break;
      default:
        color = AppTheme.slate500;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

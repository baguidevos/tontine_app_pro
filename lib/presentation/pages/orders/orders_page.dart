import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/order_delivery_status.dart';
import 'package:paya_app/presentation/controllers/customer_controller.dart';
import 'package:paya_app/presentation/controllers/order_controller.dart';
import 'package:paya_app/presentation/controllers/wave_controller.dart';
import 'package:paya_app/presentation/widgets/main_layout.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.payaCream,
        appBar: AppBar(
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.slate200, width: 1),
              ),
              child: const Icon(Icons.menu_rounded, size: 20, color: AppTheme.payaBlue),
            ),
            onPressed: () {
              MainLayout.scaffoldKey.currentState?.openDrawer();
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Commandes & Ventes',
            style: TextStyle(
              color: AppTheme.darkerBlue,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.slate200, width: 1),
                ),
                child: const Icon(Icons.search_rounded, size: 20, color: AppTheme.slate700),
              ),
              onPressed: () {
                // Search handler
              },
              tooltip: 'Rechercher',
            ),
            const SizedBox(width: 8),
          ],
          bottom: _buildCustomTabBar(),
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            // Quick Filter / Actions Bar
            _buildQuickActionsSection(),
            const SizedBox(height: 8),

            // Tab Bar View
            const Expanded(
              child: TabBarView(
                children: [
                  OrdersList(status: 'pending'),
                  OrdersList(status: 'completed'),
                  OrdersList(status: 'cancelled'),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.toNamed('/orders/create'),
          backgroundColor: AppTheme.payaBlue,
          elevation: 3,
          icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Nouvelle Vente',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.slate200, width: 1),
        ),
        child: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.slate600,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: AppTheme.payaBlue,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.payaBlue.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pending_actions_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('En cours'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Soldées'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Annulées'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildQuickActionChip(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Nouveau client',
            onTap: () => Get.toNamed('/customers/create'),
          ),
          const SizedBox(width: 8),
          _buildQuickActionChip(
            icon: Icons.people_outline_rounded,
            label: 'Voir clients',
            onTap: () => Get.toNamed('/customers'),
          ),
          const SizedBox(width: 8),
          _buildQuickActionChip(
            icon: Icons.waves_rounded,
            label: 'Mes vagues',
            onTap: () => Get.toNamed('/waves'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.slate200, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppTheme.payaBlue),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.slate700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final String status;

  const OrdersList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderController>();
    final customerController = Get.put(CustomerController());
    final waveController = Get.put(WaveController());

    return Obx(() {
      if (orderController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.payaBlue),
        );
      }

      final orders = orderController.orders.where((o) {
        switch (status) {
          case 'completed':
            return o.status == 'completed';
          case 'cancelled':
            return o.status == 'cancelled';
          case 'pending':
          default:
            return o.status != 'completed' && o.status != 'cancelled';
        }
      }).toList();

      if (orders.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.slate100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 48,
                    color: AppTheme.slate400,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucune commande trouvée',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slate700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  status == 'pending'
                      ? 'Toutes les commandes en cours apparaîtront ici.'
                      : 'Aucune commande dans cette catégorie.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppTheme.slate500),
                ),
                if (status == 'pending') ...[
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/orders/create'),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Créer une vente'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final customer = customerController.customers.firstWhereOrNull(
            (c) => c.id == order.customerId,
          );
          final customerName = customer?.name ?? 'Client inconnu';
          final initial = customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C';

          // Get wave name if waveId is present
          String? waveName;
          if (order.waveId != null) {
            final wave = waveController.waves.firstWhereOrNull(
              (w) => w.id == order.waveId,
            );
            waveName = wave?.name;
          }

          final orderShortId = order.id.length > 6
              ? order.id.substring(order.id.length - 6).toUpperCase()
              : order.id.toUpperCase();

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.slate200.withValues(alpha: 0.8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Get.toNamed('/orders/details', arguments: order);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppTheme.payaBlue.withValues(alpha: 0.08),
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: AppTheme.payaBlue,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
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
                                    fontSize: 15,
                                    color: AppTheme.slate900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Réf: #$orderShortId',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.slate400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildDeliveryBadge(order.trackingStatus),
                              const SizedBox(height: 4),
                              _buildStatusBadge(order.status),
                            ],
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: AppTheme.slate100, height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.slate100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${order.items.length} article(s)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.slate700,
                                  ),
                                ),
                              ),
                              if (waveName != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.orangeLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.campaign_rounded, size: 13, color: AppTheme.payaOrange),
                                      const SizedBox(width: 4),
                                      Text(
                                        waveName,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.payaOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '${order.totalAmount.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              color: AppTheme.payaBlue,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildDeliveryBadge(OrderDeliveryStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: status.color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 11, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.shortLabel,
            style: TextStyle(
              color: status.color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

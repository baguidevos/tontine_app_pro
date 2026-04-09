import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
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
        backgroundColor: AppTheme.warmCream,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              MainLayout.scaffoldKey.currentState?.openDrawer();
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Commandes',
            style: TextStyle(
              color: AppTheme.deepBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: AppTheme.deepBlue),
              onPressed: () {
                // TODO: Implement search
              },
              tooltip: 'Rechercher',
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: AppTheme.deepBlue),
              onPressed: () {
                // TODO: Implement filters
              },
              tooltip: 'Filtres',
            ),
          ],
          bottom: _buildCustomTabBar(),
        ),
        body: Column(
          children: [
            // Quick Actions
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
          backgroundColor: AppTheme.deepBlue,
          icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
          label: const Text(
            'Nouvelle Commande',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.deepBlue,
          indicatorColor: Colors.transparent,
          indicator: BoxDecoration(
            color: AppTheme.deepBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: [
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.pending_actions, size: 16),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'En attente',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle, size: 16),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Payées',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.cancel, size: 16),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Annulées',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions Rapides',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepBlue,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickActionChip(
                  icon: Icons.person_add_outlined,
                  label: 'Nouveau Client',
                  onTap: () => Get.toNamed('/customers/create'),
                ),
                const SizedBox(width: 12),
                _buildQuickActionChip(
                  icon: Icons.people_outline,
                  label: 'Voir Clients',
                  onTap: () => Get.toNamed('/customers'),
                ),
                const SizedBox(width: 12),
                _buildQuickActionChip(
                  icon: Icons.waves_outlined,
                  label: 'Vagues',
                  onTap: () => Get.toNamed('/waves'),
                ),
                const SizedBox(width: 12),
                _buildQuickActionChip(
                  icon: Icons.analytics_outlined,
                  label: 'Statistiques',
                  onTap: () {
                    // TODO: Navigate to stats
                  },
                ),
              ],
            ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.deepBlue.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.deepBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppTheme.deepBlue),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepBlue,
              ),
            ),
          ],
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
        return const Center(child: CircularProgressIndicator());
      }

      final orders = orderController.orders.where((o) {
        switch (status) {
          case 'completed':
            return o.status == 'completed';
          case 'cancelled':
            return o.status == 'cancelled';
          case 'pending':
          default:
            // "Pending" includes everything that is NOT completed or cancelled
            return o.status != 'completed' && o.status != 'cancelled';
        }
      }).toList();

      if (orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: AppTheme.deepBlue.withOpacity(0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune commande',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final customer = customerController.customers.firstWhereOrNull(
            (c) => c.id == order.customerId,
          );
          final customerName = customer?.name ?? 'Client inconnu';

          // Get wave name if waveId is present
          String? waveName;
          if (order.waveId != null) {
            final wave = waveController.waves.firstWhereOrNull(
              (w) => w.id == order.waveId,
            );
            waveName = wave?.name;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppTheme.payaGray.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                'Client: $customerName (#${order.id.substring(order.id.length.clamp(0, 6) == 6 ? order.id.length - 6 : 0)})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('${order.items.length} articles'),
                  const SizedBox(height: 4),
                  Text(
                    'Total: ${order.totalAmount.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: AppTheme.deepBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (waveName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.waves,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          waveName,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_buildStatusChip(order.status)],
              ),
              onTap: () {
                Get.toNamed('/orders/details', arguments: order);
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'completed':
        color = AppTheme.payaSageGreen;
        label = 'Terminée';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Annulée';
        break;
      case 'pending':
      default:
        color = Colors.orange;
        label = 'En cours';
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      autofocus: true,
    );
    // Container(
    //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    //   decoration: BoxDecoration(
    //     color: color.withOpacity(0.1),
    //     borderRadius: BorderRadius.circular(8),
    //     border: Border.all(color: color.withOpacity(0.5)),
    //   ),
    //   child: Text(
    //     label,
    //     style: TextStyle(
    //       color: color,
    //       fontSize: 10,
    //       fontWeight: FontWeight.bold,
    //     ),
    //   ),
    // );
  }
}

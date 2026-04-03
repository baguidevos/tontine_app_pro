import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/services/auth_service.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/presentation/controllers/customer_controller.dart';
import 'package:paya_app/presentation/controllers/dashboard_controller.dart';

import 'waves/widgets/create_wave_dialog.dart';
import 'package:paya_app/data/models/order_model.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final dashboardController = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        leading: const Icon(Icons.dashboard_outlined),
        title: Obx(() {
          final vendor = authService.currentVendor.value;
          return Text(
            'PayaApp - ${vendor?.businessName}' ?? 'Dashboard',
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.deepBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscription Status Card
            Obx(() {
              final vendor = authService.currentVendor.value;
              final isPremium = vendor?.isPremium ?? false;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPremium
                        ? [AppTheme.deepBlue, AppTheme.softBlue]
                        : [
                            AppTheme.sageGreen,
                            AppTheme.sageGreen.withOpacity(0.7),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isPremium ? Icons.star : Icons.account_circle,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPremium ? 'Plan Premium' : 'Plan Gratuit',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isPremium
                                ? 'Accès illimité activé'
                                : '${vendor?.waveLimit ?? 5} vagues • ${vendor?.productLimit ?? 10} produits',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    if (!isPremium)
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: () => Get.toNamed('/subscription'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.sageGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Upgrade'),
                        ),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Stats Grid
            const Text(
              'Statistiques',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Obx(
              () => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    icon: Icons.trending_up,
                    title: 'Revenus Mensuels',
                    value:
                        '${dashboardController.monthlyRevenue.value.toStringAsFixed(0)} FCFA',
                    color: AppTheme.softBlue,
                  ),
                  _buildStatCard(
                    icon: Icons.pending_actions,
                    title: 'Dette Pendante',
                    value:
                        '${dashboardController.pendingDebt.value.toStringAsFixed(0)} FCFA',
                    color: Colors.orange.shade300,
                  ),
                  _buildStatCard(
                    icon: Icons.inventory,
                    title: 'Vagues Actives',
                    value: dashboardController.activeWavesCount.value
                        .toString(),
                    color: AppTheme.sageGreen,
                  ),
                  _buildStatCard(
                    icon: Icons.shopping_cart,
                    title: 'Commandes',
                    value: dashboardController.totalOrdersCount.value
                        .toString(),
                    color: AppTheme.deepBlue,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Actions Rapides',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildQuickAction(
              icon: Icons.add_circle_outline,
              title: 'Nouvelle Vague',
              subtitle: 'Créer une nouvelle vague de produits',
              onTap: () => Get.dialog(const CreateWaveDialog()),
            ),
            const SizedBox(height: 12),
            _buildQuickAction(
              icon: Icons.receipt_long_outlined,
              title: 'Nouvelle Commande',
              subtitle: 'Enregistrer une commande client',
              onTap: () => Get.toNamed('/orders/create'),
            ),
            const SizedBox(height: 12),
            _buildQuickAction(
              icon: Icons.person_add_outlined,
              title: 'Nouveau Client',
              subtitle: 'Ajouter un client à votre base',
              onTap: () => Get.toNamed('/customers/create'),
            ),
            const SizedBox(height: 12),
            _buildQuickAction(
              icon: Icons.people_outline,
              title: 'Mes Clients',
              subtitle: 'Voir la liste de tous les clients',
              onTap: () => Get.toNamed('/customers'),
            ),

            const SizedBox(height: 24),

            // Recent Orders Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Commandes Récentes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Obx(() {
              final recents = dashboardController.recentOrders;
              if (recents.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aucune commande pour le moment',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: recents
                    .map((order) => _buildOrderTile(order))
                    .toList(),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile(OrderModel order) {
    final customerController = Get.find<CustomerController>();
    final customer = customerController.customers.firstWhereOrNull(
      (c) => c.id == order.customerId,
    );
    final customerName = customer?.name ?? 'Client Inconnu';

    return GestureDetector(
      onTap: () => Get.toNamed('/orders/details', arguments: order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warmCream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppTheme.deepBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusChipSmall(order.status),
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

  Widget _buildStatusChipSmall(String status) {
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
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}';
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.deepBlue.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.deepBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.deepBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

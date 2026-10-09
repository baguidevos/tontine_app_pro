import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/services/auth_service.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/presentation/controllers/customer_controller.dart';
import 'package:paya_app/presentation/controllers/dashboard_controller.dart';
import 'package:paya_app/presentation/controllers/main_layout_controller.dart';
import 'package:paya_app/presentation/widgets/main_layout.dart';
import 'waves/widgets/create_wave_dialog.dart';
import 'package:paya_app/data/models/order_model.dart';
import 'package:paya_app/presentation/widgets/in_app_update_banner.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final dashboardController = Get.find<DashboardController>();

    return Scaffold(
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
        title: Obx(() {
          final vendor = authService.currentVendor.value;
          final businessName = vendor?.businessName ?? 'Ma Boutique';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, $businessName 👋',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkerBlue,
                ),
              ),
              const Text(
                'Tableau de bord',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.slate500,
                ),
              ),
            ],
          );
        }),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.slate200, width: 1),
              ),
              child: const Icon(Icons.notifications_none_rounded, size: 20, color: AppTheme.slate700),
            ),
            onPressed: () {
              Get.snackbar(
                'Notifications',
                'Aucune nouvelle notification pour le moment',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 14,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bandeau In-App de mise à jour (Stratégie Flexible)
            const InAppUpdateBanner(),

            // Modern Subscription Banner Card
            Obx(() {
              final vendor = authService.currentVendor.value;
              final isPremium = vendor?.isPremium ?? false;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPremium
                        ? [AppTheme.payaBlue, AppTheme.payaLightBlue]
                        : [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.payaBlue.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPremium ? Icons.verified_rounded : Icons.star_outline_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isPremium ? 'Formule Premium' : 'Formule Découverte',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isPremium)
                          GestureDetector(
                            onTap: () => Get.toNamed('/subscription'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Passer Pro',
                                style: TextStyle(
                                  color: AppTheme.payaBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPremium
                          ? 'Accès illimité aux vagues et clients'
                          : '${vendor?.waveLimit ?? 5} vagues • ${vendor?.productLimit ?? 10} produits max',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isPremium
                          ? 'Votre compte dispose de toutes les fonctionnalités avancées de Paya.'
                          : 'Passez à la formule Pro pour débloquer des vagues illimitées et booster vos ventes.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Modern Quick Action Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Actions rapides',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkerBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.add_shopping_cart_rounded,
                    label: 'Commande',
                    color: AppTheme.payaBlue,
                    bgColor: AppTheme.payaBlue.withValues(alpha: 0.1),
                    onTap: () => Get.toNamed('/orders/create'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.person_add_rounded,
                    label: 'Client',
                    color: AppTheme.payaGreen,
                    bgColor: AppTheme.payaGreen.withValues(alpha: 0.1),
                    onTap: () => Get.toNamed('/customers/create'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.waves_rounded,
                    label: 'Vague',
                    color: AppTheme.payaOrange,
                    bgColor: AppTheme.payaOrange.withValues(alpha: 0.12),
                    onTap: () => Get.dialog(const CreateWaveDialog()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.add_box_rounded,
                    label: 'Produit',
                    color: AppTheme.payaLightBlue,
                    bgColor: AppTheme.payaLightBlue.withValues(alpha: 0.1),
                    onTap: () => Get.toNamed('/products/create'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Modern Stats Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aperçu de l\'activité',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkerBlue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.slate200),
                  ),
                  child: const Text(
                    'Ce mois-ci',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slate600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Obx(
              () => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _buildStatCard(
                    icon: Icons.trending_up_rounded,
                    title: 'Revenus encaissés',
                    value:
                        '${dashboardController.monthlyRevenue.value.toStringAsFixed(0)} F',
                    accentColor: AppTheme.payaGreen,
                    badgeLabel: '+ Encaissé',
                  ),
                  _buildStatCard(
                    icon: Icons.pending_actions_rounded,
                    title: 'Dettes en attente',
                    value:
                        '${dashboardController.pendingDebt.value.toStringAsFixed(0)} F',
                    accentColor: AppTheme.payaOrange,
                    badgeLabel: 'À recouvrer',
                  ),
                  _buildStatCard(
                    icon: Icons.waves_rounded,
                    title: 'Vagues actives',
                    value: dashboardController.activeWavesCount.value.toString(),
                    accentColor: AppTheme.payaBlue,
                    badgeLabel: 'En cours',
                  ),
                  _buildStatCard(
                    icon: Icons.receipt_long_rounded,
                    title: 'Commandes totales',
                    value: dashboardController.totalOrdersCount.value.toString(),
                    accentColor: AppTheme.payaLightBlue,
                    badgeLabel: 'Total',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // Recent Orders Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Commandes récentes',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkerBlue,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.find<MainLayoutController>().changeTab(1);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Voir tout',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.payaBlue,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.payaBlue),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Obx(() {
              final recents = dashboardController.recentOrders;
              if (recents.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: AppTheme.modernCardDecoration(),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.slate100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          size: 36,
                          color: AppTheme.slate400,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Aucune commande pour le moment',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.slate700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Créez votre première commande pour voir l\'activité ici',
                        style: TextStyle(
                          color: AppTheme.slate400,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: recents.map((order) => _buildOrderTile(order)).toList(),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.slate200.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.slate800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color accentColor,
    required String badgeLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.payaBlue.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkerBlue,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.slate500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTile(OrderModel order) {
    final customerController = Get.find<CustomerController>();
    final customer = customerController.customers.firstWhereOrNull(
      (c) => c.id == order.customerId,
    );
    final customerName = customer?.name ?? 'Client Inconnu';
    final initial = customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed('/orders/details', arguments: order),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.payaBlue.withValues(alpha: 0.08),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppTheme.payaBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
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
                      const SizedBox(height: 3),
                      Text(
                        '${order.items.length} article(s) • ${_formatDate(order.createdAt)}',
                        style: const TextStyle(
                          color: AppTheme.slate500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${order.totalAmount.toStringAsFixed(0)} F',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppTheme.darkerBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusChipSmall(order.status),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChipSmall(String status) {
    Color color;
    Color bgColor;
    String label;

    switch (status) {
      case 'completed':
        color = AppTheme.payaGreen;
        bgColor = AppTheme.greenLight;
        label = 'Soldé';
        break;
      case 'pending':
        color = AppTheme.payaOrange;
        bgColor = AppTheme.orangeLight;
        label = 'En cours';
        break;
      case 'cancelled':
        color = AppTheme.payaRed;
        bgColor = AppTheme.redLight;
        label = 'Annulé';
        break;
      default:
        color = AppTheme.slate600;
        bgColor = AppTheme.slate100;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}

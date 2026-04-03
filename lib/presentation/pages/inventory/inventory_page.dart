import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import '../waves/waves_page.dart';
import '../products/products_page.dart';
import '../waves/widgets/create_wave_dialog.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.warmCream,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Inventaire',
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
            const SizedBox(height: 16),

            // Tab Bar View
            Expanded(
              child: TabBarView(children: [WavesPage(), ProductsPage()]),
            ),
          ],
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
                    Icon(Icons.waves, size: 16),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Vagues',
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
                    Icon(Icons.inventory_2, size: 16),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Produits',
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
                  icon: Icons.add_circle_outline,
                  label: 'Nouvelle Vague',
                  onTap: () => Get.dialog(const CreateWaveDialog()),
                ),
                const SizedBox(width: 12),
                _buildQuickActionChip(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Nouvelle Commande',
                  onTap: () => Get.toNamed('/orders/create'),
                ),
                const SizedBox(width: 12),
                _buildQuickActionChip(
                  icon: Icons.person_add_outlined,
                  label: 'Nouveau Client',
                  onTap: () => Get.toNamed('/customers/create'),
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

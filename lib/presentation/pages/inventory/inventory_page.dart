import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/presentation/widgets/main_layout.dart';
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
            'Gestion & Inventaire',
            style: TextStyle(
              color: AppTheme.darkerBlue,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          bottom: _buildCustomTabBar(),
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            _buildQuickActionsSection(),
            const SizedBox(height: 8),

            // Tab Bar View
            const Expanded(
              child: TabBarView(
                physics: BouncingScrollPhysics(),
                children: [
                  WavesPage(),
                  ProductsPage(),
                ],
              ),
            ),
          ],
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
                  Icon(Icons.waves_rounded, size: 16),
                  SizedBox(width: 8),
                  Text('Vagues'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_rounded, size: 16),
                  SizedBox(width: 8),
                  Text('Produits'),
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildQuickActionChip(
            icon: Icons.add_circle_outline_rounded,
            label: 'Nouvelle Vague',
            onTap: () => Get.dialog(const CreateWaveDialog()),
          ),
          const SizedBox(width: 8),
          _buildQuickActionChip(
            icon: Icons.add_box_outlined,
            label: 'Nouveau Produit',
            onTap: () => Get.toNamed('/products/create'),
          ),
          const SizedBox(width: 8),
          _buildQuickActionChip(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Nouveau Client',
            onTap: () => Get.toNamed('/customers/create'),
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

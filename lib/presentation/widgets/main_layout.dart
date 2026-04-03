import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/services/connectivity_service.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import '../pages/dashboard_page.dart';
import '../pages/inventory/inventory_page.dart';
import '../pages/orders/orders_page.dart';
import '../pages/profile/profile_page.dart';
import '../controllers/main_layout_controller.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();
    final mainLayoutController = Get.find<MainLayoutController>();

    final List<Widget> pages = [
      const DashboardPage(),
      const OrdersPage(),
      const InventoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Obx(() => pages[mainLayoutController.currentIndex.value]),

          // Connectivity Overlay
          Obx(
            () => !connectivityService.isConnected.value
                ? Positioned.fill(
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.wifi_off,
                                      size: 48,
                                      color: AppTheme.deepBlue,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Pas de connexion',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Veuillez vérifier votre connexion internet pour continuer.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    label: 'Accueil',
                    index: 0,
                    currentIndex: mainLayoutController.currentIndex.value,
                    onTap: () => mainLayoutController.changeTab(0),
                  ),
                  _buildNavItem(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long,
                    label: 'Commandes',
                    index: 1,
                    currentIndex: mainLayoutController.currentIndex.value,
                    onTap: () => mainLayoutController.changeTab(1),
                  ),
                  _buildNavItem(
                    icon: Icons.inventory_2_outlined,
                    activeIcon: Icons.inventory_2,
                    label: 'Inventaire',
                    index: 2,
                    currentIndex: mainLayoutController.currentIndex.value,
                    onTap: () => mainLayoutController.changeTab(2),
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profil',
                    index: 3,
                    currentIndex: mainLayoutController.currentIndex.value,
                    onTap: () => mainLayoutController.changeTab(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.deepBlue.withOpacity(0.08) : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppTheme.deepBlue : Colors.grey.shade400,
                  size: isSelected ? 28 : 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 13 : 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppTheme.deepBlue : Colors.grey.shade500,
                ),
                child: Text(label, maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

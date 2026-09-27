import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/services/connectivity_service.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/presentation/widgets/app_drawer.dart';
import '../pages/dashboard_page.dart';
import '../pages/orders/orders_page.dart';
import '../pages/waves/waves_page.dart';
import '../pages/products/products_page.dart';
import '../pages/more/more_menu_page.dart';
import '../controllers/main_layout_controller.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  // Global key to access scaffold state
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();
    final mainLayoutController = Get.find<MainLayoutController>();

    final List<Widget> pages = [
      const DashboardPage(),
      const OrdersPage(),
      const WavesPage(),
      const ProductsPage(),
      const MoreMenuPage(),
    ];

    return Scaffold(
      key: scaffoldKey,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Obx(() => pages[mainLayoutController.currentIndex.value]),

          // Modern Connectivity Overlay
          Obx(
            () => !connectivityService.isConnected.value
                ? Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.35),
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppTheme.slate200,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.redLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.wifi_off_rounded,
                                    size: 36,
                                    color: AppTheme.payaRed,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Connexion interrompue',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Veuillez vérifier votre connexion internet pour continuer à synchroniser vos données.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.slate500,
                                  ),
                                ),
                              ],
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
            border: Border(
              top: BorderSide(
                color: AppTheme.slate200.withValues(alpha: 0.8),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.payaBlue.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    label: 'Accueil',
                    index: 0,
                    currentIndex: mainLayoutController.currentIndex.value,
                    onTap: () => mainLayoutController.changeTab(0),
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long_rounded,
                    label: 'Commandes',
                    index: 1,
                    currentIndex: mainLayoutController.currentIndex.value,
                    onTap: () => mainLayoutController.changeTab(1),
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.campaign_outlined,
                    activeIcon: Icons.campaign_rounded,
                    label: 'Campagnes',
                    index: 2,
                    currentIndex: mainLayoutController.currentIndex.value,
                    onTap: () => mainLayoutController.changeTab(2),
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.shopping_bag_outlined,
                    activeIcon: Icons.shopping_bag_rounded,
                    label: 'Produits',
                    index: 3,
                    currentIndex: mainLayoutController.currentIndex.value,
                    onTap: () => mainLayoutController.changeTab(3),
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view_rounded,
                    label: 'Plus',
                    index: 4,
                    currentIndex: mainLayoutController.currentIndex.value,
                    onTap: () => mainLayoutController.changeTab(4),
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
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppTheme.payaBlue.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.payaBlue.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey<bool>(isSelected),
                    color: isSelected ? AppTheme.payaBlue : AppTheme.slate400,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.payaBlue : AppTheme.slate500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

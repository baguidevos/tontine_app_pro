import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/theme/app_theme.dart';
import '../pages/dashboard_page.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();
    final RxInt currentIndex = 0.obs;

    final List<Widget> pages = [
      const DashboardPage(),
      const Center(child: Text('Commandes')),
      const Center(child: Text('Inventaire')),
      const Center(child: Text('Profil')),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Obx(() => pages[currentIndex.value]),

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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BottomNavigationBar(
              currentIndex: currentIndex.value,
              onTap: (index) => currentIndex.value = index,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: AppTheme.deepBlue,
              unselectedItemColor: AppTheme.darkerBlue.withOpacity(0.5),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  label: 'Commandes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  label: 'Inventaire',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

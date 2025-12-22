import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        title: Obx(() {
          final vendor = authService.currentVendor.value;
          return Text(
            vendor?.businessName ?? 'Dashboard',
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
                      ElevatedButton(
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

            GridView.count(
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
                  value: '0 FCFA',
                  color: AppTheme.softBlue,
                ),
                _buildStatCard(
                  icon: Icons.pending_actions,
                  title: 'Dette Pendante',
                  value: '0 FCFA',
                  color: Colors.orange.shade300,
                ),
                _buildStatCard(
                  icon: Icons.inventory,
                  title: 'Vagues Actives',
                  value: '0',
                  color: AppTheme.sageGreen,
                ),
                _buildStatCard(
                  icon: Icons.shopping_cart,
                  title: 'Commandes',
                  value: '0',
                  color: AppTheme.deepBlue,
                ),
              ],
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
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildQuickAction(
              icon: Icons.receipt_long_outlined,
              title: 'Nouvelle Commande',
              subtitle: 'Enregistrer une commande client',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildQuickAction(
              icon: Icons.person_add_outlined,
              title: 'Nouveau Client',
              subtitle: 'Ajouter un client à votre base',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
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

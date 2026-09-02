import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/wave_model.dart';
import 'package:paya_app/presentation/controllers/auth_controller.dart';
import 'package:paya_app/presentation/controllers/main_layout_controller.dart';
import 'package:paya_app/presentation/controllers/wave_controller.dart';
import 'package:paya_app/presentation/pages/waves/widgets/create_wave_dialog.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final mainLayoutController = Get.find<MainLayoutController>();

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header
          _buildHeader(authController),

          // Navigation & Actions
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions Section
                  _buildSectionTitle('Actions rapides'),
                  _buildQuickActions(context, mainLayoutController),

                  const Divider(height: 24),

                  // Navigation Section
                  _buildSectionTitle('Navigation'),
                  _buildNavigationList(mainLayoutController),

                  const Divider(height: 24),

                  // Waves Section
                  _buildSectionTitle('Vagues'),
                  _buildWavesSection(context),

                  const Divider(height: 24),

                  // Management Section
                  _buildSectionTitle('Gestion'),
                  _buildManagementSection(context),
                ],
              ),
            ),
          ),

          // Footer
          _buildFooter(authController),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthController authController) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 24,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.deepBlue, AppTheme.softBlue],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Paya',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'La Gestion simplifiée',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppTheme.payaOrange,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    MainLayoutController mainLayoutController,
  ) {
    return Column(
      children: [
        _buildActionTile(
          icon: Icons.receipt_long,
          title: 'Nouvelle commande',
          subtitle: 'Créer une commande',
          onTap: () {
            Get.back();
            Get.toNamed('/orders/create');
          },
        ),
        _buildActionTile(
          icon: Icons.person_add,
          title: 'Nouveau client',
          subtitle: 'Ajouter un client',
          onTap: () {
            Get.back();
            Get.toNamed('/customers/create');
          },
        ),
        _buildActionTile(
          icon: Icons.waves,
          title: 'Nouvelle vague',
          subtitle: 'Créer une vague',
          onTap: () {
            Get.back();
            Get.dialog(const CreateWaveDialog());
          },
        ),
        _buildActionTile(
          icon: Icons.shopping_bag,
          title: 'Nouveau produit',
          subtitle: 'Ajouter un produit',
          onTap: () {
            Get.back();
            Get.toNamed('/products/create');
          },
        ),
      ],
    );
  }

  Widget _buildNavigationList(MainLayoutController mainLayoutController) {
    return Obx(() {
      final currentIndex = mainLayoutController.currentIndex.value;

      return Column(
        children: [
          _buildNavTile(
            icon: Icons.dashboard,
            title: 'Tableau de bord',
            isSelected: currentIndex == 0,
            onTap: () {
              Get.back();
              mainLayoutController.changeTab(0);
            },
          ),
          _buildNavTile(
            icon: Icons.receipt_long,
            title: 'Commandes',
            isSelected: currentIndex == 1,
            onTap: () {
              Get.back();
              mainLayoutController.changeTab(1);
            },
          ),
          _buildNavTile(
            icon: Icons.inventory_2,
            title: 'Inventaire',
            isSelected: currentIndex == 2,
            onTap: () {
              Get.back();
              mainLayoutController.changeTab(2);
            },
          ),
          _buildNavTile(
            icon: Icons.person,
            title: 'Profil',
            isSelected: currentIndex == 3,
            onTap: () {
              Get.back();
              mainLayoutController.changeTab(3);
            },
          ),
        ],
      );
    });
  }

  Widget _buildWavesSection(BuildContext context) {
    if (!Get.isRegistered<WaveController>()) {
      return _buildEmptyTile('Contrôleur non disponible');
    }

    final waveController = Get.find<WaveController>();

    return Obx(() {
      final waves = waveController.waves;
      final activeWaves = waves
          .where(
            (w) =>
                w.status == WaveStatus.active || w.status == WaveStatus.draft,
          )
          .toList();

      return Column(
        children: [
          if (activeWaves.isEmpty)
            _buildEmptyTile('Aucune vague active')
          else
            ...activeWaves.take(3).map((wave) {
              return _buildWaveTile(wave);
            }),
          if (activeWaves.length > 3)
            _buildActionTile(
              icon: Icons.arrow_forward,
              title: 'Voir toutes les vagues',
              subtitle: '${activeWaves.length} vagues au total',
              onTap: () {
                Get.back();
                Get.find<MainLayoutController>().changeTab(
                  2,
                ); // Go to inventory
              },
            ),
        ],
      );
    });
  }

  Widget _buildManagementSection(BuildContext context) {
    return Column(
      children: [
        _buildActionTile(
          icon: Icons.people,
          title: 'Clients',
          subtitle: 'Gérer les clients',
          onTap: () {
            Get.back();
            Get.toNamed('/customers');
          },
        ),
        _buildActionTile(
          icon: Icons.shopping_cart,
          title: 'Produits',
          subtitle: 'Gérer les produits',
          onTap: () {
            Get.back();
            Get.find<MainLayoutController>().changeTab(2);
          },
        ),
        _buildActionTile(
          icon: Icons.analytics,
          title: 'Statistiques',
          subtitle: 'Voir les statistiques',
          onTap: () {
            Get.back();
            Get.find<MainLayoutController>().changeTab(0);
          },
        ),
      ],
    );
  }

  Widget _buildFooter(AuthController authController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Version 0.7.0',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Get.defaultDialog(
                  title: 'Déconnexion',
                  middleText: 'Êtes-vous sûr de vouloir vous déconnecter ?',
                  textCancel: 'Annuler',
                  textConfirm: 'Déconnexion',
                  confirmTextColor: Colors.white,
                  onConfirm: () async {
                    Get.back(); // Close dialog
                    await authController.logout();
                  },
                  buttonColor: AppTheme.softRed,
                  cancelTextColor: AppTheme.deepBlue,
                );
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Déconnexion'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.softRed,
                side: const BorderSide(color: AppTheme.softRed),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.deepBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppTheme.deepBlue),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.deepBlue : Colors.grey.shade600,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.deepBlue : Colors.grey.shade700,
        ),
      ),
      trailing: isSelected
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.deepBlue,
                shape: BoxShape.circle,
              ),
            )
          : null,
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      tileColor: isSelected ? AppTheme.deepBlue.withOpacity(0.05) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildWaveTile(dynamic wave) {
    Color statusColor;
    switch (wave.status) {
      case WaveStatus.active:
        statusColor = AppTheme.successGreen;
        break;
      case WaveStatus.closed:
        statusColor = AppTheme.softRed;
        break;
      case WaveStatus.draft:
      default:
        statusColor = AppTheme.payaOrange;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.waves, size: 20, color: statusColor),
      ),
      title: Text(
        wave.name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        'Produits: ${wave.productIds.length}',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: () {
        Get.back();
        Get.toNamed('/waves/details', arguments: wave);
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  Widget _buildEmptyTile(String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

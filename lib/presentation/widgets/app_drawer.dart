import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/wave_model.dart';
import 'package:paya_app/presentation/controllers/auth_controller.dart';
import 'package:paya_app/presentation/controllers/main_layout_controller.dart';
import 'package:paya_app/presentation/controllers/wave_controller.dart';
import 'package:paya_app/presentation/pages/waves/widgets/create_wave_dialog.dart';
import 'package:paya_app/presentation/widgets/logout_bottom_sheet.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final mainLayoutController = Get.find<MainLayoutController>();

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 16,
      child: Column(
        children: [
          // Header
          _buildHeader(authController),

          // Navigation & Actions
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions Section
                  _buildSectionTitle('Actions rapides'),
                  _buildQuickActions(context, mainLayoutController),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: AppTheme.slate200, height: 1),
                  ),

                  // Navigation Section
                  _buildSectionTitle('Navigation'),
                  _buildNavigationList(mainLayoutController),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: AppTheme.slate200, height: 1),
                  ),

                  // Waves Section
                  _buildSectionTitle('Campagnes récentes'),
                  _buildWavesSection(context),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: AppTheme.slate200, height: 1),
                  ),

                  // Management Section
                  _buildSectionTitle('Gestion'),
                  _buildManagementSection(context),
                ],
              ),
            ),
          ),

          // Footer
          _buildFooter(context, authController),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthController authController) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 20,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.payaBlue, AppTheme.payaLightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.storefront_rounded,
                      color: AppTheme.payaBlue,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PAYA',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Commerce & Tontine',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Gestion simplifiée de vos ventes',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.slate400,
          letterSpacing: 1.1,
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
          icon: Icons.add_shopping_cart_rounded,
          iconColor: AppTheme.payaBlue,
          bgColor: AppTheme.payaBlue.withValues(alpha: 0.1),
          title: 'Nouvelle commande',
          subtitle: 'Enregistrer une vente',
          onTap: () {
            Get.back();
            Get.toNamed('/orders/create');
          },
        ),
        _buildActionTile(
          icon: Icons.person_add_alt_1_rounded,
          iconColor: AppTheme.payaGreen,
          bgColor: AppTheme.payaGreen.withValues(alpha: 0.1),
          title: 'Nouveau client',
          subtitle: 'Ajouter au répertoire',
          onTap: () {
            Get.back();
            Get.toNamed('/customers/create');
          },
        ),
        _buildActionTile(
          icon: Icons.campaign_rounded,
          iconColor: AppTheme.payaOrange,
          bgColor: AppTheme.payaOrange.withValues(alpha: 0.1),
          title: 'Nouvelle campagne',
          subtitle: 'Lancer un cycle de vente ou tontine',
          onTap: () {
            Get.back();
            Get.dialog(const CreateWaveDialog());
          },
        ),
        _buildActionTile(
          icon: Icons.inventory_2_rounded,
          iconColor: AppTheme.payaLightBlue,
          bgColor: AppTheme.payaLightBlue.withValues(alpha: 0.1),
          title: 'Nouveau produit',
          subtitle: 'Ajouter au catalogue',
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
            icon: Icons.dashboard_rounded,
            title: 'Tableau de bord',
            isSelected: currentIndex == 0,
            onTap: () {
              Get.back();
              mainLayoutController.changeTab(0);
            },
          ),
          _buildNavTile(
            icon: Icons.receipt_long_rounded,
            title: 'Commandes',
            isSelected: currentIndex == 1,
            onTap: () {
              Get.back();
              mainLayoutController.changeTab(1);
            },
          ),
          _buildNavTile(
            icon: Icons.campaign_rounded,
            title: 'Campagnes de vente',
            isSelected: currentIndex == 2,
            onTap: () {
              Get.back();
              mainLayoutController.changeTab(2);
            },
          ),
          _buildNavTile(
            icon: Icons.shopping_bag_rounded,
            title: 'Catalogue Produits',
            isSelected: currentIndex == 3,
            onTap: () {
              Get.back();
              mainLayoutController.changeTab(3);
            },
          ),
          _buildNavTile(
            icon: Icons.grid_view_rounded,
            title: 'Plus d\'options',
            isSelected: currentIndex == 4,
            onTap: () {
              Get.back();
              mainLayoutController.changeTab(4);
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
            _buildEmptyTile('Aucune campagne active pour l\'instant')
          else
            ...activeWaves.take(3).map((wave) {
              return _buildWaveTile(wave);
            }),
          if (activeWaves.length > 3)
            _buildActionTile(
              icon: Icons.arrow_forward_rounded,
              iconColor: AppTheme.payaBlue,
              bgColor: AppTheme.payaBlue.withValues(alpha: 0.08),
              title: 'Voir toutes les campagnes',
              subtitle: '${activeWaves.length} campagnes enregistrées',
              onTap: () {
                Get.back();
                Get.find<MainLayoutController>().changeTab(2);
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
          icon: Icons.people_alt_rounded,
          iconColor: AppTheme.payaBlue,
          bgColor: AppTheme.payaBlue.withValues(alpha: 0.08),
          title: 'Clients & Adhérents',
          subtitle: 'Liste et suivi des clients',
          onTap: () {
            Get.back();
            Get.toNamed('/customers');
          },
        ),
        _buildActionTile(
          icon: Icons.stars_rounded,
          iconColor: AppTheme.payaOrange,
          bgColor: AppTheme.payaOrange.withValues(alpha: 0.1),
          title: 'Abonnement & Formules',
          subtitle: 'Gérer votre formule Paya',
          onTap: () {
            Get.back();
            Get.toNamed('/subscription');
          },
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, AuthController authController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.slate50,
        border: Border(top: BorderSide(color: AppTheme.slate200, width: 1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 16, color: AppTheme.payaGreen),
                  const SizedBox(width: 6),
                  Text(
                    'Paya v0.10.0 Pro',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slate600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.greenLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Actif',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.payaGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showLogoutSheet(context, authController),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Déconnexion'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.payaRed,
                side: BorderSide(color: AppTheme.payaRed.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.slate800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppTheme.slate500),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: AppTheme.slate400,
        ),
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.payaBlue.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.payaBlue : AppTheme.slate500,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppTheme.payaBlue : AppTheme.slate800,
            fontSize: 14,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppTheme.payaBlue,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildWaveTile(WaveModel wave) {
    Color statusColor;
    String statusLabel;
    switch (wave.status) {
      case WaveStatus.active:
        statusColor = AppTheme.payaGreen;
        statusLabel = 'En cours';
        break;
      case WaveStatus.closed:
        statusColor = AppTheme.payaRed;
        statusLabel = 'Clôturée';
        break;
      case WaveStatus.draft:
        statusColor = AppTheme.payaOrange;
        statusLabel = 'Brouillon';
    }

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.campaign_rounded, size: 20, color: statusColor),
        ),
        title: Text(
          wave.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          '${wave.productIds.length} produits • $statusLabel',
          style: const TextStyle(fontSize: 11, color: AppTheme.slate500),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: AppTheme.slate400,
        ),
        onTap: () {
          Get.back();
          Get.toNamed('/waves/details', arguments: wave);
        },
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildEmptyTile(String message) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.slate400,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

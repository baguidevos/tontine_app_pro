import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/core/services/auth_service.dart';
import 'package:paya_app/core/services/whatsapp_service.dart';
import 'package:paya_app/presentation/widgets/main_layout.dart';
import 'package:paya_app/presentation/controllers/auth_controller.dart';
import 'package:paya_app/presentation/widgets/logout_bottom_sheet.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:paya_app/core/services/update_service.dart';
import 'package:paya_app/core/services/subscription_service.dart';

class MoreMenuPage extends StatelessWidget {
  const MoreMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Plus d\'options',
          style: TextStyle(
            color: AppTheme.darkerBlue,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor Card Profile Summary
            Obx(() {
              final vendor = authService.currentVendor.value;
              final businessName = vendor?.businessName ?? 'Ma Boutique';
              final phone = vendor?.phone ?? '';
              final initial = businessName.isNotEmpty ? businessName[0].toUpperCase() : 'P';
              final subService =
                  Get.isRegistered<SubscriptionService>() ? SubscriptionService.to : null;
              final isPro = (subService?.isPro ?? false) || (vendor?.isPremium ?? false);
              final formulaBadge = subService != null
                  ? (subService.isPro ? 'PRO' : 'GRATUIT')
                  : (isPro ? 'PRO' : 'GRATUIT');

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: AppTheme.modernCardDecoration(borderRadius: 20, hasShadow: true),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.payaBlue, AppTheme.payaLightBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.payaBlue.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  businessName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.darkerBlue,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isPro ? AppTheme.greenLight : AppTheme.orangeLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formulaBadge,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isPro ? AppTheme.payaGreen : AppTheme.payaOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            phone.isNotEmpty ? phone : (vendor?.email ?? 'Connecté'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.slate500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.slate400),
                      onPressed: () => Get.toNamed('/profile'),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Section 1: Modules Métier & Outils
            _buildSectionHeader('GESTION & EXPÉDITION'),
            const SizedBox(height: 10),
            _buildModernTile(
              icon: Icons.chat_bubble_outline_rounded,
              color: const Color(0xFF25D366), // WhatsApp Green
              title: 'Modèles WhatsApp',
              subtitle: 'Personnaliser les 5 messages du cycle de commande',
              badgeText: 'NOUVEAU',
              badgeColor: const Color(0xFF25D366),
              onTap: () => Get.toNamed('/whatsapp/templates'),
            ),
            const SizedBox(height: 10),
            _buildModernTile(
              icon: Icons.people_outline_rounded,
              color: AppTheme.payaBlue,
              title: 'Clients & Répertoire',
              subtitle: 'Coordonnées, historique et soldes clients',
              onTap: () => Get.toNamed('/customers'),
            ),
            const SizedBox(height: 10),
            _buildModernTile(
              icon: Icons.inventory_2_outlined,
              color: AppTheme.payaOrange,
              title: 'Inventaire Global',
              subtitle: 'Aperçu consolidé des stocks et catalogues',
              onTap: () => Get.toNamed('/inventory'),
            ),

            const SizedBox(height: 24),

            // Section 2: Compte & Paramètres
            _buildSectionHeader('COMPTE & BOUTIQUE'),
            const SizedBox(height: 10),
            _buildModernTile(
              icon: Icons.storefront_outlined,
              color: AppTheme.payaLightBlue,
              title: 'Profil & Informations Boutique',
              subtitle: 'Devise, coordonnées et adresse commerciale',
              onTap: () => Get.toNamed('/profile'),
            ),
            const SizedBox(height: 10),
            Obx(() {
              final subService =
                  Get.isRegistered<SubscriptionService>() ? SubscriptionService.to : null;
              final vendor = authService.currentVendor.value;
              final isPro = (subService?.isPro ?? false) || (vendor?.isPremium ?? false);
              final formulaLabel = subService?.formulaDisplayName ?? (isPro ? 'Formule Pro' : 'Formule Gratuite');

              return _buildModernTile(
                icon: Icons.workspace_premium_outlined,
                color: const Color(0xFF8B5CF6),
                title: 'Abonnement & Forfaits',
                subtitle: '$formulaLabel • Gérer votre souscription',
                badgeText: isPro ? 'ACTIF' : null,
                badgeColor: isPro ? AppTheme.payaGreen : null,
                onTap: () => Get.toNamed('/subscription'),
              );
            }),

            const SizedBox(height: 24),

            // Section 3: Assistance & Session
            _buildSectionHeader('ASSISTANCE & SESSION'),
            const SizedBox(height: 10),
            _buildModernTile(
              icon: Icons.support_agent_rounded,
              color: const Color(0xFF0EA5E9),
              title: 'Assistance Paya Support',
              subtitle: 'Discuter avec l\'équipe technique via WhatsApp',
              onTap: () {
                WhatsAppService.launchWhatsAppMessage(
                  phone: '2250700000000', // Paya support hotline
                  message: 'Bonjour l\'équipe Paya, j\'ai besoin d\'aide avec mon compte.',
                );
              },
            ),
            const SizedBox(height: 10),
            _buildModernTile(
              icon: Icons.system_update_rounded,
              color: AppTheme.payaGreen,
              title: 'Mise à jour de l\'application',
              subtitle: 'Vérifier si une nouvelle version est disponible',
              onTap: () {
                UpdateService.to.checkForUpdate(showNotificationIfUpToDate: true);
              },
            ),
            const SizedBox(height: 10),
            _buildModernTile(
              icon: Icons.logout_rounded,
              color: AppTheme.payaRed,
              title: 'Déconnexion',
              subtitle: 'Fermer la session sur cet appareil',
              isDestructive: true,
              onTap: () => showLogoutSheet(context, authController),
            ),

            const SizedBox(height: 32),

            // App version footer
            Center(
              child: Column(
                children: [
                  Obx(() {
                    final updateService =
                        Get.isRegistered<UpdateService>() ? UpdateService.to : null;
                    final dynamicVersion = updateService?.appVersion.value;
                    final subService =
                        Get.isRegistered<SubscriptionService>() ? SubscriptionService.to : null;
                    final vendor = authService.currentVendor.value;
                    final isPro = (subService?.isPro ?? false) || (vendor?.isPremium ?? false);
                    final formula = subService?.formulaShortName ?? (isPro ? 'Pro' : 'Gratuit');

                    if (dynamicVersion != null && dynamicVersion.isNotEmpty) {
                      return Text(
                        'Paya $formula • Version $dynamicVersion',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.slate400,
                        ),
                      );
                    }
                    return FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final version = snapshot.data?.version;
                        final label = version != null
                            ? 'Paya $formula • Version $version'
                            : 'Paya $formula';
                        return Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.slate400,
                          ),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 4),
                  Text(
                    'Simplifiez votre commerce social & vos tontines',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.slate400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppTheme.slate400,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildModernTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDestructive
              ? AppTheme.payaRed.withValues(alpha: 0.15)
              : AppTheme.slate200.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: color.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDestructive ? AppTheme.payaRed : AppTheme.slate900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeText != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (badgeColor ?? color).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: badgeColor ?? color,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDestructive ? AppTheme.payaRed.withValues(alpha: 0.7) : AppTheme.slate500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDestructive ? AppTheme.payaRed.withValues(alpha: 0.4) : AppTheme.slate300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


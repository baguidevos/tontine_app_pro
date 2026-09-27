import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/core/services/auth_service.dart';
import 'package:paya_app/core/services/whatsapp_service.dart';
import 'package:paya_app/presentation/widgets/main_layout.dart';
import 'package:paya_app/presentation/controllers/auth_controller.dart';

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
              final isPro = vendor?.isPremium ?? false;

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
                                  isPro ? 'PRO' : 'ESSAI',
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
            _buildModernTile(
              icon: Icons.workspace_premium_outlined,
              color: const Color(0xFF8B5CF6),
              title: 'Abonnement & Forfaits',
              subtitle: 'Gérer votre souscription et fonctionnalités Pro',
              onTap: () => Get.toNamed('/subscription'),
            ),

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
              icon: Icons.logout_rounded,
              color: AppTheme.payaRed,
              title: 'Déconnexion',
              subtitle: 'Fermer la session sur cet appareil',
              isDestructive: true,
              onTap: () => _showLogoutSheet(context, authController),
            ),

            const SizedBox(height: 32),

            // App version footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Paya Pro • Version 0.9.1',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slate400,
                    ),
                  ),
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


  void _showLogoutSheet(BuildContext context, AuthController authController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _LogoutBottomSheet(authController: authController),
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

// ─────────────────────────────────────────────
// Widget privé : bottom sheet de déconnexion
// ─────────────────────────────────────────────
class _LogoutBottomSheet extends StatefulWidget {
  final AuthController authController;
  const _LogoutBottomSheet({required this.authController});

  @override
  State<_LogoutBottomSheet> createState() => _LogoutBottomSheetState();
}

class _LogoutBottomSheetState extends State<_LogoutBottomSheet> {
  bool _isLoading = false;

  Future<void> _doLogout() async {
    setState(() => _isLoading = true);
    Navigator.pop(context);
    await widget.authController.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 28),
            decoration: BoxDecoration(
              color: AppTheme.slate200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Icône principale avec dégradé rouge
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.softRed.withValues(alpha: 0.15),
                  AppTheme.payaRed.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.softRed.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: AppTheme.softRed,
              size: 36,
            ),
          ),

          const SizedBox(height: 20),

          // Titre
          const Text(
            'Se déconnecter ?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.slate900,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 8),

          // Message
          const Text(
            'Vous serez redirigé vers l\'écran de connexion.\nVos données locales seront conservées.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.slate500,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          // Bandeau d'avertissement
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.softRed.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: AppTheme.softRed.withValues(alpha: 0.8)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Toutes les sessions actives sur cet appareil seront fermées.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.softRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bouton Déconnecter
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _doLogout,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.logout_rounded, size: 20),
              label: Text(
                _isLoading ? 'Déconnexion...' : 'Oui, me déconnecter',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.softRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bouton Annuler
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.slate600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.slate200),
                ),
              ),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/core/services/auth_service.dart';
import 'package:paya_app/presentation/controllers/profile_controller.dart';
import 'package:paya_app/presentation/widgets/main_layout.dart';
import 'package:paya_app/presentation/widgets/confirmation_dialog.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppTheme.deepBlue),
          onPressed: () {
            MainLayout.scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            color: AppTheme.deepBlue,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Obx(() {
        final vendor = authService.currentVendor.value;

        if (vendor == null && authService.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.deepBlue),
            ),
          );
        }

        if (vendor == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.deepBlue.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 48,
                      color: AppTheme.deepBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Profil non disponible',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.slate900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Veuillez vous reconnecter pour gérer votre profil',
                    style: TextStyle(fontSize: 13, color: AppTheme.slate500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.offAllNamed('/login'),
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: const Text('Se connecter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.deepBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Merchant Hero Card
                  _buildMerchantHero(vendor),
                  const SizedBox(height: 20),

                  // Business Details Section
                  _buildSectionHeader('Informations de la boutique', Icons.store_rounded),
                  const SizedBox(height: 10),
                  _buildBusinessCard(),
                  const SizedBox(height: 24),

                  // Subscription & Limits Section
                  _buildSectionHeader('Abonnement et quotas', Icons.workspace_premium_rounded),
                  const SizedBox(height: 10),
                  _buildQuotasCard(vendor),
                  const SizedBox(height: 28),

                  // Action Buttons
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Enregistrer les modifications',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.dialog(
                          ConfirmationDialog(
                            title: 'Déconnexion',
                            message: 'Êtes-vous sûr de vouloir vous déconnecter de votre compte Paya ?',
                            confirmText: 'Se déconnecter',
                            isDanger: true,
                            onConfirm: () async {
                              Get.back();
                              await authService.logout();
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout_rounded, color: AppTheme.softRed, size: 18),
                      label: const Text(
                        'Déconnexion',
                        style: TextStyle(
                          color: AppTheme.softRed,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFFCDD2)),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMerchantHero(dynamic vendor) {
    final isPremium = vendor.isPremium == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.deepBlue, AppTheme.softBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.deepBlue.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.store_mall_directory_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.businessName.isNotEmpty ? vendor.businessName : 'Ma Boutique',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate900,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  vendor.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.slate500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPlanChip(isPremium),
                    if (!isPremium) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => Get.toNamed('/subscription'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.deepBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Passer au Pro',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.deepBlue,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(Icons.arrow_forward_rounded, size: 12, color: AppTheme.deepBlue),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanChip(bool isPremium) {
    if (isPremium) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.workspace_premium_rounded, size: 12, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'PREMIUM',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.slate100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'PLAN GRATUIT',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.slate600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.deepBlue),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.slate900,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(
            label: 'Nom de la boutique / entreprise',
            controller: controller.businessNameController,
            icon: Icons.storefront_outlined,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Numéro de téléphone',
            controller: controller.phoneController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Adresse e-mail (Compte vérifié)',
            controller: controller.emailController,
            icon: Icons.email_outlined,
            readOnly: true,
            trailingBadge: 'Non modifiable',
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    String? trailingBadge,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.slate600,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (trailingBadge != null)
              Text(
                trailingBadge,
                style: const TextStyle(fontSize: 10, color: AppTheme.slate400),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: TextStyle(
            color: readOnly ? AppTheme.slate500 : AppTheme.slate900,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: readOnly ? AppTheme.slate400 : AppTheme.deepBlue, size: 18),
            filled: true,
            fillColor: readOnly ? AppTheme.slate50 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.deepBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuotasCard(dynamic vendor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildQuotaRow(
            icon: Icons.waves_rounded,
            title: 'Vagues de livraison',
            subtitle: 'Nombre max de vagues actives',
            value: vendor.isPremium == true ? 'Illimitées' : '${vendor.waveLimit}',
            color: AppTheme.deepBlue,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppTheme.slate100),
          ),
          _buildQuotaRow(
            icon: Icons.inventory_2_outlined,
            title: 'Catalogue Produits',
            subtitle: 'Nombre max de produits enregistrés',
            value: vendor.isPremium == true ? 'Illimités' : '${vendor.productLimit}',
            color: AppTheme.payaOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.slate900,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppTheme.slate500),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

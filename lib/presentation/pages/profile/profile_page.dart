import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/core/services/auth_service.dart';
import 'package:paya_app/presentation/controllers/profile_controller.dart';
import 'package:paya_app/presentation/widgets/main_layout.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            MainLayout.scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            color: AppTheme.deepBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        final vendor = authService.currentVendor.value;

        // Cas 1: Chargement en cours (vendor null et authService en chargement)
        if (vendor == null && authService.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Cas 2: Vendor non connecté ou erreur de chargement
        if (vendor == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 80,
                  color: AppTheme.deepBlue.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Profil non disponible',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkerBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Veuillez vous reconnecter',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.offAllNamed('/login'),
                  icon: const Icon(Icons.login),
                  label: const Text('Se connecter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deepBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Cas 3: Vendor connecté - affichage normal
        return _buildProfileContent(vendor);
      }),
    );
  }

  Widget _buildProfileContent(vendor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Avatar Section
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.deepBlue.withOpacity(0.1),
                  child: const Icon(
                    Icons.business,
                    size: 50,
                    color: AppTheme.deepBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  vendor.businessName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkerBlue,
                  ),
                ),
                const SizedBox(height: 4),
                _buildPlanBadge(vendor.plan),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Business Info Section
          const Text(
            'Informations de l\'entreprise',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepBlue,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            label: 'Nom de l\'entreprise',
            controller: controller.businessNameController,
            icon: Icons.store_outlined,
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            label: 'Téléphone',
            controller: controller.phoneController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            label: 'Email (Non modifiable)',
            controller: controller.emailController,
            icon: Icons.email_outlined,
            readOnly: true,
          ),
          const SizedBox(height: 32),

          // Subscription & Limits Section
          const Text(
            'Abonnement et Limites',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepBlue,
            ),
          ),
          const SizedBox(height: 16),
          _buildLimitCard(
            title: 'Vagues de livraison',
            value: vendor.waveLimit.toString(),
            icon: Icons.waves,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildLimitCard(
            title: 'Catalogue Produits',
            value: vendor.productLimit.toString(),
            icon: Icons.inventory_2,
            color: Colors.orange,
          ),
          const SizedBox(height: 40),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Enregistrer les modifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton(
              onPressed: controller.logout,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.softRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Déconnexion',
                style: TextStyle(
                  color: AppTheme.softRed,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPlanBadge(String plan) {
    final isPremium = plan.toLowerCase() == 'premium';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isPremium ? Colors.amber.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPremium ? Colors.amber.shade700 : Colors.grey.shade400,
        ),
      ),
      child: Text(
        plan.toUpperCase(),
        style: TextStyle(
          color: isPremium ? Colors.amber.shade900 : Colors.grey.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: TextStyle(
            color: readOnly ? Colors.grey : AppTheme.darkerBlue,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.deepBlue, size: 20),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLimitCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.payaGray.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.darkerBlue,
              ),
            ),
          ),
          Text(
            'Limite: $value',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.deepBlue,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/presentation/controllers/auth_controller.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.payaCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.slate200, width: 1),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppTheme.payaBlue),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title Section
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkerBlue,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Rejoignez Paya et commencez à gérer vos tontines',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.slate500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Registration Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.modernCardDecoration(
                    borderRadius: 24,
                    hasShadow: true,
                  ),
                  child: Column(
                    children: [
                      // Business Name Field
                      TextField(
                        onChanged: (value) =>
                            authController.registerBusinessName.value = value,
                        decoration: InputDecoration(
                          labelText: 'Nom de la boutique / entreprise',
                          hintText: 'ex: Tontine Confort Pro',
                          prefixIcon: const Icon(Icons.storefront_rounded, color: AppTheme.payaBlue, size: 20),
                          fillColor: AppTheme.slate50,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone Field
                      TextField(
                        onChanged: (value) =>
                            authController.registerPhone.value = value,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Numéro de téléphone',
                          hintText: 'ex: +225 0700000000',
                          prefixIcon: const Icon(Icons.phone_rounded, color: AppTheme.payaBlue, size: 20),
                          fillColor: AppTheme.slate50,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextField(
                        onChanged: (value) =>
                            authController.registerEmail.value = value,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Adresse email',
                          hintText: 'ex: contact@maboutique.com',
                          prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.payaBlue, size: 20),
                          fillColor: AppTheme.slate50,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextField(
                        onChanged: (value) =>
                            authController.registerPassword.value = value,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe sécurisé',
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.payaBlue, size: 20),
                          fillColor: AppTheme.slate50,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Register Button
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: authController.isLoading.value
                                ? null
                                : () => authController.register(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.payaBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              shadowColor: AppTheme.payaBlue.withValues(alpha: 0.35),
                            ),
                            child: authController.isLoading.value
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'S\'inscrire',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Déjà inscrit ?',
                      style: TextStyle(
                        color: AppTheme.slate600,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: AppTheme.payaBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

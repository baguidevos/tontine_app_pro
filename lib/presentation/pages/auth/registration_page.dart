import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/theme/app_theme.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepBlue),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title Section
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Commencez à gérer vos tontines',
                  style: TextStyle(fontSize: 16, color: AppTheme.darkerBlue),
                ),
                const SizedBox(height: 32),

                // Registration Form
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Business Name Field
                      TextField(
                        onChanged: (value) =>
                            authController.registerBusinessName.value = value,
                        decoration: InputDecoration(
                          labelText: 'Nom de l\'entreprise',
                          prefixIcon: const Icon(Icons.business_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: AppTheme.warmCream.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone Field
                      TextField(
                        onChanged: (value) =>
                            authController.registerPhone.value = value,
                        decoration: InputDecoration(
                          labelText: 'Téléphone',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: AppTheme.warmCream.withOpacity(0.3),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextField(
                        onChanged: (value) =>
                            authController.registerEmail.value = value,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: AppTheme.warmCream.withOpacity(0.3),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextField(
                        onChanged: (value) =>
                            authController.registerPassword.value = value,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: AppTheme.warmCream.withOpacity(0.3),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),

                      // Register Button
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authController.isLoading.value
                                ? null
                                : () => authController.register(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.deepBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: authController.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'S\'inscrire',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
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
                      'Déjà un compte ?',
                      style: TextStyle(color: AppTheme.darkerBlue),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: AppTheme.deepBlue,
                          fontWeight: FontWeight.bold,
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/theme/app_theme.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Title Section
                const Icon(
                  Icons.store_rounded,
                  size: 80,
                  color: AppTheme.deepBlue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'TontineManager Pro',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gérez vos ventes en tontine',
                  style: TextStyle(fontSize: 16, color: AppTheme.darkerBlue),
                ),
                const SizedBox(height: 48),

                // Login Form
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
                      const Text(
                        'Connexion',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Email Field
                      TextField(
                        onChanged: (value) =>
                            authController.loginEmail.value = value,
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
                            authController.loginPassword.value = value,
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

                      // Login Button
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authController.isLoading.value
                                ? null
                                : () => authController.login(),
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
                                    'Se connecter',
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

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pas encore de compte ?',
                      style: TextStyle(color: AppTheme.darkerBlue),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/register'),
                      child: const Text(
                        'S\'inscrire',
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

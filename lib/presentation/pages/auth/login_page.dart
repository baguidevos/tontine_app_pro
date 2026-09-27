import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/presentation/controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppTheme.payaCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo & Header Section
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.slate200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.payaBlue.withValues(alpha: 0.1),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.store_rounded,
                        size: 42,
                        color: AppTheme.payaBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'PAYA',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkerBlue,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gérez vos ventes et vos tontines en toute sérénité',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.slate500,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Modern Login Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.modernCardDecoration(
                    borderRadius: 24,
                    hasShadow: true,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Connexion',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkerBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Accédez à votre espace marchand',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.slate500,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Email Field
                      TextField(
                        onChanged: (value) =>
                            authController.loginEmail.value = value,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Adresse email',
                          hintText: 'ex: vendeur@paya.com',
                          prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.payaBlue, size: 20),
                          fillColor: AppTheme.slate50,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextField(
                        onChanged: (value) =>
                            authController.loginPassword.value = value,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.payaBlue, size: 20),
                          fillColor: AppTheme.slate50,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: authController.isLoading.value
                                ? null
                                : () => authController.login(),
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
                                    'Se connecter',
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

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pas encore de compte ?',
                      style: TextStyle(
                        color: AppTheme.slate600,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/register'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text(
                        'Créer un compte',
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

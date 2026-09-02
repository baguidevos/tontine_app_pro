import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/services/auth_service.dart';
import 'package:paya_app/core/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    if (kIsWeb) {
      final uri = Uri.base;
      if (uri.path.contains('/order') ||
          uri.fragment.contains('/order') ||
          uri.queryParameters.containsKey('p')) {
        Get.offAllNamed('/order');
        return;
      }
    }

    // Wait for a moment to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (Get.isRegistered<AuthService>()) {
      final authService = Get.find<AuthService>();
      if (authService.isLoggedIn) {
        Get.offAllNamed('/');
      } else {
        Get.offAllNamed('/login');
      }
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon/Logo
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  'assets/logo.png',
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.store_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // App Name
            const Text(
              'PAYA',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gérez vos ventes et commandes en toute simplicité',
              style: TextStyle(fontSize: 15, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

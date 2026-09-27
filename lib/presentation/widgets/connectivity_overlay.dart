import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/services/connectivity_service.dart';
import 'package:paya_app/core/theme/app_theme.dart';

class ConnectivityOverlay extends StatelessWidget {
  final Widget child;

  const ConnectivityOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();

    return Obx(() {
      return Stack(
        children: [
          child,
          if (!connectivityService.isConnected.value)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.65),
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 360),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.softRed.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.wifi_off_rounded,
                            size: 44,
                            color: AppTheme.softRed,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Connexion perdue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.slate900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Veuillez vérifier votre connexion Internet pour continuer à synchroniser vos données.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.slate600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

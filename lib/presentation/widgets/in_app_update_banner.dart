import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/services/update_service.dart';
import 'package:paya_app/core/theme/app_theme.dart';

/// Bandeau In-App discret notifiant l'utilisateur qu'une mise à jour de l'app est disponible.
class InAppUpdateBanner extends StatelessWidget {
  const InAppUpdateBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UpdateService>()) {
      return const SizedBox.shrink();
    }

    final updateService = UpdateService.to;

    return Obx(() {
      final info = updateService.latestUpdate.value;
      final showBanner = updateService.showInAppBanner.value;

      if (!showBanner || info == null || !info.isUpdateAvailable) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF), // Soft Blue
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFDBFE)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.payaBlue.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.payaBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.system_update_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Mise à jour Paya',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.darkerBlue,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.greenLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'v${info.latestVersion}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.payaGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Nouvelles fonctionnalités et améliorations',
                    style: TextStyle(fontSize: 11, color: AppTheme.slate600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => updateService.showFlexibleUpdateDialog(info),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.payaBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Installer',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.slate400),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 16,
              onPressed: () => updateService.showInAppBanner.value = false,
            ),
          ],
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/subscription_service.dart';

class SubscriptionGuard extends GetMiddleware {
  final subscriptionService = Get.find<SubscriptionService>();

  @override
  RouteSettings? redirect(String? route) {
    // Example: Redirect to subscription page if premium feature accessed on free plan
    // This is a simplified version; custom logic can be added here
    return null;
  }

  // Helper method to check limits before actions
  static void checkLimitAndExecute({
    required String limitType,
    required int currentCount,
    required VoidCallback onAllowed,
  }) {
    final service = Get.find<SubscriptionService>();
    bool allowed = false;

    if (limitType == 'wave') {
      allowed = service.canCreateWave(currentCount);
    } else if (limitType == 'product') {
      allowed = service.canCreateProduct(currentCount);
    }

    if (allowed) {
      onAllowed();
    } else {
      Get.defaultDialog(
        title: 'Limite atteinte',
        middleText:
            'Vous avez atteint la limite de votre plan actuel. Passez au Premium pour continuer.',
        textConfirm: 'Voir les plans',
        onConfirm: () {
          Get.back();
          Get.toNamed('/subscription');
        },
        textCancel: 'Plus tard',
      );
    }
  }
}

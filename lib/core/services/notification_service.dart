import 'package:get/get.dart';

class NotificationService extends GetxService {
  /// Sends a notification to the admin when a new subscription request is created.
  /// Currently a placeholder as per requirements.
  Future<void> notifyAdminNewSubscription(
    String vendorId,
    String planType,
  ) async {
    // Eventually implement FCM or Email API here
    print(
      'NOTIFICATION: New subscription request from Vendor $vendorId for plan $planType',
    );
  }
}

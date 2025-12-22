import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var currentPlan = 'free'.obs;
  var waveLimit = 5.obs;
  var productLimit = 10.obs;

  Future<SubscriptionService> init() async {
    // Listen to vendor document changes to update plan status
    _auth.userChanges().listen((user) {
      if (user != null) {
        _listenToVendorPlan(user.uid);
      }
    });
    return this;
  }

  void _listenToVendorPlan(String vendorId) {
    _firestore.collection('vendors').doc(vendorId).snapshots().listen((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        currentPlan.value = data['plan'] ?? 'free';
        // Mock limits for now
        if (currentPlan.value == 'premium') {
          waveLimit.value = 999;
          productLimit.value = 999;
        } else {
          waveLimit.value = 5;
          productLimit.value = 10;
        }
      }
    });
  }

  Future<void> requestActivation(String planType, String duration) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('subscription_requests').add({
        'vendorId': user.uid,
        'planType': planType,
        'duration': duration,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar('Succès', 'Demande d\'activation envoyée');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de l\'envoi: $e');
    }
  }

  bool canCreateWave(int currentWaveCount) {
    return currentWaveCount < waveLimit.value;
  }

  bool canCreateProduct(int currentProductCount) {
    return currentProductCount < productLimit.value;
  }
}

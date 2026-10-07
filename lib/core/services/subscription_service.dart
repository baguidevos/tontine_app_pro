import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paya_app/core/services/saspay_payment_service.dart';

class SubscriptionService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final SasPayPaymentService _sasPayPaymentService;

  var currentPlan = 'free'.obs;
  var waveLimit = 5.obs;
  var productLimit = 10.obs;

  var availablePlans = <SubscriptionPlanModel>[].obs;
  var isLoadingPlans = false.obs;
  var isProcessingPayment = false.obs;
  var activeSubscriptionInfo = Rxn<Map<String, dynamic>>();

  Future<SubscriptionService> init() async {
    _sasPayPaymentService = Get.isRegistered<SasPayPaymentService>()
        ? Get.find<SasPayPaymentService>()
        : Get.put(SasPayPaymentService());

    // Charger les plans disponibles depuis le backend SasPay
    loadSasPayPlans();

    // Écouter les changements utilisateur pour mettre à jour le statut
    _auth.userChanges().listen((user) {
      if (user != null) {
        _listenToVendorPlan(user.uid);
        checkBackendSubscription();
      }
    });

    return this;
  }

  void _listenToVendorPlan(String vendorId) {
    _firestore.collection('vendors').doc(vendorId).snapshots().listen((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        currentPlan.value = data['plan'] ?? 'free';
        _applyLimitsForPlan(currentPlan.value);
      }
    });
  }

  void _applyLimitsForPlan(String plan) {
    if (plan == 'premium' || plan == 'pro' || plan == 'active') {
      waveLimit.value = 9999;
      productLimit.value = 9999;
    } else {
      waveLimit.value = 5;
      productLimit.value = 10;
    }
  }

  /// Charge la liste des plans SasPay depuis le backend Laravel.
  Future<void> loadSasPayPlans() async {
    isLoadingPlans.value = true;
    try {
      final plans = await _sasPayPaymentService.fetchPlans();
      if (plans.isNotEmpty) {
        availablePlans.assignAll(plans);
      }
    } finally {
      isLoadingPlans.value = false;
    }
  }

  /// Vérifie si l'utilisateur possède un abonnement actif sur le backend SasPay.
  Future<void> checkBackendSubscription() async {
    final subData = await _sasPayPaymentService.fetchCurrentSubscription();
    activeSubscriptionInfo.value = subData;
    if (subData != null && subData['status'] == 'active') {
      currentPlan.value = 'premium';
      _applyLimitsForPlan('premium');
    }
  }

  /// Déclenche le paiement d'un abonnement via SasPay.
  Future<Map<String, dynamic>?> subscribeWithSasPay({
    required int planId,
    String flow = 'checkout',
    String? phone,
    String? network,
    String? otp,
  }) async {
    isProcessingPayment.value = true;
    try {
      final result = await _sasPayPaymentService.initiateSubscriptionCheckout(
        planId: planId,
        flow: flow,
        phone: phone,
        network: network,
        otp: otp,
      );

      if (result != null) {
        final checkoutUrl = result['checkout_url'] as String?;
        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          await _sasPayPaymentService.openCheckoutPage(checkoutUrl);
        }
        return result;
      }
      return null;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Vérifie le statut d'une transaction après le retour de paiement de l'utilisateur.
  Future<bool> verifyPayment(int paymentId) async {
    final statusData = await _sasPayPaymentService.verifyPaymentStatus(paymentId);
    if (statusData != null) {
      final payment = statusData['payment'] as Map<String, dynamic>?;
      final sub = statusData['subscription'] as Map<String, dynamic>?;

      if (payment != null && payment['status'] == 'SUCCESS') {
        currentPlan.value = 'premium';
        _applyLimitsForPlan('premium');
        activeSubscriptionInfo.value = sub;

        // Mise à jour optionnelle sur Firestore pour synchroniser les deux
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('vendors').doc(user.uid).set({
            'plan': 'premium',
            'plan_updated_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        Get.snackbar(
          'Paiement Confirmé ! 🎉',
          'Votre abonnement Pro est maintenant activé.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
        return true;
      }
    }
    return false;
  }

  /// Fallback historique de demande manuelle
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

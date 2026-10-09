import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paya_app/core/services/connectivity_service.dart';
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
  var isRefreshing = false.obs;
  var isOfflineMode = false.obs;
  var activeSubscriptionInfo = Rxn<Map<String, dynamic>>();

  /// Catalogue de secours hors-ligne garantissant la disponibilité continue de l'UI
  static final List<SubscriptionPlanModel> _defaultFallbackPlans = [
    SubscriptionPlanModel(
      id: 1,
      name: 'Plan Gratuit',
      slug: 'free',
      description: 'Pour tester et démarrer votre activité',
      price: '0.00',
      currency: 'XOF',
      durationInDays: 3650,
      order: 1,
      isFeatured: false,
      badgeText: null,
      features: [
        'Jusqu\'à 5 vagues de livraison',
        'Jusqu\'à 10 produits au catalogue',
        'Gestion des clients et des commandes',
        'Suivi standard des paiements',
      ],
    ),
    SubscriptionPlanModel(
      id: 2,
      name: 'Premium Mensuel',
      slug: 'pro-monthly',
      description: 'Flexibilité totale sans engagement long',
      price: '1000.00',
      currency: 'XOF',
      durationInDays: 30,
      order: 2,
      isFeatured: false,
      badgeText: 'Sans engagement',
      features: [
        'Vagues de livraison illimitées',
        'Produits illimités au catalogue',
        'Historique complet des transactions',
        'Export et rapports détaillés',
        'Support client prioritaire',
      ],
    ),
    SubscriptionPlanModel(
      id: 3,
      name: 'Premium Semestriel',
      slug: 'pro-semiannual',
      description: 'Idéal pour installer vos cycles de vente',
      price: '4500.00',
      currency: 'XOF',
      durationInDays: 180,
      order: 3,
      isFeatured: true,
      badgeText: 'Recommandé • Éco 1 500 F',
      features: [
        'Vagues et produits illimités',
        'Historique complet et analyses',
        'Support prioritaire par WhatsApp',
        'Économisez 1 500 FCFA',
      ],
    ),
    SubscriptionPlanModel(
      id: 4,
      name: 'Premium Annuel',
      slug: 'pro-annual',
      description: 'La rentabilité maximale pour les pros',
      price: '10000.00',
      currency: 'XOF',
      durationInDays: 365,
      order: 4,
      isFeatured: false,
      badgeText: 'Meilleure valeur • 2 mois offerts',
      features: [
        'Toutes les fonctionnalités en illimité',
        'Gestion multi-vendeurs et collaborateurs',
        'Accompagnement VIP dédié',
        'Économisez 2 000 FCFA (2 mois offerts)',
      ],
    ),
  ];

  Future<SubscriptionService> init() async {
    _sasPayPaymentService = Get.isRegistered<SasPayPaymentService>()
        ? Get.find<SasPayPaymentService>()
        : Get.put(SasPayPaymentService());

    // 1. Initialiser immédiatement avec les plans par défaut pour une UI instantanée
    availablePlans.assignAll(_defaultFallbackPlans);

    // 2. Écouter la collection Firestore subscription_plans en temps réel (auto-seed si vide)
    _listenToFirestorePlans();

    // 3. Charger également les plans distants depuis le backend SasPay
    loadSasPayPlans();

    // 4. Écouter les changements utilisateur pour mettre à jour le statut
    _auth.userChanges().listen((user) {
      if (user != null) {
        _listenToVendorPlan(user.uid);
        checkBackendSubscription();
      }
    });

    // 5. Stratégie de reconnexion automatique : réactualiser dès le retour du réseau
    if (Get.isRegistered<ConnectivityService>()) {
      final conn = Get.find<ConnectivityService>();
      conn.isConnected.listen((hasConnection) {
        if (hasConnection && isOfflineMode.value) {
          debugPrint('[SubscriptionService] Reconnexion détectée, rafraîchissement des abonnements...');
          refreshSubscription(silent: true);
        }
      });
    }

    return this;
  }

  /// Écoute en temps réel la collection Firestore 'subscription_plans'
  void _listenToFirestorePlans() {
    _firestore
        .collection('subscription_plans')
        .where('is_active', isEqualTo: true)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final plans = snapshot.docs.map((doc) {
          final data = doc.data();
          return SubscriptionPlanModel.fromJson(data);
        }).toList();

        // Trier selon le champ 'order'
        plans.sort((a, b) => a.order.compareTo(b.order));
        availablePlans.assignAll(plans);
        isOfflineMode.value = false;
        debugPrint('[SubscriptionService] ${plans.length} plans chargés depuis Firestore en direct.');
      } else {
        // La collection est vide sur Firestore : initialisation automatique avec nos 4 offres
        _seedFirestorePlansIfEmpty();
      }
    }, onError: (e) {
      debugPrint('[SubscriptionService] Erreur écoute Firestore subscription_plans: $e');
    });
  }

  /// Initialise la collection Firestore 'subscription_plans' si elle est vide
  Future<void> _seedFirestorePlansIfEmpty() async {
    try {
      final existing = await _firestore.collection('subscription_plans').limit(1).get();
      if (existing.docs.isEmpty) {
        debugPrint('[SubscriptionService] Initialisation automatique des offres dans Firestore...');
        final batch = _firestore.batch();
        for (final plan in _defaultFallbackPlans) {
          final docRef = _firestore.collection('subscription_plans').doc(plan.slug);
          batch.set(docRef, plan.toMap());
        }
        await batch.commit();
        debugPrint('[SubscriptionService] 4 offres créées avec succès dans Firestore !');
      }
    } catch (e) {
      debugPrint('[SubscriptionService] Note auto-seed Firestore: $e');
    }
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

  /// Charge la liste des plans SasPay depuis le backend Laravel avec fallback automatique.
  Future<void> loadSasPayPlans() async {
    isLoadingPlans.value = true;
    try {
      final plans = await _sasPayPaymentService.fetchPlans();
      if (plans.isNotEmpty) {
        availablePlans.assignAll(plans);
        isOfflineMode.value = false;
      } else {
        // En cas de non-réponse du backend, conserver le catalogue de secours
        if (availablePlans.isEmpty) {
          availablePlans.assignAll(_defaultFallbackPlans);
        }
        isOfflineMode.value = true;
      }
    } catch (e) {
      debugPrint('[SubscriptionService] Erreur chargement plans: $e');
      if (availablePlans.isEmpty) {
        availablePlans.assignAll(_defaultFallbackPlans);
      }
      isOfflineMode.value = true;
    } finally {
      isLoadingPlans.value = false;
    }
  }

  /// Rafraîchit activement le statut et les plans (Pull-to-refresh ou Reconnexion).
  Future<void> refreshSubscription({bool showFeedback = false, bool silent = false}) async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    try {
      await Future.wait([
        loadSasPayPlans(),
        checkBackendSubscription(),
      ]);

      if (showFeedback) {
        if (isOfflineMode.value) {
          Get.snackbar(
            'Mode Hors-ligne',
            'Le serveur distant n\'est pas joignable. Données locales affichées.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        } else {
          Get.snackbar(
            'Synchronisation terminée',
            'Les forfaits et votre statut sont à jour.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      if (showFeedback) {
        Get.snackbar(
          'Erreur',
          'Impossible d\'actualiser pour le moment.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isRefreshing.value = false;
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

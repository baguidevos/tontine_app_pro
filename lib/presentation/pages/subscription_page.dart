import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/services/saspay_payment_service.dart';
import 'package:paya_app/core/services/subscription_service.dart';
import 'package:paya_app/core/services/whatsapp_service.dart';
import 'package:paya_app/core/theme/app_theme.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionService = Get.find<SubscriptionService>();

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        title: const Text(
          'Abonnements',
          style: TextStyle(
            color: AppTheme.deepBlue,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.deepBlue),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            final isRefreshing = subscriptionService.isRefreshing.value;
            return IconButton(
              tooltip: 'Actualiser mon abonnement',
              icon: isRefreshing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.deepBlue,
                      ),
                    )
                  : const Icon(Icons.sync_rounded, color: AppTheme.deepBlue),
              onPressed: isRefreshing
                  ? null
                  : () => subscriptionService.refreshSubscription(showFeedback: true),
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.deepBlue,
        onRefresh: () => subscriptionService.refreshSubscription(showFeedback: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avertissement Mode Hors-Ligne si le backend ne répond pas
                  Obx(() {
                    if (!subscriptionService.isOfflineMode.value) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFB74D)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_off_rounded, color: Color(0xFFE65100), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Serveur en cours de synchronisation. Tarifs officiels affichés en mode local.',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE65100),
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () => subscriptionService.refreshSubscription(showFeedback: true),
                            child: const Text('Réessayer', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Hero Banner
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.deepBlue, Color(0xFF283593), Color(0xFF3949AB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.deepBlue.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFFFFD54F),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Paya Pro Business',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Passez au niveau supérieur sans aucune restriction',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Créez autant de vagues et de produits que nécessaire pour développer vos ventes.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section header
                const Text(
                  'Choisissez votre formule',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate900,
                  ),
                ),
                const SizedBox(height: 12),

                // Plan cards générés dynamiquement depuis le backend / catalogue local
                Obx(() {
                  final plans = subscriptionService.availablePlans;
                  if (plans.isEmpty && subscriptionService.isLoadingPlans.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return Column(
                    children: plans.map((plan) {
                      final isFree = plan.slug == 'free' || plan.price == '0.00' || plan.price == '0';
                      final isCurrent = isFree
                          ? subscriptionService.currentPlan.value == 'free'
                          : (subscriptionService.currentPlan.value != 'free' &&
                              subscriptionService.activeSubscriptionInfo.value?['plan_id'] == plan.id);

                      // Formatage du prix
                      final numPrice = double.tryParse(plan.price) ?? 0.0;
                      final formattedPrice = isFree
                          ? '0 FCFA'
                          : '${numPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA';

                      // Formatage de la période
                      final String period;
                      if (isFree) {
                        period = 'pour toujours';
                      } else if (plan.durationInDays <= 31) {
                        period = '/ mois';
                      } else if (plan.durationInDays <= 185) {
                        period = '/ 6 mois';
                      } else if (plan.durationInDays <= 366) {
                        period = '/ an';
                      } else {
                        period = '/ ${plan.durationInDays} jours';
                      }

                      // Badge & mise en avant (dynamique depuis Firestore ou calculé)
                      String? badgeText = plan.badgeText;
                      Color? badgeColor;
                      bool isFeatured = plan.isFeatured;

                      if (badgeText == null || badgeText.isEmpty) {
                        if (plan.slug.contains('semiannual') || plan.durationInDays == 180) {
                          badgeText = 'Recommandé • Éco 1 500 F';
                          badgeColor = AppTheme.payaGreen;
                          isFeatured = true;
                        } else if (plan.slug.contains('annual') || plan.durationInDays == 365) {
                          badgeText = 'Meilleure valeur • 2 mois offerts';
                          badgeColor = const Color(0xFFF57C00);
                        } else if (plan.slug.contains('monthly') || plan.durationInDays == 30) {
                          badgeText = 'Sans engagement';
                        }
                      } else {
                        if (isFeatured) {
                          badgeColor = AppTheme.payaGreen;
                        } else if (plan.durationInDays >= 360) {
                          badgeColor = const Color(0xFFF57C00);
                        } else {
                          badgeColor = AppTheme.deepBlue;
                        }
                      }

                      // Texte du bouton d'action
                      final String ctaText;
                      if (isCurrent) {
                        ctaText = 'Votre plan actuel';
                      } else if (isFree) {
                        ctaText = 'Revenir au gratuit';
                      } else {
                        ctaText = isFeatured ? 'Profiter de l\'offre' : 'Choisir ce plan';
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPlanCard(
                          title: plan.name,
                          subtitle: plan.description ?? '',
                          price: formattedPrice,
                          period: period,
                          features: plan.features,
                          isCurrent: isCurrent,
                          isFeatured: isFeatured,
                          badgeText: badgeText,
                          badgeColor: badgeColor,
                          ctaText: ctaText,
                          onTap: () {
                            if (isFree) {
                              Get.back();
                            } else {
                              _confirmActivation(
                                context,
                                service: subscriptionService,
                                planType: 'premium',
                                duration: '${plan.durationInDays}_days',
                                planName: '${plan.name} ($formattedPrice)',
                                targetPlanId: plan.id,
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  );
                }),

                const SizedBox(height: 28),

                // Trust footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.slate200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.payaGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: AppTheme.payaGreen,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Paiement sécurisé & Activation rapide',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.slate900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Paiement par Orange Money, Moov Money, Wave ou Carte Bancaire',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildPlanCard({
    required String title,
    required String subtitle,
    required String price,
    required String period,
    required List<String> features,
    required bool isCurrent,
    required bool isFeatured,
    required String ctaText,
    required VoidCallback onTap,
    String? badgeText,
    Color? badgeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isFeatured ? AppTheme.deepBlue : AppTheme.slate200,
          width: isFeatured ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isFeatured
                ? AppTheme.deepBlue.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badgeText != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              decoration: BoxDecoration(
                color: badgeColor ?? AppTheme.deepBlue,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.slate900,
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.payaGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Actif',
                          style: TextStyle(
                            color: AppTheme.payaGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppTheme.slate500),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.slate900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      period,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.slate500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, color: AppTheme.slate100),
                ),
                ...features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppTheme.payaGreen.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: AppTheme.payaGreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.slate700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isCurrent ? null : onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFeatured ? AppTheme.deepBlue : AppTheme.slate900,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.slate100,
                      disabledForegroundColor: AppTheme.slate400,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      ctaText,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmActivation(
    BuildContext context, {
    required SubscriptionService service,
    required String planType,
    required String duration,
    required String planName,
    int? targetPlanId,
    SubscriptionPlanModel? selectedPlan,
  }) {
    // Résolution de l'identifiant du plan correspondant dans SasPay
    int? planId = targetPlanId;
    if (planId == null && service.availablePlans.isNotEmpty) {
      if (duration == '1_month' || planName.contains('5 000')) {
        planId = service.availablePlans.firstWhereOrNull((p) => p.slug.contains('pro-monthly') || p.slug.contains('month'))?.id;
      } else if (duration == '1_year' || planName.contains('Annuel')) {
        planId = service.availablePlans.firstWhereOrNull((p) => p.slug.contains('annual') || p.slug.contains('year'))?.id;
      }
      planId ??= service.availablePlans.first.id;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final paymentState = Rxn<Map<String, dynamic>>();
        final isChecking = false.obs;

        return Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
          child: Obx(() {
            final activePayment = paymentState.value;

            // Vue 2 : En attente de confirmation après redirection SasPay
            if (activePayment != null) {
              final paymentId = activePayment['payment_id'] as int;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.slate300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6633D6).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      color: Color(0xFF6633D6),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Paiement en cours',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.slate900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Finalisez la transaction sur la page sécurisée SasPay (Mobile Money ou Carte).',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppTheme.slate600, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isChecking.value
                          ? null
                          : () async {
                              isChecking.value = true;
                              try {
                                final isSuccess = await service.verifyPayment(paymentId);
                                if (isSuccess) {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                } else {
                                  Get.snackbar(
                                    'Paiement en attente',
                                    'Le paiement n\'a pas encore été validé. Réessayez dans un instant après avoir confirmé sur votre mobile.',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              } finally {
                                isChecking.value = false;
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6633D6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isChecking.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text(
                              'Vérifier mon paiement',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer', style: TextStyle(color: AppTheme.slate600)),
                  ),
                ],
              );
            }

            // Vue 1 : Récapitulatif et lancement SasPay
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.slate300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6633D6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: Color(0xFF6633D6),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Paiement sécurisé SasPay',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Souscription au $planName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.slate700),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.slate50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.slate200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_android_rounded, size: 18, color: AppTheme.slate600),
                      const SizedBox(width: 8),
                      const Text(
                        'MTN • Moov • Orange • Wave • Carte Bancaire',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slate700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.slate700,
                          side: const BorderSide(color: AppTheme.slate300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: service.isProcessingPayment.value
                            ? null
                            : () async {
                                final selectedId = planId ?? (service.availablePlans.isNotEmpty ? service.availablePlans.first.id : 1);
                                final result = await service.subscribeWithSasPay(planId: selectedId);
                                if (result != null) {
                                  paymentState.value = result;
                                } else {
                                  if (context.mounted) {
                                    Navigator.pop(context); // Fermer le bottom sheet
                                    _showBackendOfflineFallback(
                                      context,
                                      planName: planName,
                                      planType: planType,
                                      duration: duration,
                                      service: service,
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6633D6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: service.isProcessingPayment.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Payer avec SasPay',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        );
      },
    );
  }

  void _showBackendOfflineFallback(
    BuildContext context, {
    required String planName,
    required String planType,
    required String duration,
    required SubscriptionService service,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.cloud_off_rounded, color: Color(0xFFE65100), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Serveur indisponible',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.darkerBlue),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Le serveur de paiement en ligne ne répond pas actuellement.\n\nVous pouvez tout de même activer votre $planName sans interruption grâce à nos canaux directs :',
              style: const TextStyle(fontSize: 13, color: AppTheme.slate600, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.slate50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.slate200),
              ),
              child: Row(
                children: const [
                  Icon(Icons.flash_on_rounded, color: AppTheme.payaGreen, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Activation directe via WhatsApp Support ou demande enregistrée dans votre compte.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slate700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    service.requestActivation(planType, duration);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.slate700,
                    side: const BorderSide(color: AppTheme.slate300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Demande locale', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    WhatsAppService.launchWhatsAppMessage(
                      phone: '2250700000000',
                      message: 'Bonjour l\'équipe Paya, je souhaite activer le $planName pour ma boutique. Le serveur automatique est momentanément indisponible.',
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                  label: const Text('WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


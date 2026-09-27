import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/services/subscription_service.dart';
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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

                // Plan cards
                _buildPlanCard(
                  title: 'Plan Gratuit',
                  subtitle: 'Pour tester et démarrer votre activité',
                  price: '0 FCFA',
                  period: 'pour toujours',
                  features: [
                    'Jusqu\'à 5 vagues de livraison',
                    'Jusqu\'à 10 produits au catalogue',
                    'Gestion des clients et des commandes',
                    'Suivi standard des paiements',
                  ],
                  isCurrent: subscriptionService.currentPlan.value == 'free',
                  isFeatured: false,
                  ctaText: subscriptionService.currentPlan.value == 'free'
                      ? 'Votre plan actuel'
                      : 'Revenir au gratuit',
                  onTap: () => Get.back(),
                ),

                const SizedBox(height: 16),

                _buildPlanCard(
                  title: 'Premium Mensuel',
                  subtitle: 'Flexibilité totale sans engagement long',
                  price: '5 000 FCFA',
                  period: '/ mois',
                  features: [
                    'Vagues de livraison illimitées',
                    'Produits illimités au catalogue',
                    'Historique complet des transactions',
                    'Export et rapports détaillés',
                    'Support client prioritaire',
                  ],
                  isCurrent: false,
                  isFeatured: false,
                  badgeText: 'Sans engagement',
                  ctaText: 'Choisir ce plan',
                  onTap: () => _confirmActivation(
                    context,
                    service: subscriptionService,
                    planType: 'premium',
                    duration: '1_month',
                    planName: 'Premium Mensuel (5 000 FCFA)',
                  ),
                ),

                const SizedBox(height: 16),

                _buildPlanCard(
                  title: 'Premium Semestriel',
                  subtitle: 'Idéal pour installer vos cycles de vente',
                  price: '25 000 FCFA',
                  period: '/ 6 mois',
                  features: [
                    'Vagues et produits illimités',
                    'Historique complet et analyses',
                    'Support prioritaire par WhatsApp',
                    'Économisez 5 000 FCFA',
                  ],
                  isCurrent: false,
                  isFeatured: true,
                  badgeText: 'Recommandé • Éco 5 000 F',
                  badgeColor: AppTheme.payaGreen,
                  ctaText: 'Profiter de l\'offre semestrielle',
                  onTap: () => _confirmActivation(
                    context,
                    service: subscriptionService,
                    planType: 'premium',
                    duration: '6_months',
                    planName: 'Premium Semestriel (25 000 FCFA)',
                  ),
                ),

                const SizedBox(height: 16),

                _buildPlanCard(
                  title: 'Premium Annuel',
                  subtitle: 'La rentabilité maximale pour les pros',
                  price: '45 000 FCFA',
                  period: '/ an',
                  features: [
                    'Toutes les fonctionnalités en illimité',
                    'Gestion multi-vendeurs et collaborateurs',
                    'Accompagnement VIP dédié',
                    'Économisez 15 000 FCFA (3 mois offerts)',
                  ],
                  isCurrent: false,
                  isFeatured: false,
                  badgeText: 'Meilleure valeur • -25%',
                  badgeColor: Color(0xFFF57C00),
                  ctaText: 'Souscrire pour 1 an',
                  onTap: () => _confirmActivation(
                    context,
                    service: subscriptionService,
                    planType: 'premium',
                    duration: '1_year',
                    planName: 'Premium Annuel (45 000 FCFA)',
                  ),
                ),

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
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
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
                  color: AppTheme.deepBlue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.deepBlue,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Confirmer la demande',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.slate900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Vous êtes sur le point de demander l\'activation du $planName.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppTheme.slate600),
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
                      onPressed: () async {
                        Navigator.pop(context);
                        await service.requestActivation(planType, duration);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Confirmer et envoyer',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

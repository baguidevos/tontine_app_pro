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
      appBar: AppBar(title: const Text('Plans d\'Abonnement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisissez votre plan',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Libérez tout le potentiel de votre gestion avec le Premium.',
              style: TextStyle(color: AppTheme.deepBlue),
            ),
            const SizedBox(height: 32),
            _buildPlanCard(
              title: 'Plan Gratuit',
              price: '0 FCFA',
              features: [
                'Jusqu\'à 5 Vagues',
                'Jusqu\'à 10 Produits',
                'Suivi standard',
              ],
              color: AppTheme.sageGreen.withOpacity(0.2),
              isPremium: false,
              onSubscribe: () => Get.back(),
            ),
            const SizedBox(height: 24),
            _buildPremiumPlans(subscriptionService),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumPlans(SubscriptionService service) {
    return Column(
      children: [
        _buildPlanCard(
          title: 'Premium Mensuel',
          price: '5,000 FCFA / mois',
          features: [
            'Vagues Illimitées',
            'Produits Illimités',
            'Historique complet',
            'Support Prioritaire',
          ],
          color: AppTheme.softBlue.withOpacity(0.3),
          isPremium: true,
          onSubscribe: () => service.requestActivation('premium', '1_month'),
        ),
        const SizedBox(height: 24),
        _buildPlanCard(
          title: 'Premium Semestriel',
          price: '25,000 FCFA / 6 mois',
          features: [
            'Vagues Illimitées',
            'Produits Illimités',
            'Historique complet',
            'Économisez 5,000 FCFA',
          ],
          color: AppTheme.softBlue.withOpacity(0.5),
          isPremium: true,
          onSubscribe: () => service.requestActivation('premium', '6_months'),
        ),
        const SizedBox(height: 24),
        _buildPlanCard(
          title: 'Premium Annuel',
          price: '45,000 FCFA / an',
          features: [
            'Vagues Illimitées',
            'Produits Illimités',
            'Gestion Multi-vendeurs',
            'Économisez 15,000 FCFA',
          ],
          color: AppTheme.softBlue,
          isPremium: true,
          onSubscribe: () => service.requestActivation('premium', '1_year'),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required Color color,
    required bool isPremium,
    required VoidCallback onSubscribe,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: isPremium
            ? Border.all(color: AppTheme.deepBlue, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(
              fontSize: 20,
              color: AppTheme.darkerBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.deepBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(f)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onSubscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPremium ? AppTheme.deepBlue : Colors.white,
              foregroundColor: isPremium ? Colors.white : AppTheme.deepBlue,
            ),
            child: Text(isPremium ? 'S\'abonner' : 'Plan Actuel'),
          ),
        ],
      ),
    );
  }
}

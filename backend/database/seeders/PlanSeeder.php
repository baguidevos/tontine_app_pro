<?php

namespace Database\Seeders;

use App\Models\Plan;
use Illuminate\Database\Seeder;

class PlanSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Plan::updateOrCreate(
            ['slug' => 'free'],
            [
                'name' => 'Plan Gratuit',
                'description' => 'Pour tester et démarrer votre activité',
                'price' => '0.00',
                'currency' => 'XOF',
                'duration_in_days' => 3650,
                'features' => [
                    'Jusqu\'à 5 vagues de livraison',
                    'Jusqu\'à 10 produits au catalogue',
                    'Gestion des clients et des commandes',
                    'Suivi standard des paiements',
                ],
                'is_active' => true,
            ]
        );

        Plan::updateOrCreate(
            ['slug' => 'pro-monthly'],
            [
                'name' => 'Premium Mensuel',
                'description' => 'Flexibilité totale sans engagement long',
                'price' => '1000.00',
                'currency' => 'XOF',
                'duration_in_days' => 30,
                'features' => [
                    'Vagues de livraison illimitées',
                    'Produits illimités au catalogue',
                    'Historique complet des transactions',
                    'Export et rapports détaillés',
                    'Support client prioritaire',
                ],
                'is_active' => true,
            ]
        );

        Plan::updateOrCreate(
            ['slug' => 'pro-semiannual'],
            [
                'name' => 'Premium Semestriel',
                'description' => 'Idéal pour installer vos cycles de vente',
                'price' => '4500.00',
                'currency' => 'XOF',
                'duration_in_days' => 180,
                'features' => [
                    'Vagues et produits illimités',
                    'Historique complet et analyses',
                    'Support prioritaire par WhatsApp',
                    'Économisez 1 500 FCFA',
                ],
                'is_active' => true,
            ]
        );

        Plan::updateOrCreate(
            ['slug' => 'pro-annual'],
            [
                'name' => 'Premium Annuel',
                'description' => 'La rentabilité maximale pour les pros',
                'price' => '10000.00',
                'currency' => 'XOF',
                'duration_in_days' => 365,
                'features' => [
                    'Toutes les fonctionnalités en illimité',
                    'Gestion multi-vendeurs et collaborateurs',
                    'Accompagnement VIP dédié',
                    'Économisez 2 000 FCFA (2 mois offerts)',
                ],
                'is_active' => true,
            ]
        );
    }
}

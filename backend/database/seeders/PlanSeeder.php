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
            ['slug' => 'starter-monthly'],
            [
                'name' => 'Abonnement Mensuel Starter',
                'description' => 'Accès complet aux fonctionnalités de base pour 30 jours.',
                'price' => '2500.00',
                'currency' => 'XOF',
                'duration_in_days' => 30,
                'features' => [
                    'Gestion d\'une tontine active',
                    'Rappels SMS et notifications',
                    'Support standard',
                ],
                'is_active' => true,
            ]
        );

        Plan::updateOrCreate(
            ['slug' => 'pro-monthly'],
            [
                'name' => 'Abonnement Mensuel Pro',
                'description' => 'Toutes les fonctionnalités avancées avec gestion illimitée.',
                'price' => '5000.00',
                'currency' => 'XOF',
                'duration_in_days' => 30,
                'features' => [
                    'Tontines illimitées',
                    'Rappels automatiques par Mobile Money',
                    'Export comptable & PDF',
                    'Support prioritaire',
                ],
                'is_active' => true,
            ]
        );

        Plan::updateOrCreate(
            ['slug' => 'pro-annual'],
            [
                'name' => 'Abonnement Annuel Pro',
                'description' => 'Pack annuel avec 2 mois offerts.',
                'price' => '50000.00',
                'currency' => 'XOF',
                'duration_in_days' => 365,
                'features' => [
                    'Toutes les options Pro',
                    '2 mois offerts inclus',
                    'Support VIP dédié',
                ],
                'is_active' => true,
            ]
        );
    }
}

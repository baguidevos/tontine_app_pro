<?php

namespace App\Console\Commands;

use App\Services\SasPayService;
use Illuminate\Console\Command;

class SasPayTestConnectionCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'saspay:test-connection';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Vérifie la configuration et teste la connectivité avec l\'API SasPay';

    /**
     * Execute the console command.
     */
    public function handle(SasPayService $sasPayService): int
    {
        $this->info('=== Diagnostic de l\'intégration SasPay ===');
        $this->newLine();

        $baseUrl = config('saspay.base_url');
        $apiKey = config('saspay.api_key');
        $webhookSecret = config('saspay.webhook_secret');

        $this->line("• Base URL : <comment>{$baseUrl}</comment>");
        $this->line('• Clé API : ' . ($apiKey ? '<info>Configurée (' . substr($apiKey, 0, 7) . '...)</info>' : '<error>Manquante</error>'));
        $this->line('• Secret Webhook : ' . ($webhookSecret ? '<info>Configuré</info>' : '<error>Manquant</error>'));
        $this->newLine();

        // 1. Test de connectivité publique (/countries/)
        $this->info('1. Test de connectivité réseau (GET /countries/)...');
        try {
            $countries = $sasPayService->getCountries();
            $count = is_array($countries) ? count($countries) : 0;
            $this->info("✔ Succès : SasPay a répondu ({$count} pays disponibles).");
        } catch (\Throwable $e) {
            $this->error("✖ Échec du test réseau public : {$e->getMessage()}");
            return self::FAILURE;
        }

        // 2. Test d'authentification (/pricing/my-rates/) si clé présente
        if (!empty($apiKey) && !str_starts_with($apiKey, 'sk_test_replace') && !str_starts_with($apiKey, 'sk_test_your_key')) {
            $this->newLine();
            $this->info('2. Test d\'authentification avec votre clé API (GET /pricing/my-rates/)...');
            try {
                $rates = $sasPayService->getMyRates();
                $this->info('✔ Clé API valide et reconnue par SasPay !');
                if (isset($rates['rates']) && is_array($rates['rates'])) {
                    $this->table(
                        ['Code Réseau', 'Nom', 'Devise'],
                        array_map(fn ($r) => [
                            $r['network'] ?? 'N/A',
                            $r['network_name'] ?? 'N/A',
                            $r['currency'] ?? 'N/A',
                        ], array_slice($rates['rates'], 0, 5))
                    );
                }
            } catch (\Throwable $e) {
                $this->warn("⚠ Échec d'authentification : {$e->getMessage()}");
                $this->comment('Vérifiez que votre clé est bien générée depuis https://app.saspay.me.');
            }
        } else {
            $this->newLine();
            $this->comment('ℹ Clé API d\'exemple détectée. Pour tester l\'authentification complète :');
            $this->comment('  1. Obtenez une clé sk_test_... sur https://app.saspay.me');
            $this->comment('  2. Renseignez-la dans backend/.env (SASPAY_API_KEY=sk_test_...)');
        }

        $this->newLine();
        $this->info('=== Diagnostic terminé avec succès ===');

        return self::SUCCESS;
    }
}

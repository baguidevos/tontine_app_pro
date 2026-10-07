<?php

namespace App\Http\Controllers;

use App\Models\Payment;
use App\Models\Subscription;
use App\Services\SasPayService;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class SasPayWebhookController extends Controller
{
    protected SasPayService $sasPayService;

    public function __construct(SasPayService $sasPayService)
    {
        $this->sasPayService = $sasPayService;
    }

    /**
     * Traite les webhooks envoyés par SasPay.
     * Route: POST /api/webhooks/saspay
     */
    public function handle(Request $request): JsonResponse
    {
        $signature = $request->header('X-Webhook-Signature');
        $timestamp = $request->header('X-Webhook-Timestamp');
        $eventHeader = $request->header('X-Webhook-Event');
        $rawBody = $request->getContent();

        // 1. Vérification de la signature et de l'âge de la requête
        if (!$this->sasPayService->verifyWebhookSignature($rawBody, $signature, $timestamp)) {
            Log::warning('SasPay Webhook: Rejet pour signature ou horodatage invalide.', [
                'signature' => $signature,
                'timestamp' => $timestamp,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Invalid signature or timestamp',
            ], 400);
        }

        $payload = $request->json()->all();
        $event = $eventHeader ?: ($payload['event'] ?? 'unknown');
        $data = $payload['data'] ?? [];

        Log::info("SasPay Webhook reçu: [{$event}]", ['data' => $data]);

        // 2. Traitement selon l'événement
        try {
            switch ($event) {
                case 'transaction.success':
                    $this->handleTransactionSuccess($data);
                    break;

                case 'transaction.failed':
                    $this->handleTransactionFailed($data);
                    break;

                case 'webhook.test':
                    Log::info('SasPay Webhook test réussi avec succès.');
                    break;

                default:
                    Log::info("SasPay Webhook événement non géré: {$event}");
                    break;
            }
        } catch (\Throwable $e) {
            Log::error('Erreur lors du traitement du webhook SasPay', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            // Retourner quand même 200 si l'erreur vient d'un traitement interne déjà consigné
            // pour éviter que SasPay rejoue indéfiniment un payload non réparable
            return response()->json([
                'success' => false,
                'message' => 'Error processed internally',
            ], 200);
        }

        return response()->json(['success' => true]);
    }

    /**
     * Gère un paiement réussi de manière idempotente.
     */
    protected function handleTransactionSuccess(array $data): void
    {
        $saspayId = $data['id'] ?? null;
        $metadata = $data['metadata'] ?? [];
        $localPaymentId = $metadata['payment_id'] ?? null;
        $subscriptionId = $metadata['subscription_id'] ?? null;

        DB::transaction(function () use ($saspayId, $localPaymentId, $subscriptionId, $data) {
            // Recherche de la transaction locale
            $payment = null;

            if ($localPaymentId) {
                $payment = Payment::find($localPaymentId);
            }

            if (!$payment && $saspayId) {
                $payment = Payment::where('saspay_payment_id', $saspayId)
                    ->orWhere('checkout_session_id', $saspayId)
                    ->first();
            }

            if (!$payment && $subscriptionId) {
                $payment = Payment::where('subscription_id', $subscriptionId)
                    ->where('status', 'PENDING')
                    ->latest()
                    ->first();
            }

            if (!$payment) {
                Log::warning('SasPay Webhook success: Aucun enregistrement de paiement correspondant trouvé.', [
                    'saspay_id' => $saspayId,
                    'metadata' => $metadata,
                ]);
                return;
            }

            // IDEMPOTENCE : Si le paiement est déjà validé, ne pas retraiter
            if ($payment->status === 'SUCCESS') {
                Log::info("Paiement #{$payment->id} déjà marqué SUCCESS. Aucun changement.");
                return;
            }

            // Mise à jour du paiement
            $payment->update([
                'status' => 'SUCCESS',
                'saspay_payment_id' => $saspayId ?: $payment->saspay_payment_id,
                'paid_at' => Carbon::now(),
                'raw_response' => $data,
            ]);

            // Activation ou prolongation de l'abonnement
            $subscription = $payment->subscription;
            if ($subscription && $subscription->plan) {
                $subscription->activateWithPlan($subscription->plan);

                Log::info("Abonnement #{$subscription->id} activé/prolongé jusqu'au {$subscription->expires_at}");
            }
        });
    }

    /**
     * Gère un paiement échoué.
     */
    protected function handleTransactionFailed(array $data): void
    {
        $saspayId = $data['id'] ?? null;
        $metadata = $data['metadata'] ?? [];
        $localPaymentId = $metadata['payment_id'] ?? null;

        $payment = null;
        if ($localPaymentId) {
            $payment = Payment::find($localPaymentId);
        }

        if (!$payment && $saspayId) {
            $payment = Payment::where('saspay_payment_id', $saspayId)
                ->orWhere('checkout_session_id', $saspayId)
                ->first();
        }

        if ($payment && $payment->status !== 'SUCCESS') {
            $payment->update([
                'status' => 'FAILED',
                'raw_response' => $data,
            ]);
            Log::info("Paiement #{$payment->id} marqué comme FAILED.");
        }
    }
}

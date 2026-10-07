<?php

namespace App\Services;

use App\Exceptions\SasPayException;
use Illuminate\Http\Client\PendingRequest;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class SasPayService
{
    protected string $baseUrl;
    protected ?string $apiKey;
    protected ?string $webhookSecret;
    protected int $timeout;
    protected int $webhookToleranceSeconds;

    public function __construct()
    {
        $this->baseUrl = rtrim((string) config('saspay.base_url', 'https://api.saspay.me/api/v1'), '/');
        $this->apiKey = config('saspay.api_key');
        $this->webhookSecret = config('saspay.webhook_secret');
        $this->timeout = (int) config('saspay.timeout', 30);
        $this->webhookToleranceSeconds = (int) config('saspay.webhook_tolerance_seconds', 300);
    }

    /**
     * Initialise le client HTTP avec les en-têtes d'authentification Bearer.
     */
    protected function client(?string $idempotencyKey = null): PendingRequest
    {
        $headers = [
            'Accept' => 'application/json',
            'Content-Type' => 'application/json',
        ];

        if ($idempotencyKey) {
            $headers['Idempotency-Key'] = $idempotencyKey;
        }

        return Http::baseUrl($this->baseUrl)
            ->withToken($this->apiKey)
            ->withHeaders($headers)
            ->timeout($this->timeout);
    }

    /**
     * Formate un montant en chaîne décimale conforme SasPay (ex: "2500.00").
     */
    public function formatAmount(float|int|string $amount): string
    {
        return number_format((float) $amount, 2, '.', '');
    }

    /**
     * Crée une session de paiement hébergée (Hosted Checkout).
     * Route: POST /checkout-sessions/
     *
     * Note: Selon la spec SasPay, cette route ne prend pas Idempotency-Key.
     */
    public function createCheckoutSession(array $payload): array
    {
        // Garantir que le montant est bien une chaîne décimale
        if (isset($payload['amount'])) {
            $payload['amount'] = $this->formatAmount($payload['amount']);
        }

        if (!isset($payload['currency'])) {
            $payload['currency'] = config('saspay.currency', 'XOF');
        }

        // Nettoyer les champs nuls ou vides (SasPay renvoie 400 si un champ optionnel comme customer_phone est null)
        $payload = array_filter($payload, fn ($val) => $val !== null && $val !== '');

        $response = $this->client()->post('/checkout-sessions/', $payload);

        return $this->handleResponse($response, 'createCheckoutSession');
    }

    /**
     * Initie un paiement direct softpay (Push USSD sur téléphone).
     * Route: POST /payments/softpay/
     *
     * Nécessite impérativement Idempotency-Key.
     */
    public function initiateSoftpay(array $payload, ?string $idempotencyKey = null): array
    {
        $idempotencyKey = $idempotencyKey ?: Str::uuid()->toString();

        if (isset($payload['amount'])) {
            $payload['amount'] = $this->formatAmount($payload['amount']);
        }

        if (!isset($payload['currency'])) {
            $payload['currency'] = config('saspay.currency', 'XOF');
        }

        if (!isset($payload['country'])) {
            $payload['country'] = config('saspay.country', 'BJ');
        }

        $response = $this->client($idempotencyKey)->post('/payments/softpay/', $payload);

        return $this->handleResponse($response, 'initiateSoftpay');
    }

    /**
     * Vérifie l'état réel d'un paiement auprès de SasPay.
     * Route: GET /payments/{payment_id}/verify/
     */
    public function verifyPayment(string $paymentId): array
    {
        $response = $this->client()->get("/payments/{$paymentId}/verify/");

        return $this->handleResponse($response, 'verifyPayment');
    }

    /**
     * Récupère le statut d'une session de checkout.
     * Route: GET /checkout-sessions/{id}/status/
     */
    public function getCheckoutSessionStatus(string $sessionId): array
    {
        $response = $this->client()->get("/checkout-sessions/{$sessionId}/status/");

        return $this->handleResponse($response, 'getCheckoutSessionStatus');
    }

    /**
     * Confirme un paiement par OTP post-paiement (si exigé par le réseau).
     * Route: POST /payments/{payment_id}/confirm-otp/
     */
    public function confirmOtp(string $paymentId, string $otp): array
    {
        $response = $this->client()->post("/payments/{$paymentId}/confirm-otp/", [
            'otp' => $otp,
        ]);

        return $this->handleResponse($response, 'confirmOtp');
    }

    /**
     * Rejoue un paiement échoué sans créer de nouvelle transaction.
     * Route: POST /payments/{payment_id}/retry/
     */
    public function retryPayment(string $paymentId, ?string $idempotencyKey = null): array
    {
        $idempotencyKey = $idempotencyKey ?: Str::uuid()->toString();
        $response = $this->client($idempotencyKey)->post("/payments/{$paymentId}/retry/");

        return $this->handleResponse($response, 'retryPayment');
    }

    /**
     * Récupère la liste des pays supportés (catalogue public).
     * Route: GET /countries/
     */
    public function getCountries(): array
    {
        $response = Http::baseUrl($this->baseUrl)
            ->acceptJson()
            ->timeout($this->timeout)
            ->get('/countries/');

        if (!$response->successful()) {
            throw new SasPayException(
                "Impossible de récupérer la liste des pays SasPay: {$response->body()}",
                $response->status()
            );
        }

        return $response->json();
    }

    /**
     * Récupère les tarifs et réseaux associés au compte.
     * Route: GET /pricing/my-rates/
     */
    public function getMyRates(): array
    {
        $response = $this->client()->get('/pricing/my-rates/');

        return $this->handleResponse($response, 'getMyRates');
    }

    /**
     * Vérifie la validité cryptographique de la signature du webhook SasPay.
     *
     * Règles SasPay :
     * 1. Rejeter si abs(time() - timestamp) > 300s
     * 2. Recalculer HMAC-SHA256 sur f"{timestamp}.{raw_body}" avec signing_secret
     * 3. Comparer avec hash_equals
     */
    public function verifyWebhookSignature(string $rawBody, ?string $signature, ?string $timestamp): bool
    {
        if (empty($signature) || empty($timestamp) || empty($this->webhookSecret)) {
            Log::warning('SasPay Webhook: signature, timestamp ou secret manquant.');
            return false;
        }

        $timestampInt = (int) $timestamp;
        if (abs(time() - $timestampInt) > $this->webhookToleranceSeconds) {
            Log::warning('SasPay Webhook: horodatage expiré (> 300s).', [
                'timestamp' => $timestamp,
                'current_time' => time(),
            ]);
            return false;
        }

        $signedPayload = "{$timestamp}.{$rawBody}";
        $expectedSignature = hash_hmac('sha256', $signedPayload, $this->webhookSecret);

        return hash_equals(strtolower($expectedSignature), strtolower($signature));
    }

    /**
     * Traite la réponse standardisée de l'API SasPay :
     * { "success": true, "data": {...}, "code": 200 }
     */
    protected function handleResponse(Response $response, string $operation): array
    {
        $status = $response->status();
        $body = $response->json();

        if ($response->successful()) {
            // SasPay enveloppe les données dans "data"
            return $body['data'] ?? $body;
        }

        $errorMessage = "Erreur SasPay lors de {$operation} (HTTP {$status})";
        $errorCode = null;
        $errorDetails = null;

        if (is_array($body) && isset($body['error'])) {
            if (is_array($body['error'])) {
                $errorCode = $body['error']['code'] ?? null;
                $errorMessage = $body['error']['message'] ?? $errorMessage;
                $errorDetails = $body['error'];
            } elseif (is_string($body['error'])) {
                $errorMessage = $body['error'];
            }
        }

        Log::error("SasPay API Error [{$operation}]", [
            'status' => $status,
            'message' => $errorMessage,
            'code' => $errorCode,
            'raw_body' => $response->body(),
        ]);

        throw new SasPayException($errorMessage, $status, $errorCode, $errorDetails);
    }
}

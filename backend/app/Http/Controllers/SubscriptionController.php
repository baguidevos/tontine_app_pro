<?php

namespace App\Http\Controllers;

use App\Exceptions\SasPayException;
use App\Models\Payment;
use App\Models\Plan;
use App\Models\Subscription;
use App\Models\User;
use App\Services\SasPayService;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class SubscriptionController extends Controller
{
    protected SasPayService $sasPayService;

    public function __construct(SasPayService $sasPayService)
    {
        $this->sasPayService = $sasPayService;
    }

    /**
     * Liste des plans disponibles.
     * Route: GET /api/plans
     */
    public function plans(): JsonResponse
    {
        $plans = Plan::where('is_active', true)->get();

        return response()->json([
            'success' => true,
            'data' => $plans,
        ]);
    }

    /**
     * Initialise un paiement d'abonnement (Checkout hébergé par défaut ou Softpay direct).
     * Route: POST /api/subscriptions/checkout
     */
    public function checkout(Request $request): JsonResponse
    {
        $request->validate([
            'plan_id' => 'required|exists:plans,id',
            'return_url' => 'nullable|url',
            'flow' => 'nullable|in:checkout,softpay',
            // Champs requis uniquement si flow = softpay
            'network' => 'required_if:flow,softpay|string|nullable',
            'phone' => 'required_if:flow,softpay|string|nullable',
            'otp' => 'nullable|string',
        ]);

        $user = Auth::user();
        if (!$user) {
            // Utilisateur fallback de test si non authentifié par token pour faciliter les tests
            $user = User::first() ?? User::factory()->create([
                'name' => 'Utilisateur Démo',
                'email' => 'client@tontinepro.app',
            ]);
        }

        $plan = Plan::findOrFail($request->plan_id);
        $flow = $request->input('flow', 'checkout');
        $idempotencyKey = Str::uuid()->toString();

        // 1. Création ou récupération de l'enregistrement de souscription
        $subscription = Subscription::create([
            'user_id' => $user->id,
            'plan_id' => $plan->id,
            'status' => 'pending',
        ]);

        // 2. Création de l'enregistrement de paiement local
        $payment = Payment::create([
            'user_id' => $user->id,
            'subscription_id' => $subscription->id,
            'amount' => $plan->price,
            'currency' => $plan->currency,
            'status' => 'PENDING',
            'flow_type' => $flow,
            'idempotency_key' => $idempotencyKey,
            'customer_email' => $user->email,
            'customer_phone' => $request->input('phone'),
            'payment_method' => $request->input('network'),
        ]);

        try {
            if ($flow === 'softpay') {
                // FLUX SOFTPAY DIRECT (Push mobile money)
                $softpayPayload = [
                    'amount' => $plan->getSaspayAmountString(),
                    'currency' => $plan->currency,
                    'country' => config('saspay.country', 'BJ'),
                    'network' => $request->input('network'),
                    'description' => "Souscription: {$plan->name}",
                    'customer' => [
                        'email' => $user->email,
                        'first_name' => explode(' ', $user->name)[0] ?? 'Client',
                        'last_name' => explode(' ', $user->name)[1] ?? 'Tontine',
                        'phone' => $request->input('phone'),
                    ],
                    'metadata' => [
                        'payment_id' => $payment->id,
                        'subscription_id' => $subscription->id,
                        'user_id' => $user->id,
                    ],
                ];

                if ($request->filled('otp')) {
                    $softpayPayload['otp'] = $request->input('otp');
                }

                $sasResponse = $this->sasPayService->initiateSoftpay($softpayPayload, $idempotencyKey);

                $payment->update([
                    'saspay_payment_id' => $sasResponse['id'] ?? null,
                    'checkout_url' => $sasResponse['checkout_url'] ?? null,
                    'raw_response' => $sasResponse,
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Demande de paiement envoyée sur le mobile.',
                    'data' => [
                        'payment_id' => $payment->id,
                        'status' => $payment->status,
                        'checkout_url' => $sasResponse['checkout_url'] ?? null,
                        'saspay_id' => $sasResponse['id'] ?? null,
                    ],
                ]);
            }

            // FLUX CHECKOUT HÉBERGÉ (Page de paiement SasPay avec MTN, Moov, Orange, Wave, Carte)
            $returnUrl = $request->input('return_url', url("/api/subscriptions/status/{$payment->id}"));

            $checkoutPayload = [
                'amount' => $plan->getSaspayAmountString(),
                'currency' => $plan->currency,
                'description' => "Abonnement - {$plan->name}",
                'customer_email' => $user->email ?: 'client@tontinepro.app',
                'customer_name' => $user->name ?: 'Client Paya',
                'return_url' => $returnUrl,
                'metadata' => [
                    'payment_id' => $payment->id,
                    'subscription_id' => $subscription->id,
                    'user_id' => $user->id,
                ],
            ];

            if ($request->filled('phone')) {
                $checkoutPayload['customer_phone'] = $request->input('phone');
            }

            $sasResponse = $this->sasPayService->createCheckoutSession($checkoutPayload);

            $payment->update([
                'checkout_session_id' => $sasResponse['id'] ?? null,
                'checkout_url' => $sasResponse['checkout_url'] ?? null,
                'raw_response' => $sasResponse,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Session de paiement créée avec succès.',
                'data' => [
                    'payment_id' => $payment->id,
                    'checkout_url' => $sasResponse['checkout_url'] ?? null,
                    'session_id' => $sasResponse['id'] ?? null,
                    'status' => $payment->status,
                ],
            ]);
        } catch (SasPayException $e) {
            $payment->update([
                'status' => 'FAILED',
                'raw_response' => ['error' => $e->getMessage(), 'details' => $e->getErrorDetails()],
            ]);

            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
                'error_code' => $e->getErrorCode(),
                'error_details' => $e->getErrorDetails(),
            ], $e->getHttpStatus() ?: 422);
        }
    }

    /**
     * Vérifie le statut d'un paiement en interrogeant SasPay si nécessaire.
     * Route: GET /api/subscriptions/status/{payment}
     */
    public function status(Payment $payment): JsonResponse
    {
        // Si le paiement est encore PENDING et qu'on a un id SasPay, on interroge l'API
        if ($payment->status === 'PENDING' && $payment->saspay_payment_id) {
            try {
                $verifyResponse = $this->sasPayService->verifyPayment($payment->saspay_payment_id);
                $remoteStatus = $verifyResponse['status'] ?? null;

                if ($remoteStatus === 'SUCCESS') {
                    $payment->update([
                        'status' => 'SUCCESS',
                        'paid_at' => Carbon::now(),
                        'raw_response' => $verifyResponse,
                    ]);

                    if ($payment->subscription && $payment->subscription->plan) {
                        $payment->subscription->activateWithPlan($payment->subscription->plan);
                    }
                } elseif ($remoteStatus === 'FAILED') {
                    $payment->update([
                        'status' => 'FAILED',
                        'raw_response' => $verifyResponse,
                    ]);
                }
            } catch (\Throwable $e) {
                // Si la vérification réseau échoue, on conserve l'état local actuel
            }
        }

        $payment->refresh();
        $subscription = $payment->subscription;

        return response()->json([
            'success' => true,
            'data' => [
                'payment' => [
                    'id' => $payment->id,
                    'amount' => $payment->amount,
                    'currency' => $payment->currency,
                    'status' => $payment->status,
                    'paid_at' => $payment->paid_at,
                ],
                'subscription' => $subscription ? [
                    'id' => $subscription->id,
                    'status' => $subscription->status,
                    'starts_at' => $subscription->starts_at,
                    'expires_at' => $subscription->expires_at,
                    'is_active' => $subscription->isActive(),
                ] : null,
            ],
        ]);
    }

    /**
     * Récupère l'état de l'abonnement en cours pour l'utilisateur connecté.
     * Route: GET /api/subscriptions/current
     */
    public function current(): JsonResponse
    {
        $user = Auth::user() ?? User::first();
        if (!$user) {
            return response()->json([
                'success' => true,
                'data' => null,
            ]);
        }

        $activeSub = $user->activeSubscription();

        return response()->json([
            'success' => true,
            'data' => $activeSub ? [
                'id' => $activeSub->id,
                'plan' => $activeSub->plan,
                'status' => $activeSub->status,
                'starts_at' => $activeSub->starts_at,
                'expires_at' => $activeSub->expires_at,
                'days_remaining' => $activeSub->expires_at ? now()->diffInDays($activeSub->expires_at, false) : null,
            ] : null,
        ]);
    }
}

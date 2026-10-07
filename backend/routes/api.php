<?php

use App\Http\Controllers\SasPayWebhookController;
use App\Http\Controllers\SubscriptionController;
use App\Services\SasPayService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Routes d'abonnements, paiements et webhooks SasPay.
|
*/

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// 1. Offres et abonnements
Route::get('/plans', [SubscriptionController::class, 'plans']);
Route::post('/subscriptions/checkout', [SubscriptionController::class, 'checkout']);
Route::get('/subscriptions/status/{payment}', [SubscriptionController::class, 'status']);
Route::get('/subscriptions/current', [SubscriptionController::class, 'current']);

// 2. Webhook SasPay (sécurisé par signature HMAC-SHA256 et horodatage 300s)
Route::post('/webhooks/saspay', [SasPayWebhookController::class, 'handle']);

// 3. Utilitaires SasPay (catalogues & informations)
Route::get('/saspay/countries', function (SasPayService $sasPayService) {
    return response()->json([
        'success' => true,
        'data' => $sasPayService->getCountries(),
    ]);
});

Route::get('/saspay/rates', function (SasPayService $sasPayService) {
    return response()->json([
        'success' => true,
        'data' => $sasPayService->getMyRates(),
    ]);
});

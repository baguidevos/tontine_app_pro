<?php

return [
    /*
    |--------------------------------------------------------------------------
    | SasPay Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration options for the SasPay REST API integration.
    | Official documentation: https://docs.saspay.me
    |
    */

    'base_url' => env('SASPAY_BASE_URL', 'https://api.saspay.me/api/v1'),

    'api_key' => env('SASPAY_API_KEY'),

    'webhook_secret' => env('SASPAY_WEBHOOK_SECRET'),

    'currency' => env('SASPAY_DEFAULT_CURRENCY', 'XOF'),

    'country' => env('SASPAY_DEFAULT_COUNTRY', 'BJ'),

    // Timeout in seconds for HTTP requests
    'timeout' => 30,

    // Tolerance in seconds for webhook timestamp verification (SasPay rule: max 300s)
    'webhook_tolerance_seconds' => 300,
];

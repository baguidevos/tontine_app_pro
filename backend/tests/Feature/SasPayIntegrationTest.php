<?php

namespace Tests\Feature;

use App\Models\Payment;
use App\Models\Plan;
use App\Models\Subscription;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SasPayIntegrationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config(['saspay.webhook_secret' => 'test_webhook_secret_key_12345']);
    }

    public function test_can_retrieve_active_plans(): void
    {
        Plan::factory()->create([
            'name' => 'Plan Test',
            'slug' => 'plan-test',
            'price' => '3000.00',
            'currency' => 'XOF',
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/plans');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data');
    }

    public function test_webhook_rejects_expired_timestamp(): void
    {
        $timestamp = (string) (time() - 400); // Expiré (> 300s)
        $body = json_encode(['event' => 'transaction.success', 'data' => []]);
        $signature = hash_hmac('sha256', "{$timestamp}.{$body}", 'test_webhook_secret_key_12345');

        $response = $this->call(
            'POST',
            '/api/webhooks/saspay',
            [],
            [],
            [],
            [
                'HTTP_X-Webhook-Signature' => $signature,
                'HTTP_X-Webhook-Timestamp' => $timestamp,
                'HTTP_X-Webhook-Event' => 'transaction.success',
                'CONTENT_TYPE' => 'application/json',
            ],
            $body
        );

        $response->assertStatus(400);
    }

    public function test_webhook_rejects_invalid_signature(): void
    {
        $timestamp = (string) time();
        $body = json_encode(['event' => 'transaction.success', 'data' => []]);
        $invalidSignature = 'fake_invalid_signature';

        $response = $this->call(
            'POST',
            '/api/webhooks/saspay',
            [],
            [],
            [],
            [
                'HTTP_X-Webhook-Signature' => $invalidSignature,
                'HTTP_X-Webhook-Timestamp' => $timestamp,
                'CONTENT_TYPE' => 'application/json',
            ],
            $body
        );

        $response->assertStatus(400);
    }

    public function test_webhook_activates_subscription_idempotently(): void
    {
        $user = User::factory()->create();
        $plan = Plan::create([
            'name' => 'Plan Pro',
            'slug' => 'pro-monthly',
            'price' => '5000.00',
            'currency' => 'XOF',
            'duration_in_days' => 30,
            'is_active' => true,
        ]);

        $subscription = Subscription::create([
            'user_id' => $user->id,
            'plan_id' => $plan->id,
            'status' => 'pending',
        ]);

        $payment = Payment::create([
            'user_id' => $user->id,
            'subscription_id' => $subscription->id,
            'amount' => '5000.00',
            'currency' => 'XOF',
            'status' => 'PENDING',
            'saspay_payment_id' => 'saspay_txn_uuid_999',
        ]);

        $timestamp = (string) time();
        $payload = [
            'event' => 'transaction.success',
            'data' => [
                'id' => 'saspay_txn_uuid_999',
                'amount' => '5000.00',
                'metadata' => [
                    'payment_id' => $payment->id,
                    'subscription_id' => $subscription->id,
                ],
            ],
        ];
        $rawBody = json_encode($payload);
        $signature = hash_hmac('sha256', "{$timestamp}.{$rawBody}", 'test_webhook_secret_key_12345');

        // 1er appel webhook
        $response = $this->call(
            'POST',
            '/api/webhooks/saspay',
            [],
            [],
            [],
            [
                'HTTP_X-Webhook-Signature' => $signature,
                'HTTP_X-Webhook-Timestamp' => $timestamp,
                'HTTP_X-Webhook-Event' => 'transaction.success',
                'CONTENT_TYPE' => 'application/json',
            ],
            $rawBody
        );

        $response->assertStatus(200);

        $payment->refresh();
        $subscription->refresh();

        $this->assertEquals('SUCCESS', $payment->status);
        $this->assertEquals('active', $subscription->status);
        $this->assertTrue($subscription->isActive());
        $firstExpiresAt = $subscription->expires_at;

        // 2eme appel webhook identique (Test d'idempotence)
        $response2 = $this->call(
            'POST',
            '/api/webhooks/saspay',
            [],
            [],
            [],
            [
                'HTTP_X-Webhook-Signature' => $signature,
                'HTTP_X-Webhook-Timestamp' => $timestamp,
                'HTTP_X-Webhook-Event' => 'transaction.success',
                'CONTENT_TYPE' => 'application/json',
            ],
            $rawBody
        );

        $response2->assertStatus(200);
        $subscription->refresh();

        // La date d'expiration ne doit PAS avoir été doublée
        $this->assertEquals($firstExpiresAt->toDateTimeString(), $subscription->expires_at->toDateTimeString());
    }
}

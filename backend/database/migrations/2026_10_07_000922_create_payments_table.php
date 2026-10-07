<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('subscription_id')->nullable()->constrained()->nullOnDelete();
            $table->decimal('amount', 12, 2);
            $table->string('currency', 10)->default('XOF');
            $table->string('status')->default('PENDING'); // PENDING, SUCCESS, FAILED
            $table->string('flow_type')->default('checkout'); // checkout, softpay
            $table->string('idempotency_key', 64)->nullable()->index();
            $table->string('saspay_payment_id', 100)->nullable()->index();
            $table->string('checkout_session_id', 100)->nullable()->index();
            $table->text('checkout_url')->nullable();
            $table->string('payment_method', 50)->nullable();
            $table->string('customer_phone', 50)->nullable();
            $table->string('customer_email', 150)->nullable();
            $table->json('raw_response')->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};

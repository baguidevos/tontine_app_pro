<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Payment extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'subscription_id',
        'amount',
        'currency',
        'status',
        'flow_type',
        'idempotency_key',
        'saspay_payment_id',
        'checkout_session_id',
        'checkout_url',
        'payment_method',
        'customer_phone',
        'customer_email',
        'raw_response',
        'paid_at',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'raw_response' => 'array',
        'paid_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function subscription(): BelongsTo
    {
        return $this->belongsTo(Subscription::class);
    }

    public function isSuccessful(): bool
    {
        return $this->status === 'SUCCESS';
    }

    /**
     * Montant sous forme de chaîne décimale formatée pour SasPay (ex: "2500.00").
     */
    public function getSaspayAmountString(): string
    {
        return number_format((float) $this->amount, 2, '.', '');
    }
}

<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Subscription extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'plan_id',
        'status',
        'starts_at',
        'expires_at',
        'cancelled_at',
    ];

    protected $casts = [
        'starts_at' => 'datetime',
        'expires_at' => 'datetime',
        'cancelled_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function plan(): BelongsTo
    {
        return $this->belongsTo(Plan::class);
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    public function isActive(): bool
    {
        return $this->status === 'active' && ($this->expires_at === null || $this->expires_at->isFuture());
    }

    /**
     * Active ou prolonge l'abonnement en fonction du plan associé.
     */
    public function activateWithPlan(Plan $plan): void
    {
        $now = Carbon::now();
        // Si l'abonnement est déjà actif et n'a pas encore expiré, on prolonge à partir de la date d'expiration
        $baseDate = ($this->isActive() && $this->expires_at) ? $this->expires_at : $now;

        $this->update([
            'status' => 'active',
            'starts_at' => $this->starts_at ?? $now,
            'expires_at' => (clone $baseDate)->addDays($plan->duration_in_days),
        ]);
    }
}

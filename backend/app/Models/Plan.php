<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Plan extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'price',
        'currency',
        'duration_in_days',
        'features',
        'is_active',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'duration_in_days' => 'integer',
        'features' => 'array',
        'is_active' => 'boolean',
    ];

    public function subscriptions(): HasMany
    {
        return $this->hasMany(Subscription::class);
    }

    /**
     * Montant sous forme de chaîne décimale formatée pour SasPay (ex: "2500.00").
     */
    public function getSaspayAmountString(): string
    {
        return number_format((float) $this->price, 2, '.', '');
    }
}

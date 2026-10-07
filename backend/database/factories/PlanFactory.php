<?php

namespace Database\Factories;

use App\Models\Plan;
use Illuminate\Database\Eloquent\Factories\Factory;

class PlanFactory extends Factory
{
    protected $model = Plan::class;

    public function definition(): array
    {
        return [
            'name' => fake()->words(2, true),
            'slug' => fake()->unique()->slug(),
            'description' => fake()->sentence(),
            'price' => '2500.00',
            'currency' => 'XOF',
            'duration_in_days' => 30,
            'features' => ['Option A', 'Option B'],
            'is_active' => true,
        ];
    }
}

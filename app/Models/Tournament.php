<?php
// app/Models/Tournament.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Tournament extends Model
{
    use HasFactory;
    protected $fillable = [
        'name', 'slug', 'description', 'start_date', 'end_date',
        'status', 'third_place_match', 'is_featured', 'created_by',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function (Tournament $tournament) {
            $base = Str::slug($tournament->name);
            $slug = $base;
            $counter = 1;

            while (static::where('slug', $slug)->exists()) {
                $slug = $base . '-' . $counter;
                $counter++;
            }

            $tournament->slug = $slug;
        });
    }
    
    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'third_place_match' => 'boolean',
        'is_featured' => 'boolean',
    ];

    public function groups()
    {
        return $this->hasMany(TournamentGroup::class);
    }

    public function teams()
    {
        return $this->hasMany(Team::class);
    }

    public function matches()
    {
        return $this->hasMany(MatchGame::class);
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}

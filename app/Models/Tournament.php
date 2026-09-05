<?php
// app/Models/Tournament.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Tournament extends Model
{
    use HasFactory;
    protected $fillable = [
        'name', 'description', 'start_date', 'end_date',
        'status', 'third_place_match', 'is_featured', 'created_by',
    ];
    
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

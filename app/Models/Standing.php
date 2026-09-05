<?php
// app/Models/Standing.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Standing extends Model
{
    use HasFactory;

    protected $fillable = [
        'tournament_id',
        'group_id',
        'team_id',
        'played',
        'won',
        'drawn',
        'lost',
        'goals_for',
        'goals_against',
        'goal_diff',
        'points',
    ];

    public function team()
    {
        return $this->belongsTo(Team::class);
    }

    public function group()
    {
        return $this->belongsTo(TournamentGroup::class, 'group_id');
    }

    public function tournament()
    {
        return $this->belongsTo(Tournament::class);
    }
}
<?php
// app/Models/MatchGame.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MatchGame extends Model
{
    use HasFactory;

    protected $table = 'matches';

    protected $fillable = [
        'tournament_id', 'group_id', 'stage',
        'home_team_id', 'away_team_id', 'venue', 'scheduled_at',
        'home_score', 'away_score', 'home_penalty', 'away_penalty',
        'winner_team_id', 'status',
    ];

    protected $casts = [
        'scheduled_at' => 'datetime',
    ];

    public function tournament()
    {
        return $this->belongsTo(Tournament::class);
    }

    public function group()
    {
        return $this->belongsTo(TournamentGroup::class, 'group_id');
    }

    public function homeTeam()
    {
        return $this->belongsTo(Team::class, 'home_team_id');
    }

    public function awayTeam()
    {
        return $this->belongsTo(Team::class, 'away_team_id');
    }

    public function winner()
    {
        return $this->belongsTo(Team::class, 'winner_team_id');
    }

    public function events()
    {
        return $this->hasMany(MatchEvent::class, 'match_id');
    }
}

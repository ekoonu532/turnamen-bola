<?php
// app/Models/TournamentGroup.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TournamentGroup extends Model
{
    use HasFactory;

    protected $fillable = ['tournament_id', 'name'];

    public function tournament()
    {
        return $this->belongsTo(Tournament::class);
    }

    public function teams()
    {
        return $this->hasMany(Team::class, 'group_id');
    }

    public function matches()
    {
        return $this->hasMany(MatchGame::class, 'group_id');
    }

    public function standings()
    {
        return $this->hasMany(Standing::class, 'group_id');
    }
}

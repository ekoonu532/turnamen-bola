<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Player extends Model
{
    use HasFactory;

    protected $fillable = ['team_id', 'name', 'jersey_number', 'position'];

    public function team()
    {
        return $this->belongsTo(Team::class);
    }

    public function events()
    {
        return $this->hasMany(MatchEvent::class);
    }
}
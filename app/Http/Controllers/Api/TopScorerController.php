<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tournament;
use Illuminate\Support\Facades\DB;

class TopScorerController extends Controller
{
    public function index(Tournament $tournament)
    {
        return DB::table('match_events')
            ->join('players', 'players.id', '=', 'match_events.player_id')
            ->join('teams', 'teams.id', '=', 'match_events.team_id')
            ->join('matches', 'matches.id', '=', 'match_events.match_id')
            ->where('matches.tournament_id', $tournament->id)
            ->where('match_events.type', 'goal')
            ->select(
                'players.id as player_id',
                'players.name as player_name',
                'teams.name as team_name',
                DB::raw('COUNT(*) as goals')
            )
            ->groupBy('players.id', 'players.name', 'teams.name')
            ->orderByDesc('goals')
            ->limit(20)
            ->get();
    }
}
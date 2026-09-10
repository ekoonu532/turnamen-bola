<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MatchEvent;
use App\Models\MatchGame;
use Illuminate\Http\Request;

class MatchEventController extends Controller
{
    public function index(MatchGame $match)
    {
        return $match->events()->with('player', 'team')->get();
    }

    public function store(Request $request, MatchGame $match)
    {
        $validated = $request->validate([
            'team_id' => 'required|exists:teams,id',
            'player_id' => 'required|exists:players,id',
            'type' => 'required|in:goal,yellow_card,red_card',
            'minute' => 'nullable|integer|min:0|max:120',
        ]);

        $event = $match->events()->create($validated);

        return response()->json($event->load('player', 'team'), 201);
    }

    public function destroy(MatchGame $match, MatchEvent $event)
    {
        $event->delete();

        return response()->json(['message' => 'Event berhasil dihapus.']);
    }
}
<?php
// app/Http/Controllers/Api/KnockoutController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tournament;
use App\Services\KnockoutService;
use Illuminate\Http\Request;

class KnockoutController extends Controller
{
    public function __construct(protected KnockoutService $knockoutService)
    {
    }

    
    public function generateSemifinals(Tournament $tournament)
    {
        try {
            $matches = $this->knockoutService->generateSemifinals($tournament);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Semifinal berhasil digenerate.',
            'matches' => \App\Models\MatchGame::whereIn('id', collect($matches)->pluck('id'))
                ->with(['homeTeam', 'awayTeam'])
                ->get(),
        ]);
    }

    public function generateFinal(Tournament $tournament)
    {
        try {
            $matches = $this->knockoutService->generateFinal($tournament);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Final berhasil digenerate.',
            'matches' => \App\Models\MatchGame::whereIn('id', collect($matches)->pluck('id'))
                ->with(['homeTeam', 'awayTeam'])
                ->get(),
        ]);
    }
}

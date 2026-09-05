<?php
// app/Http/Controllers/Api/MatchController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MatchGame;
use App\Models\Tournament;
use App\Services\StandingService;
use Illuminate\Http\Request;

class MatchController extends Controller
{
    public function __construct(protected StandingService $standingService)
    {
    }

    public function index(Tournament $tournament)
    {
        return $tournament->matches()
            ->with(['homeTeam', 'awayTeam', 'group'])
            ->orderBy('scheduled_at')
            ->get();
    }

    public function updateScore(Request $request, MatchGame $match)
    {
        $validated = $request->validate([
            'home_score' => 'required|integer|min:0',
            'away_score' => 'required|integer|min:0',
            'home_penalty' => 'nullable|integer|min:0',
            'away_penalty' => 'nullable|integer|min:0',
            'force' => 'boolean',
        ]);

        if ($this->standingService->isMatchLocked($match) && ! $request->boolean('force')) {
            return response()->json([
                'message' => 'Babak berikutnya sudah digenerate berdasarkan hasil ini. Kirim "force": true untuk tetap koreksi.',
            ], 422);
        }

        $isKnockout = $match->stage !== 'group';
        $isDraw = $validated['home_score'] === $validated['away_score'];

        if ($isKnockout && $isDraw) {
            // Imbang di knockout wajib lanjut adu penalti
            if (! isset($validated['home_penalty']) || ! isset($validated['away_penalty'])) {
                return response()->json([
                    'message' => 'Pertandingan berakhir imbang. Sertakan skor adu penalti (home_penalty & away_penalty).',
                    'requires_penalty' => true,
                ], 422);
            }

            if ($validated['home_penalty'] === $validated['away_penalty']) {
                return response()->json([
                    'message' => 'Skor adu penalti tidak boleh sama.',
                ], 422);
            }

            $winnerId = $validated['home_penalty'] > $validated['away_penalty']
                ? $match->home_team_id
                : $match->away_team_id;
        } elseif ($validated['home_score'] > $validated['away_score']) {
            $winnerId = $match->home_team_id;
        } elseif ($validated['away_score'] > $validated['home_score']) {
            $winnerId = $match->away_team_id;
        } else {
            $winnerId = null; // imbang sah, khusus fase grup
        }

        $match->update([
            'home_score' => $validated['home_score'],
            'away_score' => $validated['away_score'],
            'home_penalty' => $validated['home_penalty'] ?? null,
            'away_penalty' => $validated['away_penalty'] ?? null,
            'winner_team_id' => $winnerId,
            'status' => 'finished',
        ]);

        if ($match->group_id) {
            $this->standingService->recalculate($match->group_id);
        }

        return response()->json([
            'message' => 'Skor berhasil disimpan.',
            'match' => $match->fresh(['homeTeam', 'awayTeam']),
        ]);
    }

    public function reschedule(Request $request, MatchGame $match)
    {
        $validated = $request->validate([
            'scheduled_at' => 'required|date',
            'venue' => 'nullable|string|max:255',
        ]);

        $match->update($validated);

        return response()->json([
            'message' => 'Jadwal berhasil diperbarui.',
            'match' => $match,
        ]);
    }


    public function show(MatchGame $match)
    {
        return $match->load(['homeTeam', 'awayTeam', 'group']);
    }


    public function walkover(Request $request, MatchGame $match)
    {
        $validated = $request->validate([
            'winner_team_id' => 'required|exists:teams,id|in:' . $match->home_team_id . ',' . $match->away_team_id,
        ]);

        // skor WO standar: 3-0 untuk pemenang (bisa disesuaikan aturan turnamen kamu)
        $isHomeWinner = $validated['winner_team_id'] == $match->home_team_id;

        $match->update([
            'home_score' => $isHomeWinner ? 3 : 0,
            'away_score' => $isHomeWinner ? 0 : 3,
            'winner_team_id' => $validated['winner_team_id'],
            'status' => 'walkover',
        ]);

        if ($match->group_id) {
            $this->standingService->recalculate($match->group_id);
        }

        return response()->json([
            'message' => 'Walkover berhasil dicatat.',
            'match' => $match->fresh(['homeTeam', 'awayTeam']),
        ]);
    }
}

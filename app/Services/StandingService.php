<?php
// app/Services/StandingService.php

namespace App\Services;

use App\Models\MatchGame;
use App\Models\Standing;
use App\Models\Team;

class StandingService
{
    /**
     * Hitung ulang klasemen satu grup dari nol berdasarkan semua match yang sudah selesai.
     */
    public function recalculate(int $groupId): void
    {
        $teams = Team::where('group_id', $groupId)->get();

        foreach ($teams as $team) {
            $matches = MatchGame::where('group_id', $groupId)
                ->where('status', 'finished')
                ->where(function ($q) use ($team) {
                    $q->where('home_team_id', $team->id)
                        ->orWhere('away_team_id', $team->id);
                })
                ->get();

            $played = $won = $drawn = $lost = $gf = $ga = 0;

            foreach ($matches as $match) {
                $isHome = $match->home_team_id === $team->id;
                $scoreFor = $isHome ? $match->home_score : $match->away_score;
                $scoreAgainst = $isHome ? $match->away_score : $match->home_score;

                $played++;
                $gf += $scoreFor;
                $ga += $scoreAgainst;

                if ($scoreFor > $scoreAgainst) {
                    $won++;
                } elseif ($scoreFor === $scoreAgainst) {
                    $drawn++;
                } else {
                    $lost++;
                }
            }

            Standing::updateOrCreate(
                ['group_id' => $groupId, 'team_id' => $team->id],
                [
                    'tournament_id' => $team->tournament_id,
                    'played' => $played,
                    'won' => $won,
                    'drawn' => $drawn,
                    'lost' => $lost,
                    'goals_for' => $gf,
                    'goals_against' => $ga,
                    'goal_diff' => $gf - $ga,
                    'points' => ($won * 3) + $drawn,
                ]
            );
        }
    }

    /**
     * Ambil klasemen terurut: poin -> selisih gol -> gol memasukkan.
     */
    // app/Services/StandingService.php
    public function getRanked(int $groupId)
    {
        $teams = Team::where('group_id', $groupId)->get();

        // pastikan setiap tim di grup ini punya baris standing, meski belum pernah main
        foreach ($teams as $team) {
            Standing::firstOrCreate(
                ['group_id' => $groupId, 'team_id' => $team->id],
                [
                    'tournament_id' => $team->tournament_id,
                    'played' => 0,
                    'won' => 0,
                    'drawn' => 0,
                    'lost' => 0,
                    'goals_for' => 0,
                    'goals_against' => 0,
                    'goal_diff' => 0,
                    'points' => 0,
                ]
            );
        }

        return Standing::where('group_id', $groupId)
            ->with('team')
            ->orderByDesc('points')
            ->orderByDesc('goal_diff')
            ->orderByDesc('goals_for')
            ->get();
    }

    public function isMatchLocked(\App\Models\MatchGame $match): bool
    {
        if ($match->stage !== 'semifinal') {
            return false;
        }

        return $match->tournament->matches()
            ->where('stage', 'final')
            ->whereNotNull('home_team_id') // hanya terkunci kalau Final SUDAH terisi tim asli, bukan placeholder kosong
            ->exists();
    }

    public function withdrawTeam(\App\Models\Team $team): void
    {
        $team->update(['status' => 'withdrawn']);

        // semua match yang belum main langsung WO untuk lawannya
        $upcomingMatches = \App\Models\MatchGame::where('status', 'scheduled')
            ->where(function ($q) use ($team) {
                $q->where('home_team_id', $team->id)->orWhere('away_team_id', $team->id);
            })
            ->get();

        foreach ($upcomingMatches as $match) {
            $opponentId = $match->home_team_id === $team->id ? $match->away_team_id : $match->home_team_id;

            $match->update([
                'home_score' => $match->home_team_id === $team->id ? 0 : 3,
                'away_score' => $match->away_team_id === $team->id ? 0 : 3,
                'winner_team_id' => $opponentId,
                'status' => 'walkover',
            ]);
        }

        // recalculate semua grup yang terdampak
        $groupIds = $upcomingMatches->pluck('group_id')->filter()->unique();
        foreach ($groupIds as $groupId) {
            $this->recalculate($groupId);
        }
    }
}

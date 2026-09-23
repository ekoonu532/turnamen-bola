<?php
// app/Services/KnockoutService.php

namespace App\Services;

use App\Models\MatchGame;
use App\Models\Tournament;
use App\Services\StandingService;

class KnockoutService
{
    public function __construct(protected StandingService $standingService)
    {
    }

    /**
     * Generate semifinal dari juara & runner-up tiap grup (khusus format 2 grup).
     * Juara Grup A vs Runner-up Grup B, Juara Grup B vs Runner-up Grup A.
     */
        public function generateSemifinals(Tournament $tournament): array
    {
        $groups = $tournament->groups;

        if ($groups->count() !== 2) {
            throw new \RuntimeException('Generate semifinal otomatis ini hanya untuk format 2 grup.');
        }

        $unfinished = $tournament->matches()
            ->where('stage', 'group')
            ->where('status', '!=', 'finished')
            ->count();

        if ($unfinished > 0) {
            throw new \RuntimeException('Masih ada pertandingan fase grup yang belum selesai.');
        }

        $existingSemifinals = $tournament->matches()->where('stage', 'semifinal')->get();

        if ($existingSemifinals->count() === 2 && $existingSemifinals->every(fn ($m) => $m->home_team_id !== null)) {
            throw new \RuntimeException('Semifinal sudah pernah digenerate.');
        }

        [$groupA, $groupB] = $groups->values();

        $rankedA = $this->standingService->getRanked($groupA->id);
        $rankedB = $this->standingService->getRanked($groupB->id);

        $pairs = [
            [$rankedA[0]->team_id, $rankedB[1]->team_id],
            [$rankedB[0]->team_id, $rankedA[1]->team_id],
        ];

        if ($existingSemifinals->count() === 2) {
            foreach ($existingSemifinals->values() as $i => $match) {
                $match->update([
                    'home_team_id' => $pairs[$i][0],
                    'away_team_id' => $pairs[$i][1],
                ]);
            }
            return $existingSemifinals->fresh()->all();
        }

        return [
            MatchGame::create([
                'tournament_id' => $tournament->id, 'stage' => 'semifinal',
                'home_team_id' => $pairs[0][0], 'away_team_id' => $pairs[0][1], 'status' => 'scheduled',
            ]),
            MatchGame::create([
                'tournament_id' => $tournament->id, 'stage' => 'semifinal',
                'home_team_id' => $pairs[1][0], 'away_team_id' => $pairs[1][1], 'status' => 'scheduled',
            ]),
        ];
    }

    public function generateFinal(Tournament $tournament): array
    {
        $semifinals = $tournament->matches()->where('stage', 'semifinal')->get();

        if ($semifinals->count() !== 2) {
            throw new \RuntimeException('Semifinal belum digenerate.');
        }

        if ($semifinals->contains(fn ($m) => $m->status !== 'finished')) {
            throw new \RuntimeException('Masih ada semifinal yang belum selesai.');
        }

        $existingFinal = $tournament->matches()->where('stage', 'final')->first();

        if ($existingFinal && $existingFinal->home_team_id !== null) {
            throw new \RuntimeException('Final sudah pernah digenerate.');
        }

        [$sf1, $sf2] = $semifinals->values();

        if ($existingFinal) {
            $existingFinal->update(['home_team_id' => $sf1->winner_team_id, 'away_team_id' => $sf2->winner_team_id]);
            $final = $existingFinal->fresh();
        } else {
            $final = MatchGame::create([
                'tournament_id' => $tournament->id, 'stage' => 'final',
                'home_team_id' => $sf1->winner_team_id, 'away_team_id' => $sf2->winner_team_id, 'status' => 'scheduled',
            ]);
        }

        $matches = [$final];

        if ($tournament->third_place_match) {
            $loserSf1 = $sf1->home_team_id === $sf1->winner_team_id ? $sf1->away_team_id : $sf1->home_team_id;
            $loserSf2 = $sf2->home_team_id === $sf2->winner_team_id ? $sf2->away_team_id : $sf2->home_team_id;

            $existingThird = $tournament->matches()->where('stage', 'third_place')->first();

            if ($existingThird) {
                $existingThird->update(['home_team_id' => $loserSf1, 'away_team_id' => $loserSf2]);
                $matches[] = $existingThird->fresh();
            } else {
                $matches[] = MatchGame::create([
                    'tournament_id' => $tournament->id, 'stage' => 'third_place',
                    'home_team_id' => $loserSf1, 'away_team_id' => $loserSf2, 'status' => 'scheduled',
                ]);
            }
        }

        return $matches;
    }

    public function autoAdvanceSemifinal(\App\Models\Tournament $tournament): void
    {
        $semifinals = $tournament->matches()->where('stage', 'semifinal')->orderBy('id')->get();

        if ($semifinals->count() !== 2) {
            return;
        }

        [$sf1, $sf2] = $semifinals->values();

        $final = $tournament->matches()->where('stage', 'final')->first();
        $thirdPlace = $tournament->matches()->where('stage', 'third_place')->first();

        if (in_array($sf1->status, ['finished', 'walkover']) && $sf1->winner_team_id) {
            $winner = $sf1->winner_team_id;
            $loser = $sf1->home_team_id === $winner ? $sf1->away_team_id : $sf1->home_team_id;

            $final?->update(['home_team_id' => $winner]);
            $thirdPlace?->update(['home_team_id' => $loser]);
        }

        if (in_array($sf2->status, ['finished', 'walkover']) && $sf2->winner_team_id) {
            $winner = $sf2->winner_team_id;
            $loser = $sf2->home_team_id === $winner ? $sf2->away_team_id : $sf2->home_team_id;

            $final?->update(['away_team_id' => $winner]);
            $thirdPlace?->update(['away_team_id' => $loser]);
        }
    }
}

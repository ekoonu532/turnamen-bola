<?php
// app/Http/Controllers/Api/Public/TournamentPublicController.php

namespace App\Http\Controllers\Api\Public;

use App\Http\Controllers\Controller;
use App\Models\Tournament;
use App\Services\StandingService;

class TournamentPublicController extends Controller
{
    public function __construct(protected StandingService $standingService)
    {
    }

    /**
     * Daftar turnamen yang statusnya sudah publik (bukan draft).
     */
    public function index()
    {
        return Tournament::whereIn('status', ['registration', 'ongoing', 'finished'])
            ->orderByDesc('is_featured')
            ->latest()
            ->get(['id', 'name', 'slug', 'description', 'start_date', 'end_date', 'status', 'is_featured']);
    }

    /**
     * Detail turnamen + daftar tim per grup.
     */
    public function show(Tournament $tournament)
    {
        $this->ensurePublic($tournament);

        return $tournament->load([
            'groups.teams' => fn ($q) => $q->select('id', 'group_id', 'name', 'logo_url', 'status'),
        ])->only('id', 'name', 'description', 'start_date', 'end_date', 'status', 'groups');
    }

    /**
     * Jadwal & hasil pertandingan, urut tanggal.
     */
    public function matches(Tournament $tournament)
    {
        $this->ensurePublic($tournament);

        return $tournament->matches()
            ->with([
                'homeTeam:id,name,logo_url',
                'awayTeam:id,name,logo_url',
                'group:id,name',
            ])
            ->orderBy('scheduled_at')
            ->get([
                'id', 'group_id', 'stage', 'home_team_id', 'away_team_id',
                'venue', 'scheduled_at', 'home_score', 'away_score',
                'home_penalty', 'away_penalty',
                'winner_team_id', 'status',
            ]);
    }

    /**
     * Klasemen tiap grup.
     */
    public function standings(Tournament $tournament)
    {
        $this->ensurePublic($tournament);

        $groups = $tournament->groups;

        return $groups->map(function ($group) {
            return [
                'group' => $group->only('id', 'name'),
                'standings' => $this->standingService->getRanked($group->id)
                    ->map(fn ($s) => [
                        'team' => $s->team->only('id', 'name', 'logo_url'),
                        'played' => $s->played,
                        'won' => $s->won,
                        'drawn' => $s->drawn,
                        'lost' => $s->lost,
                        'goals_for' => $s->goals_for,
                        'goals_against' => $s->goals_against,
                        'goal_diff' => $s->goal_diff,
                        'points' => $s->points,
                    ]),
            ];
        });
    }

    /**
     * Bracket knockout (semifinal, final, third place).
     */
    public function bracket(Tournament $tournament)
    {
        $this->ensurePublic($tournament);

        return $tournament->matches()
            ->whereIn('stage', ['semifinal', 'final', 'third_place'])
            ->with(['homeTeam:id,name,logo_url', 'awayTeam:id,name,logo_url'])
            ->get([
                'id', 'stage', 'home_team_id', 'away_team_id',
                'home_score', 'away_score', 'winner_team_id',
                'home_penalty', 'away_penalty',
                'status', 'scheduled_at',
            ])
            ->groupBy('stage');
    }

    /**
     * Turnamen dengan status 'draft' tidak boleh diakses publik.
     */
    protected function ensurePublic(Tournament $tournament): void
    {
        if ($tournament->status === 'draft') {
            abort(404);
        }
    }
}

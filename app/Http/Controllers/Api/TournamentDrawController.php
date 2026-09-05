<?php
// app/Http/Controllers/Api/TournamentDrawController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MatchGame;
use App\Models\Tournament;
use App\Models\TournamentGroup;
use App\Services\TournamentDrawService;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TournamentDrawController extends Controller
{
    public function __construct(protected TournamentDrawService $drawService)
    {
    }

    /**
     * Step 1: Undi tim ke dalam grup.
     */
    public function drawGroups(Request $request, Tournament $tournament)
    {
        $validated = $request->validate([
            'group_count' => 'required|integer|min:2|max:8',
            'group_names' => 'nullable|array',
        ]);

        $teamIds = $tournament->teams()->pluck('id')->toArray();

        if (count($teamIds) < $validated['group_count'] * 2) {
            return response()->json([
                'message' => 'Jumlah tim tidak cukup untuk dibagi ke jumlah grup ini.',
            ], 422);
        }

        $groupedTeamIds = $this->drawService->drawGroups($teamIds, $validated['group_count']);

        DB::transaction(function () use ($tournament, $groupedTeamIds, $validated) {
            // hapus grup lama kalau undi ulang
            $tournament->groups()->delete();

            foreach ($groupedTeamIds as $index => $teamIdsInGroup) {
                $groupName = $validated['group_names'][$index] ?? 'Grup ' . chr(65 + $index); // A, B, C...

                $group = $tournament->groups()->create(['name' => $groupName]);

                foreach ($teamIdsInGroup as $teamId) {
                    \App\Models\Team::where('id', $teamId)->update(['group_id' => $group->id]);
                }
            }
        });

        return response()->json([
            'message' => 'Undian grup berhasil.',
            'groups' => $tournament->groups()->with('teams')->get(),
        ]);
    }

    /**
     * Step 2: Generate jadwal round robin fase grup, 1 match/hari, adil antar grup.
     */

    public function generateSchedule(Request $request, Tournament $tournament)
    {
        $validated = $request->validate([
            'start_date' => 'required|date',
            'rest_days_after_group' => 'nullable|integer|min:0|max:14',
            'rest_days_after_semifinal' => 'nullable|integer|min:0|max:14',
            'match_time' => 'nullable|date_format:H:i',
        ]);

        $restAfterGroup = $validated['rest_days_after_group'] ?? 1;
        $restAfterSemifinal = $validated['rest_days_after_semifinal'] ?? 1;
        $matchTime = $validated['match_time'] ?? '16:00';

        $groups = $tournament->groups()->with('teams')->get();

        if ($groups->isEmpty()) {
            return response()->json(['message' => 'Grup belum diundi.'], 422);
        }

        $tournament->matches()->delete();

        $groupSchedules = [];
        foreach ($groups as $group) {
            $teamIds = $group->teams->pluck('id')->toArray();
            $groupSchedules[$group->id] = $this->drawService->roundRobinPairing($teamIds);
        }

        $sequence = $this->drawService->interleaveSchedules($groupSchedules);
        $sequence = $this->drawService->assignDates($sequence, Carbon::parse($validated['start_date']), $matchTime);

        DB::transaction(function () use ($sequence, $tournament, $restAfterGroup, $restAfterSemifinal, $matchTime) {
            foreach ($sequence as $item) {
                MatchGame::create([
                    'tournament_id' => $tournament->id,
                    'group_id' => $item['group_id'],
                    'stage' => 'group',
                    'home_team_id' => $item['home_team_id'],
                    'away_team_id' => $item['away_team_id'],
                    'scheduled_at' => $item['scheduled_at'],
                    'status' => 'scheduled',
                ]);
            }

            [$hour, $minute] = explode(':', $matchTime);
            $setTime = fn (Carbon $date) => $date->setTime((int) $hour, (int) $minute);

            $lastGroupDate = collect($sequence)->max('scheduled_at');

            // restAfterGroup hari LIBUR (tanpa pertandingan), baru semifinal 1 dimainkan di hari setelahnya
            $semifinal1Date = $setTime($lastGroupDate->copy()->addDays($restAfterGroup + 1));
            // Semifinal 2 — hari berikutnya
            $semifinal2Date = $setTime($semifinal1Date->copy()->addDay());

            MatchGame::create([
                'tournament_id' => $tournament->id,
                'stage' => 'semifinal',
                'scheduled_at' => $semifinal1Date,
                'status' => 'scheduled',
            ]);
            MatchGame::create([
                'tournament_id' => $tournament->id,
                'stage' => 'semifinal',
                'scheduled_at' => $semifinal2Date,
                'status' => 'scheduled',
            ]);

            // restAfterSemifinal hari LIBUR, baru perebutan juara 3 dimainkan di hari setelahnya
            $thirdPlaceDate = $setTime($semifinal2Date->copy()->addDays($restAfterSemifinal + 1));
            // Final — hari berikutnya
            $finalDate = $setTime($thirdPlaceDate->copy()->addDay());

            if ($tournament->third_place_match) {
                MatchGame::create([
                    'tournament_id' => $tournament->id,
                    'stage' => 'third_place',
                    'scheduled_at' => $thirdPlaceDate,
                    'status' => 'scheduled',
                ]);

                MatchGame::create([
                    'tournament_id' => $tournament->id,
                    'stage' => 'final',
                    'scheduled_at' => $finalDate,
                    'status' => 'scheduled',
                ]);
            } else {
                // tanpa perebutan juara 3, final langsung setelah jeda dari semifinal 2
                MatchGame::create([
                    'tournament_id' => $tournament->id,
                    'stage' => 'final',
                    'scheduled_at' => $thirdPlaceDate,
                    'status' => 'scheduled',
                ]);
            }
        });

        return response()->json([
            'message' => 'Jadwal berhasil dibuat, termasuk perkiraan jadwal semifinal & final.',
            'matches' => $tournament->matches()->with(['homeTeam', 'awayTeam', 'group'])->orderBy('scheduled_at')->get(),
        ]);
    }
    public function createGroups(Request $request, Tournament $tournament)
    {
        $validated = $request->validate([
            'group_names' => 'required|array|min:2',
            'group_names.*' => 'required|string|max:255',
        ]);

        DB::transaction(function () use ($tournament, $validated) {
            \App\Models\Team::where('tournament_id', $tournament->id)->update(['group_id' => null]);
            $tournament->groups()->delete();

            foreach ($validated['group_names'] as $name) {
                $tournament->groups()->create(['name' => $name]);
            }
        });

        return response()->json([
            'message' => 'Grup berhasil dibuat.',
            'groups' => $tournament->groups()->with('teams')->get(),
        ]);
    }

    /**
     * Reset grup — lepas semua tim dari grup & hapus semua grup.
     */
    public function resetGroups(Tournament $tournament)
    {
        DB::transaction(function () use ($tournament) {
            \App\Models\Team::where('tournament_id', $tournament->id)->update(['group_id' => null]);
            $tournament->groups()->delete();
        });

        return response()->json(['message' => 'Grup berhasil direset.']);
    }
}

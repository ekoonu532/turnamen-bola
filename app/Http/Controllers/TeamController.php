<?php
// app/Http/Controllers/TeamController.php

namespace App\Http\Controllers;

use App\Models\Team;
use App\Models\Tournament;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function index(Tournament $tournament)
    {
        return $tournament->teams()->with('group')->orderBy('name')->get();
    }

    public function store(Request $request, Tournament $tournament)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'logo_url' => 'nullable|url',
            'contact_person' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:30',
        ]);

        $team = $tournament->teams()->create($validated + ['status' => 'pending']);

        return response()->json($team, 201);
    }

    public function update(Request $request, Tournament $tournament, Team $team)
    {
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'logo_url' => 'nullable|url',
            'contact_person' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:30',
            'status' => 'sometimes|required|in:pending,verified,rejected',
        ]);

        $team->update($validated);

        return response()->json($team);
    }

    public function destroy(Tournament $tournament, Team $team)
    {
        $team->delete();

        return response()->json(['message' => 'Team deleted'], 200);
    }

    public function withdraw(Request $request, Tournament $tournament, Team $team, \App\Services\StandingService $standingService)
    {
        $standingService->withdrawTeam($team);

        return response()->json([
            'message' => 'Tim berhasil ditandai mundur, semua pertandingan tersisa otomatis WO.',
            'team' => $team->fresh(),
        ]);
    }

    public function assignGroup(Request $request, Team $team)
    {
        $validated = $request->validate([
            'group_id' => 'nullable|exists:tournament_groups,id',
        ]);

        $team->update(['group_id' => $validated['group_id']]);

        return response()->json([
            'message' => 'Grup tim berhasil diperbarui.',
            'team' => $team->fresh('group'),
        ]);
    }
}

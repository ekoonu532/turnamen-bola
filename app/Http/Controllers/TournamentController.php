<?php
// app/Http/Controllers/TournamentController.php

namespace App\Http\Controllers;

use App\Models\Tournament;
use Illuminate\Http\Request;

class TournamentController extends Controller
{
    public function index()
    {
        return Tournament::latest()->get();
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'third_place_match' => 'boolean',
        ]);

        $validated['created_by'] = $request->user()->id;
        $validated['status'] = 'draft';

        $tournament = Tournament::create($validated);

        return response()->json($tournament, 201);
    }

    public function show(Tournament $tournament)
    {
        return $tournament->load('groups.teams', 'teams', 'matches');
    }

    public function update(Request $request, Tournament $tournament)
    {
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'status' => 'sometimes|required|in:draft,registration,ongoing,finished',
            'third_place_match' => 'boolean',
        ]);

        $tournament->update($validated);

        return response()->json($tournament);
    }

    public function destroy(Tournament $tournament)
    {
        $tournament->delete();

        return response()->json(['message' => 'Tournament deleted'], 200);
    }


    public function feature(Tournament $tournament)
    {
        \Illuminate\Support\Facades\DB::transaction(function () use ($tournament) {
            Tournament::where('id', '!=', $tournament->id)->update(['is_featured' => false]);
            $tournament->update(['is_featured' => true]);
        });

        return response()->json([
            'message' => 'Turnamen dijadikan tampilan utama.',
            'tournament' => $tournament->fresh(),
        ]);
    }

    public function unfeature(Tournament $tournament)
    {
        $tournament->update(['is_featured' => false]);

        return response()->json([
            'message' => 'Turnamen tidak lagi jadi tampilan utama.',
            'tournament' => $tournament->fresh(),
        ]);
    }


}

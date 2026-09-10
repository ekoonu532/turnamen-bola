<?php

namespace App\Http\Controllers;

use App\Models\Player;
use App\Models\Team;
use Illuminate\Http\Request;

class PlayerController extends Controller
{
    public function index(Team $team)
    {
        return $team->players()->orderBy('jersey_number')->get();
    }

    public function store(Request $request, Team $team)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'jersey_number' => 'nullable|integer|min:0|max:99',
            'position' => 'nullable|string|max:50',
        ]);

        $player = $team->players()->create($validated);

        return response()->json($player, 201);
    }

    public function update(Request $request, Team $team, Player $player)
    {
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'jersey_number' => 'nullable|integer|min:0|max:99',
            'position' => 'nullable|string|max:50',
        ]);

        $player->update($validated);

        return response()->json($player);
    }

    public function destroy(Team $team, Player $player)
    {
        $player->delete();

        return response()->json(['message' => 'Pemain berhasil dihapus.']);
    }
}
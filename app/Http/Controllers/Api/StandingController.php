<?php
// app/Http/Controllers/Api/StandingController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tournament;
use App\Services\StandingService;

class StandingController extends Controller
{
    public function __construct(protected StandingService $standingService)
    {
    }

    public function index(Tournament $tournament)
    {
        $groups = $tournament->groups;

        $result = $groups->map(function ($group) {
            return [
                'group' => $group->only('id', 'name'),
                'standings' => $this->standingService->getRanked($group->id),
            ];
        });

        return response()->json($result);
    }
}

<?php
// routes/api.php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\KnockoutController;
use App\Http\Controllers\Api\MatchController;
use App\Http\Controllers\Api\StandingController;
use App\Http\Controllers\Api\TournamentDrawController;
use App\Http\Controllers\TeamController;
use App\Http\Controllers\TournamentController;
use App\Http\Controllers\Api\Public\TournamentPublicController;
use App\Http\Controllers\Api\MatchEventController;
use App\Http\Controllers\Api\TopScorerController;
use App\Http\Controllers\PlayerController;
use Illuminate\Support\Facades\Route;

// ── Auth ──────────────────────────────────────────────
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {

    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // ── Tournament & Team CRUD ───────────────────────────
    Route::apiResource('tournaments', TournamentController::class);
    Route::apiResource('tournaments.teams', TeamController::class)
        ->shallow()
        ->except(['show']);

    // ── Undian Grup & Generate Jadwal ────────────────────
    Route::post('/tournaments/{tournament}/draw-groups', [TournamentDrawController::class, 'drawGroups']);
    Route::post('/tournaments/{tournament}/generate-schedule', [TournamentDrawController::class, 'generateSchedule']);

    // ── Pertandingan (Match) ─────────────────────────────
    Route::get('/tournaments/{tournament}/matches', [MatchController::class, 'index']);
    Route::patch('/matches/{match}/score', [MatchController::class, 'updateScore']);
    Route::patch('/matches/{match}/reschedule', [MatchController::class, 'reschedule']);

    // ── Klasemen ──────────────────────────────────────────
    Route::get('/tournaments/{tournament}/standings', [StandingController::class, 'index']);

    // ── Knockout (Semifinal & Final) ─────────────────────
    Route::post('/tournaments/{tournament}/generate-semifinals', [KnockoutController::class, 'generateSemifinals']);
    Route::post('/tournaments/{tournament}/generate-final', [KnockoutController::class, 'generateFinal']);

    Route::post('/teams/{team}/withdraw', [TeamController::class, 'withdraw']);
    Route::patch('/matches/{match}/walkover', [MatchController::class, 'walkover']);

    // routes/api.php — tambahkan di dalam middleware auth:sanctum group

    Route::post('/tournaments/{tournament}/groups', [TournamentDrawController::class, 'createGroups']);
    Route::delete('/tournaments/{tournament}/groups', [TournamentDrawController::class, 'resetGroups']);
    Route::patch('/teams/{team}/assign-group', [TeamController::class, 'assignGroup']);

    Route::get('/matches/{match}', [MatchController::class, 'show']);
    // routes/api.php — tambahkan di dalam middleware auth:sanctum group

    Route::post('/tournaments/{tournament}/feature', [TournamentController::class, 'feature']);
    Route::delete('/tournaments/{tournament}/feature', [TournamentController::class, 'unfeature']);

    // di dalam middleware auth:sanctum group, tambahkan:
    Route::apiResource('teams.players', PlayerController::class)
    ->shallow()
    ->except(['show']);

    Route::get('/matches/{match}/events', [MatchEventController::class, 'index']);
    Route::post('/matches/{match}/events', [MatchEventController::class, 'store']);
    Route::delete('/matches/{match}/events/{event}', [MatchEventController::class, 'destroy']);

    Route::get('/tournaments/{tournament}/top-scorers', [TopScorerController::class, 'index']);

});

Route::prefix('public')->middleware('throttle:60,1')->group(function () {
    Route::get('/tournaments', [TournamentPublicController::class, 'index']);
    Route::get('/tournaments/{tournament:slug}', [TournamentPublicController::class, 'show']);
    Route::get('/tournaments/{tournament:slug}/matches', [TournamentPublicController::class, 'matches']);
    Route::get('/tournaments/{tournament:slug}/standings', [TournamentPublicController::class, 'standings']);
    Route::get('/tournaments/{tournament:slug}/bracket', [TournamentPublicController::class, 'bracket']);
    Route::get('/tournaments/{tournament:slug}/top-scorers', [TopScorerController::class, 'index']);
});

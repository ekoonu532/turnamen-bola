<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('matches', function (Blueprint $table) {
            $table->unsignedInteger('home_penalty')->nullable()->after('away_score');
            $table->unsignedInteger('away_penalty')->nullable()->after('home_penalty');
        });
    }

    public function down(): void
    {
        Schema::table('matches', function (Blueprint $table) {
            $table->dropColumn(['home_penalty', 'away_penalty']);
        });
    }
};
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('players', function (Blueprint $table) {
            $table->foreignId('team_id')->after('id')->constrained()->cascadeOnDelete();
            $table->string('name')->after('team_id');
            $table->unsignedInteger('jersey_number')->nullable()->after('name');
            $table->string('position')->nullable()->after('jersey_number');

            $table->unique(['team_id', 'jersey_number']);
        });
    }

    public function down(): void
    {
        Schema::table('players', function (Blueprint $table) {
            $table->dropUnique(['team_id', 'jersey_number']);
            $table->dropForeign(['team_id']);
            $table->dropColumn(['team_id', 'name', 'jersey_number', 'position']);
        });
    }
};
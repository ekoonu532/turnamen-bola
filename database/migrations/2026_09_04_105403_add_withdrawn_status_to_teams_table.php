<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement("ALTER TABLE teams DROP CONSTRAINT IF EXISTS teams_status_check");
        DB::statement("ALTER TABLE teams ADD CONSTRAINT teams_status_check CHECK (status IN ('pending','verified','rejected','withdrawn'))");
    }

    public function down(): void
    {
        DB::statement("ALTER TABLE teams DROP CONSTRAINT IF EXISTS teams_status_check");
        DB::statement("ALTER TABLE teams ADD CONSTRAINT teams_status_check CHECK (status IN ('pending','verified','rejected'))");
    }
};

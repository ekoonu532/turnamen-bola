<?php
// PostgreSQL enum lewat string check constraint, cara paling gampang: ubah kolom jadi string biasa

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement("ALTER TABLE matches DROP CONSTRAINT IF EXISTS matches_status_check");
        DB::statement("ALTER TABLE matches ADD CONSTRAINT matches_status_check CHECK (status IN ('scheduled','live','finished','postponed','walkover'))");
    }

    public function down(): void
    {
        DB::statement("ALTER TABLE matches DROP CONSTRAINT IF EXISTS matches_status_check");
        DB::statement("ALTER TABLE matches ADD CONSTRAINT matches_status_check CHECK (status IN ('scheduled','live','finished'))");
    }
};

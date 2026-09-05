<?php
// app/Services/TournamentDrawService.php

namespace App\Services;

use App\Models\Team;
use App\Models\TournamentGroup;
use Carbon\Carbon;

class TournamentDrawService
{
    /**
     * Undi tim ke dalam grup secara acak merata.
     */
    public function drawGroups(array $teamIds, int $groupCount = 2): array
    {
        shuffle($teamIds);

        $groups = array_fill(0, $groupCount, []);
        foreach ($teamIds as $i => $teamId) {
            $groups[$i % $groupCount][] = $teamId;
        }

        return $groups;
    }

    /**
     * Generate pairing round robin untuk satu grup.
     * Return: array of rounds, tiap round array of [teamA, teamB]
     */
    public function roundRobinPairing(array $teams): array
    {
        $n = count($teams);

        // kalau ganjil, tambahkan dummy null (bye)
        if ($n % 2 !== 0) {
            $teams[] = null;
            $n++;
        }

        $rounds = [];
        $fixed = $teams[0];
        $rotating = array_slice($teams, 1);

        for ($r = 0; $r < $n - 1; $r++) {
            $roundTeams = array_merge([$fixed], $rotating);
            $pairs = [];

            for ($i = 0; $i < $n / 2; $i++) {
                $teamA = $roundTeams[$i];
                $teamB = $roundTeams[$n - 1 - $i];

                // skip bye (null vs tim)
                if ($teamA !== null && $teamB !== null) {
                    $pairs[] = [$teamA, $teamB];
                }
            }

            $rounds[] = $pairs;
            array_unshift($rotating, array_pop($rotating));
        }

        return $rounds;
    }

    /**
     * Gabungkan jadwal beberapa grup dengan pola selang-seling per ronde,
     * supaya adil (1 hari 1 pertandingan, tidak ada grup yang selesai duluan).
     *
     * @param array $groupSchedules ['group_id' => [round1 => [...], round2 => [...]]]
     * @return array sequence pertandingan terurut siap diberi tanggal
     */
    public function interleaveSchedules(array $groupSchedules): array
    {
        $maxRounds = max(array_map('count', $groupSchedules));
        $sequence = [];

        for ($r = 0; $r < $maxRounds; $r++) {
            foreach ($groupSchedules as $groupId => $rounds) {
                if (! isset($rounds[$r])) {
                    continue;
                }

                foreach ($rounds[$r] as $pair) {
                    $sequence[] = [
                        'group_id' => $groupId,
                        'home_team_id' => $pair[0],
                        'away_team_id' => $pair[1],
                    ];
                }
            }
        }

        return $sequence;
    }

    /**
     * Beri tanggal ke sequence pertandingan, 1 pertandingan per hari.
     */
    public function assignDates(array $sequence, Carbon $startDate, string $matchTime = '16:00'): array
    {
        [$hour, $minute] = explode(':', $matchTime);

        foreach ($sequence as $i => &$item) {
            $item['scheduled_at'] = $startDate->copy()
                ->addDays($i)
                ->setTime((int) $hour, (int) $minute);
        }

        return $sequence;
    }
}

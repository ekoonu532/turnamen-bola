<!-- resources/js/pages/MatchShow.vue -->
<template>
    <div v-if="match">
        <TopBar show-logout :user-name="auth.user?.name" @logout="handleLogout" />

        <main class="max-w-lg mx-auto px-4 sm:px-6 py-6 sm:py-10">
            <button @click="$router.back()" class="text-sm text-pitch-400 hover:text-gold-400 transition">
                &larr; Kembali
            </button>

            <p class="text-xs text-pitch-400 mt-3 mb-1">
                {{ match.group?.name ?? stageLabels[match.stage] }}
                <span v-if="match.scheduled_at"> · {{ formatDate(match.scheduled_at) }}</span>
            </p>

            <StatusBadge :status="matchStatus" class="mb-6" />

            <!-- ── Papan Skor ── -->
            <div class="border border-dashed border-pitch-600 rounded-lg p-5 sm:p-6">
                <div class="flex items-center justify-between gap-4 mb-6">
                    <div class="flex-1 text-center">
                        <p class="font-display font-semibold text-sm sm:text-base mb-3">{{ match.home_team?.name ?? 'TBD' }}</p>
                        <input
                            v-model.number="homeScore"
                            type="number"
                            min="0"
                            class="w-16 sm:w-20 mx-auto text-center font-display font-bold text-2xl sm:text-3xl bg-pitch-800 border border-pitch-600 rounded-md py-2 focus:outline-none focus:ring-2 focus:ring-gold-400"
                        />
                    </div>
                    <span class="font-display text-pitch-400 pt-8">–</span>
                    <div class="flex-1 text-center">
                        <p class="font-display font-semibold text-sm sm:text-base mb-3">{{ match.away_team?.name ?? 'TBD' }}</p>
                        <input
                            v-model.number="awayScore"
                            type="number"
                            min="0"
                            class="w-16 sm:w-20 mx-auto text-center font-display font-bold text-2xl sm:text-3xl bg-pitch-800 border border-pitch-600 rounded-md py-2 focus:outline-none focus:ring-2 focus:ring-gold-400"
                        />
                    </div>
                </div>

                <!-- ── Adu Penalti (muncul otomatis kalau knockout & skor imbang) ── -->
                <div v-if="showPenaltySection" class="border-t border-pitch-600 pt-5 mb-5">
                    <p class="text-sm text-pitch-400 mb-3 text-center">Skor imbang — lanjut adu penalti</p>
                    <div class="flex items-center justify-between gap-4">
                        <div class="flex-1 text-center">
                            <input
                                v-model.number="homePenalty"
                                type="number"
                                min="0"
                                placeholder="0"
                                class="w-14 sm:w-16 mx-auto text-center font-display font-semibold text-lg bg-pitch-800 border border-gold-400/40 rounded-md py-1.5 focus:outline-none focus:ring-2 focus:ring-gold-400"
                            />
                        </div>
                        <span class="text-xs text-pitch-400">penalti</span>
                        <div class="flex-1 text-center">
                            <input
                                v-model.number="awayPenalty"
                                type="number"
                                min="0"
                                placeholder="0"
                                class="w-14 sm:w-16 mx-auto text-center font-display font-semibold text-lg bg-pitch-800 border border-gold-400/40 rounded-md py-1.5 focus:outline-none focus:ring-2 focus:ring-gold-400"
                            />
                        </div>
                    </div>
                </div>

                <p v-if="error" class="text-sm text-clay-500 mb-4">{{ error }}</p>
                <p v-if="message" class="text-sm text-lime-400 mb-4">{{ message }}</p>

                <button
                    @click="handleSaveScore"
                    :disabled="saving"
                    class="w-full bg-gold-400 text-pitch-950 font-semibold py-2.5 rounded-md hover:bg-gold-500 transition disabled:opacity-60"
                >
                    {{ saving ? 'Menyimpan...' : 'Simpan Skor' }}
                </button>
            </div>

                        <!-- ── Ubah Jadwal ── -->
            <div class="mt-6 border border-pitch-600 rounded-lg p-4 sm:p-5">
                <p class="text-sm text-pitch-400 mb-3">Jadwal Pertandingan</p>

                <div class="flex flex-col sm:flex-row gap-2 mb-3">
                    <input
                        v-model="scheduleDate"
                        type="date"
                        class="flex-1 bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
                    />
                    <input
                        v-model="scheduleTime"
                        type="time"
                        class="w-full sm:w-32 bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
                    />
                </div>

                <input
                    v-model="venue"
                    type="text"
                    placeholder="Venue (opsional)"
                    class="w-full bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2 text-sm mb-3 focus:outline-none focus:ring-2 focus:ring-gold-400"
                />

                <p v-if="scheduleError" class="text-xs text-clay-500 mb-3">{{ scheduleError }}</p>
                <p v-if="scheduleMessage" class="text-xs text-lime-400 mb-3">{{ scheduleMessage }}</p>

                <button
                    @click="handleReschedule"
                    :disabled="reschedulingSaving"
                    class="w-full sm:w-auto bg-gold-400 text-pitch-950 font-semibold px-4 py-2 rounded-md hover:bg-gold-500 transition disabled:opacity-60"
                >
                    {{ reschedulingSaving ? 'Menyimpan...' : 'Simpan Jadwal' }}
                </button>
            </div>

            <!-- ── Pencetak Gol ── -->
            <div v-if="match.status === 'finished'" class="mt-6 border border-pitch-600 rounded-lg p-4 sm:p-5">
                <p class="text-sm text-pitch-400 mb-3">Pencetak Gol</p>

                <form @submit.prevent="handleAddEvent" class="space-y-2 mb-4">
                    <div class="flex flex-col sm:flex-row gap-2">
                        <select
                            v-model="eventForm.team_id"
                            @change="loadPlayersForTeam"
                            required
                            class="flex-1 bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
                        >
                            <option value="" disabled>Pilih tim</option>
                            <option :value="match.home_team_id">{{ match.home_team?.name }}</option>
                            <option :value="match.away_team_id">{{ match.away_team?.name }}</option>
                        </select>

                        <select
                            v-model="eventForm.player_id"
                            :disabled="!eventForm.team_id"
                            required
                            class="flex-1 bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-gold-400 disabled:opacity-50"
                        >
                            <option value="" disabled>Pilih pemain</option>
                            <option v-for="p in eventTeamPlayers" :key="p.id" :value="p.id">{{ p.name }}</option>
                            <option value="__new__">+ Pemain baru...</option>
                        </select>

                        <input
                            v-model.number="eventForm.minute"
                            type="number"
                            placeholder="Menit"
                            min="0"
                            max="120"
                            class="w-full sm:w-20 bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
                        />
                    </div>

                    <!-- Muncul kalau pilih "+ Pemain baru..." -->
                    <div v-if="eventForm.player_id === '__new__'" class="flex gap-2">
                        <input
                            v-model="newPlayerName"
                            type="text"
                            placeholder="Nama pemain baru"
                            required
                            class="flex-1 bg-pitch-800 border border-gold-400/40 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
                        />
                    </div>

                    <p v-if="eventError" class="text-xs text-clay-500">{{ eventError }}</p>

                    <button type="submit" class="w-full sm:w-auto bg-gold-400 text-pitch-950 font-semibold px-4 py-2 rounded-md hover:bg-gold-500 transition">
                        + Catat Gol
                    </button>
                </form>

                <ul v-if="events.length" class="space-y-2 text-sm">
                    <li v-for="e in events" :key="e.id" class="flex items-center justify-between">
                        <span>
                            ⚽ {{ e.player?.name }}
                            <span class="text-pitch-400">({{ e.team?.name }})</span>
                            <span v-if="e.minute" class="text-pitch-400"> — {{ e.minute }}'</span>
                        </span>
                        <button @click="handleDeleteEvent(e)" class="text-xs text-pitch-400 hover:text-clay-500 transition">
                            Hapus
                        </button>
                    </li>
                </ul>
                <p v-else class="text-sm text-pitch-400">Belum ada gol tercatat.</p>
            </div>

            <!-- ── Walkover ── -->
            <div v-if="match.home_team_id && match.away_team_id" class="mt-6 border border-pitch-600 rounded-lg p-4 sm:p-5">
                <p class="text-sm text-pitch-400 mb-3">Walkover (tim tidak hadir)</p>
                <div class="flex flex-col sm:flex-row gap-2">
                    <button
                        @click="handleWalkover(match.home_team_id)"
                        class="flex-1 border border-pitch-600 text-sm px-3 py-2 rounded-md hover:border-clay-500/50 hover:text-clay-500 transition"
                    >
                        {{ match.away_team?.name }} menang WO
                    </button>
                    <button
                        @click="handleWalkover(match.away_team_id)"
                        class="flex-1 border border-pitch-600 text-sm px-3 py-2 rounded-md hover:border-clay-500/50 hover:text-clay-500 transition"
                    >
                        {{ match.home_team?.name }} menang WO
                    </button>
                </div>
            </div>
        </main>
        <Footer />
    </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import api from '../lib/api';
import TopBar from '../components/TopBar.vue';
import StatusBadge from '../components/StatusBadge.vue';
import Footer from '../components/Footer.vue';

const route = useRoute();
const router = useRouter();
const auth = useAuthStore();
const matchId = route.params.matchId;

const match = ref(null);
const homeScore = ref(0);
const awayScore = ref(0);
const homePenalty = ref(null);
const awayPenalty = ref(null);
const error = ref('');
const message = ref('');
const saving = ref(false);

// ── State untuk ubah jadwal ──
const scheduleDate = ref('');
const scheduleTime = ref('');
const venue = ref('');
const scheduleError = ref('');
const scheduleMessage = ref('');
const reschedulingSaving = ref(false);

// ── State untuk pencatatan gol ──
const events = ref([]);
const eventForm = reactive({ team_id: '', player_id: '', minute: null });
const eventTeamPlayers = ref([]);
const newPlayerName = ref('');
const eventError = ref('');

const stageLabels = {
    group: 'Fase Grup',
    semifinal: 'Semifinal',
    final: 'Final',
    third_place: 'Perebutan Juara 3',
};

const statusMap = {
    scheduled: 'scheduled',
    live: 'ongoing',
    finished: 'finished',
    walkover: 'finished',
    postponed: 'draft',
};

const matchStatus = computed(() => statusMap[match.value?.status] ?? match.value?.status);

const isKnockout = computed(() => match.value && match.value.stage !== 'group');
const showPenaltySection = computed(
    () => isKnockout.value && homeScore.value === awayScore.value
);

function formatDate(d) {
    return new Date(d).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
}

async function fetchMatch() {
    const { data } = await api.get(`/matches/${matchId}`);
    match.value = data;
    homeScore.value = data.home_score ?? 0;
    awayScore.value = data.away_score ?? 0;
    homePenalty.value = data.home_penalty;
    awayPenalty.value = data.away_penalty;

    if (data.scheduled_at) {
        const dt = new Date(data.scheduled_at);
        scheduleDate.value = dt.toISOString().slice(0, 10);
        scheduleTime.value = dt.toTimeString().slice(0, 5);
    }
    venue.value = data.venue ?? '';
}

async function handleReschedule() {
    if (!scheduleDate.value || !scheduleTime.value) {
        scheduleError.value = 'Tanggal dan jam wajib diisi.';
        return;
    }

    scheduleError.value = '';
    scheduleMessage.value = '';
    reschedulingSaving.value = true;

    try {
        await api.patch(`/matches/${matchId}/reschedule`, {
            scheduled_at: `${scheduleDate.value} ${scheduleTime.value}:00`,
            venue: venue.value || null,
        });
        scheduleMessage.value = 'Jadwal berhasil diperbarui.';
        await fetchMatch();
    } catch (e) {
        scheduleError.value = e.response?.data?.message || 'Gagal mengubah jadwal.';
    } finally {
        reschedulingSaving.value = false;
    }
}

async function fetchEvents() {
    const { data } = await api.get(`/matches/${matchId}/events`);
    events.value = data;
}

async function loadPlayersForTeam() {
    eventForm.player_id = '';
    newPlayerName.value = '';
    const { data } = await api.get(`/teams/${eventForm.team_id}/players`);
    eventTeamPlayers.value = data;
}

async function handleAddEvent() {
    eventError.value = '';
    try {
        let playerId = eventForm.player_id;

        // Kalau pilih "pemain baru", buat dulu pemainnya sebelum catat gol
        if (playerId === '__new__') {
            const { data: newPlayer } = await api.post(`/teams/${eventForm.team_id}/players`, {
                name: newPlayerName.value,
            });
            playerId = newPlayer.id;
            eventTeamPlayers.value.push(newPlayer);
        }

        await api.post(`/matches/${matchId}/events`, {
            team_id: eventForm.team_id,
            player_id: playerId,
            type: 'goal',
            minute: eventForm.minute,
        });

        eventForm.player_id = '';
        eventForm.minute = null;
        newPlayerName.value = '';
        await fetchEvents();
    } catch (e) {
        eventError.value = e.response?.data?.message || 'Gagal mencatat gol.';
    }
}

async function handleDeleteEvent(event) {
    if (!confirm('Hapus catatan gol ini?')) return;
    await api.delete(`/matches/${matchId}/events/${event.id}`);
    await fetchEvents();
}

async function handleSaveScore() {
    const confirmed = confirm(
        `Simpan skor ${match.value.home_team?.name ?? 'TBD'} ${homeScore.value} - ${awayScore.value} ${match.value.away_team?.name ?? 'TBD'}?`
    );
    if (!confirmed) return;

    error.value = '';
    saving.value = true;
    try {
        const payload = {
            home_score: homeScore.value,
            away_score: awayScore.value,
        };

        if (showPenaltySection.value) {
            payload.home_penalty = homePenalty.value;
            payload.away_penalty = awayPenalty.value;
        }

        await api.patch(`/matches/${matchId}/score`, payload);
        await fetchMatch();
        message.value = 'Skor berhasil disimpan.';
    } catch (e) {
        error.value = e.response?.data?.message || 'Gagal menyimpan skor.';
    } finally {
        saving.value = false;
    }
}

async function handleWalkover(winnerTeamId) {
    if (!confirm('Catat sebagai walkover?')) return;
    error.value = '';
    try {
        await api.patch(`/matches/${matchId}/walkover`, { winner_team_id: winnerTeamId });
        message.value = 'Walkover berhasil dicatat.';
        await fetchMatch();
    } catch (e) {
        error.value = e.response?.data?.message || 'Gagal mencatat walkover.';
    }
}

async function handleLogout() {
    await auth.logout();
    router.push({ name: 'login' });
}

onMounted(async () => {
    await fetchMatch();
    await fetchEvents();
});
</script>

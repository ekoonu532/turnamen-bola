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
import { ref, computed, onMounted } from 'vue';
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

        if (match.value.stage === 'group') {
            router.push({ name: 'standings.index', params: { id: match.value.tournament_id } });
        } else {
            router.push({ name: 'bracket.show', params: { id: match.value.tournament_id } });
        }
    } catch (e) {
        error.value = e.response?.data?.message || 'Gagal menyimpan skor.';
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

onMounted(fetchMatch);
</script>

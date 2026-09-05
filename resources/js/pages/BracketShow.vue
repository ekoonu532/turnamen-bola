<!-- resources/js/pages/BracketShow.vue -->
<template>
    <div>
        <TopBar show-logout :user-name="auth.user?.name" @logout="handleLogout" class="no-print" />

        <main class="max-w-2xl mx-auto px-4 sm:px-6 py-6 sm:py-10">
            <router-link :to="{ name: 'tournaments.show', params: { id: tournamentId } }" class="no-print text-sm text-pitch-400 hover:text-gold-400 transition">
                &larr; Kembali ke turnamen
            </router-link>

            <PrintHeader v-if="tournament" :tournament-name="tournament.name" title="Bracket Knockout" />

            <div class="flex items-center justify-between mt-3 mb-6 sm:mb-8 no-print">
                <h1 class="font-display font-bold text-xl sm:text-2xl">Bracket Knockout</h1>
                <button
                    v-if="semifinals.length"
                    @click="handlePrint"
                    class="text-sm border border-pitch-600 px-3 py-1.5 rounded-md hover:border-gold-400/50 hover:bg-pitch-800/40 transition"
                >
                    Cetak
                </button>
            </div>

            <p v-if="error" class="text-sm text-clay-500 mb-4 no-print">{{ error }}</p>
            <p v-if="message" class="text-sm text-lime-400 mb-4 no-print">{{ message }}</p>

            <div v-if="loading" class="text-pitch-400 text-sm no-print">Memuat...</div>

            <div v-else>
                <!-- ── Belum ada jadwal knockout sama sekali ── -->
                <div v-if="semifinals.length === 0" class="no-print border border-dashed border-pitch-600 rounded-lg p-5 text-center text-sm text-pitch-400">
                    Generate jadwal fase grup terlebih dahulu — jadwal semifinal & final akan otomatis dibuat sebagai perkiraan.
                </div>

                <template v-else>
                    <div class="flex items-center justify-between mb-4 no-print">
                        <p class="text-sm text-pitch-400">
                            {{ semifinalsGenerated ? 'Semifinal terisi' : 'Menunggu hasil fase grup' }}
                        </p>
                        <button
                            v-if="!semifinalsGenerated"
                            @click="handleGenerateSemifinals"
                            class="text-sm bg-gold-400 text-pitch-950 font-semibold px-3 py-1.5 rounded-md hover:bg-gold-500 transition"
                        >
                            Isi Semifinal
                        </button>
                        <button
                            v-else-if="!finalGenerated"
                            @click="handleGenerateFinal"
                            :disabled="!bothSemifinalsFinished"
                            class="text-sm bg-gold-400 text-pitch-950 font-semibold px-3 py-1.5 rounded-md hover:bg-gold-500 transition disabled:opacity-40 disabled:cursor-not-allowed"
                        >
                            Isi Final
                        </button>
                    </div>

                    <BracketTree :semifinals="semifinals" :final="final" :third-place="thirdPlace" />

                    <p v-if="semifinalsGenerated && !finalGenerated && !bothSemifinalsFinished" class="text-xs text-pitch-400 mt-3 no-print">
                        Selesaikan kedua semifinal untuk mengisi final.
                    </p>

                    <!-- ── Juara ── -->
                    <div v-if="champion" class="mt-8 border border-dashed border-gold-400/50 rounded-lg p-6 text-center bg-pitch-900/50 print:border-gray-400">
                        <p class="text-xs text-pitch-400 mb-2 uppercase tracking-wide">Juara Turnamen</p>
                        <p class="font-display font-bold text-2xl text-gold-400 print:text-black">{{ champion.name }}</p>
                    </div>
                </template>
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
import PrintHeader from '../components/PrintHeader.vue';
import BracketTree from '../components/BracketTree.vue';
import Footer from '../components/Footer.vue';

const route = useRoute();
const router = useRouter();
const auth = useAuthStore();
const tournamentId = route.params.id;

const tournament = ref(null);
const matches = ref([]);
const loading = ref(true);
const error = ref('');
const message = ref('');

const semifinals = computed(() => matches.value.filter((m) => m.stage === 'semifinal'));
const final = computed(() => matches.value.find((m) => m.stage === 'final') ?? null);
const thirdPlace = computed(() => matches.value.find((m) => m.stage === 'third_place') ?? null);

const semifinalsGenerated = computed(
    () => semifinals.value.length === 2 && semifinals.value.every((m) => m.home_team_id !== null)
);
const finalGenerated = computed(() => final.value && final.value.home_team_id !== null);

const bothSemifinalsFinished = computed(() =>
    semifinalsGenerated.value && semifinals.value.every((m) => m.status === 'finished' || m.status === 'walkover')
);

const champion = computed(() => {
    if (!final.value || !final.value.winner_team_id) return null;
    return final.value.winner_team_id === final.value.home_team_id ? final.value.home_team : final.value.away_team;
});

async function fetchData() {
    loading.value = true;
    const [{ data: t }, { data: m }] = await Promise.all([
        api.get(`/tournaments/${tournamentId}`),
        api.get(`/tournaments/${tournamentId}/matches`),
    ]);
    tournament.value = t;
    matches.value = m.filter((x) => ['semifinal', 'final', 'third_place'].includes(x.stage));
    loading.value = false;
}

function handlePrint() {
    window.print();
}

async function handleGenerateSemifinals() {
    error.value = '';
    message.value = '';
    try {
        await api.post(`/tournaments/${tournamentId}/generate-semifinals`);
        message.value = 'Semifinal berhasil diisi.';
        await fetchData();
    } catch (e) {
        error.value = e.response?.data?.message || 'Gagal mengisi semifinal.';
    }
}

async function handleGenerateFinal() {
    error.value = '';
    message.value = '';
    try {
        await api.post(`/tournaments/${tournamentId}/generate-final`);
        message.value = 'Final berhasil diisi.';
        await fetchData();
    } catch (e) {
        error.value = e.response?.data?.message || 'Gagal mengisi final.';
    }
}

async function handleLogout() {
    await auth.logout();
    router.push({ name: 'login' });
}

onMounted(fetchData);
</script>

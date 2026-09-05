<!-- resources/js/pages/MatchesIndex.vue -->
<template>
    <div>
        <TopBar show-logout :user-name="auth.user?.name" @logout="handleLogout" class="no-print" />

        <main class="max-w-3xl mx-auto px-4 sm:px-6 py-6 sm:py-10">
            <router-link :to="{ name: 'tournaments.show', params: { id: tournamentId } }" class="no-print text-sm text-pitch-400 hover:text-gold-400 transition">
                &larr; Kembali ke turnamen
            </router-link>

            <PrintHeader v-if="tournament" :tournament-name="tournament.name" title="Jadwal Pertandingan" />

            <div class="flex items-center justify-between mt-3 mb-6 sm:mb-8 no-print">
                <h1 class="font-display font-bold text-xl sm:text-2xl">Jadwal Pertandingan</h1>
                <button
                    v-if="matches.length"
                    @click="handlePrint"
                    class="text-sm border border-pitch-600 px-3 py-1.5 rounded-md hover:border-gold-400/50 hover:bg-pitch-800/40 transition"
                >
                    Cetak
                </button>
            </div>

            <p v-if="error" class="text-sm text-clay-500 mb-4 no-print">{{ error }}</p>
            <p v-if="message" class="text-sm text-lime-400 mb-4 no-print">{{ message }}</p>

            <!-- ── Belum ada jadwal ── -->
            <div v-if="!loading && matches.length === 0" class="no-print border border-dashed border-pitch-600 rounded-lg p-5 sm:p-6 space-y-4">
                <p class="text-sm text-pitch-400">
                    Jadwal fase grup dibuat otomatis (1 pertandingan/hari), diikuti perkiraan jadwal semifinal & final dengan jeda hari libur.
                </p>
                <div class="grid sm:grid-cols-3 gap-3">
                    <div>
                        <label class="block text-sm text-pitch-400 mb-1.5">Tanggal mulai</label>
                        <input
                            v-model="startDate"
                            type="date"
                            class="w-full bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2.5 text-base sm:text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
                        />
                    </div>
                    <div>
                        <label class="block text-sm text-pitch-400 mb-1.5">Libur sebelum semifinal (hari)</label>
                        <input
                            v-model.number="restAfterGroup"
                            type="number"
                            min="0"
                            class="w-full bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2.5 text-base sm:text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
                        />
                    </div>
                    <div>
                        <label class="block text-sm text-pitch-400 mb-1.5">Libur sebelum final (hari)</label>
                        <input
                            v-model.number="restAfterSemifinal"
                            type="number"
                            min="0"
                            class="w-full bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2.5 text-base sm:text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
                        />
                    </div>
                </div>
                <button
                    @click="handleGenerate"
                    class="w-full sm:w-auto bg-gold-400 text-pitch-950 font-semibold px-4 py-2.5 rounded-md hover:bg-gold-500 transition"
                >
                    Generate Jadwal
                </button>
            </div>

            <!-- ── Sudah ada jadwal ── -->
            <div v-else-if="!loading" class="space-y-6">
                <div v-for="(group, stage) in matchesByStage" :key="stage">
                    <h2 class="font-display font-semibold text-sm text-pitch-400 mb-3 uppercase tracking-wide">
                        {{ stageLabels[stage] ?? stage }}
                    </h2>
                    <div class="space-y-3">
                        <MatchCard v-for="match in group" :key="match.id" :match="match" />
                    </div>
                </div>

                <div class="pt-4 border-t border-pitch-600 no-print">
                    <button @click="handleRegenerate" class="text-sm text-pitch-400 hover:text-clay-500 transition">
                        Generate ulang jadwal (fase grup & knockout)
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
import MatchCard from '../components/MatchCard.vue';
import PrintHeader from '../components/PrintHeader.vue';

const route = useRoute();
const router = useRouter();
const auth = useAuthStore();
const tournamentId = route.params.id;

const tournament = ref(null);
const matches = ref([]);
const loading = ref(true);
const error = ref('');
const message = ref('');
const startDate = ref('');
const restAfterGroup = ref(1);
const restAfterSemifinal = ref(1);

const stageLabels = {
    group: 'Fase Grup',
    semifinal: 'Semifinal',
    final: 'Final',
    third_place: 'Perebutan Juara 3',
};

const stageOrder = ['group', 'semifinal', 'third_place', 'final'];

const matchesByStage = computed(() => {
    const sorted = [...matches.value].sort((a, b) => new Date(a.scheduled_at) - new Date(b.scheduled_at));
    const grouped = sorted.reduce((acc, m) => {
        (acc[m.stage] ??= []).push(m);
        return acc;
    }, {});
    return Object.fromEntries(
        stageOrder.filter((stage) => grouped[stage]?.length).map((stage) => [stage, grouped[stage]])
    );
});

async function fetchData() {
    loading.value = true;
    const [{ data: t }, { data: m }] = await Promise.all([
        api.get(`/tournaments/${tournamentId}`),
        api.get(`/tournaments/${tournamentId}/matches`),
    ]);
    tournament.value = t;
    matches.value = m;

    // isi default startDate dari tanggal mulai turnamen, fallback ke hari ini kalau kosong
    if (!startDate.value) {
        startDate.value = t.start_date
            ? new Date(t.start_date).toISOString().slice(0, 10)
            : new Date().toISOString().slice(0, 10);
    }

    loading.value = false;
}

async function handleGenerate() {
    error.value = '';
    message.value = '';
    try {
        await api.post(`/tournaments/${tournamentId}/generate-schedule`, {
            start_date: startDate.value,
            rest_days_after_group: restAfterGroup.value,
            rest_days_after_semifinal: restAfterSemifinal.value,
        });
        message.value = 'Jadwal berhasil dibuat.';
        await fetchData();
    } catch (e) {
        error.value = e.response?.data?.message || 'Gagal membuat jadwal. Pastikan grup sudah dibagi.';
    }
}

function handlePrint() {
    window.print();
}

async function handleRegenerate() {
    if (!confirm('Generate ulang jadwal? Semua skor fase grup dan knockout yang sudah diinput akan hilang.')) return;
    await handleGenerate();
}

async function handleLogout() {
    await auth.logout();
    router.push({ name: 'login' });
}

onMounted(fetchData);
</script>

<!-- resources/js/pages/public/TournamentsList.vue -->
<template>
    <div>
        <PublicTopBar />

        <div v-if="loading" class="max-w-3xl mx-auto px-4 sm:px-6 py-10 text-pitch-400 text-sm">Memuat...</div>

        <template v-else>
            <!-- ── Hero ── -->
            <section v-if="featured" class="relative border-b border-pitch-600 overflow-hidden">
                <!-- Motif lapangan: lingkaran tengah + garis tengah, dekoratif -->
                <div class="absolute inset-0 pointer-events-none">
                    <svg class="absolute -right-20 -top-20 w-[380px] h-[380px] opacity-[0.12]" viewBox="0 0 400 400" fill="none">
                        <circle cx="200" cy="200" r="120" stroke="#8FA396" stroke-width="1.5" />
                        <circle cx="200" cy="200" r="3" fill="#8FA396" />
                    </svg>
                    <div class="absolute left-0 right-0 top-[45%] h-px bg-pitch-600/40"></div>
                </div>

                <div class="relative max-w-3xl mx-auto px-4 sm:px-6 py-12 sm:py-20">
                    <div class="animate-hero-in">
                        <div class="inline-flex items-center gap-2 mb-4">
                            <span class="w-1.5 h-1.5 rounded-full" :class="featured.status === 'ongoing' ? 'bg-lime-400 animate-pulse' : 'bg-gold-400'"></span>
                            <span class="text-xs tracking-wide text-pitch-400">Turnamen Utama</span>
                        </div>
                        <div class="flex flex-wrap items-center gap-3 mb-3">
                            <h1 class="font-display font-bold text-3xl sm:text-5xl leading-tight">{{ featured.name }}</h1>
                        </div>

                        <p v-if="featured.description" class="text-pitch-400 mb-8 max-w-lg">{{ featured.description }}</p>

                        <!-- ── Statistik dengan ikon (BARU) ── -->
                        <div class="grid grid-cols-3 gap-4 sm:gap-6 mb-6 max-w-md">
                            <div>
                                <div class="flex items-center gap-1.5 mb-1">
                                    <svg class="w-4 h-4 text-pitch-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a4 4 0 00-3-3.87M9 20H4v-2a4 4 0 013-3.87m6-1.13a4 4 0 100-8 4 4 0 000 8zm6 3c0-1.1-.9-2-2-2M7 11c-1.1 0-2 .9-2 2" />
                                    </svg>
                                    <span class="text-xs text-pitch-400">Tim</span>
                                </div>
                                <p class="font-display font-bold text-2xl sm:text-3xl font-tabular">{{ featuredStats.teamCount }}</p>
                            </div>
                            <div>
                                <div class="flex items-center gap-1.5 mb-1">
                                    <svg class="w-4 h-4 text-pitch-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
                                    </svg>
                                    <span class="text-xs text-pitch-400">Pertandingan</span>
                                </div>
                                <p class="font-display font-bold text-2xl sm:text-3xl font-tabular">{{ featuredStats.finished }}/{{ featuredStats.total }}</p>
                            </div>
                            <div>
                                <div class="flex items-center gap-1.5 mb-1">
                                    <svg class="w-4 h-4 text-gold-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                    </svg>
                                    <span class="text-xs text-pitch-400">Juara</span>
                                </div>
                                <p class="font-display font-bold text-lg sm:text-xl text-gold-400 truncate">{{ featuredStats.champion ?? 'Belum ada' }}</p>
                            </div>
                        </div>

                        <!-- ── Progress bar turnamen (BARU) ── -->
                        <div v-if="featuredStats.total > 0" class="mb-8 max-w-md">
                            <div class="flex justify-between text-xs text-pitch-400 mb-1.5">
                                <span>Progres Turnamen</span>
                                <span>{{ progressPercent }}%</span>
                            </div>
                            <div class="h-1.5 bg-pitch-800 rounded-full overflow-hidden">
                                <div
                                    class="h-full bg-gold-400 rounded-full transition-all duration-700"
                                    :style="{ width: progressPercent + '%' }"
                                ></div>
                            </div>
                        </div>

                        <div class="flex flex-wrap gap-3">
                            <router-link
                                :to="{ name: 'public.matches', params: { slug: featured.slug } }"
                                class="bg-gold-400 text-pitch-950 font-semibold px-5 py-2.5 rounded-md hover:bg-gold-500 transition text-sm"
                            >
                                Lihat Jadwal
                            </router-link>
                            <router-link
                                :to="{ name: 'public.standings', params: { slug: featured.slug } }"
                                class="border border-pitch-600 px-5 py-2.5 rounded-md hover:border-gold-400/50 hover:bg-pitch-800/40 transition text-sm"
                            >
                                Klasemen
                            </router-link>
                            <router-link
                                :to="{ name: 'public.bracket', params: { slug: featured.slug } }"
                                class="border border-pitch-600 px-5 py-2.5 rounded-md hover:border-gold-400/50 hover:bg-pitch-800/40 transition text-sm"
                            >
                                Bracket
                            </router-link>
                            <router-link
                                :to="{ name: 'public.topscorers', params: { slug: featured.slug } }"
                                class="border border-pitch-600 px-5 py-2.5 rounded-md hover:border-gold-400/50 hover:bg-pitch-800/40 transition text-sm"
                            >
                                Top Scorer
                            </router-link>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ── Pertandingan Berikutnya (BARU) ── -->
            <section v-if="nextMatch" class="border-b border-pitch-600 bg-pitch-900/30">
                <div class="max-w-3xl mx-auto px-4 sm:px-6 py-4 flex items-center justify-between gap-3">
                    <div class="min-w-0">
                        <p class="text-xs text-pitch-400 mb-0.5">Pertandingan berikutnya</p>
                        <p class="text-sm font-medium truncate">
                            {{ nextMatch.home_team?.name ?? 'TBD' }} vs {{ nextMatch.away_team?.name ?? 'TBD' }}
                        </p>
                    </div>
                    <div class="text-right shrink-0">
                        <p class="font-display font-bold text-gold-400 text-sm sm:text-base">{{ nextMatchDate }}</p>
                    </div>
                </div>
            </section>

            <!-- ── Tiket Pertandingan ── -->
            <section v-if="featured && tickerMatches.length" class="border-b border-pitch-600">
                <div class="max-w-3xl mx-auto px-4 sm:px-6 py-6 sm:py-8">
                    <h2 class="font-display font-semibold text-sm text-pitch-400 mb-4 uppercase tracking-wide">
                        Hasil &amp; Jadwal Terdekat
                    </h2>
                    <div class="flex gap-3 overflow-x-auto scrollbar-thin pb-2 -mx-4 px-4 sm:mx-0 sm:px-0">
                        <TickerCard v-for="m in tickerMatches" :key="m.id" :match="m" />
                    </div>
                </div>
            </section>

            <!-- ── Cuplikan Klasemen ── -->
            <section v-if="featured && standingsPreview.length" class="border-b border-pitch-600">
                <div class="max-w-3xl mx-auto px-4 sm:px-6 py-6 sm:py-8">
                    <div class="flex items-center justify-between mb-4">
                        <h2 class="font-display font-semibold text-sm text-pitch-400 uppercase tracking-wide">Klasemen Sementara</h2>
                        <router-link :to="{ name: 'public.standings', params: { slug: featured.slug } }" class="text-xs text-gold-400 hover:underline">
                            Lihat semua
                        </router-link>
                    </div>

                    <div class="grid sm:grid-cols-2 gap-4">
                        <div v-for="entry in standingsPreview" :key="entry.group.id" class="border border-pitch-600 rounded-lg p-4">
                            <p class="text-xs text-pitch-400 mb-3">{{ entry.group.name }}</p>
                            <ol class="space-y-2 text-sm">
                                <li
                                    v-for="(s, i) in entry.standings.slice(0, 3)"
                                    :key="s.team.id"
                                    class="flex items-center justify-between"
                                    :class="{ 'text-gold-400': i < 2 }"
                                >
                                    <span class="truncate">
                                        <span class="text-pitch-400 font-tabular mr-2">{{ i + 1 }}</span>
                                        {{ s.team.name }}
                                    </span>
                                    <span class="font-tabular font-semibold shrink-0 ml-2">{{ s.points }} pts</span>
                                </li>
                            </ol>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ── Turnamen Lainnya ── -->
            <main class="max-w-3xl mx-auto px-4 sm:px-6 py-8 sm:py-10">
                <h2 class="font-display font-semibold text-sm text-pitch-400 mb-4 uppercase tracking-wide">
                    {{ featured ? 'Turnamen Lainnya' : 'Semua Turnamen' }}
                </h2>

                <div v-if="others.length === 0 && !featured" class="border border-dashed border-pitch-600 rounded-lg p-8 sm:p-10 text-center">
                    <p class="text-pitch-100 font-medium mb-1">Belum ada turnamen dipublikasikan</p>
                    <p class="text-sm text-pitch-400">Cek kembali nanti.</p>
                </div>

                <p v-else-if="others.length === 0" class="text-sm text-pitch-400">Belum ada turnamen lain.</p>

                <ul v-else class="divide-y divide-pitch-600 border-t border-b border-pitch-600">
                    <li v-for="t in others" :key="t.id">
                        <router-link
                            :to="{ name: 'public.tournament', params: { slug: t.slug } }"
                            class="flex items-center justify-between gap-3 py-4 px-2 -mx-2 rounded-md hover:bg-pitch-800/60 transition"
                        >
                            <div class="min-w-0">
                                <p class="font-medium truncate">{{ t.name }}</p>
                                <p class="text-xs text-pitch-400 mt-0.5" v-if="t.start_date">
                                    {{ formatDate(t.start_date) }} — {{ formatDate(t.end_date) }}
                                </p>
                            </div>
                            <StatusBadge :status="t.status" class="shrink-0" />
                        </router-link>
                    </li>
                </ul>
            </main>

            <footer class="border-t border-pitch-600 no-print">
                <div class="max-w-3xl mx-auto px-4 sm:px-6 py-6 text-center">
                    <p class="text-xs text-pitch-400">
                        Made with <span class="text-clay-500">❤️</span> by
                        <span class="text-pitch-100 font-medium">KKONU DEV</span>
                    </p>
                </div>
            </footer>
        </template>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import api from '../../lib/api';
import PublicTopBar from '../../components/PublicTopBar.vue';
import StatusBadge from '../../components/StatusBadge.vue';
import TickerCard from '../../components/TickerCard.vue';

const tournaments = ref([]);
const loading = ref(true);
const featuredStats = ref({ teamCount: 0, total: 0, finished: 0, champion: null });
const tickerMatches = ref([]);
const standingsPreview = ref([]);
const nextMatch = ref(null); // BARU

const featured = computed(() => {
    return tournaments.value.find((t) => t.is_featured)
        ?? tournaments.value.find((t) => t.status === 'ongoing')
        ?? null;
});

const others = computed(() => tournaments.value.filter((t) => t.id !== featured.value?.id));

// BARU — progress bar
const progressPercent = computed(() => {
    if (!featuredStats.value.total) return 0;
    return Math.round((featuredStats.value.finished / featuredStats.value.total) * 100);
});

// BARU — countdown pertandingan berikutnya
const nextMatchDate = computed(() => {
    if (!nextMatch.value?.scheduled_at) return '';
    return new Date(nextMatch.value.scheduled_at).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
});

function formatDate(d) {
    if (!d) return '';
    return new Date(d).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
}

async function loadFeaturedExtras(tournamentSlug) {
    const [{ data: detail }, { data: matches }, { data: standings }] = await Promise.all([
        api.get(`/public/tournaments/${tournamentSlug}`),
        api.get(`/public/tournaments/${tournamentSlug}/matches`),
        api.get(`/public/tournaments/${tournamentSlug}/standings`),
    ]);

    const teamCount = detail.groups?.reduce((sum, g) => sum + (g.teams?.length ?? 0), 0) ?? 0;
    const finishedMatches = matches.filter((m) => m.status === 'finished' || m.status === 'walkover');
    const final = matches.find((m) => m.stage === 'final');
    const champion = final?.winner_team_id
        ? (final.winner_team_id === final.home_team_id ? final.home_team?.name : final.away_team?.name)
        : null;

    featuredStats.value = { teamCount, total: matches.length, finished: finishedMatches.length, champion };

    const sorted = [...matches].sort((a, b) => new Date(a.scheduled_at) - new Date(b.scheduled_at));
    const recent = sorted.filter((m) => finishedMatches.includes(m)).slice(-3);
    const upcoming = sorted.filter((m) => m.status === 'scheduled').slice(0, 3);
    tickerMatches.value = [...recent, ...upcoming];

    nextMatch.value = sorted.find((m) => m.status === 'scheduled') ?? null;

    standingsPreview.value = standings;
}

onMounted(async () => {
    const { data } = await api.get('/public/tournaments');
    tournaments.value = data;
    loading.value = false;

    if (featured.value) {
        await loadFeaturedExtras(featured.value.slug); 
    }
});
</script>
<!-- resources/js/pages/StandingsIndex.vue -->
<template>
    <div>
        <TopBar show-logout :user-name="auth.user?.name" @logout="handleLogout" class="no-print" />

        <main class="max-w-3xl mx-auto px-4 sm:px-6 py-6 sm:py-10">
            <router-link :to="{ name: 'tournaments.show', params: { id: tournamentId } }" class="no-print text-sm text-pitch-400 hover:text-gold-400 transition">
                &larr; Kembali ke turnamen
            </router-link>

            <PrintHeader v-if="tournament" :tournament-name="tournament.name" title="Klasemen Turnamen" />

            <div class="flex items-center justify-between mt-3 mb-6 sm:mb-8 no-print">
                <h1 class="font-display font-bold text-xl sm:text-2xl">Klasemen</h1>
                <button
                    @click="handlePrint"
                    class="text-sm border border-pitch-600 px-3 py-1.5 rounded-md hover:border-gold-400/50 hover:bg-pitch-800/40 transition"
                >
                    Cetak
                </button>
            </div>

            <div v-if="loading" class="text-pitch-400 text-sm">Memuat...</div>

            <div v-else class="space-y-8">
                <div v-for="entry in standings" :key="entry.group.id">
                    <h2 class="font-display font-semibold mb-3">{{ entry.group.name }}</h2>

                    <div class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="text-pitch-400 text-xs border-b border-pitch-600">
                                    <th class="text-left py-2 pr-2">Tim</th>
                                    <th class="px-2 font-tabular">M</th>
                                    <th class="px-2 font-tabular">MN</th>
                                    <th class="px-2 font-tabular">S</th>
                                    <th class="px-2 font-tabular">K</th>
                                    <th class="px-2 font-tabular">SG</th>
                                    <th class="pl-2 font-tabular">Poin</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr
                                    v-for="(s, i) in entry.standings"
                                    :key="s.team.id"
                                    class="border-b border-pitch-700"
                                    :class="{ 'text-gold-400': i < 2 }"
                                >
                                    <td class="py-2.5 pr-2">
                                        <span class="text-pitch-400 font-tabular mr-2">{{ i + 1 }}</span>
                                        {{ s.team.name }}
                                    </td>
                                    <td class="px-2 text-center font-tabular">{{ s.played }}</td>
                                    <td class="px-2 text-center font-tabular">{{ s.won }}</td>
                                    <td class="px-2 text-center font-tabular">{{ s.drawn }}</td>
                                    <td class="px-2 text-center font-tabular">{{ s.lost }}</td>
                                    <td class="px-2 text-center font-tabular">{{ s.goal_diff > 0 ? '+' : '' }}{{ s.goal_diff }}</td>
                                    <td class="pl-2 text-center font-tabular font-semibold">{{ s.points }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <p class="text-xs text-pitch-400 mt-2 no-print">2 besar (kuning) lolos ke semifinal</p>
                </div>
            </div>
        </main>
        <Footer />
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import api from '../lib/api';
import TopBar from '../components/TopBar.vue';
import PrintHeader from '../components/PrintHeader.vue';
import Footer from '../components/Footer.vue';

const route = useRoute();
const router = useRouter();
const auth = useAuthStore();
const tournamentId = route.params.id;

const tournament = ref(null);
const standings = ref([]);
const loading = ref(true);

async function fetchStandings() {
    loading.value = true;
    const [{ data: t }, { data: s }] = await Promise.all([
        api.get(`/tournaments/${tournamentId}`),
        api.get(`/tournaments/${tournamentId}/standings`),
    ]);
    tournament.value = t;
    standings.value = s;
    loading.value = false;
}

function handlePrint() {
    window.print();
}

async function handleLogout() {
    await auth.logout();
    router.push({ name: 'login' });
}

onMounted(fetchStandings);
</script>

<!-- resources/js/pages/public/Standings.vue -->
<template>
    <div>
        <PublicTopBar />

        <main class="max-w-3xl mx-auto px-4 sm:px-6 py-6 sm:py-10">
            <router-link :to="{ name: 'public.tournament', params: { id: tournamentId } }" class="text-sm text-pitch-400 hover:text-gold-400 transition">
                &larr; Kembali
            </router-link>

            <h1 class="font-display font-bold text-xl sm:text-2xl mt-3 mb-6 sm:mb-8">Klasemen</h1>

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
                    <p class="text-xs text-pitch-400 mt-2">2 besar (kuning) lolos ke semifinal</p>
                </div>
            </div>
        </main>
        <Footer />
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import api from '../../lib/api';
import PublicTopBar from '../../components/PublicTopBar.vue';
import Footer from '../components/Footer.vue';

const route = useRoute();
const tournamentId = route.params.id;
const standings = ref([]);
const loading = ref(true);

onMounted(async () => {
    const { data } = await api.get(`/public/tournaments/${tournamentId}/standings`);
    standings.value = data;
    loading.value = false;
});
</script>

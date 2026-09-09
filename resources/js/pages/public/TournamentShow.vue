<!-- resources/js/pages/public/TournamentShow.vue -->
<template>
    <div v-if="tournament">
        <PublicTopBar />

        <main class="max-w-3xl mx-auto px-4 sm:px-6 py-6 sm:py-10">
            <div class="flex items-center gap-3 mb-2">
                <h1 class="font-display font-bold text-xl sm:text-2xl">{{ tournament.name }}</h1>
                <StatusBadge :status="tournament.status" />
            </div>
            <p v-if="tournament.description" class="text-sm text-pitch-400 mb-2">{{ tournament.description }}</p>
            <p v-if="tournament.start_date" class="text-xs text-pitch-400 mb-8">
                {{ formatDate(tournament.start_date) }} — {{ formatDate(tournament.end_date) }}
            </p>

            <!-- ganti grid-cols-3 gap-3 jadi ini -->
            <div class="grid grid-cols-3 gap-2 sm:gap-3 mb-10">
                <router-link
                    :to="{ name: 'public.matches', params: { id: tournamentId } }"
                    class="border border-pitch-600 rounded-lg p-3 sm:p-4 text-center hover:border-gold-400/50 hover:bg-pitch-800/40 transition"
                >
                    <p class="text-xs sm:text-sm font-medium">Jadwal</p>
                </router-link>
                <router-link
                    :to="{ name: 'public.standings', params: { id: tournamentId } }"
                    class="border border-pitch-600 rounded-lg p-3 sm:p-4 text-center hover:border-gold-400/50 hover:bg-pitch-800/40 transition"
                >
                    <p class="text-xs sm:text-sm font-medium">Klasemen</p>
                </router-link>
                <router-link
                    :to="{ name: 'public.bracket', params: { id: tournamentId } }"
                    class="border border-pitch-600 rounded-lg p-3 sm:p-4 text-center hover:border-gold-400/50 hover:bg-pitch-800/40 transition"
                >
                    <p class="text-xs sm:text-sm font-medium">Bracket</p>
                </router-link>
            </div>

            <div v-if="tournament.groups?.length">
                <h2 class="font-display font-semibold mb-3">Tim Peserta</h2>
                <div class="grid sm:grid-cols-2 gap-4">
                    <div v-for="group in tournament.groups" :key="group.id" class="border border-pitch-600 rounded-lg p-4">
                        <p class="text-sm text-pitch-400 mb-2">{{ group.name }}</p>
                        <ul class="space-y-1 text-sm">
                            <li v-for="team in group.teams" :key="team.id">{{ team.name }}</li>
                        </ul>
                    </div>
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
import StatusBadge from '../../components/StatusBadge.vue';
import Footer from '../../components/Footer.vue';

const route = useRoute();
const tournamentId = route.params.id;
const tournament = ref(null);
const tournamentSlug = route.params.slug;

function formatDate(d) {
    if (!d) return '';
    return new Date(d).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
}

onMounted(async () => {
    const { data } = await api.get(`/public/tournaments/${tournamentSlug}`);
    tournament.value = data;
});
</script>

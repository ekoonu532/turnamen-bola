<!-- resources/js/pages/public/Bracket.vue -->
<template>
    <div>
        <PublicTopBar />

        <main class="max-w-2xl mx-auto px-4 sm:px-6 py-6 sm:py-10">
            <router-link :to="{ name: 'public.tournament', params: { id: tournamentId } }" class="text-sm text-pitch-400 hover:text-gold-400 transition">
                &larr; Kembali
            </router-link>

            <h1 class="font-display font-bold text-xl sm:text-2xl mt-3 mb-6 sm:mb-8">Bracket Knockout</h1>

            <div v-if="loading" class="text-pitch-400 text-sm">Memuat...</div>

            <div v-else-if="!hasBracket" class="border border-dashed border-pitch-600 rounded-lg p-8 sm:p-10 text-center">
                <p class="text-sm text-pitch-400">Babak knockout belum dimulai.</p>
            </div>

            <div v-else class="space-y-8">
                <div v-if="bracket.semifinal?.length">
                    <h2 class="font-display font-semibold text-sm text-pitch-400 mb-3 uppercase tracking-wide">Semifinal</h2>
                    <div class="space-y-3">
                        <MatchCard v-for="m in bracket.semifinal" :key="m.id" :match="m" :clickable="false" />
                    </div>
                </div>

                <div v-if="bracket.final?.length || bracket.third_place?.length">
                    <h2 class="font-display font-semibold text-sm text-pitch-400 mb-3 uppercase tracking-wide">Final</h2>
                    <div class="space-y-3">
                        <MatchCard v-for="m in bracket.final ?? []" :key="m.id" :match="m" :clickable="false" />
                        <MatchCard v-for="m in bracket.third_place ?? []" :key="m.id" :match="m" :clickable="false" />
                    </div>
                </div>

                <div v-if="champion" class="border border-dashed border-gold-400/50 rounded-lg p-6 text-center bg-pitch-900/50">
                    <p class="text-xs text-pitch-400 mb-2 uppercase tracking-wide">Juara Turnamen</p>
                    <p class="font-display font-bold text-2xl text-gold-400">{{ champion.name }}</p>
                </div>
            </div>
        </main>
        <Footer />
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import api from '../../lib/api';
import PublicTopBar from '../../components/PublicTopBar.vue';
import MatchCard from '../../components/MatchCard.vue';
import Footer from '../components/Footer.vue';

const route = useRoute();
const tournamentId = route.params.id;
const bracket = ref({});
const loading = ref(true);

const hasBracket = computed(() => Object.keys(bracket.value).length > 0);

const champion = computed(() => {
    const final = bracket.value.final?.[0];
    if (!final || !final.winner_team_id) return null;
    return final.winner_team_id === final.home_team_id ? final.home_team : final.away_team;
});

onMounted(async () => {
    const { data } = await api.get(`/public/tournaments/${tournamentId}/bracket`);
    bracket.value = data;
    loading.value = false;
});
</script>

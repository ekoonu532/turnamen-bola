<!-- resources/js/pages/public/TopScorers.vue -->
<template>
    <div>
        <PublicTopBar />

        <main class="max-w-2xl mx-auto px-4 sm:px-6 py-6 sm:py-10">
            <router-link :to="{ name: 'public.tournament', params: { slug: tournamentSlug } }" class="text-sm text-pitch-400 hover:text-gold-400 transition">
                &larr; Kembali
            </router-link>

            <h1 class="font-display font-bold text-xl sm:text-2xl mt-3 mb-6 sm:mb-8">Top Scorer</h1>

            <div v-if="loading" class="text-pitch-400 text-sm">Memuat...</div>

            <ol v-else-if="scorers.length" class="divide-y divide-pitch-600 border-t border-b border-pitch-600">
                <li
                    v-for="(s, i) in scorers"
                    :key="s.player_id"
                    class="flex items-center justify-between py-3 px-2 -mx-2"
                    :class="{ 'text-gold-400': i === 0 }"
                >
                    <div>
                        <span class="font-tabular text-pitch-400 mr-2">{{ i + 1 }}</span>
                        <span class="font-medium">{{ s.player_name }}</span>
                        <span class="text-xs text-pitch-400 ml-2">{{ s.team_name }}</span>
                    </div>
                    <span class="font-tabular font-bold">{{ s.goals }} gol</span>
                </li>
            </ol>

            <div v-else class="border border-dashed border-pitch-600 rounded-lg p-8 sm:p-10 text-center">
                <p class="text-sm text-pitch-400">Belum ada gol tercatat.</p>
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
import Footer from '../../components/Footer.vue';

const route = useRoute();
const tournamentSlug = route.params.slug;
const scorers = ref([]);
const loading = ref(true);

onMounted(async () => {
    const { data } = await api.get(`/public/tournaments/${tournamentSlug}/top-scorers`);
    scorers.value = data;
    loading.value = false;
});
</script>
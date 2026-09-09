<!-- resources/js/pages/public/Matches.vue -->
<template>
    <div>
        <PublicTopBar />

        <main class="max-w-3xl mx-auto px-4 sm:px-6 py-6 sm:py-10">
            <router-link :to="{ name: 'public.tournament', params: { slug: tournamentSlug } }" class="text-sm text-pitch-400 hover:text-gold-400 transition">
                &larr; Kembali
            </router-link>

            <h1 class="font-display font-bold text-xl sm:text-2xl mt-3 mb-6 sm:mb-8">Jadwal Pertandingan</h1>

            <div v-if="loading" class="text-pitch-400 text-sm">Memuat...</div>

            <div v-else-if="matches.length === 0" class="border border-dashed border-pitch-600 rounded-lg p-8 sm:p-10 text-center">
                <p class="text-sm text-pitch-400">Jadwal belum tersedia.</p>
            </div>

            <div v-else class="space-y-6">
                <div v-for="(group, stage) in matchesByStage" :key="stage">
                    <h2 class="font-display font-semibold text-sm text-pitch-400 mb-3 uppercase tracking-wide">
                        {{ stageLabels[stage] ?? stage }}
                    </h2>
                    <div class="space-y-3">
                        <MatchCard v-for="m in group" :key="m.id" :match="m" :clickable="false" />
                    </div>
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
import Footer from '../../components/Footer.vue';

const route = useRoute();
const tournamentId = route.params.id;
const matches = ref([]);
const loading = ref(true);
const tournamentSlug = route.params.slug;

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

onMounted(async () => {
    const { data } = await api.get(`/public/tournaments/${tournamentSlug}/matches`);
    matches.value = data;
    loading.value = false;
});
</script>

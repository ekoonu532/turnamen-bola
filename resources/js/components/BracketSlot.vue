<!-- resources/js/components/BracketSlot.vue -->
<template>
    <div
        class="border rounded-lg p-3 bg-pitch-900/40 print:bg-white"
        :class="highlight ? 'border-gold-400/50' : 'border-pitch-600'"
    >
        <p class="text-[11px] text-pitch-400 mb-1.5">{{ dateLabel }}</p>
        <div class="flex items-center justify-between text-sm mb-1">
            <span class="truncate" :class="{ 'text-gold-400 font-medium': match?.winner_team_id === match?.home_team_id }">
                {{ match?.home_team?.name ?? 'TBD' }}
            </span>
            <span class="font-tabular font-semibold ml-2">{{ isFinished ? match.home_score : '' }}</span>
        </div>
        <div class="flex items-center justify-between text-sm">
            <span class="truncate" :class="{ 'text-gold-400 font-medium': match?.winner_team_id === match?.away_team_id }">
                {{ match?.away_team?.name ?? 'TBD' }}
            </span>
            <span class="font-tabular font-semibold ml-2">{{ isFinished ? match.away_score : '' }}</span>
        </div>
        <p v-if="isFinished && match.home_penalty !== null" class="text-[11px] text-pitch-400 mt-1.5">
            ({{ match.home_penalty }}-{{ match.away_penalty }} pen)
        </p>
    </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
    match: { type: Object, default: null },
    highlight: { type: Boolean, default: false },
});

const isFinished = computed(() => props.match && ['finished', 'walkover'].includes(props.match.status));

const dateLabel = computed(() => {
    if (!props.match?.scheduled_at) return '';
    return new Date(props.match.scheduled_at).toLocaleDateString('id-ID', { day: 'numeric', month: 'short' });
});
</script>

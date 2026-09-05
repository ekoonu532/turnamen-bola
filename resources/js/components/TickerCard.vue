<!-- resources/js/components/TickerCard.vue -->
<template>
    <div class="shrink-0 w-52 border border-pitch-600 rounded-lg p-3.5 bg-pitch-900/40">
        <p class="text-[11px] text-pitch-400 mb-2 truncate">{{ dateLabel }}</p>
        <div class="flex items-center justify-between text-sm mb-1">
            <span class="truncate" :class="{ 'text-gold-400': match.winner_team_id === match.home_team_id }">
                {{ match.home_team?.name ?? 'TBD' }}
            </span>
            <span class="font-display font-tabular font-semibold ml-2">
                {{ isFinished ? match.home_score : '' }}
            </span>
        </div>
        <div class="flex items-center justify-between text-sm">
            <span class="truncate" :class="{ 'text-gold-400': match.winner_team_id === match.away_team_id }">
                {{ match.away_team?.name ?? 'TBD' }}
            </span>
            <span class="font-display font-tabular font-semibold ml-2">
                {{ isFinished ? match.away_score : '' }}
            </span>
        </div>
        <p v-if="!isFinished" class="text-[11px] text-pitch-400 mt-2">vs</p>
    </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({ match: Object });

const isFinished = computed(() => ['finished', 'walkover'].includes(props.match.status));

const dateLabel = computed(() => {
    if (!props.match.scheduled_at) return '';
    return new Date(props.match.scheduled_at).toLocaleDateString('id-ID', { day: 'numeric', month: 'short' });
});
</script>
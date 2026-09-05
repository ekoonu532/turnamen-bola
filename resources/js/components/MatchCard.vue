<!-- resources/js/components/MatchCard.vue -->
<template>
    <component
        :is="clickable ? 'router-link' : 'div'"
        v-bind="clickable ? { to: { name: 'matches.show', params: { matchId: match.id } } } : {}"
        class="border border-pitch-600 rounded-lg p-4 flex items-center justify-between gap-4 transition block"
        :class="clickable ? 'hover:border-gold-400/50 hover:bg-pitch-800/40' : ''"
    >
        <div class="flex-1 min-w-0">
            <p class="text-xs text-pitch-400 mb-2">
                {{ match.group?.name ?? stageLabel }}
                <span v-if="match.scheduled_at"> · {{ formatDate(match.scheduled_at) }}</span>
            </p>
            <div class="flex items-center justify-between gap-3">
                <span class="truncate" :class="{ 'text-gold-400 font-medium': match.winner_team_id === match.home_team_id }">
                    {{ match.home_team?.name ?? 'TBD' }}
                </span>

                <div class="font-display font-tabular text-lg shrink-0 text-center">
                    <template v-if="match.status === 'finished' || match.status === 'walkover'">
                        <div>{{ match.home_score }} – {{ match.away_score }}</div>
                        <div v-if="match.stage !== 'group' && match.home_penalty !== null" class="text-xs text-pitch-400 font-sans">
                            ({{ match.home_penalty }}-{{ match.away_penalty }} pen)
                        </div>
                    </template>
                    <template v-else>vs</template>
                </div>

                <span class="truncate text-right" :class="{ 'text-gold-400 font-medium': match.winner_team_id === match.away_team_id }">
                    {{ match.away_team?.name ?? 'TBD' }}
                </span>
            </div>
        </div>

        <StatusBadge :status="matchStatus" class="shrink-0" />
    </component>
</template>

<script setup>
import { computed } from 'vue';
import StatusBadge from './StatusBadge.vue';

const props = defineProps({
    match: Object,
    clickable: { type: Boolean, default: true },
});

const stageLabels = {
    group: 'Fase Grup',
    semifinal: 'Semifinal',
    final: 'Final',
    third_place: 'Perebutan Juara 3',
};

const stageLabel = computed(() => stageLabels[props.match.stage] ?? props.match.stage);

const statusLabels = {
    scheduled: 'scheduled',
    live: 'ongoing',
    finished: 'finished',
    walkover: 'finished',
    postponed: 'draft',
};

const matchStatus = computed(() => statusLabels[props.match.status] ?? props.match.status);

function formatDate(d) {
    return new Date(d).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
}
</script>
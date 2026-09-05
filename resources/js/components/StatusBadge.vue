<!-- resources/js/components/StatusBadge.vue -->
<template>
    <span class="inline-flex items-center gap-1.5 text-xs px-2 py-1 rounded-full border" :class="classes">
        <span class="w-1.5 h-1.5 rounded-full" :class="dotClass"></span>
        {{ label }}
    </span>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({ status: String });

const map = {
    draft: { label: 'Draf', classes: 'border-pitch-600 text-pitch-400', dot: 'bg-pitch-400' },
    registration: { label: 'Pendaftaran', classes: 'border-gold-400/40 text-gold-400', dot: 'bg-gold-400' },
    ongoing: { label: 'Berlangsung', classes: 'border-lime-400/40 text-lime-400', dot: 'bg-lime-400 animate-pulse' },
    finished: { label: 'Selesai', classes: 'border-pitch-600 text-pitch-100', dot: 'bg-pitch-100' },
    pending: { label: 'Menunggu', classes: 'border-pitch-600 text-pitch-400', dot: 'bg-pitch-400' },
    verified: { label: 'Terverifikasi', classes: 'border-lime-400/40 text-lime-400', dot: 'bg-lime-400' },
    rejected: { label: 'Ditolak', classes: 'border-clay-500/40 text-clay-500', dot: 'bg-clay-500' },
    withdrawn: { label: 'Mundur', classes: 'border-clay-500/40 text-clay-500', dot: 'bg-clay-500' },
};

const label = computed(() => map[props.status]?.label ?? props.status);
const classes = computed(() => map[props.status]?.classes ?? 'border-pitch-600 text-pitch-400');
const dotClass = computed(() => map[props.status]?.dot ?? 'bg-pitch-400');
</script>
<!-- resources/js/components/PrintHeader.vue -->
<template>
    <div class="hidden print:block mb-6 pb-4 border-b-2 border-black">
        <div class="flex items-center justify-between">
            <div>
                <p class="font-display font-bold text-xl">{{ tournamentName }}</p>
                <p class="text-sm text-gray-600 mt-0.5">{{ title }}</p>
            </div>
            <p class="text-xs text-gray-500">Dicetak: {{ printedAt }}</p>
        </div>
    </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
    tournamentName: { type: String, required: true },
    title: { type: String, required: true },
});

const printedAt = computed(() =>
    new Date().toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })
);
</script>

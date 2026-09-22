<!-- resources/js/components/BracketTree.vue -->
<template>
    <div class="overflow-x-auto print:overflow-visible">
        <div class="flex items-stretch gap-6 sm:gap-10 min-w-[520px] py-4">
            <!-- Kolom Semifinal -->
            <div class="flex flex-col justify-around gap-10 w-56 shrink-0">
                <BracketSlot :match="semifinals[0]" />
                <BracketSlot :match="semifinals[1]" />
            </div>

            <!-- Konektor -->
            <div class="relative w-8 shrink-0">
                <div class="bracket-connector"></div>
            </div>

            <!-- Kolom Final -->
            <div class="flex flex-col justify-center w-56 shrink-0">
                <BracketSlot :match="final" highlight />
            </div>
        </div>

        <!-- Perebutan Juara 3, cabang terpisah -->
        <div v-if="thirdPlace" class="mt-6 pt-5 border-t border-dashed border-pitch-600 print:border-gray-300 max-w-xs">
            <p class="text-xs text-pitch-400 mb-2 uppercase tracking-wide">Perebutan Juara 3</p>
            <BracketSlot :match="thirdPlace" />
        </div>
    </div>
</template>

<script setup>
import BracketSlot from './BracketSlot.vue';

defineProps({
    semifinals: { type: Array, required: true },
    final: { type: Object, default: null },
    thirdPlace: { type: Object, default: null },
});
</script>

<!-- resources/js/components/TopBar.vue -->
<template>
    <header class="border-b border-pitch-600">
        <div class="max-w-5xl mx-auto px-4 sm:px-6 py-4 sm:py-5 flex items-center justify-between">
            <router-link :to="{ name: 'tournaments.index' }" class="flex items-baseline gap-2">
                <span class="font-display font-bold text-lg sm:text-xl tracking-tight">Turnamen</span>
                <span class="w-1.5 h-1.5 rounded-full bg-gold-400"></span>
            </router-link>
            <nav v-if="showLogout" class="flex items-center gap-3 sm:gap-4 text-sm text-pitch-400">
                <span v-if="userName" class="hidden sm:inline">{{ userName }}</span>
                <button @click="$emit('logout')" class="text-pitch-100 hover:text-gold-400 transition-colors">
                    Keluar
                </button>
            </nav>
        </div>
    </header>
</template>

<script setup>
defineProps({
    showLogout: { type: Boolean, default: false },
    userName: { type: String, default: '' },
});
defineEmits(['logout']);
</script>
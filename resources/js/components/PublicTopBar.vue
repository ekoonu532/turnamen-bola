<!-- resources/js/components/PublicTopBar.vue -->
<template>
    <header class="border-b border-pitch-600">
        <div class="max-w-3xl mx-auto px-4 sm:px-6 py-4 sm:py-5 flex items-center justify-between">
            <router-link :to="{ name: 'public.tournaments' }" class="flex items-baseline gap-2">
                <span class="font-display font-bold text-lg sm:text-xl tracking-tight">Turnamen</span>
                <span class="w-1.5 h-1.5 rounded-full bg-gold-400"></span>
            </router-link>
            <!-- <router-link :to="{ name: 'login' }" class="text-sm text-pitch-400 hover:text-gold-400 transition">
                Admin
            </router-link> -->
        </div>
    </header>
</template>
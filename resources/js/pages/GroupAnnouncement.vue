<!-- resources/js/pages/GroupAnnouncement.vue -->
<template>
    <div>
        <TopBar show-logout :user-name="auth.user?.name" @logout="handleLogout" class="no-print" />

        <div class="max-w-3xl mx-auto px-4 sm:px-6 py-6 sm:py-10">
            <router-link :to="{ name: 'groups.manage', params: { id: tournamentId } }" class="no-print text-sm text-pitch-400 hover:text-gold-400 transition">
                &larr; Kembali
            </router-link>

            <div class="flex items-center justify-between mt-3 mb-8 no-print">
                <h1 class="font-display font-bold text-xl sm:text-2xl">Pengumuman Grup</h1>
                <button
                    @click="handlePrint"
                    class="text-sm bg-gold-400 text-pitch-950 font-semibold px-4 py-2 rounded-md hover:bg-gold-500 transition"
                >
                    Cetak Poster
                </button>
            </div>

            <div v-if="loading" class="text-pitch-400 text-sm no-print">Memuat...</div>

            <!-- ── Poster ── -->
            <div v-else class="print-color bg-pitch-900 border-2 border-gold-400/40 rounded-2xl p-6 sm:p-10 relative overflow-hidden">
                <!-- Motif dekoratif -->
                <svg class="absolute -right-16 -top-16 w-64 h-64 opacity-[0.08] pointer-events-none" viewBox="0 0 400 400" fill="none">
                    <circle cx="200" cy="200" r="150" stroke="#F2C744" stroke-width="2" />
                    <circle cx="200" cy="200" r="90" stroke="#F2C744" stroke-width="1.5" />
                </svg>

                <div class="relative text-center mb-8 sm:mb-10">
                    <div class="inline-flex items-center gap-2 mb-3">
                        <span class="w-1.5 h-1.5 rounded-full bg-gold-400"></span>
                        <span class="text-xs tracking-[0.2em] text-pitch-400 uppercase">Pengumuman Resmi</span>
                        <span class="w-1.5 h-1.5 rounded-full bg-gold-400"></span>
                    </div>
                    <h1 class="font-display font-bold text-2xl sm:text-4xl text-pitch-100 mb-2">
                        Hasil Undian Grup
                    </h1>
                    <p class="font-display text-gold-400 text-lg sm:text-xl">{{ tournament?.name }}</p>
                </div>

                <div class="relative grid sm:grid-cols-2 gap-5 sm:gap-6">
                    <div
                        v-for="group in groups"
                        :key="group.id"
                        class="border border-gold-400/30 rounded-xl overflow-hidden bg-pitch-950/40"
                    >
                        <div class="bg-gold-400 text-pitch-950 px-5 py-3">
                            <p class="font-display font-bold text-lg">{{ group.name }}</p>
                        </div>
                        <ul class="p-5 space-y-3">
                            <li
                                v-for="(team, i) in group.teams ?? []"
                                :key="team.id"
                                class="flex items-center gap-3"
                            >
                                <span class="font-display font-bold text-gold-400 w-6 text-right">{{ i + 1 }}</span>
                                <span class="text-pitch-100 font-medium">{{ team.name }}</span>
                            </li>
                            <li v-if="(group.teams ?? []).length === 0" class="text-sm text-pitch-400 italic">
                                Belum ada tim
                            </li>
                        </ul>
                    </div>
                </div>

                <div class="relative text-center mt-8 sm:mt-10 pt-6 border-t border-gold-400/20">
                    <p class="text-xs text-pitch-400">
                        Diumumkan pada {{ announcedDate }}
                    </p>
                    <p class="text-xs text-pitch-400 mt-1">Panitia {{ tournament?.name }}</p>
                </div>
            </div>
        </div>

        <Footer class="no-print" />
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import api from '../lib/api';
import TopBar from '../components/TopBar.vue';
import Footer from '../components/Footer.vue';

const route = useRoute();
const router = useRouter();
const auth = useAuthStore();
const tournamentId = route.params.id;

const tournament = ref(null);
const groups = ref([]);
const loading = ref(true);

const announcedDate = computed(() =>
    new Date().toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })
);

async function fetchData() {
    loading.value = true;
    const { data } = await api.get(`/tournaments/${tournamentId}`);
    tournament.value = data;
    groups.value = data.groups ?? [];
    loading.value = false;
}

function handlePrint() {
    window.print();
}

async function handleLogout() {
    await auth.logout();
    router.push({ name: 'login' });
}

onMounted(fetchData);
</script>

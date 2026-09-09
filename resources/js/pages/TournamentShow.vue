<!-- resources/js/pages/TournamentShow.vue -->
<template>
    <div v-if="tournament">
        <TopBar show-logout :user-name="auth.user?.name" @logout="handleLogout" class="no-print" />

        <main class="max-w-5xl mx-auto px-4 sm:px-6 py-6 sm:py-10">
            <router-link :to="{ name: 'tournaments.index' }" class="no-print text-sm text-pitch-400 hover:text-gold-400 transition">
                &larr; Semua turnamen
            </router-link>

            <div class="flex flex-wrap items-center gap-3 mt-3 mb-2">
                <h1 class="font-display font-bold text-xl sm:text-2xl">{{ tournament.name }}</h1>

                <select
                    :value="tournament.status"
                    @change="handleStatusChange($event.target.value)"
                    class="text-xs bg-pitch-800 border border-pitch-600 rounded-full px-3 py-1 focus:outline-none focus:ring-2 focus:ring-gold-400"
                >
                    <option value="draft">Draf</option>
                    <option value="registration">Pendaftaran</option>
                    <option value="ongoing">Berlangsung</option>
                    <option value="finished">Selesai</option>
                </select>
            </div>

            <p class="text-xs text-pitch-400 mb-1">
                Turnamen berstatus "Draf" tidak muncul di halaman publik. Ubah ke "Pendaftaran" atau "Berlangsung" agar bisa dilihat umum.
            </p>

            <div class="flex flex-wrap items-center gap-4 mb-6 sm:mb-8">
                <button
                    @click="toggleFeatured"
                    class="text-sm transition"
                    :class="tournament.is_featured ? 'text-gold-400' : 'text-pitch-400 hover:text-gold-400'"
                >
                    {{ tournament.is_featured ? '★ Tampilan utama di beranda publik' : '☆ Jadikan tampilan utama di beranda publik' }}
                </button>

                <button
                    @click="handleDelete"
                    class="text-sm text-pitch-400 hover:text-clay-500 transition"
                >
                    Hapus Turnamen
                </button>
            </div>

            <div class="grid grid-cols-2 sm:grid-cols-5 gap-3 sm:gap-4">
                <router-link
                    :to="{ name: 'teams.index', params: { id: tournament.id } }"
                    class="border border-pitch-600 rounded-lg p-4 sm:p-5 hover:border-gold-400/50 hover:bg-pitch-800/40 transition"
                >
                    <p class="font-display font-bold text-xl sm:text-2xl font-tabular">{{ tournament.teams?.length ?? 0 }}</p>
                    <p class="text-sm text-pitch-400 mt-1">Tim</p>
                </router-link>

                <router-link
                    :to="{ name: 'groups.manage', params: { id: tournament.id } }"
                    class="border border-pitch-600 rounded-lg p-4 sm:p-5 hover:border-gold-400/50 hover:bg-pitch-800/40 transition"
                >
                    <p class="font-display font-bold text-xl sm:text-2xl font-tabular">{{ tournament.groups?.length ?? 0 }}</p>
                    <p class="text-sm text-pitch-400 mt-1">Grup</p>
                </router-link>

                <router-link
                    :to="{ name: 'matches.index', params: { id: tournament.id } }"
                    class="border border-pitch-600 rounded-lg p-4 sm:p-5 hover:border-gold-400/50 hover:bg-pitch-800/40 transition"
                >
                    <p class="font-display font-bold text-xl sm:text-2xl font-tabular">{{ tournament.matches?.length ?? 0 }}</p>
                    <p class="text-sm text-pitch-400 mt-1">Pertandingan</p>
                </router-link>

                <router-link
                    :to="{ name: 'standings.index', params: { id: tournament.id } }"
                    class="border border-pitch-600 rounded-lg p-4 sm:p-5 hover:border-gold-400/50 hover:bg-pitch-800/40 transition"
                >
                    <p class="font-display font-bold text-xl sm:text-2xl">🏅</p>
                    <p class="text-sm text-pitch-400 mt-1">Klasemen</p>
                </router-link>

                <router-link
                    :to="{ name: 'bracket.show', params: { id: tournament.id } }"
                    class="border border-pitch-600 rounded-lg p-4 sm:p-5 hover:border-gold-400/50 hover:bg-pitch-800/40 transition"
                >
                    <p class="font-display font-bold text-xl sm:text-2xl">🏆</p>
                    <p class="text-sm text-pitch-400 mt-1">Bracket</p>
                </router-link>
            </div>
        </main>

        <Footer />
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import api from '../lib/api';
import TopBar from '../components/TopBar.vue';
import Footer from '../components/Footer.vue';

const tournament = ref(null);
const route = useRoute();
const router = useRouter();
const auth = useAuthStore();

async function fetchTournament() {
    const { data } = await api.get(`/tournaments/${route.params.id}`);
    tournament.value = data;
}

async function handleStatusChange(status) {
    await api.put(`/tournaments/${tournament.value.id}`, { status });
    await fetchTournament();
}

async function toggleFeatured() {
    if (tournament.value.is_featured) {
        await api.delete(`/tournaments/${tournament.value.id}/feature`);
    } else {
        await api.post(`/tournaments/${tournament.value.id}/feature`);
    }
    await fetchTournament();
}

async function handleDelete() {
    const confirmed = confirm(
        `Hapus turnamen "${tournament.value.name}"? Semua tim, grup, jadwal, dan hasil pertandingan yang terkait akan ikut terhapus permanen. Tindakan ini tidak bisa dibatalkan.`
    );
    if (!confirmed) return;

    await api.delete(`/tournaments/${tournament.value.id}`);
    router.push({ name: 'tournaments.index' });
}

async function handleLogout() {
    await auth.logout();
    router.push({ name: 'login' });
}

onMounted(fetchTournament);
</script>
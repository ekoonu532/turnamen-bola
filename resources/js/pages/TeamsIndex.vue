<!-- resources/js/pages/TeamsIndex.vue -->
<template>
    <div>
        <TopBar show-logout :user-name="auth.user?.name" @logout="handleLogout" />

        <main class="max-w-3xl mx-auto px-4 sm:px-6 py-6 sm:py-10">
            <router-link :to="{ name: 'tournaments.show', params: { id: tournamentId } }" class="text-sm text-pitch-400 hover:text-gold-400 transition">
                &larr; Kembali ke turnamen
            </router-link>

            <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-2 mt-3 mb-6 sm:mb-8">
                <h1 class="font-display font-bold text-xl sm:text-2xl">Kelola Tim</h1>
                <p class="text-sm text-pitch-400">{{ teams.length }} tim</p>
            </div>

            <form @submit.prevent="handleAddTeam" class="flex flex-col sm:flex-row gap-2 mb-6 sm:mb-8">
                <input
                    v-model="newTeamName"
                    type="text"
                    placeholder="Nama tim baru"
                    class="flex-1 bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2.5 text-base sm:text-sm placeholder-pitch-400 focus:outline-none focus:ring-2 focus:ring-gold-400 focus:border-transparent transition"
                    required
                />
                <button type="submit" class="bg-gold-400 text-pitch-950 font-semibold px-4 py-2.5 rounded-md hover:bg-gold-500 transition shrink-0">
                    Tambah
                </button>
            </form>

            <p v-if="error" class="text-sm text-clay-500 mb-4">{{ error }}</p>

            <div v-if="loading" class="text-pitch-400 text-sm">Memuat...</div>

            <div v-else-if="teams.length === 0" class="border border-dashed border-pitch-600 rounded-lg p-8 sm:p-10 text-center">
                <p class="text-pitch-100 font-medium mb-1">Belum ada tim</p>
                <p class="text-sm text-pitch-400">Tambahkan tim lewat form di atas.</p>
            </div>

            <ul v-else class="divide-y divide-pitch-600 border-t border-b border-pitch-600">
                <li v-for="team in teams" :key="team.id" class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2 py-3 px-2 -mx-2">
                    <div class="flex-1 min-w-0">
                        <input
                            v-if="editingId === team.id"
                            v-model="editingName"
                            class="bg-pitch-800 border border-pitch-600 rounded-md px-2 py-1.5 text-base sm:text-sm w-full focus:outline-none focus:ring-2 focus:ring-gold-400"
                        />
                        <template v-else>
                            <p class="font-medium truncate">{{ team.name }}</p>
                            <p class="text-xs text-pitch-400 mt-0.5" v-if="team.group">{{ team.group.name }}</p>
                        </template>
                    </div>

                    <div class="flex items-center gap-3 shrink-0">
                        <StatusBadge :status="team.status" />
                        <template v-if="editingId === team.id">
                            <button @click="saveEdit(team)" class="text-sm text-lime-400 hover:underline">Simpan</button>
                            <button @click="cancelEdit" class="text-sm text-pitch-400 hover:underline">Batal</button>
                        </template>
                        <template v-else>
                            <button @click="startEdit(team)" class="text-sm text-pitch-400 hover:text-gold-400 transition">Edit</button>
                            <button @click="handleDelete(team)" class="text-sm text-pitch-400 hover:text-clay-500 transition">Hapus</button>
                        </template>
                    </div>
                </li>
            </ul>
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
import StatusBadge from '../components/StatusBadge.vue';
import Footer from '../components/Footer.vue';

const route = useRoute();
const router = useRouter();
const auth = useAuthStore();
const tournamentId = route.params.id;

const teams = ref([]);
const loading = ref(true);
const error = ref('');
const newTeamName = ref('');
const editingId = ref(null);
const editingName = ref('');

async function fetchTeams() {
    loading.value = true;
    const { data } = await api.get(`/tournaments/${tournamentId}/teams`);
    teams.value = data;
    loading.value = false;
}

async function handleAddTeam() {
    error.value = '';
    try {
        await api.post(`/tournaments/${tournamentId}/teams`, { name: newTeamName.value });
        newTeamName.value = '';
        await fetchTeams();
    } catch (e) {
        error.value = e.response?.data?.message || 'Gagal menambah tim.';
    }
}

function startEdit(team) {
    editingId.value = team.id;
    editingName.value = team.name;
}
function cancelEdit() {
    editingId.value = null;
}
async function saveEdit(team) {
    await api.put(`/teams/${team.id}`, { name: editingName.value });
    editingId.value = null;
    await fetchTeams();
}
async function handleDelete(team) {
    if (!confirm(`Hapus tim "${team.name}"?`)) return;
    await api.delete(`/teams/${team.id}`);
    await fetchTeams();
}

async function handleLogout() {
    await auth.logout();
    router.push({ name: 'login' });
}

onMounted(fetchTeams);
</script>

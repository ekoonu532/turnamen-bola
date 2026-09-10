<!-- resources/js/pages/PlayersManage.vue -->
<template>
    <div>
        <TopBar show-logout :user-name="auth.user?.name" @logout="handleLogout" />

        <main class="max-w-2xl mx-auto px-4 sm:px-6 py-6 sm:py-10">
            <button @click="$router.back()" class="text-sm text-pitch-400 hover:text-gold-400 transition">
                &larr; Kembali
            </button>

            <h1 class="font-display font-bold text-xl sm:text-2xl mt-3 mb-6 sm:mb-8">
                Pemain — {{ team?.name }}
            </h1>

            <form @submit.prevent="handleAdd" class="flex flex-col sm:flex-row gap-2 mb-6">
                <input
                    v-model="form.name"
                    type="text"
                    placeholder="Nama pemain"
                    required
                    class="flex-1 bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2.5 text-base sm:text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
                />
                <input
                    v-model.number="form.jersey_number"
                    type="number"
                    placeholder="No."
                    min="0"
                    max="99"
                    class="w-full sm:w-20 bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2.5 text-base sm:text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
                />
                <input
                    v-model="form.position"
                    type="text"
                    placeholder="Posisi"
                    class="w-full sm:w-28 bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2.5 text-base sm:text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
                />
                <button type="submit" class="bg-gold-400 text-pitch-950 font-semibold px-4 py-2.5 rounded-md hover:bg-gold-500 transition shrink-0">
                    Tambah
                </button>
            </form>

            <p v-if="error" class="text-sm text-clay-500 mb-4">{{ error }}</p>

            <div v-if="loading" class="text-pitch-400 text-sm">Memuat...</div>

            <div v-else-if="players.length === 0" class="border border-dashed border-pitch-600 rounded-lg p-8 sm:p-10 text-center">
                <p class="text-pitch-100 font-medium mb-1">Belum ada pemain</p>
                <p class="text-sm text-pitch-400">Tambahkan pemain lewat form di atas.</p>
            </div>

            <ul v-else class="divide-y divide-pitch-600 border-t border-b border-pitch-600">
                <li v-for="p in players" :key="p.id" class="flex items-center justify-between py-3 px-2 -mx-2">
                    <div>
                        <span class="font-tabular text-pitch-400 mr-2" v-if="p.jersey_number">#{{ p.jersey_number }}</span>
                        <span class="font-medium">{{ p.name }}</span>
                        <span class="text-xs text-pitch-400 ml-2" v-if="p.position">{{ p.position }}</span>
                    </div>
                    <button @click="handleDelete(p)" class="text-sm text-pitch-400 hover:text-clay-500 transition">
                        Hapus
                    </button>
                </li>
            </ul>
        </main>

        <Footer />
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import api from '../lib/api';
import TopBar from '../components/TopBar.vue';
import Footer from '../components/Footer.vue';

const route = useRoute();
const router = useRouter();
const auth = useAuthStore();
const teamId = route.params.teamId;

const team = ref(null);
const players = ref([]);
const loading = ref(true);
const error = ref('');
const form = reactive({ name: '', jersey_number: null, position: '' });

async function fetchPlayers() {
    loading.value = true;
    const { data } = await api.get(`/teams/${teamId}/players`);
    players.value = data;
    if (data.length > 0) {
        team.value = data[0].team ?? team.value;
    }
    loading.value = false;
}

async function handleAdd() {
    error.value = '';
    try {
        await api.post(`/teams/${teamId}/players`, form);
        form.name = '';
        form.jersey_number = null;
        form.position = '';
        await fetchPlayers();
    } catch (e) {
        error.value = e.response?.data?.message || 'Gagal menambah pemain.';
    }
}

async function handleDelete(player) {
    if (!confirm(`Hapus ${player.name}?`)) return;
    await api.delete(`/players/${player.id}`);
    await fetchPlayers();
}

async function handleLogout() {
    await auth.logout();
    router.push({ name: 'login' });
}

onMounted(fetchPlayers);
</script>
<!-- resources/js/pages/GroupsManage.vue -->
<template>
    <div>
        <TopBar show-logout :user-name="auth.user?.name" @logout="handleLogout" />

        <main class="max-w-3xl mx-auto px-4 sm:px-6 py-6 sm:py-10">
            <router-link :to="{ name: 'tournaments.show', params: { id: tournamentId } }" class="text-sm text-pitch-400 hover:text-gold-400 transition">
                &larr; Kembali ke turnamen
            </router-link>

            <h1 class="font-display font-bold text-xl sm:text-2xl mt-3 mb-6 sm:mb-8">Pembagian Grup</h1>

            <p v-if="error" class="text-sm text-clay-500 mb-4">{{ error }}</p>
            <p v-if="message" class="text-sm text-lime-400 mb-4">{{ message }}</p>

            <!-- ── Setup awal (belum ada grup) ── -->
            <div v-if="!loading && groups.length === 0" class="border border-dashed border-pitch-600 rounded-lg p-5 sm:p-6 space-y-5">
                <div>
                    <label class="block text-sm text-pitch-400 mb-1.5">Jumlah grup</label>
                    <input
                        v-model.number="groupCount"
                        type="number"
                        min="2"
                        max="8"
                        class="w-24 bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2 text-base sm:text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
                        @change="regenerateNames"
                    />
                </div>

                <div class="space-y-2">
                    <label class="block text-sm text-pitch-400 mb-1.5">Nama grup</label>
                    <input
                        v-for="(name, i) in groupNames"
                        :key="i"
                        v-model="groupNames[i]"
                        type="text"
                        class="w-full bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2 text-base sm:text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
                    />
                </div>

                <div class="flex flex-col sm:flex-row gap-2 pt-2">
                    <button
                        @click="handleAutoDraw"
                        class="flex-1 bg-gold-400 text-pitch-950 font-semibold px-4 py-2.5 rounded-md hover:bg-gold-500 transition"
                    >
                        Undi Otomatis
                    </button>
                    <button
                        @click="handleManualCreate"
                        class="flex-1 border border-pitch-600 text-pitch-100 font-semibold px-4 py-2.5 rounded-md hover:border-gold-400/50 hover:bg-pitch-800/40 transition"
                    >
                        Bagi Manual
                    </button>
                </div>
                <p class="text-xs text-pitch-400">
                    "Undi Otomatis" langsung mengacak semua tim ke tiap grup secara merata. "Bagi Manual" membuat grup kosong dulu, lalu kamu tentukan sendiri tim mana masuk grup mana di bawah.
                </p>
            </div>

            <!-- ── Grup sudah ada ── -->
            <div v-else-if="!loading" class="space-y-6">
                <div class="flex justify-end">
                    <button @click="handleReset" class="text-sm text-pitch-400 hover:text-clay-500 transition">
                        Atur ulang grup
                    </button>
                </div>

                <div v-for="group in groups" :key="group.id" class="border border-pitch-600 rounded-lg p-4 sm:p-5">
                    <div class="flex items-center justify-between mb-3">
                        <h2 class="font-display font-semibold">{{ group.name }}</h2>
                        <span class="text-xs text-pitch-400">{{ teamsInGroup(group.id).length }} tim</span>
                    </div>

                    <ul v-if="teamsInGroup(group.id).length" class="space-y-2">
                        <li
                            v-for="team in teamsInGroup(group.id)"
                            :key="team.id"
                            class="flex items-center justify-between gap-2 text-sm"
                        >
                            <span>{{ team.name }}</span>
                            <select
                                :value="team.group_id"
                                @change="handleAssign(team, $event.target.value)"
                                class="bg-pitch-800 border border-pitch-600 rounded-md px-2 py-1 text-xs focus:outline-none focus:ring-2 focus:ring-gold-400"
                            >
                                <option v-for="g in groups" :key="g.id" :value="g.id">{{ g.name }}</option>
                                <option :value="null">Belum ditentukan</option>
                            </select>
                        </li>
                    </ul>
                    <p v-else class="text-sm text-pitch-400">Belum ada tim di grup ini.</p>
                </div>

                <!-- Tim yang belum masuk grup manapun -->
                <div v-if="unassignedTeams.length" class="border border-dashed border-pitch-600 rounded-lg p-4 sm:p-5">
                    <h2 class="font-display font-semibold mb-3 text-pitch-400">Belum Ditentukan</h2>
                    <ul class="space-y-2">
                        <li
                            v-for="team in unassignedTeams"
                            :key="team.id"
                            class="flex items-center justify-between gap-2 text-sm"
                        >
                            <span>{{ team.name }}</span>
                            <select
                                :value="team.group_id"
                                @change="handleAssign(team, $event.target.value)"
                                class="bg-pitch-800 border border-pitch-600 rounded-md px-2 py-1 text-xs focus:outline-none focus:ring-2 focus:ring-gold-400"
                            >
                                <option :value="null" disabled>Pilih grup</option>
                                <option v-for="g in groups" :key="g.id" :value="g.id">{{ g.name }}</option>
                            </select>
                        </li>
                    </ul>
                </div>
            </div>
        </main>
        <Footer />
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

const groups = ref([]);
const teams = ref([]);
const loading = ref(true);
const error = ref('');
const message = ref('');

const groupCount = ref(2);
const groupNames = ref(['Grup A', 'Grup B']);

function regenerateNames() {
    const count = Math.max(2, Math.min(8, groupCount.value || 2));
    groupCount.value = count;
    groupNames.value = Array.from({ length: count }, (_, i) => groupNames.value[i] ?? `Grup ${String.fromCharCode(65 + i)}`);
}

function teamsInGroup(groupId) {
    return teams.value.filter((t) => t.group_id === groupId);
}

const unassignedTeams = computed(() => teams.value.filter((t) => !t.group_id));

async function fetchData() {
    loading.value = true;
    const [{ data: tournament }, { data: teamList }] = await Promise.all([
        api.get(`/tournaments/${tournamentId}`),
        api.get(`/tournaments/${tournamentId}/teams`),
    ]);
    groups.value = tournament.groups;
    teams.value = teamList;
    loading.value = false;
}

async function handleAutoDraw() {
    error.value = '';
    message.value = '';
    try {
        await api.post(`/tournaments/${tournamentId}/draw-groups`, { group_count: groupCount.value });
        message.value = 'Undian berhasil.';
        await fetchData();
    } catch (e) {
        error.value = e.response?.data?.message || 'Gagal melakukan undian.';
    }
}

async function handleManualCreate() {
    error.value = '';
    message.value = '';
    try {
        await api.post(`/tournaments/${tournamentId}/groups`, { group_names: groupNames.value });
        message.value = 'Grup berhasil dibuat, silakan atur tim di bawah.';
        await fetchData();
    } catch (e) {
        error.value = e.response?.data?.message || 'Gagal membuat grup.';
    }
}

async function handleAssign(team, groupId) {
    error.value = '';
    try {
        await api.patch(`/teams/${team.id}/assign-group`, {
            group_id: groupId === 'null' || groupId === '' ? null : groupId,
        });
        await fetchData();
    } catch (e) {
        error.value = e.response?.data?.message || 'Gagal mengubah grup tim.';
    }
}

async function handleReset() {
    if (!confirm('Atur ulang semua grup? Semua tim akan kembali belum ditentukan.')) return;
    await api.delete(`/tournaments/${tournamentId}/groups`);
    await fetchData();
}

async function handleLogout() {
    await auth.logout();
    router.push({ name: 'login' });
}

onMounted(fetchData);
</script>

<!-- resources/js/pages/TournamentsIndex.vue -->
<template>
    <div>
        <TopBar show-logout :user-name="auth.user?.name" @logout="handleLogout" />

        <main class="max-w-5xl mx-auto px-4 sm:px-6 py-6 sm:py-10">
            <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 mb-6 sm:mb-8">
                <div>
                    <h1 class="font-display font-bold text-xl sm:text-2xl mb-1">Daftar Turnamen</h1>
                    <p class="text-sm text-pitch-400">{{ tournaments.length }} turnamen terdaftar</p>
                </div>
                <button
                    type="button"
                    @click="openCreateModal"
                    class="text-sm bg-gold-400 text-pitch-950 font-semibold px-4 py-2.5 sm:py-2 rounded-md hover:bg-gold-500 transition w-full sm:w-auto"
                >
                    + Turnamen Baru
                </button>
            </div>

            <div v-if="loading" class="text-pitch-400 text-sm">Memuat...</div>

            <div v-else-if="tournaments.length === 0" class="border border-dashed border-pitch-600 rounded-lg p-8 sm:p-10 text-center">
                <p class="text-pitch-100 font-medium mb-1">Belum ada turnamen</p>
                <p class="text-sm text-pitch-400">Buat turnamen pertama untuk mulai mengatur pertandingan.</p>
            </div>

            <ul v-else class="divide-y divide-pitch-600 border-t border-b border-pitch-600">
                <li v-for="t in tournaments" :key="t.id">
                    <router-link
                        :to="{ name: 'tournaments.show', params: { id: t.id } }"
                        class="flex items-center justify-between gap-3 py-4 px-2 -mx-2 rounded-md hover:bg-pitch-800/60 transition"
                    >
                        <div class="min-w-0">
                            <p class="font-medium truncate">{{ t.name }}</p>
                            <p class="text-xs text-pitch-400 mt-0.5" v-if="t.start_date">
                                {{ formatDate(t.start_date) }} — {{ formatDate(t.end_date) }}
                            </p>
                        </div>
                        <StatusBadge :status="t.status" class="shrink-0" />
                    </router-link>
                </li>
            </ul>
        </main>

        <!-- Modal: Buat Turnamen Baru -->
        <div
            v-if="showModal"
            class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60"
            @click.self="closeModal"
        >
            <div class="bg-pitch-900 border border-pitch-600 rounded-lg w-full max-w-md p-5 sm:p-6">
                <div class="flex items-center justify-between mb-4">
                    <h2 class="font-display font-bold text-lg">Turnamen Baru</h2>
                    <button type="button" @click="closeModal" class="text-pitch-400 hover:text-pitch-100 text-xl leading-none">
                        &times;
                    </button>
                </div>

                <form @submit.prevent="submitCreate" class="space-y-4">
                    <div>
                        <label class="block text-sm text-pitch-300 mb-1">Nama Turnamen *</label>
                        <input
                            v-model="form.name"
                            type="text"
                            class="w-full bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2 text-sm focus:outline-none focus:border-gold-400"
                            placeholder="Contoh: Liga Desa 2026"
                        />
                        <p v-if="errors.name" class="text-xs text-red-400 mt-1">{{ errors.name[0] }}</p>
                    </div>

                    <div>
                        <label class="block text-sm text-pitch-300 mb-1">Deskripsi</label>
                        <textarea
                            v-model="form.description"
                            rows="3"
                            class="w-full bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2 text-sm focus:outline-none focus:border-gold-400"
                        ></textarea>
                        <p v-if="errors.description" class="text-xs text-red-400 mt-1">{{ errors.description[0] }}</p>
                    </div>

                    <div class="grid grid-cols-2 gap-3">
                        <div>
                            <label class="block text-sm text-pitch-300 mb-1">Mulai</label>
                            <input
                                v-model="form.start_date"
                                type="date"
                                class="w-full bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2 text-sm focus:outline-none focus:border-gold-400"
                            />
                            <p v-if="errors.start_date" class="text-xs text-red-400 mt-1">{{ errors.start_date[0] }}</p>
                        </div>
                        <div>
                            <label class="block text-sm text-pitch-300 mb-1">Selesai</label>
                            <input
                                v-model="form.end_date"
                                type="date"
                                class="w-full bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2 text-sm focus:outline-none focus:border-gold-400"
                            />
                            <p v-if="errors.end_date" class="text-xs text-red-400 mt-1">{{ errors.end_date[0] }}</p>
                        </div>
                    </div>

                    <label class="flex items-center gap-2 text-sm text-pitch-300">
                        <input v-model="form.third_place_match" type="checkbox" class="rounded border-pitch-600" />
                        Ada pertandingan perebutan juara 3
                    </label>

                    <p v-if="generalError" class="text-xs text-red-400">{{ generalError }}</p>

                    <div class="flex gap-3 pt-2">
                        <button
                            type="button"
                            @click="closeModal"
                            class="flex-1 text-sm border border-pitch-600 text-pitch-200 font-medium px-4 py-2.5 rounded-md hover:bg-pitch-800 transition"
                        >
                            Batal
                        </button>
                        <button
                            type="submit"
                            :disabled="submitting"
                            class="flex-1 text-sm bg-gold-400 text-pitch-950 font-semibold px-4 py-2.5 rounded-md hover:bg-gold-500 transition disabled:opacity-60"
                        >
                            {{ submitting ? 'Menyimpan...' : 'Simpan' }}
                        </button>
                    </div>
                </form>
            </div>
        </div>
        <Footer />
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import api from '../lib/api';
import TopBar from '../components/TopBar.vue';
import StatusBadge from '../components/StatusBadge.vue';
import Footer from '../components/Footer.vue';

const tournaments = ref([]);
const loading = ref(true);
const router = useRouter();
const auth = useAuthStore();

const showModal = ref(false);
const submitting = ref(false);
const errors = ref({});
const generalError = ref('');

const form = reactive({
    name: '',
    description: '',
    start_date: '',
    end_date: '',
    third_place_match: false,
});

function resetForm() {
    form.name = '';
    form.description = '';
    form.start_date = '';
    form.end_date = '';
    form.third_place_match = false;
    errors.value = {};
    generalError.value = '';
}

function openCreateModal() {
    resetForm();
    showModal.value = true;
}

function closeModal() {
    showModal.value = false;
}

async function submitCreate() {
    submitting.value = true;
    errors.value = {};
    generalError.value = '';

    try {
        const { data } = await api.post('/tournaments', form);
        tournaments.value.unshift(data);
        showModal.value = false;
        router.push({ name: 'tournaments.show', params: { id: data.id } });
    } catch (err) {
        if (err.response?.status === 422) {
            errors.value = err.response.data.errors || {};
        } else {
            generalError.value = 'Gagal membuat turnamen. Coba lagi.';
        }
    } finally {
        submitting.value = false;
    }
}

function formatDate(d) {
    if (!d) return '';
    return new Date(d).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
}

async function handleLogout() {
    await auth.logout();
    router.push({ name: 'login' });
}

onMounted(async () => {
    const { data } = await api.get('/tournaments');
    tournaments.value = data;
    loading.value = false;
});
</script>

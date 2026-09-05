<!-- resources/js/pages/Login.vue -->
<template>
    <div class="min-h-screen flex items-center justify-center px-4 sm:px-6">
        <div class="w-full max-w-sm">
            <div class="mb-6 sm:mb-8 text-center">
                <div class="inline-flex items-center gap-2 mb-3">
                    <span class="w-2 h-2 rounded-full bg-gold-400"></span>
                    <span class="text-xs tracking-wide text-pitch-400">Panel Admin</span>
                </div>
                <h1 class="font-display font-bold text-2xl sm:text-3xl">Turnamen Bola</h1>
            </div>

            <form @submit.prevent="handleLogin" class="border border-dashed border-pitch-600 rounded-lg p-5 sm:p-6 space-y-4 bg-pitch-900/50">
                <div>
                    <label class="block text-sm text-pitch-400 mb-1.5">Email</label>
                    <input
                        v-model="email"
                        type="email"
                        inputmode="email"
                        required
                        class="w-full bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2.5 text-base sm:text-sm text-pitch-100 placeholder-pitch-400 focus:outline-none focus:ring-2 focus:ring-gold-400 focus:border-transparent transition"
                    />
                </div>
                <div>
                    <label class="block text-sm text-pitch-400 mb-1.5">Kata sandi</label>
                    <input
                        v-model="password"
                        type="password"
                        required
                        class="w-full bg-pitch-800 border border-pitch-600 rounded-md px-3 py-2.5 text-base sm:text-sm text-pitch-100 placeholder-pitch-400 focus:outline-none focus:ring-2 focus:ring-gold-400 focus:border-transparent transition"
                    />
                </div>

                <p v-if="error" class="text-sm text-clay-500">{{ error }}</p>

                <button
                    type="submit"
                    :disabled="submitting"
                    class="w-full bg-gold-400 text-pitch-950 font-semibold rounded-md py-2.5 hover:bg-gold-500 transition disabled:opacity-60"
                >
                    {{ submitting ? 'Memproses...' : 'Masuk' }}
                </button>
            </form>
        </div>
        <Footer />
    </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import Footer from '../components/Footer.vue';

const email = ref('');
const password = ref('');
const error = ref('');
const submitting = ref(false);
const router = useRouter();
const auth = useAuthStore();

async function handleLogin() {
    error.value = '';
    submitting.value = true;
    try {
        await auth.login(email.value, password.value);
        router.push({ name: 'tournaments.index' });
    } catch (e) {
        error.value = e.response?.data?.message || 'Email atau kata sandi salah.';
    } finally {
        submitting.value = false;
    }
}
</script>

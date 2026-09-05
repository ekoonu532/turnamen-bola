// resources/js/stores/auth.js
import { defineStore } from 'pinia';
import api from '../lib/api';

export const useAuthStore = defineStore('auth', {
    state: () => ({
        user: null,
        token: localStorage.getItem('token') || null,
    }),

    actions: {
        async login(email, password) {
            const { data } = await api.post('/login', { email, password });
            this.token = data.token;
            this.user = data.user;
            localStorage.setItem('token', data.token);
        },

        async logout() {
            await api.post('/logout');
            this.token = null;
            this.user = null;
            localStorage.removeItem('token');
        },

        async fetchUser() {
            const { data } = await api.get('/me');
            this.user = data;
        },
    },
});

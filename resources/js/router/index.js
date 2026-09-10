// resources/js/router/index.js
import { createRouter, createWebHistory } from 'vue-router';

const routes = [
    // ── Publik (beranda) ──────────────────────────────
    { path: '/', name: 'public.tournaments', component: () => import('../pages/public/TournamentsList.vue') },
    { path: '/turnamen/:slug', name: 'public.tournament', component: () => import('../pages/public/TournamentShow.vue') },
    { path: '/turnamen/:slug/jadwal', name: 'public.matches', component: () => import('../pages/public/Matches.vue') },
    { path: '/turnamen/:slug/klasemen', name: 'public.standings', component: () => import('../pages/public/Standings.vue') },
    { path: '/turnamen/:slug/bracket', name: 'public.bracket', component: () => import('../pages/public/Bracket.vue') },
    // ── Auth ──────────────────────────────────────────
    { path: '/login', name: 'login', component: () => import('../pages/Login.vue') },

    // ── Admin ─────────────────────────────────────────
    {
        path: '/admin',
        name: 'tournaments.index',
        component: () => import('../pages/TournamentsIndex.vue'),
        meta: { requiresAuth: true },
    },
    {
        path: '/admin/tournaments/:id',
        name: 'tournaments.show',
        component: () => import('../pages/TournamentShow.vue'),
        meta: { requiresAuth: true },
    },
    {
        path: '/admin/tournaments/:id/teams',
        name: 'teams.index',
        component: () => import('../pages/TeamsIndex.vue'),
        meta: { requiresAuth: true },
    },
    {
        path: '/admin/tournaments/:id/groups',
        name: 'groups.manage',
        component: () => import('../pages/GroupsManage.vue'),
        meta: { requiresAuth: true },
    },
    {
        path: '/admin/tournaments/:id/matches',
        name: 'matches.index',
        component: () => import('../pages/MatchesIndex.vue'),
        meta: { requiresAuth: true },
    },
    {
        path: '/admin/tournaments/:id/standings',
        name: 'standings.index',
        component: () => import('../pages/StandingsIndex.vue'),
        meta: { requiresAuth: true },
    },
    {
        path: '/admin/tournaments/:id/bracket',
        name: 'bracket.show',
        component: () => import('../pages/BracketShow.vue'),
        meta: { requiresAuth: true },
    },
    {
        path: '/admin/matches/:matchId',
        name: 'matches.show',
        component: () => import('../pages/MatchShow.vue'),
        meta: { requiresAuth: true },
    },
    {
        path: '/admin/tournaments/:id/groups/pengumuman',
        name: 'groups.announcement',
        component: () => import('../pages/GroupAnnouncement.vue'),
        meta: { requiresAuth: true },
    },
    {
        path: '/admin/teams/:teamId/players',
        name: 'players.manage',
        component: () => import('../pages/PlayersManage.vue'),
        meta: { requiresAuth: true },
    },
    {
        path: '/admin/tournaments/:id/top-scorers',
        name: 'topscorers.index',
        component: () => import('../pages/TopScorersIndex.vue'),
        meta: { requiresAuth: true },
    },
    {
        path: '/turnamen/:slug/top-scorer',
        name: 'public.topscorers',
        component: () => import('../pages/public/TopScorers.vue'),
    },
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

router.beforeEach((to) => {
    const token = localStorage.getItem('token');
    if (to.meta.requiresAuth && !token) {
        return { name: 'login' };
    }
});

export default router;

--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5
-- Dumped by pg_dump version 14.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cache; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cache (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    expiration integer NOT NULL
);


ALTER TABLE public.cache OWNER TO postgres;

--
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cache_locks (
    key character varying(255) NOT NULL,
    owner character varying(255) NOT NULL,
    expiration integer NOT NULL
);


ALTER TABLE public.cache_locks OWNER TO postgres;

--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.failed_jobs OWNER TO postgres;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.failed_jobs_id_seq OWNER TO postgres;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: job_batches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


ALTER TABLE public.job_batches OWNER TO postgres;

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


ALTER TABLE public.jobs OWNER TO postgres;

--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jobs_id_seq OWNER TO postgres;

--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: matches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.matches (
    id bigint NOT NULL,
    tournament_id bigint NOT NULL,
    group_id bigint,
    stage character varying(255) DEFAULT 'group'::character varying NOT NULL,
    home_team_id bigint,
    away_team_id bigint,
    venue character varying(255),
    scheduled_at timestamp(0) without time zone,
    home_score integer,
    away_score integer,
    winner_team_id bigint,
    status character varying(255) DEFAULT 'scheduled'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    home_penalty integer,
    away_penalty integer,
    CONSTRAINT matches_stage_check CHECK (((stage)::text = ANY ((ARRAY['group'::character varying, 'semifinal'::character varying, 'final'::character varying, 'third_place'::character varying])::text[]))),
    CONSTRAINT matches_status_check CHECK (((status)::text = ANY ((ARRAY['scheduled'::character varying, 'live'::character varying, 'finished'::character varying, 'postponed'::character varying, 'walkover'::character varying])::text[])))
);


ALTER TABLE public.matches OWNER TO postgres;

--
-- Name: matches_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.matches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.matches_id_seq OWNER TO postgres;

--
-- Name: matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.matches_id_seq OWNED BY public.matches.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE public.password_reset_tokens OWNER TO postgres;

--
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name text NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.personal_access_tokens OWNER TO postgres;

--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.personal_access_tokens_id_seq OWNER TO postgres;

--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- Name: players; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.players OWNER TO postgres;

--
-- Name: players_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.players_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.players_id_seq OWNER TO postgres;

--
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.players_id_seq OWNED BY public.players.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: standings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.standings (
    id bigint NOT NULL,
    tournament_id bigint NOT NULL,
    group_id bigint NOT NULL,
    team_id bigint NOT NULL,
    played integer DEFAULT 0 NOT NULL,
    won integer DEFAULT 0 NOT NULL,
    drawn integer DEFAULT 0 NOT NULL,
    lost integer DEFAULT 0 NOT NULL,
    goals_for integer DEFAULT 0 NOT NULL,
    goals_against integer DEFAULT 0 NOT NULL,
    goal_diff integer DEFAULT 0 NOT NULL,
    points integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.standings OWNER TO postgres;

--
-- Name: standings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.standings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.standings_id_seq OWNER TO postgres;

--
-- Name: standings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.standings_id_seq OWNED BY public.standings.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teams (
    id bigint NOT NULL,
    tournament_id bigint NOT NULL,
    group_id bigint,
    name character varying(255) NOT NULL,
    logo_url character varying(255),
    contact_person character varying(255),
    phone character varying(255),
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT teams_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'verified'::character varying, 'rejected'::character varying, 'withdrawn'::character varying])::text[])))
);


ALTER TABLE public.teams OWNER TO postgres;

--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.teams_id_seq OWNER TO postgres;

--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: tournament_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_groups (
    id bigint NOT NULL,
    tournament_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.tournament_groups OWNER TO postgres;

--
-- Name: tournament_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tournament_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tournament_groups_id_seq OWNER TO postgres;

--
-- Name: tournament_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tournament_groups_id_seq OWNED BY public.tournament_groups.id;


--
-- Name: tournaments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournaments (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    start_date date,
    end_date date,
    status character varying(255) DEFAULT 'draft'::character varying NOT NULL,
    third_place_match boolean DEFAULT false NOT NULL,
    created_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    is_featured boolean DEFAULT false NOT NULL,
    CONSTRAINT tournaments_status_check CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'registration'::character varying, 'ongoing'::character varying, 'finished'::character varying])::text[])))
);


ALTER TABLE public.tournaments OWNER TO postgres;

--
-- Name: tournaments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tournaments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tournaments_id_seq OWNER TO postgres;

--
-- Name: tournaments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tournaments_id_seq OWNED BY public.tournaments.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    role character varying(255) DEFAULT 'admin'::character varying NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['super_admin'::character varying, 'admin'::character varying, 'operator'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: matches id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches ALTER COLUMN id SET DEFAULT nextval('public.matches_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- Name: players id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players ALTER COLUMN id SET DEFAULT nextval('public.players_id_seq'::regclass);


--
-- Name: standings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.standings ALTER COLUMN id SET DEFAULT nextval('public.standings_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: tournament_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_groups ALTER COLUMN id SET DEFAULT nextval('public.tournament_groups_id_seq'::regclass);


--
-- Name: tournaments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournaments ALTER COLUMN id SET DEFAULT nextval('public.tournaments_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cache (key, value, expiration) FROM stdin;
laravel-cache-5c785c036466adea360111aa28563bfd556b5fba:timer	i:1788576576;	1788576576
laravel-cache-5c785c036466adea360111aa28563bfd556b5fba	i:2;	1788576576
\.


--
-- Data for Name: cache_locks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cache_locks (key, owner, expiration) FROM stdin;
\.


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
\.


--
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_batches (id, name, total_jobs, pending_jobs, failed_jobs, failed_job_ids, options, cancelled_at, created_at, finished_at) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jobs (id, queue, payload, attempts, reserved_at, available_at, created_at) FROM stdin;
\.


--
-- Data for Name: matches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.matches (id, tournament_id, group_id, stage, home_team_id, away_team_id, venue, scheduled_at, home_score, away_score, winner_team_id, status, created_at, updated_at, home_penalty, away_penalty) FROM stdin;
73	1	7	group	8	6	\N	2026-09-11 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
74	1	7	group	3	5	\N	2026-09-12 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
75	1	8	group	7	4	\N	2026-09-13 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
76	1	8	group	2	1	\N	2026-09-14 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
77	1	7	group	8	5	\N	2026-09-15 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
78	1	7	group	6	3	\N	2026-09-16 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
79	1	8	group	7	1	\N	2026-09-17 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
80	1	8	group	4	2	\N	2026-09-18 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
81	1	7	group	8	3	\N	2026-09-19 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
82	1	7	group	5	6	\N	2026-09-20 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
83	1	8	group	7	2	\N	2026-09-21 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
84	1	8	group	1	4	\N	2026-09-22 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
85	1	\N	semifinal	\N	\N	\N	2026-09-24 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
86	1	\N	semifinal	\N	\N	\N	2026-09-25 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
87	1	\N	third_place	\N	\N	\N	2026-09-27 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
88	1	\N	final	\N	\N	\N	2026-09-28 16:00:00	\N	\N	\N	scheduled	2026-09-05 10:35:53	2026-09-05 10:35:53	\N	\N
89	2	11	group	9	14	\N	2026-09-11 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
90	2	11	group	10	11	\N	2026-09-12 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
91	2	12	group	13	16	\N	2026-09-13 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
92	2	12	group	12	15	\N	2026-09-14 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
93	2	11	group	9	11	\N	2026-09-15 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
94	2	11	group	14	10	\N	2026-09-16 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
95	2	12	group	13	15	\N	2026-09-17 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
96	2	12	group	16	12	\N	2026-09-18 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
97	2	11	group	9	10	\N	2026-09-19 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
98	2	11	group	11	14	\N	2026-09-20 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
99	2	12	group	13	12	\N	2026-09-21 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
100	2	12	group	15	16	\N	2026-09-22 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
101	2	\N	semifinal	\N	\N	\N	2026-09-24 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
102	2	\N	semifinal	\N	\N	\N	2026-09-25 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
103	2	\N	third_place	\N	\N	\N	2026-09-27 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
104	2	\N	final	\N	\N	\N	2026-09-28 16:00:00	\N	\N	\N	scheduled	2026-09-05 15:28:50	2026-09-05 15:28:50	\N	\N
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	0001_01_01_000000_create_users_table	1
2	0001_01_01_000001_create_cache_table	1
3	0001_01_01_000002_create_jobs_table	1
4	2026_09_04_081726_create_personal_access_tokens_table	1
5	2026_09_04_092012_create_tournaments_table	1
6	2026_09_04_092015_create_tournament_groups_table	1
7	2026_09_04_092017_create_teams_table	1
8	2026_09_04_092019_create_players_table	1
9	2026_09_04_092022_create_match_games_table	1
10	2026_09_04_092244_create_standings_table	1
11	2026_09_04_092340_add_role_to_users_table	1
12	2026_09_04_105300_add_walkover_status_to_matches_table	1
13	2026_09_04_105403_add_withdrawn_status_to_teams_table	1
14	2026_09_04_221400_add_penalty_columns_to_matches_table	1
15	2026_09_04_224235_add_is_featured_to_tournaments_table	1
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_tokens (email, token, created_at) FROM stdin;
\.


--
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, expires_at, created_at, updated_at) FROM stdin;
4	App\\Models\\User	1	admin-token	d9f93141902f762300aa5e5500de47925e856cd57de35098f7910ec50d11c693	["*"]	2026-09-05 21:35:56	\N	2026-09-05 02:48:46	2026-09-05 21:35:56
\.


--
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.players (id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (id, user_id, ip_address, user_agent, payload, last_activity) FROM stdin;
QjtlLKmHtCEBVwZCTvIu2ypa9TTWOUy0qlCnvgje	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36	YTozOntzOjY6Il90b2tlbiI7czo0MDoiOFRPNTdMQjE1NzAxVmczdmNqTWk4S1IxbnFKd0o2MkU0ajNzUzNjOCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NDU6Imh0dHA6Ly90dXJuYW1lbi1ib2xhLnRlc3QvYWRtaW4vdG91cm5hbWVudHMvMSI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1788580543
AZdKoKFs8QREFF5Fe6F1CS01DrNAcThq06i3Y2Ks	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36	YTozOntzOjY6Il90b2tlbiI7czo0MDoibUxVSjI4a00ybWtDemtUbXVzUHEzOWVtTVEwQUdUOWZIdmRpYjdVcyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NjU6Imh0dHA6Ly80MGZlLTIwMDEtNDQ4YS00MDkwLTg3Zi0xOWFmLTQ3NTItNDU4Ni0zYTE1Lm5ncm9rLWZyZWUuYXBwIjtzOjU6InJvdXRlIjtOO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19	1788584828
ebRauDfW487gJZw7xqPflS1QjkuVcZ9o3RkLxuZV	\N	127.0.0.1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36	YTozOntzOjY6Il90b2tlbiI7czo0MDoiY0ZYcXVPVUh3bUZtSXlaY2JRcFFIUlZseU91YjB6dnRoNzFPN0VXZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NzE6Imh0dHA6Ly80MGZlLTIwMDEtNDQ4YS00MDkwLTg3Zi0xOWFmLTQ3NTItNDU4Ni0zYTE1Lm5ncm9rLWZyZWUuYXBwL2xvZ2luIjtzOjU6InJvdXRlIjtOO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19	1788591294
xpY8z0E7r6k4dL4JYRGerl3lwhiVjMHZJ5p0dZAF	\N	127.0.0.1	Mozilla/5.0 (Linux; U; Android 4.3; en-us; SM-N900T Build/JSS15J) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30	YTozOntzOjY6Il90b2tlbiI7czo0MDoia2hDSDZOQ2FoUXd0alFpQ2dacUN3clE1RjZPQWlsYlZnZHVsRXB2VyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NjM6Imh0dHA6Ly90dXJuYW1lbi1ib2xhLnRlc3QvYWRtaW4vdG91cm5hbWVudHMvMi9ncm91cHMvcGVuZ3VtdW1hbiI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1788597673
XmR9mxTYmmVGAwKrctjQPu4yfxZiPLJPK2iOxHy1	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36	YTozOntzOjY6Il90b2tlbiI7czo0MDoiaW1uaWdZbFVBUUhIZzJEdmRSY1pSRWFZYjVnVzEyYWhRejdQQ004SCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTM6Imh0dHA6Ly90dXJuYW1lbi1ib2xhLnRlc3QvYWRtaW4vdG91cm5hbWVudHMvMi9tYXRjaGVzIjtzOjU6InJvdXRlIjtOO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19	1788606611
3wtSdGjnNRgpAgeNLEN1VeAx6T76lujgCEaNwGFc	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36	YTozOntzOjY6Il90b2tlbiI7czo0MDoiTnl0RjFaeVJER1M1aE5wV2h3UE9WTHlObDR1Tm1BY2M3ckpKcmxjYSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTU6Imh0dHA6Ly90dXJuYW1lbi1ib2xhLnRlc3QvYWRtaW4vdG91cm5hbWVudHMvMi9zdGFuZGluZ3MiO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1788618952
\.


--
-- Data for Name: standings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.standings (id, tournament_id, group_id, team_id, played, won, drawn, lost, goals_for, goals_against, goal_diff, points, created_at, updated_at) FROM stdin;
1	1	7	8	1	0	1	0	1	1	0	1	2026-09-05 02:26:55	2026-09-05 02:26:55
2	1	7	3	0	0	0	0	0	0	0	0	2026-09-05 02:26:55	2026-09-05 02:26:55
3	1	7	5	0	0	0	0	0	0	0	0	2026-09-05 02:26:55	2026-09-05 02:26:55
4	1	7	6	1	0	1	0	1	1	0	1	2026-09-05 02:26:55	2026-09-05 02:26:55
5	1	8	7	0	0	0	0	0	0	0	0	2026-09-05 02:42:06	2026-09-05 02:42:06
6	1	8	2	0	0	0	0	0	0	0	0	2026-09-05 02:42:06	2026-09-05 02:42:06
7	1	8	1	0	0	0	0	0	0	0	0	2026-09-05 02:42:06	2026-09-05 02:42:06
8	1	8	4	0	0	0	0	0	0	0	0	2026-09-05 02:42:06	2026-09-05 02:42:06
9	2	11	9	0	0	0	0	0	0	0	0	2026-09-05 15:26:30	2026-09-05 15:26:30
10	2	11	10	0	0	0	0	0	0	0	0	2026-09-05 15:26:30	2026-09-05 15:26:30
11	2	11	11	0	0	0	0	0	0	0	0	2026-09-05 15:26:30	2026-09-05 15:26:30
12	2	11	14	0	0	0	0	0	0	0	0	2026-09-05 15:26:30	2026-09-05 15:26:30
13	2	12	13	0	0	0	0	0	0	0	0	2026-09-05 15:26:31	2026-09-05 15:26:31
14	2	12	12	0	0	0	0	0	0	0	0	2026-09-05 15:26:31	2026-09-05 15:26:31
15	2	12	15	0	0	0	0	0	0	0	0	2026-09-05 15:26:31	2026-09-05 15:26:31
16	2	12	16	0	0	0	0	0	0	0	0	2026-09-05 15:26:31	2026-09-05 15:26:31
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teams (id, tournament_id, group_id, name, logo_url, contact_person, phone, status, created_at, updated_at) FROM stdin;
9	2	11	KEPETEK FC	\N	\N	\N	pending	2026-09-05 15:22:06	2026-09-05 15:25:04
10	2	11	BIMA JAYA FC	\N	\N	\N	pending	2026-09-05 15:22:18	2026-09-05 15:25:13
11	2	11	FOSIL FC	\N	\N	\N	pending	2026-09-05 15:22:33	2026-09-05 15:25:22
14	2	11	BELIK LEGEND	\N	\N	\N	pending	2026-09-05 15:23:25	2026-09-05 15:25:34
13	2	12	TUNAS MUDA FC	\N	\N	\N	pending	2026-09-05 15:22:52	2026-09-05 15:25:48
12	2	12	BUDI LUHUR FC	\N	\N	\N	pending	2026-09-05 15:22:41	2026-09-05 15:25:55
15	2	12	BLIZZER FC	\N	\N	\N	pending	2026-09-05 15:23:32	2026-09-05 15:26:02
16	2	12	SEDULURAN FC	\N	\N	\N	pending	2026-09-05 15:23:41	2026-09-05 15:26:08
8	1	7	ALCANTARA FC	\N	\N	\N	pending	2026-09-05 01:33:40	2026-09-05 01:34:59
3	1	7	BUDI LUHUR FC	\N	\N	\N	pending	2026-09-05 01:32:37	2026-09-05 01:34:59
5	1	7	FOSIL FC	\N	\N	\N	pending	2026-09-05 01:33:02	2026-09-05 01:34:59
6	1	7	BLIZZER FC	\N	\N	\N	pending	2026-09-05 01:33:12	2026-09-05 01:34:59
7	1	8	TUNAS MUDA FC	\N	\N	\N	pending	2026-09-05 01:33:26	2026-09-05 01:34:59
2	1	8	SEDULURAN FC	\N	\N	\N	pending	2026-09-05 01:32:20	2026-09-05 01:34:59
1	1	8	KEPETEK FC	\N	\N	\N	pending	2026-09-05 01:32:07	2026-09-05 01:34:59
4	1	8	BELIK LEGEND FC	\N	\N	\N	pending	2026-09-05 01:32:48	2026-09-05 01:34:59
\.


--
-- Data for Name: tournament_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournament_groups (id, tournament_id, name, created_at, updated_at) FROM stdin;
7	1	Grup A	2026-09-05 01:34:59	2026-09-05 01:34:59
8	1	Grup B	2026-09-05 01:34:59	2026-09-05 01:34:59
11	2	Grup A	2026-09-05 15:24:57	2026-09-05 15:24:57
12	2	Grup B	2026-09-05 15:24:57	2026-09-05 15:24:57
\.


--
-- Data for Name: tournaments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournaments (id, name, description, start_date, end_date, status, third_place_match, created_by, created_at, updated_at, is_featured) FROM stdin;
1	Dhederan Cup 2026	-	2026-09-11	2026-09-28	ongoing	t	1	2026-09-05 01:31:49	2026-09-05 10:36:39	t
2	Dhederan Cup Tournament 2026	\N	2026-09-11	2026-09-28	draft	t	1	2026-09-05 15:21:52	2026-09-05 15:21:52	f
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, email_verified_at, password, remember_token, created_at, updated_at, role) FROM stdin;
1	Admin	admin@turnamen.test	\N	$2y$12$0AXyR/vSvrbe3qMykib9Ge5ymDqVxNMXPb8irOiKIGCY8NmlC9EHO	\N	2026-09-05 01:19:15	2026-09-05 01:19:15	super_admin
\.


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.jobs_id_seq', 1, false);


--
-- Name: matches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.matches_id_seq', 104, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migrations_id_seq', 15, true);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 4, true);


--
-- Name: players_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.players_id_seq', 1, false);


--
-- Name: standings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.standings_id_seq', 16, true);


--
-- Name: teams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teams_id_seq', 16, true);


--
-- Name: tournament_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tournament_groups_id_seq', 12, true);


--
-- Name: tournaments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tournaments_id_seq', 2, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: cache_locks cache_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cache_locks
    ADD CONSTRAINT cache_locks_pkey PRIMARY KEY (key);


--
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (key);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: matches matches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: standings standings_group_id_team_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.standings
    ADD CONSTRAINT standings_group_id_team_id_unique UNIQUE (group_id, team_id);


--
-- Name: standings standings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.standings
    ADD CONSTRAINT standings_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: tournament_groups tournament_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_groups
    ADD CONSTRAINT tournament_groups_pkey PRIMARY KEY (id);


--
-- Name: tournaments tournaments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: cache_expiration_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cache_expiration_index ON public.cache USING btree (expiration);


--
-- Name: cache_locks_expiration_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cache_locks_expiration_index ON public.cache_locks USING btree (expiration);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: personal_access_tokens_expires_at_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX personal_access_tokens_expires_at_index ON public.personal_access_tokens USING btree (expires_at);


--
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);


--
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);


--
-- Name: matches matches_away_team_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_away_team_id_foreign FOREIGN KEY (away_team_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- Name: matches matches_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_group_id_foreign FOREIGN KEY (group_id) REFERENCES public.tournament_groups(id) ON DELETE SET NULL;


--
-- Name: matches matches_home_team_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_home_team_id_foreign FOREIGN KEY (home_team_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- Name: matches matches_tournament_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_tournament_id_foreign FOREIGN KEY (tournament_id) REFERENCES public.tournaments(id) ON DELETE CASCADE;


--
-- Name: matches matches_winner_team_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_winner_team_id_foreign FOREIGN KEY (winner_team_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- Name: standings standings_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.standings
    ADD CONSTRAINT standings_group_id_foreign FOREIGN KEY (group_id) REFERENCES public.tournament_groups(id) ON DELETE CASCADE;


--
-- Name: standings standings_team_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.standings
    ADD CONSTRAINT standings_team_id_foreign FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: standings standings_tournament_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.standings
    ADD CONSTRAINT standings_tournament_id_foreign FOREIGN KEY (tournament_id) REFERENCES public.tournaments(id) ON DELETE CASCADE;


--
-- Name: teams teams_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_group_id_foreign FOREIGN KEY (group_id) REFERENCES public.tournament_groups(id) ON DELETE SET NULL;


--
-- Name: teams teams_tournament_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_tournament_id_foreign FOREIGN KEY (tournament_id) REFERENCES public.tournaments(id) ON DELETE CASCADE;


--
-- Name: tournament_groups tournament_groups_tournament_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_groups
    ADD CONSTRAINT tournament_groups_tournament_id_foreign FOREIGN KEY (tournament_id) REFERENCES public.tournaments(id) ON DELETE CASCADE;


--
-- Name: tournaments tournaments_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--


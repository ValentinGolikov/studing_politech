--
-- PostgreSQL database dump
--

\restrict EResEZzDgNf91WEXhEB36jkAPTzIbo5dv3DqOzr1F8U2mwFZTcX4sHUYPY6ahqz

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
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
-- Name: auto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auto (
    id integer NOT NULL,
    num character varying(20),
    color character varying(20),
    mark character varying(20),
    personal_id integer
);


ALTER TABLE public.auto OWNER TO postgres;

--
-- Name: auto_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auto ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.auto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auto_personal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auto_personal (
    id integer NOT NULL,
    first_name character varying(20),
    last_name character varying(20),
    father_name character varying(20)
);


ALTER TABLE public.auto_personal OWNER TO postgres;

--
-- Name: auto_personal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auto_personal ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.auto_personal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: journal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.journal (
    id integer NOT NULL,
    time_out timestamp without time zone,
    time_in timestamp without time zone,
    auto_id integer,
    route_id integer
);


ALTER TABLE public.journal OWNER TO postgres;

--
-- Name: journal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.journal ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.journal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: routes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.routes (
    id integer NOT NULL,
    name character varying(20)
);


ALTER TABLE public.routes OWNER TO postgres;

--
-- Name: routes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.routes ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.routes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: auto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auto (id, num, color, mark, personal_id) FROM stdin;
4	р789уд_98	серая	Volkswagen	4
1	А749ПБ_178	желтая	fiat	5
2	А777УФ_42	красная	ВАЗ2107	5
5	м912рв_78	зеленая	Opel	2
3	р538нв_98	зеленая	BMW	3
\.


--
-- Data for Name: auto_personal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auto_personal (id, first_name, last_name, father_name) FROM stdin;
1	Раиль	Рамзанов	Романович
2	Кирилл	Байкин	Александрович
3	Полина	Пупина	Олеговна
4	Анастасия	Плужник	Дмитриевна
5	Иван	Губанов	Андреевич
\.


--
-- Data for Name: journal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.journal (id, time_out, time_in, auto_id, route_id) FROM stdin;
4	2025-09-18 12:07:13.890302	2025-09-18 12:13:01.054242	2	6
5	2025-09-18 12:15:52.404815	\N	2	6
3	2025-09-18 11:50:25.338905	2025-09-25 11:05:48.916437	4	6
6	2025-09-25 10:46:31.194291	2025-09-25 11:06:52.946998	3	7
7	2025-09-25 11:20:53.76321	2025-09-25 11:21:12.85478	1	5
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.routes (id, name) FROM stdin;
4	Северный путь
5	Южный путь
6	СПб-Москва
7	Мурманск-СПб
\.


--
-- Name: auto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auto_id_seq', 6, true);


--
-- Name: auto_personal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auto_personal_id_seq', 5, true);


--
-- Name: journal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.journal_id_seq', 7, true);


--
-- Name: routes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.routes_id_seq', 7, true);


--
-- Name: auto_personal auto_personal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auto_personal
    ADD CONSTRAINT auto_personal_pkey PRIMARY KEY (id);


--
-- Name: auto auto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auto
    ADD CONSTRAINT auto_pkey PRIMARY KEY (id);


--
-- Name: journal journal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal
    ADD CONSTRAINT journal_pkey PRIMARY KEY (id);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: auto fk_auto_auto_personal; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auto
    ADD CONSTRAINT fk_auto_auto_personal FOREIGN KEY (personal_id) REFERENCES public.auto_personal(id) ON DELETE CASCADE;


--
-- Name: journal fk_journal_auto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal
    ADD CONSTRAINT fk_journal_auto FOREIGN KEY (auto_id) REFERENCES public.auto(id) ON DELETE CASCADE;


--
-- Name: journal fk_journal_routes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal
    ADD CONSTRAINT fk_journal_routes FOREIGN KEY (route_id) REFERENCES public.routes(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict EResEZzDgNf91WEXhEB36jkAPTzIbo5dv3DqOzr1F8U2mwFZTcX4sHUYPY6ahqz


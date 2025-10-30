--
-- PostgreSQL database dump
--

\restrict uKBEZcmggr4GvjI6UCi42MmwBRvSfxVyMOu6W55JvAwT5LQ2Gr2XkjGxBhGJ6Rc

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

--
-- Name: calculate_bonuses(date, date, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_bonuses(start_date date, end_date date, total_bonus_amount numeric) RETURNS TABLE(driver_id integer, driver_name text, record_routes_count integer, bonus_amount numeric)
    LANGUAGE plpgsql
    AS $$DECLARE
    driver_rec RECORD;
    top1_id INTEGER := NULL;
    top2_id INTEGER := NULL;
    top3_id INTEGER := NULL;
    top1_count INTEGER := 0;
    top2_count INTEGER := 0;
    top3_count INTEGER := 0;
    current_count INTEGER;
BEGIN
    FOR driver_rec IN (
        SELECT 
            ap.id as driver_id,
            ap.first_name || ' ' || ap.last_name || ' ' || ap.father_name as driver_name,
            COUNT(DISTINCT r.id) as record_routes_count
        FROM auto_personal ap
        JOIN auto a ON ap.id = a.personal_id
        JOIN journal j ON a.id = j.auto_id
        JOIN routes r ON j.route_id = r.id
        WHERE j.time_out BETWEEN start_date AND end_date
          AND j.time_in IS NOT NULL
          AND j.time_in > j.time_out
		  --проверка на рекорд
          AND (j.auto_id, j.route_id, (j.time_in - j.time_out)) IN (
              SELECT j2.auto_id, j2.route_id, MIN(j2.time_in - j2.time_out)
              FROM journal j2
              WHERE j2.time_out BETWEEN start_date AND end_date
                AND j2.time_in IS NOT NULL
                AND j2.time_in > j2.time_out
                AND j2.route_id = j.route_id
              GROUP BY j2.route_id, j2.auto_id
          )
        GROUP BY ap.id, ap.first_name, ap.last_name, ap.father_name
        ORDER BY record_routes_count DESC
    )
    LOOP
        current_count := driver_rec.record_routes_count;
        
        IF current_count > top1_count THEN
            top3_id := top2_id;
            top3_count := top2_count;
            top2_id := top1_id;
            top2_count := top1_count;
            top1_id := driver_rec.driver_id;
            top1_count := current_count;
        ELSIF current_count > top2_count THEN
            top3_id := top2_id;
            top3_count := top2_count;
            top2_id := driver_rec.driver_id;
            top2_count := current_count;
        ELSIF current_count > top3_count THEN
            top3_id := driver_rec.driver_id;
            top3_count := current_count;
        END IF;
    END LOOP;

    IF top1_id IS NOT NULL THEN
        driver_id := top1_id;
        SELECT first_name || ' ' || last_name || ' ' || father_name 
        INTO driver_name 
        FROM auto_personal 
        WHERE id = top1_id;
        record_routes_count := top1_count;
        bonus_amount := total_bonus_amount * 0.5;
        RETURN NEXT;
    END IF;

    IF top2_id IS NOT NULL THEN
        driver_id := top2_id;
        SELECT first_name || ' ' || last_name || ' ' || father_name 
        INTO driver_name 
        FROM auto_personal
        WHERE id = top2_id;
        record_routes_count := top2_count;
        bonus_amount := total_bonus_amount * 0.3;
        RETURN NEXT;
    END IF;

    IF top3_id IS NOT NULL THEN
        driver_id := top3_id;
        SELECT first_name || ' ' || last_name || ' ' || father_name 
        INTO driver_name 
        FROM auto_personal
        WHERE id = top3_id;
        record_routes_count := top3_count;
        bonus_amount := total_bonus_amount * 0.2;
        RETURN NEXT;
    END IF;
END;$$;


ALTER FUNCTION public.calculate_bonuses(start_date date, end_date date, total_bonus_amount numeric) OWNER TO postgres;

--
-- Name: check_car_available(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_car_available() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM journal 
        WHERE auto_id = NEW.auto_id 
          AND time_in IS NULL
          AND (TG_OP = 'INSERT' OR id != COALESCE(NEW.id, -1))
    ) THEN
        RAISE EXCEPTION 'Car with ID % is still on route and cannot be dispatched again', NEW.auto_id;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_car_available() OWNER TO postgres;

--
-- Name: check_last_record(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_last_record() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	records_count INTEGER;
BEGIN
	SELECT COUNT(*) INTO records_count FROM journal;
	IF records_count = 1 THEN
		RAISE EXCEPTION 'Can not delete record: it is last';
	END IF;
	RETURN OLD;
END;
$$;


ALTER FUNCTION public.check_last_record() OWNER TO postgres;

--
-- Name: compare_cars_time(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.compare_cars_time(IN car1_id integer, IN car2_id integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    compare_record RECORD;
    car1_num TEXT;
    car2_num TEXT;
    routes_count INTEGER := 0;
BEGIN
    -- Получаем номера автомобилей для красивого вывода
    SELECT num INTO car1_num FROM auto WHERE id = car1_id;
    SELECT num INTO car2_num FROM auto WHERE id = car2_id;
    
    -- Заголовок
    RAISE NOTICE 'Авто 1 (ID:%): %', car1_id, COALESCE(car1_num, 'не найден');
    RAISE NOTICE 'Авто 2 (ID:%): %', car2_id, COALESCE(car2_num, 'не найден');
    RAISE NOTICE '%', FORMAT('%-6s | %-25s | %-15s | %-15s', 'ID', 'Маршрут', 'Авто1 время', 'Авто2 время');
    
    -- Обрабатываем результаты сравнения
    FOR compare_record IN 
        SELECT 
            r.id,
            r.name,
            MIN(CASE WHEN j1.auto_id = car1_id THEN j1.time_in - j1.time_out END) AS car1_time,
            MIN(CASE WHEN j2.auto_id = car2_id THEN j2.time_in - j2.time_out END) AS car2_time
        FROM routes r
        JOIN journal j1 ON r.id = j1.route_id AND j1.auto_id = car1_id AND j1.time_in IS NOT NULL
        JOIN journal j2 ON r.id = j2.route_id AND j2.auto_id = car2_id AND j2.time_in IS NOT NULL
        GROUP BY r.id, r.name
        HAVING MIN(CASE WHEN j1.auto_id = car1_id THEN j1.time_in - j1.time_out END) < 
               MIN(CASE WHEN j2.auto_id = car2_id THEN j2.time_in - j2.time_out END)
    LOOP
        -- Вывод данных о маршруте
        RAISE NOTICE '%', FORMAT('%-6s | %-25s | %-15s | %-15s', 
            compare_record.id,
            compare_record.name,
            date_trunc('second', compare_record.car1_time),
            date_trunc('second', compare_record.car2_time));
        
        routes_count := routes_count + 1;
    END LOOP;
END;
$$;


ALTER PROCEDURE public.compare_cars_time(IN car1_id integer, IN car2_id integer) OWNER TO postgres;

--
-- Name: get_route_record(text); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.get_route_record(IN route_name text, OUT min_time interval, OUT record_car_num text)
    LANGUAGE plpgsql
    AS $$BEGIN
    SELECT 
        MIN(j.time_in - j.time_out),
        a.num
    INTO 
        min_time,
        record_car_num
    FROM journal j
    JOIN routes r ON j.route_id = r.id
    JOIN auto a ON j.auto_id = a.id
    WHERE r.name = route_name
        AND j.time_in IS NOT NULL
        AND j.time_out IS NOT NULL
        AND j.time_in > j.time_out
    GROUP BY r.id, a.id, a.num
    ORDER BY MIN(j.time_in - j.time_out)
    LIMIT 1;
    
    IF min_time IS NULL THEN
        min_time := '0'::INTERVAL;
        record_car_num := 'Нет данных';
    END IF;
END;
$$;


ALTER PROCEDURE public.get_route_record(IN route_name text, OUT min_time interval, OUT record_car_num text) OWNER TO postgres;

--
-- Name: get_routes_avg_time(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.get_routes_avg_time()
    LANGUAGE plpgsql
    AS $$
DECLARE
    route_record RECORD;
BEGIN
    RAISE NOTICE '% | % | %', ' ID ', '   Маршрут  ', ' Ср. время (мин) ';
    
    FOR route_record IN 
        SELECT 
            r.id,
            r.name,
            ROUND(AVG(EXTRACT(EPOCH FROM (j.time_in - j.time_out))/60)::NUMERIC, 2) AS avg_minutes
        FROM routes r
        JOIN journal j ON r.id = j.route_id
        WHERE j.time_in IS NOT NULL
            AND j.time_out IS NOT NULL
        GROUP BY r.id, r.name
        ORDER BY avg_minutes
    LOOP
        RAISE NOTICE '%', FORMAT(' %-3s | %-12s | %-10s',
            route_record.id, 
            route_record.name, 
            route_record.avg_minutes);
    END LOOP;
END;
$$;


ALTER PROCEDURE public.get_routes_avg_time() OWNER TO postgres;

--
-- Name: prevent_personal_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevent_personal_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM auto 
        WHERE personal_id = OLD.id
    ) THEN
        RAISE EXCEPTION 'Can not delete driver ID %', OLD.id;
    END IF;
    
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.prevent_personal_delete() OWNER TO postgres;

--
-- Name: protect_route_history(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.protect_route_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_route_id INTEGER;
BEGIN
    IF EXISTS (SELECT 1 FROM journal WHERE route_id = OLD.id) THEN
        INSERT INTO routes (name) 
        VALUES (OLD.name)
        RETURNING id INTO new_route_id;
        
        UPDATE journal 
        SET route_id = new_route_id 
        WHERE route_id = OLD.id;
    END IF;

	RAISE NOTICE 'route % was changed', OLD.id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.protect_route_history() OWNER TO postgres;

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
-- Name: drivers; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.drivers AS
 SELECT id,
    first_name,
    last_name,
    father_name
   FROM public.auto_personal;


ALTER VIEW public.drivers OWNER TO postgres;

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
-- Name: on_route; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.on_route AS
 SELECT routes.id,
    routes.name,
    count(DISTINCT journal.auto_id) AS count
   FROM (public.routes
     LEFT JOIN public.journal ON (((routes.id = journal.route_id) AND (journal.time_in IS NULL))))
  GROUP BY routes.id, routes.name;


ALTER VIEW public.on_route OWNER TO postgres;

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
2	А777УФ_42	красная	ВАЗ2107	5
5	м912рв_78	зеленая	Opel	2
3	р538нв_98	зеленая	BMW	3
1	А749ПБ_178	желтая	fiat	5
11	А132БВ_178	Красный	Газель	10
12	У478АР_178	Синий	Форд	11
13	С788ДД_198	Зеленый	Мерседес	12
14	П601РС_777	Желтый	Газель	13
\.


--
-- Data for Name: auto_personal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auto_personal (id, first_name, last_name, father_name) FROM stdin;
2	Кирилл	Байкин	Александрович
3	Полина	Пупина	Олеговна
4	Анастасия	Плужник	Дмитриевна
5	Иван	Губанов	Андреевич
10	Иван	Петров	Сергеевич
11	Мария	Сидорова	Ивановна
12	Алексей	Иванов	Петрович
13	Ольга	Кузнецова	Павловна
\.


--
-- Data for Name: journal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.journal (id, time_out, time_in, auto_id, route_id) FROM stdin;
4	2025-09-18 12:07:13.890302	2025-09-18 12:13:01.054242	2	6
3	2025-09-18 11:50:25.338905	2025-09-25 11:05:48.916437	4	6
6	2025-09-25 10:46:31.194291	2025-09-25 11:06:52.946998	3	7
7	2025-09-25 11:20:53.76321	2025-09-25 11:21:12.85478	1	5
5	2025-10-27 21:30:00	2025-10-29 06:30:00	2	5
17	2025-10-30 15:40:00	\N	2	5
29	2026-01-10 08:00:00	2026-01-10 08:30:00	11	8
30	2026-01-11 09:00:00	2026-01-11 09:25:00	11	9
31	2026-01-12 10:00:00	2026-01-12 10:20:00	11	10
32	2026-01-10 14:00:00	2026-01-10 14:40:00	12	8
33	2026-01-11 15:00:00	2026-01-11 15:35:00	12	9
34	2026-01-13 16:00:00	2026-01-13 16:15:00	12	10
35	2026-01-14 11:00:00	2026-01-14 11:45:00	13	8
36	2026-01-15 12:00:00	2026-01-15 12:50:00	13	10
37	2026-01-16 08:00:00	2026-01-16 08:55:00	12	8
38	2026-01-17 09:00:00	2026-01-17 09:50:00	13	8
39	2026-01-18 10:00:00	2026-01-18 10:35:00	14	8
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.routes (id, name) FROM stdin;
5	Южный путь
6	СПб-Москва
7	Мурманск-СПб
4	СПб-Петрозаводск
8	Центр-Юг
9	Север-Запад
10	Восток-Запад
\.


--
-- Name: auto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auto_id_seq', 14, true);


--
-- Name: auto_personal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auto_personal_id_seq', 13, true);


--
-- Name: journal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.journal_id_seq', 39, true);


--
-- Name: routes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.routes_id_seq', 10, true);


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
-- Name: journal prevent_deleting_last_record_journal; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER prevent_deleting_last_record_journal BEFORE DELETE ON public.journal FOR EACH STATEMENT EXECUTE FUNCTION public.check_last_record();


--
-- Name: journal prevent_double_dispatch; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER prevent_double_dispatch BEFORE INSERT OR UPDATE ON public.journal FOR EACH ROW EXECUTE FUNCTION public.check_car_available();


--
-- Name: auto_personal prevent_personnel_delete_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER prevent_personnel_delete_trigger BEFORE DELETE ON public.auto_personal FOR EACH ROW EXECUTE FUNCTION public.prevent_personal_delete();


--
-- Name: routes protect_route_history_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER protect_route_history_trigger BEFORE UPDATE ON public.routes FOR EACH ROW EXECUTE FUNCTION public.protect_route_history();


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

\unrestrict uKBEZcmggr4GvjI6UCi42MmwBRvSfxVyMOu6W55JvAwT5LQ2Gr2XkjGxBhGJ6Rc


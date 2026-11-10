--
-- PostgreSQL database dump
--

\restrict J9JiJetpa2jliVtxXO3gzysnIOKgUUTYmO7FeWz2x4BcIYCBiGBNgSmT9pPWj1A

-- Dumped from database version 17.11
-- Dumped by pg_dump version 17.11

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
-- Name: w1_weblisting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.w1_weblisting (
    id bigint NOT NULL,
    email character varying(255) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL
);


--
-- Name: w1_weblisting_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.w1_weblisting ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.w1_weblisting_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: w2_survey; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.w2_survey (
    id bigint NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    email character varying(254) NOT NULL,
    date_of_birth date NOT NULL,
    heard_from character varying(30) NOT NULL,
    wants_updates boolean DEFAULT false NOT NULL,
    email_announcements boolean DEFAULT false NOT NULL,
    contact_via character varying(30) NOT NULL,
    submitted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT survey_responses_contact_via_check CHECK (((contact_via)::text = ANY (ARRAY[('Email or postal mail'::character varying)::text, ('Email only'::character varying)::text, ('Postal mail only'::character varying)::text]))),
    CONSTRAINT survey_responses_date_of_birth_check CHECK ((date_of_birth <= CURRENT_DATE)),
    CONSTRAINT survey_responses_email_check CHECK (((email)::text ~ '^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$'::text)),
    CONSTRAINT survey_responses_first_name_check CHECK ((btrim((first_name)::text) <> ''::text)),
    CONSTRAINT survey_responses_heard_from_check CHECK (((heard_from)::text = ANY (ARRAY[('Search engine'::character varying)::text, ('Word of mouth'::character varying)::text, ('Social Media'::character varying)::text, ('Other'::character varying)::text]))),
    CONSTRAINT survey_responses_last_name_check CHECK ((btrim((last_name)::text) <> ''::text))
);


--
-- Name: TABLE w2_survey; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.w2_survey IS 'Snapshot day du cua moi lan gui survey, khong ghi de lan gui cu.';


--
-- Name: COLUMN w2_survey.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.w2_survey.id IS 'Ma tu tang cua lan gui survey.';


--
-- Name: COLUMN w2_survey.date_of_birth; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.w2_survey.date_of_birth IS 'Ngay sinh, khong chua gio.';


--
-- Name: COLUMN w2_survey.submitted_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.w2_survey.submitted_at IS 'Thoi diem gui co mui gio; hien thi theo timezone cua phien truy van.';


--
-- Name: w2_survey_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.w2_survey ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.w2_survey_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: w1_weblisting w1_weblisting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.w1_weblisting
    ADD CONSTRAINT w1_weblisting_pkey PRIMARY KEY (id);


--
-- Name: w2_survey w2_survey_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.w2_survey
    ADD CONSTRAINT w2_survey_pkey PRIMARY KEY (id);


--
-- Name: w2_survey_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX w2_survey_email_idx ON public.w2_survey USING btree (email);


--
-- PostgreSQL database dump complete
--

\unrestrict J9JiJetpa2jliVtxXO3gzysnIOKgUUTYmO7FeWz2x4BcIYCBiGBNgSmT9pPWj1A

CREATE DATABASE reelfake_db_dev WITH TEMPLATE = template0 ENCODING = 'UTF8';

ALTER DATABASE reelfake_db_dev OWNER TO postgres;

\connect reelfake_db_dev

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

CREATE OR REPLACE FUNCTION public.set_updated_at()
	RETURNS TRIGGER
	AS
$$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

ALTER FUNCTION public.set_updated_at() OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.set_created_at()
	RETURNS TRIGGER
	AS
$$
BEGIN
    NEW.created_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

ALTER FUNCTION public.set_created_at() OWNER TO postgres;

CREATE TYPE public.ORDER_STATUS_VALUES AS ENUM ('Pending', 'Shipped', 'Delivered', 'Cancelled');

CREATE TABLE public.genre (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    genre_name CHARACTER VARYING(25) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.genre OWNER TO postgres;

CREATE TABLE public.country (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    country_name CHARACTER VARYING(60) NOT NULL,
    iso_country_code CHARACTER VARYING(2) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.country OWNER TO postgres;

CREATE TABLE public.city (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    city_name CHARACTER VARYING(50) NOT NULL,
    state_name CHARACTER VARYING(60) NOT NULL,
    country_id SMALLINT NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.city OWNER TO postgres;

CREATE TABLE public.movie_language (
	id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	language_name CHARACTER VARYING(60) not null,
	iso_language_code CHARACTER VARYING(2) unique not null,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
	updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() not null
);

ALTER TABLE public.movie_language OWNER TO postgres;

CREATE TABLE public.movie (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    tmdb_id INT NOT NULL,
    imdb_id CHARACTER VARYING(60) DEFAULT NULL,
    title CHARACTER VARYING(255) NOT NULL,
    original_title CHARACTER VARYING(255) NOT NULL,
    overview TEXT,
    runtime SMALLINT,
    release_date DATE NOT NULL,
    genre_ids INT[] NOT NULL,
    origin_country_ids INT[] NOT NULL,
    language_id SMALLINT NOT NULL,
    movie_status CHARACTER VARYING(20) NOT NULL,
    popularity REAL NOT NULL,
    budget BIGINT NOT NULL,
    revenue BIGINT NOT NULL,
    rating_average REAL NOT NULL,
    rating_count INT NOT NULL,
    poster_url CHARACTER VARYING(90) NOT NULL,
    rental_rate NUMERIC(4,2) DEFAULT 11.00 NOT NULL,
    rental_duration SMALLINT DEFAULT 3 NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.movie OWNER TO postgres;

CREATE TABLE public.actor (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    tmdb_id INT NOT NULL,
    imdb_id CHARACTER VARYING(60) DEFAULT NULL,
    actor_name CHARACTER VARYING(120) NOT NULL,
    biography TEXT,
    birthday DATE DEFAULT NULL,
    deathday DATE DEFAULT NULL,
    place_of_birth TEXT DEFAULT NULL,
    popularity REAL DEFAULT NULL,
    profile_picture_url CHARACTER VARYING(90) DEFAULT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.actor OWNER TO postgres;

CREATE TABLE public.movie_actor (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    movie_id INT,
    actor_id INT,
    character_name TEXT,
    cast_order SMALLINT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.movie_actor OWNER TO postgres;

CREATE TABLE public.address (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    address_line CHARACTER VARYING(120) NOT NULL,
    city_id int NOT NULL,
    postal_code CHARACTER VARYING(10),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.address OWNER TO postgres;

CREATE TABLE public.store (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    manager_staff_id INT UNIQUE DEFAULT NULL,
    address_id SMALLINT NOT NULL,
    phone_number CHARACTER VARYING(30) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.store OWNER TO postgres;

CREATE TABLE public.staff (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    first_name CHARACTER VARYING(45) NOT NULL,
    last_name CHARACTER VARYING(45) NOT NULL,
    email CHARACTER VARYING(50),
    address_id SMALLINT NOT NULL,
    store_id INT NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    user_name CHARACTER VARYING(40) NOT NULL,
    user_password CHARACTER VARYING(40),
    phone_number CHARACTER VARYING(30) NOT NULL,
    avatar TEXT DEFAULT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.staff OWNER TO postgres;

CREATE TABLE public.customer (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    first_name CHARACTER VARYING(45) NOT NULL,
    last_name CHARACTER VARYING(45) NOT NULL,
    email CHARACTER VARYING(50),
    address_id INT NOT NULL,
    preferred_store_id INT DEFAULT NULL,
    active boolean DEFAULT true NOT NULL,
    user_name CHARACTER VARYING(40) NOT NULL,
    user_password CHARACTER VARYING(40),
    phone_number CHARACTER VARYING(30) NOT NULL,
    avatar CHARACTER VARYING(120),
    registered_on DATE DEFAULT ('now'::text)::date NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.customer OWNER TO postgres;

CREATE TABLE public.inventory (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    movie_id INT NOT NULL,
    store_id INT NOT NULL,
    stock_count INT DEFAULT 0 NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.inventory OWNER TO postgres;

CREATE TABLE public.dvd_order (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    customer_id INT NOT NULL,
    staff_id INT NOT NULL,
    inventory_id INT NOT NULL,
    order_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    total_amount NUMERIC(5,2) NOT NULL,
    order_status public.ORDER_STATUS_VALUES NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.dvd_order OWNER TO postgres;

-- CREATE TABLE public.rental (
--     id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
--     inventory_id int NOT NULL,
--     customer_id int NOT NULL,
--     staff_id int NOT NULL,
--     rental_date timestamp without time zone NOT NULL,
--     return_date timestamp without time zone,
--     updated_at timestamp without time zone DEFAULT now() NOT NULL
-- );

-- ALTER TABLE public.rental OWNER TO postgres;

-- CREATE TABLE public.payment (
--     id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
--     staff_id int NOT NULL,
--     rental_id int NOT NULL,
--     amount numeric(5,2) NOT NULL,
--     payment_date timestamp without time zone NOT NULL
-- );

-- ALTER TABLE public.payment OWNER TO postgres;

-- ADD FOREIGN KEYS

ALTER TABLE ONLY public.movie_actor
    ADD CONSTRAINT fk_movie_actor_actor_id FOREIGN KEY (actor_id) REFERENCES public.actor(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT fk_movie_actor_movie_id FOREIGN KEY (movie_id) REFERENCES public.movie(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.city
    ADD CONSTRAINT fk_city_country_id FOREIGN KEY (country_id) REFERENCES public.country(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.address
    ADD CONSTRAINT fk_address_city_id FOREIGN KEY (city_id) REFERENCES public.city(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.store
    ADD CONSTRAINT fk_store_manager_staff_id FOREIGN KEY (manager_staff_id) REFERENCES public.staff(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT fk_store_address_id FOREIGN KEY (address_id) REFERENCES public.address(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT fk_customer_address_id FOREIGN KEY (address_id) REFERENCES public.address(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT fk_customer_pref_store_id FOREIGN KEY (preferred_store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT fk_inventory_movie_id FOREIGN KEY (movie_id) REFERENCES public.movie(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT fk_inventory_store_id FOREIGN KEY (store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.dvd_order
    ADD CONSTRAINT fk_inventory_customer_id FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT fk_inventory_staff_id FOREIGN KEY (staff_id) REFERENCES public.staff(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT fk_inventory_inventory_id FOREIGN KEY (inventory_id) REFERENCES public.inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT;

-- ALTER TABLE ONLY public.rental
--     ADD CONSTRAINT fk_rental_inventory_id FOREIGN KEY (inventory_id) REFERENCES public.inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT,
--     ADD CONSTRAINT fk_rental_customer_id FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE RESTRICT,
--     ADD CONSTRAINT fk_rental_staff_id FOREIGN KEY (staff_id) REFERENCES public.staff(id) ON UPDATE CASCADE ON DELETE RESTRICT;

-- ALTER TABLE ONLY public.payment 
--     ADD CONSTRAINT fk_payment_staff_id FOREIGN KEY (staff_id) REFERENCES public.staff(id) ON UPDATE CASCADE ON DELETE RESTRICT,
--     ADD CONSTRAINT fk_payment_rental_id FOREIGN KEY (rental_id) REFERENCES public.rental(id) ON UPDATE CASCADE ON DELETE RESTRICT;

-- VIEWS

CREATE OR REPLACE VIEW public.v_movie AS
    SELECT m.id, m.tmdb_id, m.imdb_id, m.title, m.original_title, m.overview, m.runtime, m.release_date,
    (SELECT ARRAY_AGG(genre_name) FROM public.genre g JOIN unnest(m.genre_ids) gid ON g.id = gid) AS genres, 
    (SELECT ARRAY_AGG(c.country_name) FROM public.country c JOIN unnest(m.origin_country_ids) cid ON c.id = cid) AS country,
    (SELECT l.language_name FROM public.movie_language l WHERE id = m.language_id) as movie_language,
    m.movie_status, m.popularity, m.budget, m.revenue, m.rating_average, m.rating_count, 
    m.poster_url, m.rental_rate, m.rental_duration
    FROM public.movie m;

-- FUNCTIONS

-- This function returns the list of films that contains the requested genre
CREATE OR REPLACE FUNCTION public.get_movies_by_genres(requested_genres text[])
    RETURNS SETOF public.v_movie
    AS
$$
BEGIN
    RETURN QUERY
    SELECT m.id, m.title, m.overview, m.release_year,
    (select ARRAY_AGG(genre_name) from genre g join unnest(m.genre_ids) gid on g.id = gid) as genres,
    m.runtime,
    (SELECT ARRAY_AGG(c.country_name) FROM country c JOIN unnest(m.origin_country) cid ON c.id = cid) AS country,
    m.poster_url, m.rental_duration, m.rental_rate
    FROM movie m
    WHERE m.genre_ids @> (SELECT ARRAY_AGG(g.id) FROM genre g WHERE g.genre_name = ANY(requested_genres));
END;
$$
LANGUAGE plpgsql;

-- INDEXES
-- CREATE INDEX idx_movie_release_date ON public.v_movie(release_date);

-- TRIGGERS

-- Updated at
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.genre FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.country FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.movie_language FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.movie FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.actor FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.movie_actor FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.city FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.address FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.store FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.staff FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.customer FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.inventory FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.dvd_order FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
-- CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.rental FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
-- CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.payment FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

-- Created at
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.genre FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.country FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.movie_language FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.movie FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.actor FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.movie_actor FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.city FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.address FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.store FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.staff FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.customer FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.inventory FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.dvd_order FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
-- CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.rental FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
-- CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.payment FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();

-- LOAD DATA

COPY public.genre(id, genre_name) FROM '/docker-entrypoint-initdb.d/genres.csv' DELIMITERS ',' CSV header;
COPY public.movie_language(id, language_name, iso_language_code) FROM '/docker-entrypoint-initdb.d/languages.csv' DELIMITERS ',' CSV header;
COPY public.country(id, country_name, iso_country_code) FROM '/docker-entrypoint-initdb.d/countries.csv' DELIMITERS ',' CSV header;
COPY public.movie(id, tmdb_id, imdb_id, title, original_title, overview, runtime, release_date, genre_ids, origin_country_ids, language_id, movie_status, popularity, budget, revenue, rating_average, rating_count, poster_url) FROM '/docker-entrypoint-initdb.d/movies.csv' DELIMITERS ',' CSV header;
COPY public.actor(id, tmdb_id, imdb_id, actor_name, biography, birthday, deathday, place_of_birth, popularity, profile_picture_url) FROM '/docker-entrypoint-initdb.d/actors.csv' DELIMITERS ',' CSV header;
COPY public.movie_actor(id, movie_id, actor_id, character_name, cast_order) FROM '/docker-entrypoint-initdb.d/movie_actors.csv' DELIMITERS ',' CSV header;
COPY public.city(id, city_name, state_name, country_id) FROM '/docker-entrypoint-initdb.d/cities.csv' DELIMITERS ',' CSV header;
COPY public.address(id, address_line, city_id, postal_code) FROM '/docker-entrypoint-initdb.d/addresses.csv' DELIMITERS ',' CSV header;
COPY public.staff(id, first_name, last_name, email, address_id, store_id, active, user_name, user_password, phone_number, avatar) FROM '/docker-entrypoint-initdb.d/staff.csv' DELIMITERS ',' CSV header;
COPY public.store(id, manager_staff_id, address_id, phone_number) FROM '/docker-entrypoint-initdb.d/stores.csv' DELIMITERS ',' CSV header;
COPY public.customer(id, first_name, last_name, email, address_id, preferred_store_id, active, user_name, user_password, phone_number, avatar, registered_on) FROM '/docker-entrypoint-initdb.d/customers.csv' DELIMITERS ',' CSV header;
COPY public.inventory(id, movie_id, store_id, stock_count) FROM '/docker-entrypoint-initdb.d/inventory.csv' DELIMITERS ',' CSV header;
COPY public.dvd_order(id, customer_id, staff_id, inventory_id, order_date, total_amount, order_status) FROM '/docker-entrypoint-initdb.d/orders.csv' DELIMITERS ',' CSV header;
-- COPY public.rental(id, inventory_id, customer_id, staff_id, rental_date, return_date) FROM '/docker-entrypoint-initdb.d/rentals.csv' DELIMITERS '|' CSV;
-- COPY public.payment(id, staff_id, rental_id, amount, payment_date) FROM '/docker-entrypoint-initdb.d/payments.csv' DELIMITERS '|' CSV;

-- Set foreign keys for staff table

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT fk_staff_address_id FOREIGN KEY (address_id) REFERENCES public.address(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT fk_staff_store_id FOREIGN KEY (store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE RESTRICT;
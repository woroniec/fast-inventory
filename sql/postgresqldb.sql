CREATE OR REPLACE PROCEDURE public.products_work_table_swap(
	)
LANGUAGE 'plpgsql'

AS $BODY$
BEGIN
DROP TABLE products;
ALTER TABLE work_products RENAME TO products;

CREATE TABLE public.work_products
(
    num text COLLATE pg_catalog."default",
    description text COLLATE pg_catalog."default",
    totalavailableforsale integer,
    qtyonhand integer,
    qtyallocated integer,
    qtynotavailable integer,
    qtynotavailabletopick integer,
    qtydropship integer,
    qtyonorderpo integer,
    qtyonorderso integer
)

TABLESPACE pg_default;


END
$BODY$;

CREATE TABLE public.app_usage
(
    app_user text COLLATE pg_catalog."default",
    search_phrase text COLLATE pg_catalog."default",
    time_of_search timestamp without time zone
)

CREATE TABLE public.products
(
    num text COLLATE pg_catalog."default",
    description text COLLATE pg_catalog."default",
    totalavailableforsale integer,
    qtyonhand integer,
    qtyallocated integer,
    qtynotavailable integer,
    qtynotavailabletopick integer,
    qtydropship integer,
    qtyonorderpo integer,
    qtyonorderso integer
)

CREATE TABLE public.registered_users
(
    user_name text COLLATE pg_catalog."default",
    password text COLLATE pg_catalog."default",
    CONSTRAINT "uq username" UNIQUE (user_name)
)

CREATE TABLE public."time"
(
    products_update timestamp without time zone
)




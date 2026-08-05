-- Migración: correlativo estable por venta, con secuencia atómica en `sales.number`.

-- La numeración es una secuencia de Postgres: `nextval` es atómico, así que
-- dos ventas concurrentes nunca chocan. El número se asigna al registrar la
-- venta y no cambia ni se reaprovecha (aunque anules la venta, conserva su
-- número; los únicos huecos son por transacciones que se revierten).

CREATE SEQUENCE public.sale_number_seq;

ALTER TABLE public.sales
  ADD COLUMN number bigint;

-- Backfill de datos de prueba: numerar en orden cronológico para no dejar
-- filas históricas sin correlativo.
UPDATE public.sales s
SET number = seq.rn
FROM (
  SELECT id, row_number() OVER (ORDER BY sale_date, id) AS rn
  FROM public.sales
) seq
WHERE s.id = seq.id;

ALTER TABLE public.sales
  ALTER COLUMN number SET DEFAULT nextval('public.sale_number_seq'),
  ALTER COLUMN number SET NOT NULL;

ALTER SEQUENCE public.sale_number_seq OWNED BY public.sales.number;

-- Arranca la secuencia una posición por encima del máximo existente (si no
-- hay filas, empieza en 1).
SELECT setval('public.sale_number_seq', COALESCE((SELECT max(number) FROM public.sales), 0), true);

-- Índice único: garantiza que ningún correlativo se repita y acelera la búsqueda.
ALTER TABLE public.sales
  ADD CONSTRAINT sales_number_unique UNIQUE (number);
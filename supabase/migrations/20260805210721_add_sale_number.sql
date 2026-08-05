DROP VIEW IF EXISTS public.v_sales;

ALTER TABLE public.sales DROP COLUMN IF EXISTS number;

DROP SEQUENCE IF EXISTS public.sale_number_seq;

CREATE SEQUENCE public.sale_number_seq;

ALTER TABLE public.sales
  ADD COLUMN number bigint;

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

SELECT setval(
  'public.sale_number_seq',
  COALESCE((SELECT max(number) FROM public.sales), 0) + 1,
  false
);

ALTER TABLE public.sales
  ADD CONSTRAINT sales_number_unique UNIQUE (number);
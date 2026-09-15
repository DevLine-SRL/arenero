-- Migración: castea `number` a texto en v_sales_details para que PostgREST
-- pueda buscarlo con `ilike` desde la app (era bigint y `ilike` no existe
-- para enteros), lo que rompía el buscador de ventas en los reportes de
-- cliente y vendedor.
--
-- La vista se recrea porque `CREATE OR REPLACE` no permite cambiar el tipo de
-- una columna. Las funciones de reporte que dependen de ella se borran y se
-- vuelven a crear aquí de forma explícita (DROP IF EXISTS), sin depender de
-- que DROP CASCADE las arrastre; esto hace la migración idempotente.

DROP FUNCTION IF EXISTS public.period_summary(date, date) CASCADE;
DROP FUNCTION IF EXISTS public.report_by_client(date, date) CASCADE;
DROP FUNCTION IF EXISTS public.report_by_seller(date, date) CASCADE;
DROP FUNCTION IF EXISTS public.report_by_product(date, date) CASCADE;

DROP VIEW IF EXISTS public.v_sales_details CASCADE;

CREATE VIEW public.v_sales_details
  WITH (security_invoker = true)
  AS
  select
    s.id              AS sale_id,
    s.number::text    AS number,
    s.sale_date,
    s.status,
    s.client_id,
    c.name            AS client_name,
    s.seller_id,
    p.name            AS seller_name,
    sd.product_unit_id,
    pr.name           AS product_name,
    pu.unit,
    sd.quantity,
    sd.unit_price,
    sd.discount,
    sd.subtotal
  from public.sales s
  join public.clients c on c.id = s.client_id
  join public.profiles p on p.id = s.seller_id
  join public.sale_details sd on sd.sale_id = s.id
  join public.product_units pu on pu.id = sd.product_unit_id
  join public.products pr on pr.id = pu.product_id
  where s.status = 'registered'::public.sale_status;

REVOKE ALL ON public.v_sales_details FROM PUBLIC;

GRANT SELECT ON public.v_sales_details TO authenticated;

-- Funciones de agregación. Vuelven a crearse porque DROP CASCADE las eliminó.
-- Son SECURITY INVOKER (no llevan SECURITY DEFINER): cada rol ve solo lo que
-- le permiten las políticas de las tablas subyacentes.

CREATE FUNCTION public.period_summary(start_date date, end_date date)
RETURNS table(n_sales bigint, total_sold numeric, avg_ticket numeric)
LANGUAGE sql
STABLE
AS $$
  select
    count(distinct sale_id),
    coalesce(sum(subtotal), 0),
    coalesce(sum(subtotal) / nullif(count(distinct sale_id), 0), 0)
  from public.v_sales_details
  where sale_date >= start_date
    and sale_date < end_date + 1;
$$;

REVOKE EXECUTE ON FUNCTION public.period_summary(date, date) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.period_summary(date, date) TO authenticated;

CREATE FUNCTION public.report_by_client(start_date date, end_date date)
RETURNS table(client_id uuid, client_name text, n_sales bigint, total numeric)
LANGUAGE sql
STABLE
AS $$
  select client_id, client_name, count(distinct sale_id), sum(subtotal)
  from public.v_sales_details
  where sale_date >= start_date
    and sale_date < end_date + 1
  group by client_id, client_name
  order by sum(subtotal) desc;
$$;

REVOKE EXECUTE ON FUNCTION public.report_by_client(date, date) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.report_by_client(date, date) TO authenticated;

CREATE FUNCTION public.report_by_seller(start_date date, end_date date)
RETURNS table(seller_id uuid, seller_name text, n_sales bigint, total_sold numeric)
LANGUAGE sql
STABLE
AS $$
  select seller_id, seller_name, count(distinct sale_id), sum(subtotal)
  from public.v_sales_details
  where sale_date >= start_date
    and sale_date < end_date + 1
  group by seller_id, seller_name
  order by sum(subtotal) desc;
$$;

REVOKE EXECUTE ON FUNCTION public.report_by_seller(date, date) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.report_by_seller(date, date) TO authenticated;

CREATE FUNCTION public.report_by_product(start_date date, end_date date)
RETURNS table(product_unit_id uuid, product_name text, unit public.unit_of_measure, qty_sold numeric, total_amount numeric)
LANGUAGE sql
STABLE
AS $$
  select product_unit_id, product_name, unit, sum(quantity), sum(subtotal)
  from public.v_sales_details
  where sale_date >= start_date
    and sale_date < end_date + 1
  group by product_unit_id, product_name, unit
  order by sum(subtotal) desc;
$$;

REVOKE EXECUTE ON FUNCTION public.report_by_product(date, date) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.report_by_product(date, date) TO authenticated;

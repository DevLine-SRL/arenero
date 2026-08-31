-- Migración: funciones de agregación para la pantalla de reportes sobre
-- v_sales_details. Son SECURITY INVOKER (no llevan SECURITY DEFINER), así que
-- cada rol ve solo lo que le permiten las políticas de las tablas subyacentes.
-- El rango usa sale_date >= start_date AND sale_date < end_date + 1 porque
-- sale_date es timestamptz y un end_date de tipo date cae a medianoche.

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

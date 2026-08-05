DROP VIEW IF EXISTS public.v_sales;

CREATE OR REPLACE VIEW public.v_sales
  WITH (security_invoker = true)
  AS
  select
    s.id,
    s.number,
    s.sale_date,
    s.total,
    s.payment_method,
    c.name  AS client_name,
    c.ci    AS client_ci
  from public.sales s
  join public.clients c on c.id = s.client_id
  where s.seller_id = (select auth.uid())
    and s.status = 'registered'::public.sale_status;

REVOKE ALL ON public.v_sales FROM PUBLIC;

GRANT SELECT ON public.v_sales TO authenticated;
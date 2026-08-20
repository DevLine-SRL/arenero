-- Migración: v_sales delega el alcance a la RLS de sales (el administrador ve
-- todas las ventas, el vendedor solo las suyas) y expone el id para abrir el
-- detalle.
--
-- La vista se crea con security_invoker, así que la política sales_select ya
-- aplica: is_active() AND (seller_id = auth.uid() OR is_admin()). El filtro
-- por seller_id que traía la vista se sumaba a esa política y dejaba al
-- administrador sin ninguna fila.

DROP VIEW IF EXISTS public.v_sales;

CREATE VIEW public.v_sales
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
  where s.status = 'registered'::public.sale_status;

REVOKE ALL ON public.v_sales FROM PUBLIC;

GRANT SELECT ON public.v_sales TO authenticated;

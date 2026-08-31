-- Migración: vista v_sales_details con el detalle de cada venta (cliente,
-- vendedor, producto y línea) para la pantalla de reportes. Se crea con
-- security_invoker para que el alcance lo decidan las políticas de cada tabla
-- del join: el vendedor solo ve sus ventas, el administrador todas.

CREATE VIEW public.v_sales_details
  WITH (security_invoker = true)
  AS
  select
    s.id              AS sale_id,
    s.number,
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
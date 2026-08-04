ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.client_addresses ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.product_units ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.sale_details ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.sale_deliveries ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT ON public.clients TO authenticated;

GRANT UPDATE, DELETE ON public.clients TO authenticated;

GRANT SELECT, INSERT ON public.client_addresses TO authenticated;

GRANT UPDATE, DELETE ON public.client_addresses TO authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.products TO authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.product_units TO authenticated;

GRANT SELECT, INSERT, UPDATE ON public.sales TO authenticated;

GRANT SELECT, INSERT ON public.sale_details TO authenticated;

GRANT UPDATE, DELETE ON public.sale_details TO authenticated;

GRANT SELECT, INSERT ON public.sale_deliveries TO authenticated;

GRANT UPDATE, DELETE ON public.sale_deliveries TO authenticated;

GRANT SELECT ON public.audit_logs TO authenticated;

GRANT USAGE ON TYPE public.delivery_mode TO authenticated;

GRANT USAGE ON TYPE public.payment_method TO authenticated;

GRANT USAGE ON TYPE public.sale_status TO authenticated;

GRANT USAGE ON TYPE public.unit_of_measure TO authenticated;

CREATE OR REPLACE FUNCTION public.set_updated_at()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path = ''
  AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$;

CREATE POLICY "clients_select" ON public.clients
  FOR SELECT TO authenticated
  USING (public.is_active());

CREATE POLICY "clients_insert" ON public.clients
  FOR INSERT TO authenticated
  WITH CHECK (public.is_active());

CREATE POLICY "clients_update" ON public.clients
  FOR UPDATE TO authenticated
  USING (public.is_active() AND public.is_admin())
  WITH CHECK (public.is_active() AND public.is_admin());

CREATE POLICY "clients_delete" ON public.clients
  FOR DELETE TO authenticated
  USING (public.is_active() AND public.is_admin());

CREATE POLICY "client_addresses_select" ON public.client_addresses
  FOR SELECT TO authenticated
  USING (public.is_active());

CREATE POLICY "client_addresses_insert" ON public.client_addresses
  FOR INSERT TO authenticated
  WITH CHECK (public.is_active());

CREATE POLICY "client_addresses_update" ON public.client_addresses
  FOR UPDATE TO authenticated
  USING (public.is_active() AND public.is_admin())
  WITH CHECK (public.is_active() AND public.is_admin());

CREATE POLICY "client_addresses_delete" ON public.client_addresses
  FOR DELETE TO authenticated
  USING (public.is_active() AND public.is_admin());

CREATE POLICY "products_select" ON public.products
  FOR SELECT TO authenticated
  USING (public.is_active());

CREATE POLICY "products_insert" ON public.products
  FOR INSERT TO authenticated
  WITH CHECK (public.is_active() AND public.is_admin());

CREATE POLICY "products_update" ON public.products
  FOR UPDATE TO authenticated
  USING (public.is_active() AND public.is_admin())
  WITH CHECK (public.is_active() AND public.is_admin());

CREATE POLICY "products_delete" ON public.products
  FOR DELETE TO authenticated
  USING (public.is_active() AND public.is_admin());

CREATE POLICY "product_units_select" ON public.product_units
  FOR SELECT TO authenticated
  USING (public.is_active());

CREATE POLICY "product_units_insert" ON public.product_units
  FOR INSERT TO authenticated
  WITH CHECK (public.is_active() AND public.is_admin());

CREATE POLICY "product_units_update" ON public.product_units
  FOR UPDATE TO authenticated
  USING (public.is_active() AND public.is_admin())
  WITH CHECK (public.is_active() AND public.is_admin());

CREATE POLICY "product_units_delete" ON public.product_units
  FOR DELETE TO authenticated
  USING (public.is_active() AND public.is_admin());

CREATE POLICY "sales_select" ON public.sales
  FOR SELECT TO authenticated
  USING (public.is_active() AND ((seller_id = (select auth.uid())) OR public.is_admin()));

CREATE POLICY "sales_insert" ON public.sales
  FOR INSERT TO authenticated
  WITH CHECK (public.is_active() AND ((seller_id = (select auth.uid())) OR public.is_admin()));

CREATE POLICY "sales_update" ON public.sales
  FOR UPDATE TO authenticated
  USING (public.is_active() AND (((seller_id = (select auth.uid())) AND status = 'registered'::public.sale_status) OR public.is_admin()))
  WITH CHECK (public.is_active() AND (((seller_id = (select auth.uid())) AND status = 'registered'::public.sale_status) OR public.is_admin()));

CREATE POLICY "sale_details_select" ON public.sale_details
  FOR SELECT TO authenticated
  USING (public.is_active() AND (exists (select 1 from public.sales s where ((s.id = sale_id) AND ((s.seller_id = (select auth.uid())) OR public.is_admin())))));

CREATE POLICY "sale_details_insert" ON public.sale_details
  FOR INSERT TO authenticated
  WITH CHECK (public.is_active() AND (exists (select 1 from public.sales s where ((s.id = sale_id) AND ((s.seller_id = (select auth.uid())) AND (s.status = 'registered'::public.sale_status)))) OR public.is_admin()));

CREATE POLICY "sale_details_update" ON public.sale_details
  FOR UPDATE TO authenticated
  USING (public.is_active() AND public.is_admin())
  WITH CHECK (public.is_active() AND public.is_admin());

CREATE POLICY "sale_details_delete" ON public.sale_details
  FOR DELETE TO authenticated
  USING (public.is_active() AND public.is_admin());

CREATE POLICY "sale_deliveries_select" ON public.sale_deliveries
  FOR SELECT TO authenticated
  USING (public.is_active() AND (exists (select 1 from public.sales s where ((s.id = sale_id) AND ((s.seller_id = (select auth.uid())) OR public.is_admin())))));

CREATE POLICY "sale_deliveries_insert" ON public.sale_deliveries
  FOR INSERT TO authenticated
  WITH CHECK (public.is_active() AND (exists (select 1 from public.sales s where ((s.id = sale_id) AND ((s.seller_id = (select auth.uid())) AND (s.status = 'registered'::public.sale_status)))) OR public.is_admin()));

CREATE POLICY "sale_deliveries_update" ON public.sale_deliveries
  FOR UPDATE TO authenticated
  USING (public.is_active() AND public.is_admin())
  WITH CHECK (public.is_active() AND public.is_admin());

CREATE POLICY "sale_deliveries_delete" ON public.sale_deliveries
  FOR DELETE TO authenticated
  USING (public.is_active() AND public.is_admin());

CREATE POLICY "audit_logs_select" ON public.audit_logs
  FOR SELECT TO authenticated
  USING (public.is_active() AND public.is_admin());

CREATE FUNCTION public.void_sale(p_sale_id uuid)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
declare
  v_seller_id uuid;
  v_status public.sale_status;
begin
  select seller_id, status
  into v_seller_id, v_status
  from public.sales
  where id = p_sale_id;

  if not found then
    raise exception 'sale not found' using errcode = 'P0002';
  end if;

  if v_status = 'void' then
    raise exception 'sale already void' using errcode = 'P0001';
  end if;

  if v_seller_id <> (select auth.uid()) and not public.is_admin() then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  if not public.is_active() then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  update public.sales
  set status = 'void'
  where id = p_sale_id;
end;
$function$;

REVOKE EXECUTE ON FUNCTION public.void_sale(uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.void_sale(uuid) TO authenticated;

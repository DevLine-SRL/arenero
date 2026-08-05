-- Impide registrar detalles de venta para unidades o productos inactivos.

DROP POLICY "sale_details_insert" ON public.sale_details;

CREATE POLICY "sale_details_insert" ON public.sale_details
  FOR INSERT TO authenticated
  WITH CHECK (
    (select public.is_active())
    AND (
      EXISTS (
        SELECT 1
        FROM public.sales s
        WHERE s.id = sale_id
          AND s.seller_id = (select auth.uid())
          AND s.status = 'registered'::public.sale_status
      )
      OR (select public.is_admin())
    )
    AND EXISTS (
      SELECT 1
      FROM public.product_units pu
      JOIN public.products p ON p.id = pu.product_id
      WHERE pu.id = product_unit_id
        AND pu.active
        AND p.active
    )
  );

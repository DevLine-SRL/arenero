-- Migración: valida que el abono parcial sea menor al total de la venta.

GRANT USAGE
ON TYPE public.sale_payment_status
TO authenticated;

CREATE OR REPLACE FUNCTION public.update_sale_payment(
  p_sale_id uuid,
  p_payment_status public.sale_payment_status,
  p_amount_paid numeric,
  p_pending_amount numeric
)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_sale_total numeric(14, 2);
BEGIN
  SELECT s.total
  INTO v_sale_total
  FROM public.sales s
  WHERE s.id = p_sale_id
    AND s.status = 'registered'::public.sale_status;

  IF v_sale_total IS NULL THEN
    RAISE EXCEPTION 'La venta indicada no existe.'
      USING ERRCODE = 'P0002';
  END IF;

  IF COALESCE(p_amount_paid, 0) < 0 THEN
    RAISE EXCEPTION 'El monto abonado no puede ser negativo.'
      USING ERRCODE = 'P0001';
  END IF;

  IF COALESCE(p_pending_amount, 0) < 0 THEN
    RAISE EXCEPTION 'El saldo pendiente no puede ser negativo.'
      USING ERRCODE = 'P0001';
  END IF;

  IF p_payment_status = 'partial'::public.sale_payment_status
     AND (
       COALESCE(p_amount_paid, 0) <= 0
       OR COALESCE(p_amount_paid, 0) >= v_sale_total
     ) THEN
    RAISE EXCEPTION
      'El abono parcial debe ser mayor a cero y menor al total.'
      USING ERRCODE = 'P0001';
  END IF;

  UPDATE public.sales
  SET
    payment_status = p_payment_status,
    amount_paid = CASE
      WHEN p_payment_status = 'paid_in_full'::public.sale_payment_status
        THEN v_sale_total
      WHEN p_payment_status = 'pending'::public.sale_payment_status
        THEN 0
      ELSE COALESCE(p_amount_paid, 0)
    END
  WHERE id = p_sale_id
    AND status = 'registered'::public.sale_status;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No fue posible actualizar el cobro de la venta.'
      USING ERRCODE = 'P0001';
  END IF;
END;
$$;

REVOKE ALL
ON FUNCTION public.update_sale_payment(
  uuid,
  public.sale_payment_status,
  numeric,
  numeric
)
FROM PUBLIC;

GRANT EXECUTE
ON FUNCTION public.update_sale_payment(
  uuid,
  public.sale_payment_status,
  numeric,
  numeric
)
TO authenticated;

DROP VIEW IF EXISTS public.v_sales;

CREATE OR REPLACE VIEW public.v_sales
WITH (security_invoker = true)
AS
SELECT
  s.id,
  s.number,
  s.sale_date,
  s.total,
  s.delivery_mode,
  s.freight_amount,
  s.payment_method,
  s.payment_status,
  s.amount_paid,
  s.pending_amount,
  c.name AS client_name,
  c.ci AS client_ci
FROM public.sales s
JOIN public.clients c
  ON c.id = s.client_id
WHERE s.status = 'registered'::public.sale_status;

REVOKE ALL
ON public.v_sales
FROM PUBLIC;

GRANT SELECT
ON public.v_sales
TO authenticated;

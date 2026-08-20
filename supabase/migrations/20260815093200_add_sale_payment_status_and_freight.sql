-- ============================================================
-- HU-02 + HU-04
--
-- HU-02:
--   - El flete solamente afecta el total cuando la modalidad
--     de entrega es company_delivery.
--   - customer_pickup siempre fuerza freight_amount = 0.
--   - El total se recalcula desde sale_details.
--
-- HU-04:
--   - Estado de cobro:
--       paid_in_full
--       partial
--       pending
--   - Monto abonado.
--   - Saldo pendiente.
--   - RPC para actualizar el cobro después de crear la venta.
-- ============================================================


-- ============================================================
-- 1. ENUM PARA ESTADO DEL COBRO
-- ============================================================

DO $$
BEGIN
  CREATE TYPE public.sale_payment_status AS ENUM (
    'paid_in_full',
    'partial',
    'pending'
  );
EXCEPTION
  WHEN duplicate_object THEN
    NULL;
END
$$;


-- ============================================================
-- 2. NUEVAS COLUMNAS EN SALES
-- ============================================================

ALTER TABLE public.sales
ADD COLUMN IF NOT EXISTS payment_status
  public.sale_payment_status NOT NULL DEFAULT 'pending';

ALTER TABLE public.sales
ADD COLUMN IF NOT EXISTS amount_paid
  numeric(14, 2) NOT NULL DEFAULT 0;

ALTER TABLE public.sales
ADD COLUMN IF NOT EXISTS pending_amount
  numeric(14, 2) NOT NULL DEFAULT 0;


-- ============================================================
-- 3. CONSTRAINTS
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'sales_amount_paid_non_negative'
  ) THEN
    ALTER TABLE public.sales
    ADD CONSTRAINT sales_amount_paid_non_negative
    CHECK (amount_paid >= 0);
  END IF;
END
$$;


DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'sales_pending_amount_non_negative'
  ) THEN
    ALTER TABLE public.sales
    ADD CONSTRAINT sales_pending_amount_non_negative
    CHECK (pending_amount >= 0);
  END IF;
END
$$;


DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'sales_freight_amount_non_negative'
  ) THEN
    ALTER TABLE public.sales
    ADD CONSTRAINT sales_freight_amount_non_negative
    CHECK (freight_amount >= 0);
  END IF;
END
$$;


-- ============================================================
-- 4. NORMALIZAR DATOS DE VENTAS
--
-- Esta función protege tanto HU-02 como HU-04.
--
-- HU-02:
-- customer_pickup -> freight_amount = 0
--
-- HU-04:
-- paid_in_full -> paga todo
-- partial      -> calcula saldo
-- pending      -> no existe abono y debe todo
-- ============================================================

CREATE OR REPLACE FUNCTION public.normalize_sale_financial_data()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN

  -- ----------------------------------------------------------
  -- HU-02 - Normalización del flete
  -- ----------------------------------------------------------

  NEW.freight_amount :=
    GREATEST(COALESCE(NEW.freight_amount, 0), 0);

  IF NEW.delivery_mode = 'customer_pickup' THEN
    NEW.freight_amount := 0;
  END IF;


  -- ----------------------------------------------------------
  -- Evitar valores negativos
  -- ----------------------------------------------------------

  NEW.discount_amount :=
    GREATEST(COALESCE(NEW.discount_amount, 0), 0);

  NEW.total :=
    GREATEST(COALESCE(NEW.total, 0), 0);

  NEW.amount_paid :=
    GREATEST(COALESCE(NEW.amount_paid, 0), 0);


  -- ----------------------------------------------------------
  -- HU-04 - Estado del cobro
  -- ----------------------------------------------------------

  CASE NEW.payment_status

    -- --------------------------------------------------------
    -- COBRADO COMPLETO
    -- --------------------------------------------------------
    WHEN 'paid_in_full' THEN

      NEW.amount_paid := NEW.total;
      NEW.pending_amount := 0;


    -- --------------------------------------------------------
    -- ABONO PARCIAL
    -- --------------------------------------------------------
    WHEN 'partial' THEN

      -- Si no se abonó nada realmente,
      -- la venta pasa a pendiente.
      IF NEW.amount_paid <= 0 THEN

        NEW.payment_status := 'pending';
        NEW.amount_paid := 0;
        NEW.pending_amount := NEW.total;

      -- Si el monto abonado alcanza o supera el total,
      -- automáticamente pasa a cobrado completo.
      ELSIF NEW.amount_paid >= NEW.total THEN

        NEW.payment_status := 'paid_in_full';
        NEW.amount_paid := NEW.total;
        NEW.pending_amount := 0;

      ELSE

        NEW.pending_amount :=
          GREATEST(
            NEW.total - NEW.amount_paid,
            0
          );

      END IF;


    -- --------------------------------------------------------
    -- PENDIENTE
    -- --------------------------------------------------------
    WHEN 'pending' THEN

      NEW.amount_paid := 0;
      NEW.pending_amount := NEW.total;

  END CASE;


  -- ----------------------------------------------------------
  -- Una venta anulada no debe aparecer como deuda pendiente.
  -- ----------------------------------------------------------

  IF NEW.status = 'void' THEN
    NEW.pending_amount := 0;
  END IF;


  RETURN NEW;
END;
$$;


-- ============================================================
-- 5. TRIGGER DE NORMALIZACIÓN
-- ============================================================

DROP TRIGGER IF EXISTS
  trg_normalize_sale_financial_data
ON public.sales;


CREATE TRIGGER trg_normalize_sale_financial_data
BEFORE INSERT OR UPDATE OF
  delivery_mode,
  freight_amount,
  discount_amount,
  total,
  payment_status,
  amount_paid,
  status
ON public.sales
FOR EACH ROW
EXECUTE FUNCTION public.normalize_sale_financial_data();


-- ============================================================
-- 6. FUNCIÓN PARA RECALCULAR EL TOTAL DE UNA VENTA
--
-- Fórmula:
--
-- total =
--   suma(detalles)
--   - descuento general
--   + flete
--
-- El flete solo entra cuando:
-- delivery_mode = company_delivery
-- ============================================================

CREATE OR REPLACE FUNCTION public.recalculate_sale_total(
  p_sale_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_details_total numeric(14, 2);
BEGIN

  SELECT
    COALESCE(
      SUM(
        GREATEST(
          (COALESCE(sd.quantity, 0) *
           COALESCE(sd.unit_price, 0))
          -
          COALESCE(sd.discount, 0),
          0
        )
      ),
      0
    )
  INTO v_details_total
  FROM public.sale_details sd
  WHERE sd.sale_id = p_sale_id;


  UPDATE public.sales s
  SET total =
    GREATEST(
      v_details_total
      -
      COALESCE(s.discount_amount, 0)
      +
      CASE

        -- HU-02
        -- Solo domicilio suma flete.
        WHEN s.delivery_mode = 'company_delivery'
          THEN GREATEST(
            COALESCE(s.freight_amount, 0),
            0
          )

        ELSE 0

      END,
      0
    )
  WHERE s.id = p_sale_id;

END;
$$;


REVOKE ALL
ON FUNCTION public.recalculate_sale_total(uuid)
FROM PUBLIC;


-- ============================================================
-- 7. TRIGGER SOBRE SALE_DETAILS
--
-- Cada vez que:
--   - se agrega producto
--   - cambia cantidad
--   - cambia precio
--   - cambia descuento
--   - se elimina producto
--
-- se recalcula automáticamente sales.total.
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_sale_detail_total()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN

  IF TG_OP = 'DELETE' THEN

    PERFORM public.recalculate_sale_total(
      OLD.sale_id
    );

    RETURN OLD;

  END IF;


  -- Si el detalle fue movido accidentalmente
  -- de una venta a otra, recalculamos ambas.
  IF TG_OP = 'UPDATE'
     AND OLD.sale_id IS DISTINCT FROM NEW.sale_id THEN

    PERFORM public.recalculate_sale_total(
      OLD.sale_id
    );

  END IF;


  PERFORM public.recalculate_sale_total(
    NEW.sale_id
  );


  RETURN NEW;

END;
$$;


DROP TRIGGER IF EXISTS
  trg_sale_detail_recalculate_total
ON public.sale_details;


CREATE TRIGGER trg_sale_detail_recalculate_total
AFTER INSERT OR DELETE OR UPDATE OF
  sale_id,
  quantity,
  unit_price,
  discount
ON public.sale_details
FOR EACH ROW
EXECUTE FUNCTION public.handle_sale_detail_total();


-- ============================================================
-- 8. RECALCULAR TOTAL CUANDO CAMBIA FLETE,
--    DESCUENTO O MODALIDAD DE ENTREGA
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_sale_header_total()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN

  PERFORM public.recalculate_sale_total(
    NEW.id
  );

  RETURN NEW;

END;
$$;


DROP TRIGGER IF EXISTS
  trg_sale_header_recalculate_total
ON public.sales;


CREATE TRIGGER trg_sale_header_recalculate_total
AFTER UPDATE OF
  delivery_mode,
  freight_amount,
  discount_amount
ON public.sales
FOR EACH ROW
WHEN (
  OLD.delivery_mode IS DISTINCT FROM NEW.delivery_mode
  OR
  OLD.freight_amount IS DISTINCT FROM NEW.freight_amount
  OR
  OLD.discount_amount IS DISTINCT FROM NEW.discount_amount
)
EXECUTE FUNCTION public.handle_sale_header_total();


-- ============================================================
-- 9. RPC HU-04
--
-- Este RPC coincide con:
--
-- sales_remote_datasource.dart
--
-- updateSalePayment(
--   saleId,
--   paymentStatus,
--   amountPaid,
--   pendingAmount,
-- )
--
-- IMPORTANTE:
-- pending_amount se vuelve a calcular en BD.
-- No confiamos únicamente en el valor enviado por Flutter.
-- ============================================================

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
  v_sale_exists boolean;
BEGIN

  SELECT EXISTS (
    SELECT 1
    FROM public.sales
    WHERE id = p_sale_id
  )
  INTO v_sale_exists;


  IF NOT v_sale_exists THEN
    RAISE EXCEPTION
      'La venta indicada no existe.';
  END IF;


  -- ----------------------------------------------------------
  -- No permitimos montos negativos.
  -- ----------------------------------------------------------

  IF COALESCE(p_amount_paid, 0) < 0 THEN
    RAISE EXCEPTION
      'El monto abonado no puede ser negativo.';
  END IF;


  IF COALESCE(p_pending_amount, 0) < 0 THEN
    RAISE EXCEPTION
      'El saldo pendiente no puede ser negativo.';
  END IF;


  -- ----------------------------------------------------------
  -- El trigger normalize_sale_financial_data()
  -- calculará automáticamente pending_amount.
  --
  -- Por seguridad NO confiamos en el saldo calculado
  -- por Flutter.
  -- ----------------------------------------------------------

  UPDATE public.sales
  SET
    payment_status = p_payment_status,
    amount_paid = COALESCE(p_amount_paid, 0)
  WHERE id = p_sale_id;


  IF NOT FOUND THEN
    RAISE EXCEPTION
      'No fue posible actualizar el cobro de la venta.';
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


-- ============================================================
-- 10. MIGRAR VENTAS EXISTENTES
--
-- Antes de HU-04 las ventas antiguas no manejaban
-- estados de cobro.
--
-- Las marcamos como cobradas para evitar convertir
-- ventas históricas en deudas pendientes.
-- ============================================================

UPDATE public.sales
SET
  payment_status = 'paid_in_full',
  amount_paid = GREATEST(
    COALESCE(total, 0),
    0
  ),
  pending_amount = 0
WHERE status = 'registered';


-- Las anuladas nunca deben generar deuda.
UPDATE public.sales
SET
  pending_amount = 0
WHERE status = 'void';


-- ============================================================
-- 11. CORREGIR FLETE DE VENTAS EXISTENTES
--
-- Recoge en planta jamás debe guardar flete.
-- ============================================================

UPDATE public.sales
SET freight_amount = 0
WHERE delivery_mode = 'customer_pickup'
  AND COALESCE(freight_amount, 0) <> 0;


-- ============================================================
-- 12. RECALCULAR TODAS LAS VENTAS EXISTENTES
-- ============================================================

DO $$
DECLARE
  v_sale record;
BEGIN

  FOR v_sale IN
    SELECT id
    FROM public.sales
  LOOP

    PERFORM public.recalculate_sale_total(
      v_sale.id
    );

  END LOOP;

END
$$;


-- ============================================================
-- 13. ÍNDICE PARA BUSCAR COBROS PENDIENTES
-- ============================================================

CREATE INDEX IF NOT EXISTS
  idx_sales_payment_status
ON public.sales (
  payment_status
);


CREATE INDEX IF NOT EXISTS
  idx_sales_seller_payment_status
ON public.sales (
  seller_id,
  payment_status
);


-- ============================================================
-- 14. ACTUALIZAR LA VISTA DE HISTORIAL
-- ============================================================

DROP VIEW IF EXISTS public.v_sales;


CREATE OR REPLACE VIEW public.v_sales
WITH (security_invoker = true)
AS
SELECT
  s.id,
  s.number,
  s.sale_date,

  -- Total final de la venta.
  s.total,

  -- HU-02
  s.delivery_mode,
  s.freight_amount,

  -- Método utilizado:
  -- cash / transfer / qr
  s.payment_method,

  -- HU-04:
  -- paid_in_full / partial / pending
  s.payment_status,

  -- HU-04
  s.amount_paid,
  s.pending_amount,

  c.name AS client_name,
  c.ci AS client_ci

FROM public.sales s

JOIN public.clients c
  ON c.id = s.client_id

WHERE
  s.seller_id = (
    SELECT auth.uid()
  )

  AND s.status =
    'registered'::public.sale_status;


REVOKE ALL
ON public.v_sales
FROM PUBLIC;


GRANT SELECT
ON public.v_sales
TO authenticated;
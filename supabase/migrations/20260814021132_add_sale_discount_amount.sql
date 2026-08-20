-- Migracion: agrega descuento global y flete a las ventas y los aplica en el RPC.

ALTER TABLE public.sales
  ADD COLUMN discount_amount numeric(10,2) NOT NULL DEFAULT 0,
  ADD COLUMN freight_amount numeric(10,2) NOT NULL DEFAULT 0,
  ADD CONSTRAINT sales_discount_amount_non_negative
    CHECK (discount_amount >= 0),
  ADD CONSTRAINT sales_freight_amount_non_negative
    CHECK (freight_amount >= 0);

DROP FUNCTION public.register_sale(
  uuid,
  uuid,
  public.delivery_mode,
  public.payment_method,
  text,
  jsonb,
  jsonb
);

CREATE FUNCTION public.register_sale(
  p_client_id uuid,
  p_seller_id uuid,
  p_delivery_mode public.delivery_mode,
  p_payment_method public.payment_method,
  p_discount_amount numeric,
  p_freight_amount numeric,
  p_notes text,
  p_delivery jsonb,
  p_details jsonb
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
declare
  v_sale_id uuid;
  v_detail jsonb;
  v_product_unit_id uuid;
  v_quantity numeric(10, 2);
  v_unit_price numeric(10, 2);
  v_discount numeric(10, 2);
  v_subtotal numeric(10, 2);
  v_discount_amount numeric(10, 2) := coalesce(p_discount_amount, 0);
  v_freight_amount numeric(10, 2) := coalesce(p_freight_amount, 0);
  v_total numeric(10, 2) := 0;
begin
  if (select auth.uid()) is null then
    raise exception 'not authenticated' using errcode = '42501';
  end if;

  if p_seller_id <> (select auth.uid()) and not public.is_admin() then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  if not public.is_active() then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  if v_discount_amount < 0 then
    raise exception 'discount cannot be negative' using errcode = 'P0001';
  end if;

  if v_freight_amount < 0 then
    raise exception 'freight cannot be negative' using errcode = 'P0001';
  end if;

  if p_delivery_mode <> 'company_delivery'::public.delivery_mode then
    v_freight_amount := 0;
  end if;

  if not exists (
    select 1 from public.clients where id = p_client_id and active
  ) then
    raise exception 'client not available' using errcode = 'P0001';
  end if;

  if jsonb_typeof(p_details) <> 'array' or jsonb_array_length(p_details) = 0 then
    raise exception 'sale requires at least one detail' using errcode = 'P0001';
  end if;

  insert into public.sales (
    client_id,
    seller_id,
    delivery_mode,
    payment_method,
    discount_amount,
    freight_amount,
    total,
    notes
  )
  values (
    p_client_id,
    p_seller_id,
    p_delivery_mode,
    p_payment_method,
    v_discount_amount,
    v_freight_amount,
    0,
    p_notes
  )
  returning id into v_sale_id;

  for v_detail in select * from jsonb_array_elements(p_details) loop
    v_product_unit_id := (v_detail ->> 'product_unit_id')::uuid;
    v_quantity := (v_detail->>'quantity')::numeric;
    v_unit_price := (v_detail->>'unit_price')::numeric;
    v_discount := coalesce((v_detail->>'discount')::numeric, 0);

    if v_quantity <= 0 then
      raise exception 'quantity must be positive' using errcode = 'P0001';
    end if;

    if v_unit_price < 0 or v_discount < 0 then
      raise exception 'negative amounts not allowed' using errcode = 'P0001';
    end if;

    if v_discount > v_quantity * v_unit_price then
      raise exception 'discount exceeds line total' using errcode = 'P0001';
    end if;

    if not exists (
      select 1
      from public.product_units pu
      join public.products p on p.id = pu.product_id
      where pu.id = v_product_unit_id and pu.active and p.active
    ) then
      raise exception 'product unit not available' using errcode = 'P0001';
    end if;

    insert into public.sale_details (
      sale_id,
      product_unit_id,
      quantity,
      unit_price,
      discount
    )
    values (
      v_sale_id,
      v_product_unit_id,
      v_quantity,
      v_unit_price,
      v_discount
    );

    v_subtotal := v_quantity * v_unit_price - v_discount;
    v_total := v_total + v_subtotal;
  end loop;

  if p_delivery is not null and jsonb_typeof(p_delivery) <> 'null' then
    insert into public.sale_deliveries (
      sale_id,
      delivery_address,
      vehicle_plate,
      delivery_date
    )
    values (
      v_sale_id,
      nullif(p_delivery->>'delivery_address', ''),
      nullif(p_delivery->>'vehicle_plate', ''),
      (p_delivery->>'delivery_date')::timestamptz
    );
  end if;

  update public.sales
  set total = greatest(0, v_total - v_discount_amount + v_freight_amount)
  where id = v_sale_id;

  return v_sale_id;
end;
$function$;

REVOKE EXECUTE ON FUNCTION public.register_sale(
  uuid,
  uuid,
  public.delivery_mode,
  public.payment_method,
  numeric,
  numeric,
  text,
  jsonb,
  jsonb
) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.register_sale(
  uuid,
  uuid,
  public.delivery_mode,
  public.payment_method,
  numeric,
  numeric,
  text,
  jsonb,
  jsonb
) TO authenticated;

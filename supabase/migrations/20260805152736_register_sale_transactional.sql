-- Migración: registra una venta de forma transaccional y evita montos negativos.

-- Sanea filas heredadas de datos de prueba antes de restringir: ningún
-- descuento negativo ni mayor que el importe de la línea, ninguna cantidad
-- nula o negativa.
UPDATE public.sale_details
SET discount = GREATEST(0, LEAST(discount, quantity * unit_price))
WHERE discount < 0 OR discount > quantity * unit_price;

UPDATE public.sale_details
SET quantity = 1
WHERE quantity <= 0;

-- Las líneas de venta no pueden dejar un importe negativo: la cantidad es
-- positiva y el descuento nunca puede superar el importe de la línea.
ALTER TABLE public.sale_details
  ADD CONSTRAINT sale_details_quantity_positive
    CHECK (quantity > 0),
  ADD CONSTRAINT sale_details_discount_range
    CHECK (discount >= 0 AND discount <= (quantity * unit_price));

CREATE OR REPLACE FUNCTION public.register_sale(
  p_client_id uuid,
  p_seller_id uuid,
  p_delivery_mode public.delivery_mode,
  p_payment_method public.payment_method,
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
    total,
    notes
  )
  values (
    p_client_id,
    p_seller_id,
    p_delivery_mode,
    p_payment_method,
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

  if p_delivery_mode = 'company_delivery'::public.delivery_mode
     and (p_delivery is null or nullif(p_delivery->>'delivery_address', '') is null) then
    raise exception 'delivery address required' using errcode = 'P0001';
  end if;

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
  set total = v_total
  where id = v_sale_id;

  return v_sale_id;
end;
$function$;

REVOKE EXECUTE ON FUNCTION public.register_sale(
  uuid,
  uuid,
  public.delivery_mode,
  public.payment_method,
  text,
  jsonb,
  jsonb
) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.register_sale(
  uuid,
  uuid,
  public.delivery_mode,
  public.payment_method,
  text,
  jsonb,
  jsonb
) TO authenticated;
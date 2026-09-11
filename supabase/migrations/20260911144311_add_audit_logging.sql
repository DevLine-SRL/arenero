
ALTER TABLE public.audit_logs
  ADD COLUMN metadata jsonb;

ALTER TABLE public.audit_logs
  DROP CONSTRAINT audit_logs_changed_by_fkey;

ALTER TABLE public.audit_logs
  ADD CONSTRAINT audit_logs_changed_by_fkey
  FOREIGN KEY (changed_by) REFERENCES public.profiles(id)
  ON DELETE SET NULL;

ALTER TABLE public.audit_logs
  ADD CONSTRAINT audit_logs_action_check
  CHECK (
    action IN (
      'INSERT',
      'UPDATE',
      'TOGGLE_ACTIVE',
      'UNIT_PRICE_UPDATE',
      'SALE_REGISTERED',
      'SALE_VOIDED',
      'PAYMENT_UPDATED'
    )
  );

CREATE INDEX idx_audit_logs_affected_record
  ON public.audit_logs (affected_table, record_id, changed_at DESC);

CREATE INDEX idx_audit_logs_changed_at
  ON public.audit_logs (changed_at DESC);


CREATE FUNCTION public.log_audit(
  p_affected_table text,
  p_record_id uuid,
  p_action text,
  p_old_data jsonb DEFAULT NULL,
  p_new_data jsonb DEFAULT NULL,
  p_metadata jsonb DEFAULT NULL
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
begin
  insert into public.audit_logs (
    affected_table,
    record_id,
    action,
    old_data,
    new_data,
    metadata,
    changed_by
  )
  values (
    p_affected_table,
    p_record_id,
    p_action,
    p_old_data,
    p_new_data,
    p_metadata,
    (select auth.uid())
  );
end;
$function$;

REVOKE EXECUTE ON FUNCTION public.log_audit(text, uuid, text, jsonb, jsonb, jsonb) FROM PUBLIC;


REVOKE INSERT, UPDATE, DELETE ON public.audit_logs FROM authenticated;


CREATE OR REPLACE FUNCTION public.register_sale(
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
  v_details jsonb;
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

  v_details := coalesce(
    (
      select jsonb_agg(
        jsonb_build_object(
          'product_unit_id', product_unit_id,
          'quantity', quantity,
          'unit_price', unit_price,
          'discount', discount
        )
        order by product_unit_id
      )
      from public.sale_details
      where sale_id = v_sale_id
    ),
    '[]'::jsonb
  );

  perform public.log_audit(
    'sales',
    v_sale_id,
    'SALE_REGISTERED',
    null,
    jsonb_build_object(
      'number', (select number from public.sales where id = v_sale_id),
      'client_id', p_client_id,
      'seller_id', p_seller_id,
      'delivery_mode', p_delivery_mode,
      'payment_method', p_payment_method,
      'discount_amount', v_discount_amount,
      'freight_amount', v_freight_amount,
      'total', greatest(0, v_total - v_discount_amount + v_freight_amount),
      'notes', p_notes,
      'details', v_details
    ),
    jsonb_build_object(
      'details_count',
      (select count(*)::int from public.sale_details where sale_id = v_sale_id)
    )
  );

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


CREATE OR REPLACE FUNCTION public.void_sale(p_sale_id uuid)
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

  perform public.log_audit(
    'sales',
    p_sale_id,
    'SALE_VOIDED',
    jsonb_build_object('status', v_status),
    jsonb_build_object('status', 'void'),
    null
  );
end;
$function$;

REVOKE EXECUTE ON FUNCTION public.void_sale(uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.void_sale(uuid) TO authenticated;


CREATE FUNCTION public.audit_sales_payment_changes()
  RETURNS trigger
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
begin
  if tg_op = 'UPDATE'
     and (old.payment_status is distinct from new.payment_status
       or old.amount_paid is distinct from new.amount_paid) then
    perform public.log_audit(
      'sales',
      new.id,
      'PAYMENT_UPDATED',
      jsonb_build_object(
        'payment_status', old.payment_status,
        'amount_paid', old.amount_paid,
        'pending_amount', old.pending_amount
      ),
      jsonb_build_object(
        'payment_status', new.payment_status,
        'amount_paid', new.amount_paid,
        'pending_amount', new.pending_amount
      ),
      null
    );
  end if;

  return new;
end;
$function$;

CREATE TRIGGER trg_audit_sales_payment
  AFTER UPDATE ON public.sales
  FOR EACH ROW
  EXECUTE FUNCTION public.audit_sales_payment_changes();


CREATE FUNCTION public.audit_profiles_changes()
  RETURNS trigger
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
declare
  v_old jsonb;
  v_new jsonb;
begin
  if tg_op = 'INSERT' then
    perform public.log_audit(
      'profiles',
      new.id,
      'INSERT',
      null,
      jsonb_build_object(
        'name', new.name,
        'email', new.email,
        'role', new.role,
        'active', new.active
      ),
      null
    );
    return new;
  end if;

  if tg_op = 'UPDATE' then
    v_old := jsonb_build_object(
      'name', old.name,
      'email', old.email,
      'role', old.role,
      'active', old.active
    );
    v_new := jsonb_build_object(
      'name', new.name,
      'email', new.email,
      'role', new.role,
      'active', new.active
    );

    if v_old <> v_new then
      if old.name = new.name
         and old.email = new.email
         and old.role = new.role
         and old.active is distinct from new.active then
        perform public.log_audit('profiles', new.id, 'TOGGLE_ACTIVE', v_old, v_new, null);
      else
        perform public.log_audit('profiles', new.id, 'UPDATE', v_old, v_new, null);
      end if;
    end if;
    return new;
  end if;

  return null;
end;
$function$;

CREATE TRIGGER trg_audit_profiles
  AFTER INSERT OR UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.audit_profiles_changes();


CREATE FUNCTION public.audit_clients_changes()
  RETURNS trigger
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
declare
  v_old jsonb;
  v_new jsonb;
begin
  if tg_op = 'INSERT' then
    perform public.log_audit(
      'clients',
      new.id,
      'INSERT',
      null,
      jsonb_build_object(
        'name', new.name,
        'ci', new.ci,
        'phone', new.phone,
        'nit', new.nit,
        'active', new.active
      ),
      null
    );
    return new;
  end if;

  if tg_op = 'UPDATE' then
    v_old := jsonb_build_object(
      'name', old.name,
      'ci', old.ci,
      'phone', old.phone,
      'nit', old.nit,
      'active', old.active
    );
    v_new := jsonb_build_object(
      'name', new.name,
      'ci', new.ci,
      'phone', new.phone,
      'nit', new.nit,
      'active', new.active
    );

    if v_old <> v_new then
      if old.name = new.name
         and old.ci = new.ci
         and old.phone = new.phone
         and old.nit = new.nit
         and old.active is distinct from new.active then
        perform public.log_audit('clients', new.id, 'TOGGLE_ACTIVE', v_old, v_new, null);
      else
        perform public.log_audit('clients', new.id, 'UPDATE', v_old, v_new, null);
      end if;
    end if;
    return new;
  end if;

  return null;
end;
$function$;

CREATE TRIGGER trg_audit_clients
  AFTER INSERT OR UPDATE ON public.clients
  FOR EACH ROW
  EXECUTE FUNCTION public.audit_clients_changes();


CREATE FUNCTION public.audit_products_changes()
  RETURNS trigger
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
declare
  v_old jsonb;
  v_new jsonb;
begin
  if tg_op = 'INSERT' then
    perform public.log_audit(
      'products',
      new.id,
      'INSERT',
      null,
      jsonb_build_object(
        'name', new.name,
        'active', new.active
      ),
      null
    );
    return new;
  end if;

  if tg_op = 'UPDATE' then
    v_old := jsonb_build_object(
      'name', old.name,
      'active', old.active
    );
    v_new := jsonb_build_object(
      'name', new.name,
      'active', new.active
    );

    if v_old <> v_new then
      if old.name = new.name
         and old.active is distinct from new.active then
        perform public.log_audit('products', new.id, 'TOGGLE_ACTIVE', v_old, v_new, null);
      else
        perform public.log_audit('products', new.id, 'UPDATE', v_old, v_new, null);
      end if;
    end if;
    return new;
  end if;

  return null;
end;
$function$;

CREATE TRIGGER trg_audit_products
  AFTER INSERT OR UPDATE ON public.products
  FOR EACH ROW
  EXECUTE FUNCTION public.audit_products_changes();


CREATE FUNCTION public.audit_product_units_changes()
  RETURNS trigger
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
declare
  v_old jsonb;
  v_new jsonb;
begin
  if tg_op = 'INSERT' then
    perform public.log_audit(
      'product_units',
      new.id,
      'INSERT',
      null,
      jsonb_build_object(
        'product_id', new.product_id,
        'unit', new.unit,
        'unit_price', new.unit_price,
        'active', new.active
      ),
      null
    );
    return new;
  end if;

  if tg_op = 'UPDATE' then
    v_old := jsonb_build_object(
      'unit', old.unit,
      'unit_price', old.unit_price,
      'active', old.active
    );
    v_new := jsonb_build_object(
      'unit', new.unit,
      'unit_price', new.unit_price,
      'active', new.active
    );

    if v_old <> v_new then
      if old.unit_price is distinct from new.unit_price then
        perform public.log_audit(
          'product_units',
          new.id,
          'UNIT_PRICE_UPDATE',
          v_old,
          v_new,
          jsonb_build_object('product_id', new.product_id)
        );
      elsif old.active is distinct from new.active then
        perform public.log_audit(
          'product_units',
          new.id,
          'TOGGLE_ACTIVE',
          v_old,
          v_new,
          jsonb_build_object('product_id', new.product_id)
        );
      else
        perform public.log_audit(
          'product_units',
          new.id,
          'UPDATE',
          v_old,
          v_new,
          jsonb_build_object('product_id', new.product_id)
        );
      end if;
    end if;
    return new;
  end if;

  return null;
end;
$function$;

CREATE TRIGGER trg_audit_product_units
  AFTER INSERT OR UPDATE ON public.product_units
  FOR EACH ROW
  EXECUTE FUNCTION public.audit_product_units_changes();

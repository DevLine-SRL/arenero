CREATE UNIQUE INDEX IF NOT EXISTS products_normalized_name_key
  ON public.products (lower(regexp_replace(btrim(name), '[[:space:]]+', ' ', 'g')));

CREATE OR REPLACE FUNCTION public.create_product(
  p_name text,
  p_unit public.unit_of_measure,
  p_unit_price numeric
)
  RETURNS uuid
  LANGUAGE plpgsql
  SET search_path = ''
  AS $function$
declare
  v_name text;
  v_product_id uuid;
begin
  if not public.is_active() or not public.is_admin() then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  v_name := regexp_replace(btrim(p_name), '[[:space:]]+', ' ', 'g');

  if nullif(v_name, '') is null then
    raise exception 'product name required' using errcode = '22023';
  end if;

  if p_unit_price <= 0 then
    raise exception 'invalid product unit price' using errcode = '22023';
  end if;

  insert into public.products (name)
  values (v_name)
  returning id into v_product_id;

  insert into public.product_units (product_id, unit, unit_price)
  values (v_product_id, p_unit, p_unit_price);

  return v_product_id;
exception
  when unique_violation then
    raise exception 'product already exists' using errcode = '23505';
end;
$function$;

REVOKE EXECUTE ON FUNCTION public.create_product(text, public.unit_of_measure, numeric) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.create_product(text, public.unit_of_measure, numeric) TO authenticated;

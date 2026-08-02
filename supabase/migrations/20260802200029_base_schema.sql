CREATE TYPE public.delivery_mode AS ENUM (
  'customer_pickup',
  'company_delivery'
);

CREATE TYPE public.payment_method AS ENUM (
  'cash',
  'transfer',
  'qr'
);

CREATE TYPE public.sale_status AS ENUM (
  'registered',
  'void'
);

CREATE TYPE public.unit_of_measure AS ENUM (
  'm3',
  'bag',
  'kg',
  'ton',
  'unit'
);

CREATE FUNCTION public.set_updated_at()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$;

CREATE TABLE public.clients (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name       text NOT NULL,
  phone      text,
  ci         text NOT NULL UNIQUE,
  active     boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.client_addresses (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id  uuid NOT NULL REFERENCES public.clients(id) ON DELETE CASCADE,
  alias      text,
  address    text NOT NULL,
  reference  text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.products (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name       text NOT NULL,
  active     boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.product_units (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id      uuid NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  unit            public.unit_of_measure NOT NULL,
  unit_price      numeric(10,2) NOT NULL,
  active          boolean NOT NULL DEFAULT true,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE (product_id, unit)
);

CREATE TABLE public.sales (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id       uuid NOT NULL REFERENCES public.clients(id) ON DELETE RESTRICT,
  seller_id       uuid NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  sale_date       timestamptz NOT NULL DEFAULT now(),
  delivery_mode   public.delivery_mode NOT NULL,
  payment_method  public.payment_method NOT NULL,
  status          public.sale_status NOT NULL DEFAULT 'registered',
  total           numeric(10,2) NOT NULL DEFAULT 0,
  notes           text,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.sale_deliveries (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id              uuid NOT NULL UNIQUE REFERENCES public.sales(id) ON DELETE RESTRICT,
  delivery_address_id  uuid REFERENCES public.client_addresses(id) ON DELETE SET NULL,
  vehicle_plate        text,
  delivery_date        timestamptz,
  created_at           timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.sale_details (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id          uuid NOT NULL REFERENCES public.sales(id) ON DELETE RESTRICT,
  product_unit_id  uuid NOT NULL REFERENCES public.product_units(id) ON DELETE RESTRICT,
  quantity         numeric(10,2) NOT NULL,
  unit_price       numeric(10,2) NOT NULL,
  discount         numeric(10,2) NOT NULL DEFAULT 0,
  subtotal         numeric(10,2) GENERATED ALWAYS AS ((quantity * unit_price) - discount) STORED,
  UNIQUE (sale_id, product_unit_id)
);

CREATE TABLE public.audit_logs (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  affected_table text NOT NULL,
  record_id      uuid NOT NULL,
  action         text NOT NULL,
  old_data       jsonb,
  new_data       jsonb,
  changed_by     uuid REFERENCES public.profiles(id),
  changed_at     timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_clients_updated_at
  BEFORE UPDATE ON public.clients
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_products_updated_at
  BEFORE UPDATE ON public.products
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_product_units_updated_at
  BEFORE UPDATE ON public.product_units
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_sales_updated_at
  BEFORE UPDATE ON public.sales
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();


CREATE INDEX idx_sales_client_id
  ON public.sales(client_id);

CREATE INDEX idx_sales_seller_id
  ON public.sales(seller_id);

CREATE INDEX idx_sales_status
  ON public.sales(status);

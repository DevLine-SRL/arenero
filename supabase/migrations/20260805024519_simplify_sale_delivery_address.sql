-- Migración: simplifica la dirección de entrega de ventas a texto libre y
-- elimina la tabla client_addresses (no usada por la app).

-- La dirección de entrega pasa a ser texto libre en sale_deliveries.
ALTER TABLE public.sale_deliveries
  ADD COLUMN delivery_address text;

-- Se quita la referencia a client_addresses.
ALTER TABLE public.sale_deliveries
  DROP CONSTRAINT sale_deliveries_delivery_address_id_fkey;

ALTER TABLE public.sale_deliveries
  DROP COLUMN delivery_address_id;

-- client_addresses deja de existir; se eliminan de paso sus políticas y grants.
DROP TABLE public.client_addresses CASCADE;
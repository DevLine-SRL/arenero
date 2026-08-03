-- Migración: habilita RLS en clients y client_addresses.
-- Las tablas se crearon en 20260802200029_base_schema.sql sin RLS, así que
-- cualquier portador de la clave publicable podía leerlas y escribirlas.
-- Sin políticas de DELETE: las bajas son lógicas con la columna `active`.

-- clients

ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "clients_select" ON public.clients
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "clients_insert" ON public.clients
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "clients_update" ON public.clients
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "clients_block_inactive" ON public.clients
  AS RESTRICTIVE
  TO authenticated
  USING ((select public.is_active()));

-- client_addresses

ALTER TABLE public.client_addresses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "client_addresses_select" ON public.client_addresses
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "client_addresses_insert" ON public.client_addresses
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "client_addresses_update" ON public.client_addresses
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "client_addresses_block_inactive" ON public.client_addresses
  AS RESTRICTIVE
  TO authenticated
  USING ((select public.is_active()));

-- Nombre explícito para la restricción única de la cédula: el repositorio
-- distingue qué restricción se violó leyendo el mensaje del error 23505.

ALTER TABLE public.clients
  RENAME CONSTRAINT clients_ci_key TO clients_ci_unique;

-- Índices para la búsqueda de clientes por cédula y por nombre.

CREATE INDEX idx_clients_ci ON public.clients (ci);

CREATE INDEX idx_clients_name ON public.clients (lower(name));

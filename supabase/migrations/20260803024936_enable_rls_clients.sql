-- Migración: restricción única con nombre explícito e índices de búsqueda
-- para clients.
--
-- Originalmente esta migración también habilitaba RLS y creaba las políticas
-- de `clients` y `client_addresses`. Esa parte se eliminó porque
-- 20260802220000_rls_policies_rpc.sql ya las crea con los mismos nombres, y
-- corre antes: mantener ambas fallaba con
-- `policy "clients_select" for table "clients" already exists`.
-- Las políticas de esa migración son además más estrictas (verifican
-- `is_active()` e `is_admin()` dentro de cada política en vez de delegar en
-- una política RESTRICTIVE aparte).

-- Nombre explícito para la restricción única de la cédula: el repositorio
-- distingue qué restricción se violó leyendo el mensaje del error 23505.

ALTER TABLE public.clients
  RENAME CONSTRAINT clients_ci_key TO clients_ci_unique;

-- Índices para la búsqueda de clientes por cédula y por nombre.

CREATE INDEX idx_clients_ci ON public.clients (ci);

CREATE INDEX idx_clients_name ON public.clients (lower(name));

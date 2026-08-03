-- Migración: agrega el NIT del cliente.
-- El criterio de aceptación de la consulta de clientes exige buscar por
-- nombre, cédula o NIT, y el esquema base no contemplaba esta columna.
--
-- Es opcional y sin restricción de unicidad: solo la cédula identifica de
-- forma única al cliente. Si el negocio decide que el NIT también deba ser
-- único, se agrega con una migración nueva.

ALTER TABLE public.clients
  ADD COLUMN nit text;

CREATE INDEX idx_clients_nit ON public.clients (nit);

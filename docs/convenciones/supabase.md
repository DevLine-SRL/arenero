# Convenciones de Supabase — Arenero

Cómo se trabaja el backend **en este proyecto**. Para dudas generales de
Postgres o del cliente de Supabase, consulta las skills instaladas en
`.agents/skills/supabase/` y `.agents/skills/supabase-postgres-best-practices/`.

El backend es Supabase en la nube. Todo lo que lo define está versionado:
`supabase/migrations/` y `supabase/functions/`.

## Migraciones

Flujo obligatorio:

```bash
npx supabase migration new <nombre_descriptivo>   # crea el archivo
# editar supabase/migrations/<timestamp>_<nombre>.sql
npm run supabase:deploy                            # aplica a tu proyecto
npm run supabase:status                            # verifica
git add supabase/migrations/<archivo>.sql
```

Reglas:

- **Nunca edites una migración ya commiteada.** Los demás ya la aplicaron.
  Crea una nueva que corrija.
- **Nunca escribas SQL a mano en el SQL Editor del dashboard.** Crea los
  objetos sin registrar el historial y rompe el siguiente `db push` con
  `type "X" already exists`.
- Una migración, un propósito. Si arreglas un problema de seguridad, no
  aproveches para añadir una tabla.
- Encabeza el archivo con un comentario de una línea diciendo qué hace.

Los archivos llevan timestamp, así que dos personas pueden crear migraciones
en paralelo sin conflicto textual. Lo que sí hay que coordinar es el orden:
si tu migración depende de una tabla que crea otra persona, espera a que la
suya esté en `main`.

### Historial desincronizado

Si `db push` falla con `migration history does not match`:

```bash
npx supabase migration repair --linked --status applied <version>
npx supabase migration list --linked
```

## RLS

**Toda tabla nueva nace con RLS y políticas en la misma migración que la
crea.** Sin RLS, cualquier portador de la clave publicable lee y escribe la
tabla entera; la clave publicable está en el binario de la app, así que la
tiene cualquiera que la instale.

Estado actual: solo `public.profiles` tiene RLS. Las tablas creadas en
`20260802200029_base_schema.sql` quedaron sin él. Se van cubriendo conforme
cada equipo toma su módulo.

### Plantilla

```sql
ALTER TABLE public.<tabla> ENABLE ROW LEVEL SECURITY;

-- Lectura para usuarios autenticados
CREATE POLICY "<tabla>_select" ON public.<tabla>
  FOR SELECT
  TO authenticated
  USING (true);

-- Escritura
CREATE POLICY "<tabla>_insert" ON public.<tabla>
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "<tabla>_update" ON public.<tabla>
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Los usuarios desactivados no pasan de aquí
CREATE POLICY "<tabla>_block_inactive" ON public.<tabla>
  AS RESTRICTIVE
  TO authenticated
  USING ((select public.is_active()));
```

Detalles que no son opcionales:

- **`TO authenticated` en cada política.** Sin la cláusula, el rol `anon`
  también coincide y cualquiera sin sesión entra.
- **Envuelve las funciones de contexto en subconsulta:** `(select auth.uid())`,
  `(select public.is_admin())`, `(select public.is_active())`. Postgres
  evalúa el resultado una vez en lugar de una vez por fila. Sin esto, un
  listado de mil filas hace mil llamadas.
- **Política `RESTRICTIVE` para usuarios inactivos.** Las políticas normales
  se combinan con `OR`; las restrictivas con `AND`. Bloquear al usuario
  desactivado necesita `AND`, así que tiene que ser restrictiva.
- **Sin política de `DELETE`.** Las bajas son lógicas, con la columna
  `active`. Si no hay política, el `DELETE` está denegado, que es lo que
  queremos.
- Restringe a administradores con `(select public.is_admin())` en el `USING`
  o `WITH CHECK` de la operación que corresponda.

Estas reglas salieron de corregir problemas reales en
`20260801141800_fix_policy_security.sql`. Están escritas para no repetirlos.

## Funciones

Toda función `SECURITY DEFINER`:

- lleva `SET search_path = ''`,
- califica cada referencia con su esquema (`public.profiles`, no `profiles`),
- se revoca de `PUBLIC` y se concede solo al rol que la necesita:

```sql
REVOKE EXECUTE ON FUNCTION public.<funcion>() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.<funcion>() TO authenticated;
```

Sin `search_path` fijo, un usuario puede crear un esquema propio y secuestrar
los nombres que la función resuelve, ejecutando su código con los privilegios
del dueño de la función.

Funciones de contexto disponibles: `public.is_admin()`, `public.is_active()`.

## Query directa contra Edge Function

- **Query directa** desde el cliente cuando RLS basta para autorizar. Es lo
  normal.
- **Edge Function** cuando hace falta `service_role`: operaciones sobre
  `auth.users`, o cualquier cosa que deba saltarse los límites que RLS impone
  al usuario. Ejemplo: `supabase/functions/create-seller/index.ts` crea un
  usuario de autenticación, algo que el cliente no puede hacer.

Si dudas: si la operación se puede expresar como una política, es query
directa.

### Contrato de las Edge Functions

Error con esta forma:

```json
{ "error": { "code": "UPPER_SNAKE_CASE" } }
```

El repositorio del cliente mapea el `code`, **nunca el texto del mensaje**.
Así se puede cambiar la redacción sin romper la app. Patrón en
`_mapCreateSellerError` de `sellers_repository_impl.dart`.

Despliegue: `npm run supabase:deploy` también sube las funciones.

## Códigos de error de Postgres

El cliente de Supabase lanza `PostgrestException` con un `code`. Los que
importan:

| Código | Significado | Failure |
|---|---|---|
| `23505` | Violación de restricción única | `ValidationFailure` |
| `23503` | Violación de clave foránea | `ValidationFailure` |
| `23502` | Columna obligatoria nula | `ValidationFailure` |
| `42501` | Permiso insuficiente o bloqueado por RLS | `UnauthorizedFailure` |
| `PGRST116` | La consulta no devolvió filas | `NotFoundFailure` |

Para distinguir *cuál* restricción única se violó, mira el nombre de la
restricción en `PostgrestException.message`. Por eso conviene que las
restricciones tengan nombre explícito.

Un error de red no trae código de Postgres: se detecta por el tipo de
excepción y se traduce a `NetworkFailure`.

## Convenciones de esquema

- `snake_case` en tablas y columnas.
- Nombres de tabla en plural: `clients`, `products`, `sales`.
- Clave primaria `id uuid PRIMARY KEY DEFAULT gen_random_uuid()`.
- `created_at timestamptz NOT NULL DEFAULT now()` en toda tabla.
- `updated_at timestamptz NOT NULL DEFAULT now()` más trigger:

  ```sql
  CREATE TRIGGER trg_<tabla>_updated_at
    BEFORE UPDATE ON public.<tabla>
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();
  ```

- Baja lógica con `active boolean NOT NULL DEFAULT true`. No se borran filas.
- Índice en toda columna de clave foránea que se use para filtrar.
- Tipos enumerados de Postgres para conjuntos cerrados de valores, como
  `public.app_role` o `public.payment_method`.

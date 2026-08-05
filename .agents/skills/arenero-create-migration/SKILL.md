---
name: arenero-create-migration
description: Create a Supabase migration for the Arenero project with mandatory RLS policies, correct SECURITY DEFINER settings and schema conventions already in place. Use whenever the database schema changes - new table, new column, new policy, new function - so the migration history stays valid and no table ships without row level security.
---

# Crear una migración de Supabase en Arenero

Genera migraciones que no dejen tablas sin protección ni rompan el historial.

Lee `docs/convenciones/supabase.md` si no lo has hecho en esta sesión.

## Flujo obligatorio

```bash
npx supabase migration new <nombre_descriptivo>
# editar supabase/migrations/<timestamp>_<nombre>.sql
npm run supabase:deploy
npm run supabase:status
git add supabase/migrations/<archivo>.sql
```

**Nunca** crees el archivo `.sql` a mano: el timestamp lo asigna el CLI y de
él depende el orden de aplicación.

**Nunca** edites una migración ya commiteada; los demás ya la aplicaron.
Corrige con una migración nueva.

**Nunca** ejecutes SQL en el SQL Editor del dashboard: crea objetos sin
registrar el historial y el siguiente `db push` falla con
`type "X" already exists`.

## Regla central

Una tabla nueva **no se commitea sin RLS**. La clave publicable viaja dentro
del binario de la app; sin RLS cualquiera que instale la app lee y escribe la
tabla completa.

Si la migración incluye `CREATE TABLE`, tiene que incluir en el mismo archivo:

1. `ALTER TABLE ... ENABLE ROW LEVEL SECURITY;`
2. Una política por operación permitida.
3. La política `RESTRICTIVE` que bloquea usuarios desactivados.

## Plantilla de tabla

```sql
-- Migración: <qué hace, una línea>

CREATE TABLE public.<tabla> (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name       text NOT NULL,
  active     boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_<tabla>_updated_at
  BEFORE UPDATE ON public.<tabla>
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.<tabla> ENABLE ROW LEVEL SECURITY;

CREATE POLICY "<tabla>_select" ON public.<tabla>
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "<tabla>_insert" ON public.<tabla>
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "<tabla>_update" ON public.<tabla>
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "<tabla>_block_inactive" ON public.<tabla>
  AS RESTRICTIVE
  TO authenticated
  USING ((select public.is_active()));
```

Ajusta el alcance de cada política a lo que pida la historia de usuario. Para
restringir a administradores, cambia el `USING` o el `WITH CHECK` por
`(select public.is_admin())`.

## Errores que esta plantilla evita

| Omisión | Consecuencia |
|---|---|
| Falta `TO authenticated` | El rol `anon` también coincide: acceso sin sesión |
| `auth.uid()` sin subconsulta | Se reevalúa una vez por fila; listados lentos |
| Política de inactivos no `RESTRICTIVE` | Las políticas normales se combinan con `OR`, así que el bloqueo no aplica |
| Se declara política de `DELETE` | Las bajas son lógicas con `active`; sin política, `DELETE` queda denegado, que es lo correcto |
| `SECURITY DEFINER` sin `SET search_path = ''` | Un usuario puede secuestrar la resolución de nombres y ejecutar código con privilegios ajenos |

## Funciones

```sql
CREATE FUNCTION public.<nombre>()
  RETURNS <tipo>
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
  select ... from public.<tabla> ...
$function$;

REVOKE EXECUTE ON FUNCTION public.<nombre>() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.<nombre>() TO authenticated;
```

Califica cada referencia con su esquema. Con `search_path = ''` los nombres
sin calificar no resuelven.

## Convenciones de esquema

- `snake_case`; nombres de tabla en plural.
- `id uuid PRIMARY KEY DEFAULT gen_random_uuid()`.
- `created_at` y `updated_at` `timestamptz NOT NULL DEFAULT now()`.
- Baja lógica con `active boolean NOT NULL DEFAULT true`.
- Índice en cada clave foránea que se use para filtrar.
- Restricciones únicas con nombre explícito, para poder identificarlas desde
  el mensaje de error de Postgres.
- Tipos enumerados de Postgres para conjuntos cerrados de valores.

## Verificación

```bash
npm run supabase:status
```

La migración tiene que aparecer aplicada. Si falla con
`migration history does not match`:

```bash
npx supabase migration repair --linked --status applied <version>
npx supabase migration list --linked
```

## Después

Avisa al equipo: quien haga `git pull` tiene que correr
`npm run supabase:deploy`.

# Arenero

---

## Requisitos previos

| Herramienta | Versión mínima | Notas |
|---|---|---|
| [Git](https://git-scm.com/) | — | Control de versiones |
| [Flutter](https://docs.flutter.dev/get-started/install) | 3.44+ (Dart 3.12+) | Canal stable. El proyecto exige Dart `^3.12.2` |
| [Node.js + npm](https://nodejs.org/) | Node 20+ | Necesario para el CLI de Supabase (`npx`) |
| [Docker](https://www.docker.com/products/docker-desktop/) | — | **Opcional**: solo para el stack local de Supabase |

> El CLI de Supabase **no se instala globalmente**: vive como devDependency de npm en el proyecto y se invoca con `npx supabase ...` (o con los scripts npm).

---

## Arquitectura de backend

El backend es **Supabase en la nube**. Todo lo que define el backend está **versionado en git**:

- `supabase/migrations/*.sql` — esquema (tablas, triggers, RLS, funciones)
- `supabase/functions/**` — Edge Functions (ej. `create-seller`)

El `.env` está en `.gitignore`: contiene la URL y las claves de **tu** proyecto y no se comparte. Solo el plan (migraciones + funciones) viaja por git.

---

## Primeros pasos

### 1. Clonar el repositorio

```bash
git clone git@github.com:DevLine-SRL/arenero.git
cd arenero
```

### 2. Instalar dependencias de Flutter

```bash
flutter pub get
```

### 3. Instalar el CLI de Supabase

```bash
npm install
```

### 4. Configurar el backend (primera vez)

```bash
cp .env.example .env        # pega la URL y las claves de tu proyecto
npm run supabase:setup      # login → link → migraciones → Edge Functions
```

- `supabase:setup` te pedirá el `--project-ref` (el subdominio de tu URL, ej. `<ref>.supabase.co`) y lo guarda.
- El `link` te pedirá el password de la DB de tu proyecto.

### 5. Ejecutar la app

```bash
flutter run --dart-define-from-file=.env
```

O con `--dart-define` directo:

```bash
flutter run \
  --dart-define=SUPABASE_URL='https://<ref>.supabase.co' \
  --dart-define=SUPABASE_PUBLISHABLE_KEY='sb_publishable_xxxxxxxx'
```

### 6. Crear usuario admin (primera vez)

1. Dashboard → **Authentication → Users → Add user** (ej. `admin@arenero.com`).
2. El trigger `on_auth_user_created` crea su fila en `profiles` automáticamente.
3. Para que sea admin y pueda iniciar sesión:

```sql
update public.profiles set role = 'admin', active = true where email = 'admin@arenero.com';
```

(Ejecuta el SQL en **SQL Editor**, o edita la fila en **Table Editor → profiles**: `role` es una columna de `profiles`, no de `auth.users`.)

---

## Mantener el backend al día

Después de cada `git pull` que incluya cambios en `supabase/`:

```bash
npm run supabase:deploy    # migraciones pendientes + Edge Functions
npm run supabase:status    # estado de migraciones y funciones
```

---

## Supabase

### Flujo de migraciones (obligatorio)

1. Todos los cambios de esquema viven en `supabase/migrations/<timestamp>_<nombre>.sql`.
2. Crear una migración nueva:

   ```bash
   npx supabase migration new <nombre_descriptivo>
   ```

3. Aplicarla a tu proyecto y revisar el estado:

   ```bash
   npm run supabase:deploy
   npm run supabase:status
   ```

4. Commit del archivo `.sql`.

> **Importante**: nunca pegues SQL a mano en el SQL Editor del dashboard. Eso crea los objetos **sin registrar el historial de migraciones** y rompe `db push` (error `type "X" already exists`).

### Reparar historial desincronizado

Si la nube tiene objetos sin historial (o a la inversa), `db push` falla con `migration history does not match`. Marca las versiones afectadas:

```bash
npx supabase migration repair --linked --status applied <version>
npx supabase migration list --linked
```

### Supabase local (alternativa opcional)

Si prefieres un backend 100% offline (requiere Docker, más pesado):

```bash
npx supabase start          # descarga imágenes Docker y aplica migraciones
npx supabase status -o env  # claves para el .env
```

Servicios útiles (puertos de `supabase/config.toml`):

| Servicio | URL |
|---|---|
| Studio (consola web) | http://127.0.0.1:54323 |
| API (REST/GraphQL) | http://127.0.0.1:54321 |
| Mailer de prueba (Inbucket) | http://127.0.0.1:54324 |
| Base de datos (Postgres) | `postgresql://postgres:postgres@127.0.0.1:54322/postgres` |

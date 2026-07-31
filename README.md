# Arenero

---

## Requisitos previos

| Herramienta | Versión mínima | Notas |
|---|---|---|
| [Git](https://git-scm.com/) | — | Control de versiones |
| [Flutter](https://docs.flutter.dev/get-started/install) | 3.44+ (Dart 3.12+) | Canal stable. El proyecto exige Dart `^3.12.2` |
| [Node.js + npm](https://nodejs.org/) | Node 20+ | Necesario para el CLI de Supabase (`npx`) |
| [Docker](https://www.docker.com/products/docker-desktop/) | — | Stack local de Supabase (motor + Compose) |

> El CLI de Supabase **no se instala globalmente**: vive como devDependency de npm en el proyecto y se invoca con `npx supabase ...`.

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

Verifica que quedó disponible:

```bash
npx supabase --version
```

### 4. Levantar Supabase local

```bash
npx supabase start
```

- La **primera vez** descarga las imágenes Docker (puede tardar unos minutos).
- Las migraciones de `supabase/migrations/` se aplican automáticamente al iniciar.

Servicios útiles (puertos de `supabase/config.toml`):

| Servicio | URL |
|---|---|
| Studio (consola web) | http://127.0.0.1:54323 |
| API (REST/GraphQL) | http://127.0.0.1:54321 |
| Mailer de prueba (Inbucket) | http://127.0.0.1:54324 |
| Base de datos (Postgres) | `postgresql://postgres:postgres@127.0.0.1:54322/postgres` |

### 5. Configurar las variables de entorno

Copia el template y edítalo:

```bash
cp .env.example .env
```

Para **desarrollo local**, obtén las claves que necesitas:

```bash
npx supabase status -o env
```

Usa los valores `API_URL` y `PUBLISHABLE_KEY`:

```
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxxxxxxx
```

> `.env` está en `.gitignore`, nunca se sube al repositorio. Para ver la plantilla versionada revisa [`.env.example`](.env.example).

### 6. Ejecutar la app

```bash
flutter run --dart-define-from-file=.env
```

O directamente con `--dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL='http://127.0.0.1:54321' \
  --dart-define=SUPABASE_PUBLISHABLE_KEY='sb_publishable_xxxxxxxx'
```

### 7. Crear un usuario de prueba (opcional)

1. Abre Studio (http://127.0.0.1:54323).
2. **Authentication → Users → Add user**, crea un usuario (ej. `admin@arenero.com`).
3. El trigger `on_auth_user_created` crea su fila en `profiles` automáticamente.
4. Para que sea admin y pueda iniciar sesión, en **Table Editor → profiles** pon `role = 'admin'` y `active = true`.

---

## Supabase

### Flujo de migraciones

1. Todos los cambios de esquema viven en `supabase/migrations/<timestamp>_<nombre>.sql`.
2. Crear una migración nueva:

   ```bash
   npx supabase migration new <nombre_descriptivo>
   ```

3. Aplicarla a la DB local:

   ```bash
   npx supabase db push --local
   ```

4. Revisar el estado:

   ```bash
   npx supabase migration list --local
   ```

### Sincronizar con la nube

1. Enlazar el proyecto local con el proyecto de la nube (te pedirá el password de la DB):

   ```bash
   npx supabase link --project-ref <project-ref>
   ```

   El `project-ref` es el subdominio de tu URL: `https://<project-ref>.supabase.co` (o el "Project ID" en el dashboard → Settings → General).

2. Aplicar las migraciones pendientes a la nube:

   ```bash
   npx supabase db push --linked
   ```

3. Si la nube tiene entradas de historial sin archivo local correspondiente, `db push` o `db pull` fallarán con `migration history does not match`. Repara el historial remoto marcando esas versiones como `reverted`:

   ```bash
   npx supabase migration repair --linked --status reverted <version>
   ```


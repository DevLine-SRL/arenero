# Reglas de desarrollo — Arenero

Instrucciones para cualquier agente de IA que trabaje en este repositorio
(Claude Code, Codex, Cursor, opencode, Gemini CLI). También son las reglas
para las personas.

Este archivo contiene solo reglas duras. Los detalles están en los documentos
enlazados al final; léelos cuando trabajes en el área correspondiente.

## Stack

Flutter 3.44+ / Dart 3.12+, Riverpod con generación de código, go_router,
dartz, Supabase (nube). Backend versionado en `supabase/`.

## Estructura

- Un feature vive en `lib/features/<feature>/` con las carpetas `domain/`,
  `data/` y `presentation/`.
- `domain/` no importa `data/`, no importa `presentation/` y no importa
  `package:flutter`.
- `data/` no importa `presentation/`.
- Un widget por archivo.
- **Providers de wiring** (datasource, repositorio, usecases): un único
  `*_providers.dart` por feature que agrupa todos los providers de inyección
  de dependencias.
- **Providers de estado** (controllers, formularios, queries de búsqueda): un
  provider por archivo.
- Prohibidos los barrel files dentro de `lib/features/`. Usa imports
  directos. `lib/shared/` sí puede tener barrels; los existentes se quedan.
- Código compartido entre features va en `lib/shared/`. Infraestructura de la
  aplicación (router, tema, layouts, providers globales) va en `lib/core/`.

## Código compartido

Antes de escribir una validación o un widget de uso común, mira si ya existe.
Duplicarlos es la forma más rápida de que dos módulos validen lo mismo de dos
maneras distintas.

- `lib/shared/validators/` — `required`, `minLength`, `maxLength`, `email`,
  `isNumber`, `min`, `max`, `matches`, `ci`, `nit`, `phone`. Se combinan con
  `compose`.
- `lib/shared/value_objects/` — `Email`, `Password`, `Ci`. Constructor privado
  más `static Either<Failure, T> create(String)`.
- `lib/shared/widgets/` — `RequiredLabel`, `showConfirmDialog`,
  `NotFoundPage`, `ForbiddenPage`.

Si tu módulo necesita una regla nueva de uso general, agrégala aquí y expórtala
en el barrel correspondiente.

## Errores

- Todo método de repositorio devuelve `Either<Failure, T>`.
- `Failure` es una `sealed class` en `lib/core/errors/failures.dart`. Elige el
  subtipo que comunique la causa; no colapses todo en `UnexpectedFailure`.
- El datasource lanza una excepción tipada propia del feature. El repositorio
  la traduce a `Failure`. La presentación nunca recibe una excepción de
  Supabase.

## Base de datos

- Toda tabla nueva nace con RLS habilitado y políticas explícitas **en la
  misma migración** que la crea.
- Nunca edites una migración ya commiteada. Crea una nueva.
- Nunca ejecutes SQL a mano en el dashboard de Supabase.

## Idioma

- Código, identificadores, nombres de archivo, ramas y commits: inglés.
- Mensajes al usuario, comentarios y documentación: español.

## Colaboración

- Antes de partir un feature entre dos personas, los contratos (entidad,
  modelo, interfaz de repositorio, interfaz de datasource) se mergean primero
  en un PR aparte. Ver `CONTRIBUTING.md`.
- Cambios mínimos en archivos compartidos: `lib/core/router/`,
  `lib/core/layouts/sidebar.dart`, `pubspec.yaml`.

## Antes de dar trabajo por terminado

```bash
dart format lib test
dart run build_runner build   # si tocaste providers
flutter analyze
flutter test
```

Los cuatro deben pasar. Los archivos `.g.dart` se commitean.

Para levantar la app hacen falta las claves del `.env`:

```bash
flutter run --dart-define-from-file=.env
```

## Cuando algo falla

**`build_runner` dice `Waiting for already-running build_runner`.** Quedó un
lock sin dueño porque un proceso murió a media escritura. Cortar con Ctrl-C no
alcanza: mata el envoltorio `dart`, no la VM que retiene el lock.

```bash
pkill -f 'build_runner.dart-'
rm -f .dart_tool/build/lock/build_runner.lock*
```

**Nunca corras dos `build_runner` a la vez.** Se bloquean mutuamente y dejan el
grafo de assets inconsistente.

**El `.g.dart` no se regenera y el build dice `skipped`.** El generador ignora
las librerías que no analizan. Si un archivo referencia un provider que aún no
existe, ni ese archivo ni su compañero se generan nunca. Sal del ciclo apartando
temporalmente los archivos que dan error, generando, y devolviéndolos.

**Gradle falla con `does not provide the required capabilities: [JAVA_COMPILER]`.**
Falta un JDK completo; los paquetes `jre-*` no traen compilador. Java 21, no 25:
Gradle y el plugin de Android todavía no soportan bien 25.

```bash
sudo dnf install java-21-openjdk-devel        # Fedora / Nobara
flutter config --jdk-dir /usr/lib/jvm/java-21-openjdk
```

**La consulta falla con `column ... does not exist`.** Alguien subió una
migración que tú no aplicaste: `npm run supabase:deploy`.

## Documentación

| Documento | Cuándo leerlo |
|---|---|
| `docs/convenciones/flutter.md` | Antes de escribir Dart en `lib/` |
| `docs/convenciones/supabase.md` | Antes de tocar `supabase/` |
| `CONTRIBUTING.md` | Antes de abrir una rama o un PR |
| `README.md` | Configuración del entorno |

## Skills

El repositorio trae skills en `.agents/skills/`:

- `arenero-create-feature-module`, `arenero-create-migration`,
  `arenero-add-feature-test` — específicas de este proyecto. Úsalas.
- `flutter-*`, `dart-*`, `supabase*` — conocimiento general instalado desde
  GitHub (ver `skills-lock.json`). Consúltalas para dudas genéricas del
  framework en vez de improvisar.

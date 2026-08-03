---
name: arenero-create-feature-module
description: Scaffold a new feature module in the Arenero Flutter app following the clean-architecture layout used by lib/features/sellers. Use when adding a new domain area (clients, products, sales) or when a feature folder only has a placeholder page and needs its domain, data and presentation layers.
---

# Crear un módulo de feature en Arenero

Genera el esqueleto de un feature respetando la arquitectura del proyecto.
Módulo de referencia: `lib/features/sellers/`.

Lee `docs/convenciones/flutter.md` antes de empezar si no lo has hecho en
esta sesión.

## Cuándo usar esto

- Se agrega un área de negocio nueva.
- Una carpeta de feature solo tiene una página placeholder.
- Dos personas van a trabajar el mismo feature y hacen falta los contratos.

## Entradas que necesitas

- Nombre del feature en inglés, singular y plural (`client` / `clients`).
- Tabla de Supabase asociada.
- Operaciones que el feature necesitará, **todas**, incluidas las de otras
  personas. La interfaz del repositorio es un acuerdo de equipo.

Si no las sabes, pregunta antes de generar. Una interfaz incompleta obliga a
tocarla después y eso genera el conflicto que queremos evitar.

## Estructura a generar

```
lib/features/<plural>/
  domain/
    entities/<singular>.dart
    repositories/<plural>_repository.dart
    usecases/<operacion>_usecase.dart
  data/
    models/<singular>_model.dart
    datasources/<plural>_remote_datasource.dart
    repositories/<plural>_repository_impl.dart
  presentation/
    pages/<plural>_page.dart
    providers/<plural>_providers.dart
    widgets/
```

## Orden de trabajo

1. **Entidad.** Inmutable, con `copyWith`. Sin imports de Flutter, Supabase
   ni JSON.
2. **Interfaz del repositorio.** Cada método devuelve
   `Future<Either<Failure, T>>`. Declara todas las operaciones acordadas.
3. **Modelo.** Extiende la entidad, agrega `fromJson` y `toJson` a mano. No
   uses `json_serializable`.
4. **Interfaz e implementación del datasource.** El `Impl` recibe el
   `SupabaseClient` por constructor. Lanza una excepción tipada propia del
   feature, nunca deja escapar la de Supabase.
5. **Implementación del repositorio.** Atrapa la excepción del datasource y
   la traduce al subtipo de `Failure` correcto (tabla en
   `docs/convenciones/flutter.md`). No colapses todo en `UnexpectedFailure`.
6. **Casos de uso.** Uno por operación, con un único método `call`.
7. **Providers.** En `<plural>_providers.dart`: datasource, repositorio y
   casos de uso. Un `@riverpod` por declaración.
8. **Registro de la ruta.** Agrega las constantes en
   `lib/core/router/route_paths.dart` y un `StatefulShellBranch` **al final**
   de la lista de `branches` en `lib/core/router/route_definitions.dart`. No
   reordenes las ramas existentes: hay índices escritos a mano en
   `adminBranchIndex`, en la lista `titles` de `main_layout.dart` y en los
   destinos de `bottom_nav_bar.dart`, y desalinearlos no produce ningún
   error visible.
9. **Navegación.** Agrega el título en `main_layout.dart` y el destino en
   `bottom_nav_bar.dart`, o en `sidebar.dart` si el módulo es solo para
   administradores.
10. **Codegen y verificación.**

```bash
dart run build_runner build --delete-conflicting-outputs
dart format lib
flutter analyze
flutter test
```

## Reglas que no se negocian

- `domain/` no importa `data/`, ni `presentation/`, ni `package:flutter`.
- Un widget por archivo, un provider por archivo.
- Sin barrel files dentro de `lib/features/`.
- Identificadores en inglés, mensajes al usuario en español.
- Si la tabla de Supabase todavía no tiene RLS, usa la skill
  `arenero-create-migration` antes de escribir el datasource.

## Plantillas

Ver `references/templates.md` para el código base de cada archivo.

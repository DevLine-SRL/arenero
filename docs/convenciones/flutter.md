# Convenciones de Flutter — Arenero

Cómo se programa Flutter **en este proyecto**. Para dudas generales del
framework, consulta las skills instaladas en `.agents/skills/flutter-*` y
`.agents/skills/dart-*`.

Módulo de referencia: `lib/features/sellers/`. Cuando dudes de dónde va algo,
mira cómo está resuelto ahí.

## Capas

```
lib/features/<feature>/
  domain/
    entities/          objetos de negocio, sin dependencias externas
    repositories/      interfaces abstractas
    usecases/          una operación de negocio por clase
  data/
    models/            extienden la entidad, saben de JSON
    datasources/       hablan con Supabase, lanzan excepciones tipadas
    repositories/      implementan la interfaz, traducen excepción a Failure
  presentation/
    pages/             una página por ruta
    providers/         un provider por archivo
    widgets/           un widget por archivo
```

Reglas de dependencia:

- `domain/` no importa `data/`, ni `presentation/`, ni `package:flutter`, ni
  `package:supabase_flutter`. Solo Dart puro y `dartz`.
- `data/` importa `domain/`. Nunca `presentation/`.
- `presentation/` importa `domain/`. Importa `data/` únicamente en el archivo
  de providers, para armar el grafo de dependencias.

## Entidades y modelos

La entidad es inmutable y no sabe de JSON:

```dart
class Client {
  final String id;
  final String name;
  final String? phone;
  final String ci;
  final bool active;

  const Client({ ... });

  Client copyWith({ ... }) { ... }
}
```

El modelo extiende la entidad y añade la serialización:

```dart
class ClientModel extends Client {
  const ClientModel({ ... });

  factory ClientModel.fromJson(Map<String, dynamic> json) { ... }

  Map<String, dynamic> toJson() { ... }
}
```

Este es el patrón de `SellerModel` sobre `Seller`. No uses `json_serializable`
por ahora: el proyecto no lo tiene configurado y añadirlo es decisión del
equipo.

## Manejo de errores

Flujo completo, en tres pasos.

**1. El datasource lanza una excepción tipada del feature.** No deja escapar
la excepción de Supabase:

```dart
class ClientsRemoteException implements Exception {
  final String? code;
  const ClientsRemoteException({this.code});
}
```

**2. El repositorio traduce a `Failure` y devuelve `Either`:**

```dart
Future<Either<Failure, Client>> createClient({ ... }) async {
  try {
    return Right(await remoteDataSource.createClient( ... ));
  } on ClientsRemoteException catch (e) {
    return Left(_mapError(e));
  }
}
```

**3. La presentación hace `switch` sobre el `sealed class Failure`.** Como es
`sealed`, el analizador exige cubrir todos los casos: si alguien añade un
subtipo, los `switch` incompletos fallan al compilar.

### Qué subtipo usar

`lib/core/errors/failures.dart` define estos. Elige por causa, no por
comodidad:

| Situación | Failure |
|---|---|
| Sin conexión de red | `NetworkFailure` |
| Sesión inválida o expirada | `UnauthorizedFailure` |
| Sin permisos para la operación | `UnauthorizedFailure` |
| Credenciales de login incorrectas | `InvalidCredentialsFailure` |
| Dato duplicado o rechazado por el servidor | `ValidationFailure` |
| Recurso inexistente | `NotFoundFailure` |
| Cualquier otra cosa | `UnexpectedFailure` |

`ValidationFailure` acepta además un mapa `errors` de campo a mensaje. Úsalo
cuando el error apunta a un campo concreto del formulario.

> **Patrón a no copiar:** `sellers_repository_impl.dart` traduce todos los
> errores a `UnexpectedFailure`, incluidos `FORBIDDEN` y `EMAIL_TAKEN`. Es
> deuda técnica conocida. Se corregirá cuando alguien trabaje en ese módulo.

## Casos de uso

Una clase por operación, con un único método `call`. Reciben datos crudos de
la presentación y construyen los value objects:

```dart
class CreateClientUseCase {
  final ClientsRepository repository;

  const CreateClientUseCase(this.repository);

  Future<Either<Failure, Client>> call({ ... }) { ... }
}
```

Si la operación no tiene lógica propia y solo reenvía al repositorio, el caso
de uso igual existe: mantiene a la presentación desacoplada del repositorio.

## Riverpod

Generación de código con `@riverpod` de `riverpod_annotation`. Tras editar
cualquier provider:

```bash
dart run build_runner build
```

Los `.g.dart` se commitean.

**Un provider por archivo.** `riverpod_generator` emite un `.g.dart` por
archivo fuente. Si agrupas providers, el archivo generado crece y sus
conflictos de merge son difíciles de resolver a mano. Excepción tolerada: el
archivo `<feature>_providers.dart` que arma el grafo de dependencias del
módulo (datasource, repositorio, casos de uso), porque son declaraciones de
una línea que cambian juntas.

Tipos de provider y cuándo usarlos:

| Tipo | Uso |
|---|---|
| Función simple `@riverpod` | Inyección de dependencias: datasource, repositorio, caso de uso |
| Clase `@riverpod` con `build()` async | Datos remotos. La UI los consume con `AsyncValue.when` |
| Clase `@riverpod` con `build()` sync | Estado de formulario |

Referencias: `sellers_providers.dart` (inyección),
`sellers_controller_provider.dart` (datos remotos),
`create_seller_form_provider.dart` (formulario).

## Formularios

El estado va en su propio archivo, es inmutable y tiene `copyWith`. El
notifier va en otro archivo. Patrón:
`create_seller_form_state.dart` + `create_seller_form_provider.dart`.

El estado guarda, por cada campo, el valor y su mensaje de error:

```dart
class CreateClientFormState {
  final String name;
  final String? nameError;
  // ...
  final bool isSubmitting;
  final String? submitError;
}
```

El notifier valida en cada `onXChanged` y vuelve a validar todo en `submit()`.
`submit()` devuelve `bool` y deja el mensaje del servidor en `submitError`.

Cuidado con `copyWith` y los campos de error: se asignan directo
(`nameError: nameError`, sin `??`) para poder limpiarlos pasando `null`. Es
intencional; no lo "arregles".

## Widgets

- Uno por archivo, en `presentation/widgets/`.
- `const` donde el analizador lo permita.
- Sin lógica de negocio. Un widget lee del provider y dispara callbacks.
- La página compone widgets; no dibuja formularios enteros.
- `ConsumerWidget` si solo lee; `ConsumerStatefulWidget` si tiene estado
  local de UI (visibilidad de contraseña, selección en lista).

Reutilizables en `lib/shared/widgets/`: `RequiredLabel` para etiquetas de
campo obligatorio, `showConfirmDialog` para confirmaciones.

## Validación

Dos mecanismos, con propósitos distintos:

- **`lib/shared/validators/`** — funciones `String? Function(String)` para
  reglas de campo de formulario: `required`, `minLength`, `maxLength`,
  `email`, `isNumber`, `matches`. Combínalas con `compose`.
- **`lib/shared/value_objects/`** — clases que garantizan una invariante y
  cruzan capas: `Email`, `Password`. Constructor privado más
  `static Either<Failure, T> create(String)`. Si un dato no puede existir
  inválido dentro del dominio, es un value object.

Regla: si la validación solo importa en el formulario, es un validador. Si el
dominio no debe poder representar el valor inválido, es un value object.

## Rutas

Toda la navegación vive en `lib/core/router/`:

- `route_paths.dart` — constantes `RoutePaths` y `RouteNames`. Agrega una de
  cada una para tu módulo.
- `route_definitions.dart` — un `StatefulShellBranch` por módulo dentro de
  `protectedRoutes`, más `adminOnlyRoutes` para las rutas restringidas.
- `app_router.dart` — el `GoRouter` y el guard de sesión y rol.

Es un archivo compartido por todo el equipo: agrega tu bloque al final de la
lista de `branches` y no reordenes los existentes.

### Riesgo conocido: los índices de rama están escritos a mano

`route_definitions.dart` declara `const adminBranchIndex = 4` apuntando a la
posición de la rama de vendedores. `main_layout.dart` indexa una lista
`titles` por el mismo número, y `bottom_nav_bar.dart` lista sus destinos en
ese mismo orden.

Insertar un módulo **antes** de la posición 4 desplaza las tres cosas: el
título de la AppBar deja de corresponder, los íconos de la barra inferior se
desalinean y el menú de administración navega a la rama equivocada. Nada de
eso da error de compilación ni excepción en tiempo de ejecución.

Mientras siga así: **agrega tu rama al final de la lista** y revisa
`adminBranchIndex`, `titles` y `_navBarDestinations` si tocas el orden.

Arreglarlo requiere refactorizar archivos compartidos por varias personas, así
que es una tarea que se acuerda con el equipo, no algo que se cuela dentro de
una historia de usuario.

## Textos

Identificadores en inglés, cadenas visibles en español. No hay capa de
internacionalización; si algún día se agrega, será una tarea propia.

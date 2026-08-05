---
name: arenero-add-feature-test
description: Add a test to the Arenero Flutter app in the right mirrored path, with the right test type, using the hand-written fakes and builders in test/support. Use when writing tests for a use case, repository, validator, value object, form provider or widget in this project.
---

# Escribir un test en Arenero

Coloca el test donde toca, del tipo que toca, con los fakes que ya existen.

## Dónde va

`test/` espeja `lib/` exactamente:

| Código | Test |
|---|---|
| `lib/features/clients/domain/usecases/create_client_usecase.dart` | `test/features/clients/domain/usecases/create_client_usecase_test.dart` |
| `lib/shared/validators/ci.dart` | `test/shared/validators/ci_test.dart` |
| `lib/features/clients/presentation/widgets/client_list_item.dart` | `test/features/clients/presentation/widgets/client_list_item_test.dart` |

Soporte compartido:

```
test/support/
  fakes/       fakes escritos a mano
  builders/    constructores de entidades para tests
```

## Qué se testea

| Elemento | Test | Obligatorio |
|---|---|---|
| Caso de uso con lógica propia | Unitario, con fake del repositorio | Sí |
| Caso de uso que solo reenvía | — | No |
| Validador | Unitario | Sí |
| Value object | Unitario, casos válido e inválido | Sí |
| Repositorio | Unitario: mapeo de excepción a `Failure` | Sí |
| Provider de formulario | Unitario con `ProviderContainer` | Sí |
| Widget con estado o validación | Widget test | Sí |
| Widget de presentación pura | — | No |
| Datasource | — | No, requiere red |

## Reglas

- **Sin `mockito` ni `mocktail`.** No están en `pubspec.yaml`. Los fakes se
  escriben a mano en `test/support/fakes/`. Agregar una dependencia de
  mocking es decisión del equipo, no tuya.
- **Reutiliza los fakes existentes** antes de escribir uno nuevo. Si el que
  hay no alcanza, extiéndelo; no crees un duplicado.
- **Un `group` por unidad probada**, con el nombre de la clase o función.
- **Nombres de test en inglés**, describiendo el comportamiento:
  `'returns ValidationFailure when ci is duplicated'`.
- Nada de red, nada de Supabase real, nada de `Supabase.instance`.

## Fake de repositorio

Implementa la interfaz y devuelve lo que la prueba necesite:

```dart
class FakeClientsRepository implements ClientsRepository {
  Either<Failure, Client>? createResult;
  int createCallCount = 0;

  @override
  Future<Either<Failure, Client>> createClient({ ... }) async {
    createCallCount++;
    return createResult ?? Right(buildClient());
  }

  @override
  Future<Either<Failure, List<Client>>> searchClients(String query) async {
    throw UnimplementedError();
  }
}
```

Los métodos que la prueba no usa lanzan `UnimplementedError`: si alguien los
llama sin querer, el test falla de forma evidente.

## Builder de entidad

Valores por defecto razonables, todo sobreescribible:

```dart
Client buildClient({
  String id = 'client-1',
  String name = 'Juan Pérez',
  String ci = '1234567',
  bool active = true,
}) {
  return Client(id: id, name: name, ci: ci, active: active);
}
```

Así un test al que solo le importa `ci` no tiene que inventar los demás
campos.

## Probar un provider

```dart
final container = ProviderContainer(
  overrides: [clientsRepositoryProvider.overrideWithValue(fake)],
);
addTearDown(container.dispose);

final notifier = container.read(createClientFormProvider.notifier);
```

`addTearDown(container.dispose)` no es opcional: sin él los providers quedan
vivos entre tests.

## Widget test

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [clientsRepositoryProvider.overrideWithValue(fake)],
    child: const MaterialApp(home: Scaffold(body: CreateClientDialog())),
  ),
);
```

Envuelve siempre en `MaterialApp` y `Scaffold`: los widgets del proyecto usan
`Theme.of(context)` y fallan sin ellos.

## Verificación

```bash
flutter test
flutter analyze
```

Ambos tienen que pasar antes de commitear.

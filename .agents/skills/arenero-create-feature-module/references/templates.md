# Plantillas de módulo

Sustituye `Client` / `client` / `clients` por el nombre de tu feature.

## Entidad

`lib/features/clients/domain/entities/client.dart`

```dart
class Client {
  final String id;
  final String name;
  final bool active;

  const Client({
    required this.id,
    required this.name,
    required this.active,
  });

  Client copyWith({
    String? id,
    String? name,
    bool? active,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      active: active ?? this.active,
    );
  }
}
```

## Interfaz del repositorio

`lib/features/clients/domain/repositories/clients_repository.dart`

```dart
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client.dart';

abstract class ClientsRepository {
  Future<Either<Failure, List<Client>>> getClients();

  Future<Either<Failure, Client>> createClient({required String name});
}
```

## Modelo

`lib/features/clients/data/models/client_model.dart`

```dart
import '../../domain/entities/client.dart';

class ClientModel extends Client {
  const ClientModel({
    required super.id,
    required super.name,
    required super.active,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'active': active};
  }
}
```

## Datasource

`lib/features/clients/data/datasources/clients_remote_datasource.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/client_model.dart';

abstract class ClientsRemoteDataSource {
  Future<List<ClientModel>> getClients();

  Future<ClientModel> createClient({required String name});
}

class ClientsRemoteDataSourceImpl implements ClientsRemoteDataSource {
  final supabase.SupabaseClient client;

  const ClientsRemoteDataSourceImpl(this.client);

  @override
  Future<List<ClientModel>> getClients() async {
    final rows = await client.from('clients').select().order('name');
    return [for (final row in rows) ClientModel.fromJson(row)];
  }

  @override
  Future<ClientModel> createClient({required String name}) async {
    final row = await client
        .from('clients')
        .insert({'name': name})
        .select()
        .single();
    return ClientModel.fromJson(row);
  }
}
```

El datasource deja subir `PostgrestException`. El repositorio la traduce; ese
es el único lugar donde se conoce el mapeo de códigos.

Si el feature necesita una excepción propia (por ejemplo para errores de
Edge Function), declárala al final del mismo archivo, como
`CreateSellerRemoteException`.

## Implementación del repositorio

`lib/features/clients/data/repositories/clients_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/failures.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/clients_repository.dart';
import '../datasources/clients_remote_datasource.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  final ClientsRemoteDataSource remoteDataSource;

  const ClientsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Client>>> getClients() async {
    try {
      return Right(await remoteDataSource.getClients());
    } on supabase.PostgrestException catch (e) {
      return Left(_mapPostgrestError(e));
    } catch (_) {
      return const Left(
        UnexpectedFailure(message: 'No se pudieron obtener los clientes.'),
      );
    }
  }

  Failure _mapPostgrestError(supabase.PostgrestException e) {
    return switch (e.code) {
      '42501' => const UnauthorizedFailure(
          message: 'No tienes permisos para esta acción.',
        ),
      'PGRST116' => const NotFoundFailure(
          message: 'El cliente no existe.',
        ),
      _ => UnexpectedFailure(message: 'Error inesperado.', code: e.code),
    };
  }
}
```

Tabla completa de códigos en `docs/convenciones/supabase.md`.

## Caso de uso

`lib/features/clients/domain/usecases/get_clients_usecase.dart`

```dart
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client.dart';
import '../repositories/clients_repository.dart';

class GetClientsUseCase {
  final ClientsRepository repository;

  const GetClientsUseCase(this.repository);

  Future<Either<Failure, List<Client>>> call() => repository.getClients();
}
```

## Providers

`lib/features/clients/presentation/providers/clients_providers.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/supabase_client_provider.dart';
import '../../data/datasources/clients_remote_datasource.dart';
import '../../data/repositories/clients_repository_impl.dart';
import '../../domain/repositories/clients_repository.dart';
import '../../domain/usecases/get_clients_usecase.dart';

part 'clients_providers.g.dart';

@riverpod
ClientsRemoteDataSource clientsRemoteDataSource(Ref ref) {
  return ClientsRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
}

@riverpod
ClientsRepository clientsRepository(Ref ref) {
  return ClientsRepositoryImpl(ref.watch(clientsRemoteDataSourceProvider));
}

@riverpod
GetClientsUseCase getClientsUseCase(Ref ref) {
  return GetClientsUseCase(ref.watch(clientsRepositoryProvider));
}
```

## Controlador de datos remotos

`lib/features/clients/presentation/providers/clients_controller_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/client.dart';
import 'clients_providers.dart';

part 'clients_controller_provider.g.dart';

@riverpod
class ClientsController extends _$ClientsController {
  @override
  Future<List<Client>> build() async {
    final result = await ref.watch(getClientsUseCaseProvider)();
    return result.fold((failure) => throw failure, (clients) => clients);
  }
}
```

La página lo consume con `AsyncValue.when` y muestra `error.message` cuando
el error es un `Failure`.

## Registro de la ruta

En `lib/core/router/route_paths.dart`, una constante en cada clase:

```dart
abstract final class RoutePaths {
  static const clients = '/clientes';
}

abstract final class RouteNames {
  static const clients = 'clients';
}
```

En `lib/core/router/route_definitions.dart`, **al final** de la lista de
`branches`:

```dart
StatefulShellBranch(
  routes: [
    GoRoute(
      path: RoutePaths.clients,
      name: RouteNames.clients,
      builder: (context, state) => const ClientsPage(),
    ),
  ],
),
```

No reordenes las ramas existentes. `adminBranchIndex` en ese mismo archivo, la
lista `titles` de `main_layout.dart` y los destinos de `bottom_nav_bar.dart`
están indexados por posición a mano, y desalinearlos no produce ningún error.

Si el módulo es solo para administradores, agrega además su ruta a
`adminOnlyRoutes` y su destino a `sidebar.dart`.

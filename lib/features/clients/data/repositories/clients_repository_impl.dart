import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uuid/uuid.dart';

import '../../../../core/data/datasources/sync_local_datasource.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/network_errors.dart';
import '../../../../core/models/sync_status.dart';
import '../../../../shared/value_objects/value_objects.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/clients_repository.dart';
import '../datasources/clients_local_datasource.dart';
import '../datasources/clients_remote_datasource.dart';
import '../models/client_model.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  final ClientsRemoteDataSource remoteDataSource;
  final ClientsLocalDataSource localDataSource;
  final SyncLocalDataSource syncDataSource;
  final bool Function() isOnline;

  const ClientsRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource, {
    required this.syncDataSource,
    required this.isOnline,
  });

  @override
  Future<Either<Failure, List<Client>>> searchClients({
    required String query,
    bool includeInactive = false,
  }) async {
    if (!isOnline()) {
      return searchCachedClients(
        query: query,
        includeInactive: includeInactive,
      );
    }
    try {
      final clients = await remoteDataSource.searchClients(
        query: query,
        includeInactive: includeInactive,
      );
      await _syncLocal(() => localDataSource.upsertClients(clients));
      return Right(clients);
    } on supabase.PostgrestException catch (e) {
      return Left(
        _mapPostgrestException(e, 'No se pudieron obtener los clientes.'),
      );
    } catch (e) {
      if (isNetworkError(e)) {
        return searchCachedClients(
          query: query,
          includeInactive: includeInactive,
        );
      }
      return const Left(
        UnexpectedFailure(message: 'Error inesperado al buscar clientes.'),
      );
    }
  }

  /// Sirve la búsqueda desde la caché local cuando no hay red. Si la caché no
  /// tiene resultados, el fallo es de red, no una búsqueda legítimamente vacía.
  @override
  Future<Either<Failure, List<Client>>> searchCachedClients({
    required String query,
    bool includeInactive = false,
  }) async {
    try {
      final cached = await localDataSource.searchCachedClients(
        query: query,
        includeInactive: includeInactive,
      );
      if (cached.isEmpty) {
        return const Left(NetworkFailure());
      }
      return Right(cached);
    } catch (_) {
      return const Left(
        CacheFailure(message: 'No se pudo leer la caché de clientes.'),
      );
    }
  }

  @override
  Future<Either<Failure, Client>> createClient({
    required String name,
    required Ci ci,
    String? phone,
    String? nit,
  }) async {
    if (!isOnline()) {
      return _createClientOffline(name: name, ci: ci, phone: phone, nit: nit);
    }
    try {
      final client = await remoteDataSource.createClient(
        name: name,
        ci: ci.value,
        phone: phone,
        nit: nit,
      );
      await _syncLocal(() => localDataSource.upsertClients([client]));
      return Right(client);
    } on supabase.PostgrestException catch (e) {
      return Left(
        _mapPostgrestException(e, 'No se pudo registrar el cliente.'),
      );
    } catch (e) {
      if (isNetworkError(e)) {
        return const Left(NetworkFailure());
      }
      return const Left(
        UnexpectedFailure(message: 'Error inesperado al registrar el cliente.'),
      );
    }
  }

  /// Guarda el cliente en la caché local como pendiente y encola la operación
  /// en el outbox para reproducirla en el servidor cuando vuelva la conexión.
  Future<Either<Failure, Client>> _createClientOffline({
    required String name,
    required Ci ci,
    String? phone,
    String? nit,
  }) async {
    final client = ClientModel(
      id: const Uuid().v4(),
      name: name,
      phone: phone,
      ci: ci.value,
      nit: nit,
      active: true,
    );

    try {
      await localDataSource.upsertClients([
        client,
      ], syncStatus: SyncStatus.pending);
      await syncDataSource.enqueue(
        operation: OutboxOperationType.createClient,
        payload: {
          'id': client.id,
          'name': client.name,
          'phone': client.phone,
          'ci': client.ci,
          'nit': client.nit,
        },
      );
      return Right(client);
    } catch (_) {
      return const Left(
        CacheFailure(message: 'No se pudo guardar el cliente sin conexión.'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> existsByCi(Ci ci) async {
    if (!isOnline()) {
      try {
        return Right(await localDataSource.existsByCi(ci.value));
      } catch (_) {
        return const Left(
          CacheFailure(message: 'No se pudo verificar la cédula localmente.'),
        );
      }
    }
    try {
      return Right(await remoteDataSource.existsByCi(ci.value));
    } on supabase.PostgrestException catch (e) {
      return Left(_mapPostgrestException(e, 'No se pudo verificar la cédula.'));
    } catch (e) {
      if (isNetworkError(e)) {
        try {
          return Right(await localDataSource.existsByCi(ci.value));
        } catch (_) {
          return const Left(
            CacheFailure(message: 'No se pudo verificar la cédula localmente.'),
          );
        }
      }
      return const Left(
        UnexpectedFailure(message: 'Error inesperado al verificar la cédula.'),
      );
    }
  }

  @override
  Future<Either<Failure, Client>> updateClient({
    required String id,
    required String name,
    required Ci ci,
    String? phone,
    String? nit,
  }) async {
    if (!isOnline()) {
      return const Left(NetworkFailure());
    }
    try {
      final client = await remoteDataSource.updateClient(
        id: id,
        name: name,
        ci: ci.value,
        phone: phone,
        nit: nit,
      );
      await _syncLocal(() => localDataSource.upsertClients([client]));
      return Right(client);
    } on supabase.PostgrestException catch (e) {
      return Left(
        _mapPostgrestException(e, 'No se pudo actualizar el cliente.'),
      );
    } catch (e) {
      if (isNetworkError(e)) {
        return const Left(NetworkFailure());
      }
      return const Left(
        UnexpectedFailure(
          message: 'Error inesperado al actualizar el cliente.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setActive(String id, bool active) async {
    if (!isOnline()) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.setActive(id, active);
      await _syncLocal(() => localDataSource.setActive(id, active));
      return const Right(unit);
    } on supabase.PostgrestException catch (e) {
      return Left(
        _mapPostgrestException(
          e,
          'No se pudo actualizar el estado del cliente.',
        ),
      );
    } catch (e) {
      if (isNetworkError(e)) {
        return const Left(NetworkFailure());
      }
      return const Left(
        UnexpectedFailure(
          message: 'Error inesperado al actualizar el estado del cliente.',
        ),
      );
    }
  }

  /// Escribe la operación exitosa en la caché local sin propagar sus errores:
  /// el remoto ya confirmó, y una caché que falla no debe invalidar el éxito.
  Future<void> _syncLocal(Future<void> Function() write) async {
    try {
      await write();
    } catch (_) {
      // La caché se actualizará en la próxima lectura con red.
    }
  }

  /// Traduce el error de Postgres al `Failure` que corresponde. La tabla de
  /// códigos está en `docs/convenciones/supabase.md`.
  Failure _mapPostgrestException(
    supabase.PostgrestException e,
    String fallbackMessage,
  ) {
    return switch (e.code) {
      // La restricción `clients_ci_unique` es la garantía real de que no hay
      // cédulas repetidas: la comprobación previa de la interfaz no cubre el
      // caso de dos altas simultáneas.
      '23505' when _violates(e, 'clients_ci_unique') => const ValidationFailure(
        message: 'Ya existe un cliente registrado con esa cédula de identidad.',
        errors: {'ci': 'Esta cédula ya está registrada'},
        code: '23505',
      ),
      '23505' => const ValidationFailure(
        message: 'Ya existe un registro con esos datos.',
        code: '23505',
      ),
      '23502' => const ValidationFailure(
        message: 'Faltan datos obligatorios.',
        code: '23502',
      ),
      '23503' => const ValidationFailure(
        message: 'El cliente está referenciado por otro registro.',
        code: '23503',
      ),
      '42501' => const UnauthorizedFailure(
        message: 'No tienes permisos para realizar esta acción.',
        code: '42501',
      ),
      'PGRST116' => const NotFoundFailure(
        message: 'El cliente no existe.',
        code: 'PGRST116',
      ),
      _ => UnexpectedFailure(message: fallbackMessage, code: e.code),
    };
  }

  bool _violates(supabase.PostgrestException e, String constraint) {
    return e.message.contains(constraint);
  }
}

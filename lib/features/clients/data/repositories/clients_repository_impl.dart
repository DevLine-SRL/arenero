import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/value_objects.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/clients_repository.dart';
import '../datasources/clients_remote_datasource.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  final ClientsRemoteDataSource remoteDataSource;

  const ClientsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Client>>> searchClients({
    required String query,
    bool includeInactive = false,
  }) async {
    try {
      final clients = await remoteDataSource.searchClients(
        query: query,
        includeInactive: includeInactive,
      );
      return Right(clients);
    } on supabase.PostgrestException catch (e) {
      return Left(
        _mapPostgrestException(e, 'No se pudieron obtener los clientes.'),
      );
    } catch (_) {
      return const Left(
        UnexpectedFailure(message: 'Error inesperado al buscar clientes.'),
      );
    }
  }

  @override
  Future<Either<Failure, Client>> createClient({
    required String name,
    required Ci ci,
    String? phone,
  }) async {
    try {
      final client = await remoteDataSource.createClient(
        name: name,
        ci: ci.value,
        phone: phone,
      );
      return Right(client);
    } on supabase.PostgrestException catch (e) {
      return Left(
        _mapPostgrestException(e, 'No se pudo registrar el cliente.'),
      );
    } catch (_) {
      return const Left(
        UnexpectedFailure(message: 'Error inesperado al registrar el cliente.'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> existsByCi(Ci ci) async {
    try {
      return Right(await remoteDataSource.existsByCi(ci.value));
    } on supabase.PostgrestException catch (e) {
      return Left(_mapPostgrestException(e, 'No se pudo verificar la cédula.'));
    } catch (_) {
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
  }) async {
    try {
      final client = await remoteDataSource.updateClient(
        id: id,
        name: name,
        ci: ci.value,
        phone: phone,
      );
      return Right(client);
    } on supabase.PostgrestException catch (e) {
      return Left(
        _mapPostgrestException(e, 'No se pudo actualizar el cliente.'),
      );
    } catch (_) {
      return const Left(
        UnexpectedFailure(
          message: 'Error inesperado al actualizar el cliente.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setActive(String id, bool active) async {
    try {
      await remoteDataSource.setActive(id, active);
      return const Right(unit);
    } on supabase.PostgrestException catch (e) {
      return Left(
        _mapPostgrestException(
          e,
          'No se pudo actualizar el estado del cliente.',
        ),
      );
    } catch (_) {
      return const Left(
        UnexpectedFailure(
          message: 'Error inesperado al actualizar el estado del cliente.',
        ),
      );
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

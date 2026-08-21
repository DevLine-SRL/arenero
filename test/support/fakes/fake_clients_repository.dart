import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/clients/domain/entities/client.dart';
import 'package:arenero/features/clients/domain/repositories/clients_repository.dart';
import 'package:arenero/shared/value_objects/value_objects.dart';
import 'package:dartz/dartz.dart';

import '../builders/client_builder.dart';

/// Repositorio de mentira, escrito a mano: el proyecto no usa librerías de
/// mocking. Cada prueba configura solo el resultado que necesita.
class FakeClientsRepository implements ClientsRepository {
  Either<Failure, Client>? createResult;
  Either<Failure, List<Client>>? searchResult;
  Either<Failure, bool>? existsResult;
  Either<Failure, bool>? existsByNitResult;
  Either<Failure, Client>? updateResult;
  Either<Failure, Unit>? setActiveResult;

  String? lastCreatedName;
  String? lastCreatedCi;
  String? lastCreatedPhone;
  String? lastCreatedNit;
  String? lastSearchQuery;
  bool? lastIncludeInactive;
  Ci? lastCheckedCi;
  String? lastCheckedNit;
  int createCallCount = 0;
  int existsCallCount = 0;
  int existsByNitCallCount = 0;

  @override
  Future<Either<Failure, Client>> createClient({
    required String name,
    required Ci ci,
    String? phone,
    String? nit,
  }) async {
    createCallCount++;
    lastCreatedName = name;
    lastCreatedCi = ci.value;
    lastCreatedPhone = phone;
    lastCreatedNit = nit;
    return createResult ??
        Right(buildClient(name: name, ci: ci.value, nit: nit));
  }

  @override
  Future<Either<Failure, List<Client>>> searchClients({
    required String query,
    bool includeInactive = false,
  }) async {
    lastSearchQuery = query;
    lastIncludeInactive = includeInactive;
    return searchResult ?? const Right([]);
  }

  @override
  Future<Either<Failure, bool>> existsByCi(Ci ci) async {
    existsCallCount++;
    lastCheckedCi = ci;
    return existsResult ?? const Right(false);
  }

  @override
  Future<Either<Failure, bool>> existsByNit(String nit) async {
    existsByNitCallCount++;
    lastCheckedNit = nit;
    return existsByNitResult ?? const Right(false);
  }

  @override
  Future<Either<Failure, Client>> updateClient({
    required String id,
    required String name,
    required Ci ci,
    String? phone,
    String? nit,
  }) async {
    return updateResult ??
        Right(buildClient(id: id, name: name, ci: ci.value, nit: nit));
  }

  @override
  Future<Either<Failure, Unit>> setActive(String id, bool active) async {
    return setActiveResult ?? const Right(unit);
  }
}

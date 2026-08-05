import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/value_objects.dart';
import '../entities/client.dart';
import '../repositories/clients_repository.dart';

class CreateClientUseCase {
  final ClientsRepository repository;

  const CreateClientUseCase(this.repository);

  Future<Either<Failure, Client>> call({
    required String name,
    required String rawCi,
    String? phone,
    String? nit,
  }) async {
    return Ci.create(rawCi).fold(
      (failure) => Left<Failure, Client>(failure),
      (ci) =>
          repository.createClient(name: name, ci: ci, phone: phone, nit: nit),
    );
  }
}

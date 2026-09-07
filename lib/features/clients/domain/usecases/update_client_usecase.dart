import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/value_objects.dart';
import '../entities/client.dart';
import '../repositories/clients_repository.dart';

class UpdateClientUseCase {
  final ClientsRepository repository;

  const UpdateClientUseCase(this.repository);

  Future<Either<Failure, Client>> call({
    required String id,
    required String name,
    required String rawCi,
    String? phone,
    String? nit,
  }) async {
    return Ci.create(rawCi).fold(
      (failure) => Left<Failure, Client>(failure),
      (ci) => repository.updateClient(
        id: id,
        name: name,
        ci: ci,
        phone: phone,
        nit: nit,
      ),
    );
  }
}

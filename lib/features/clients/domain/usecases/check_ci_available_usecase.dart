import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/value_objects.dart';
import '../repositories/clients_repository.dart';

/// Aviso temprano de cédula duplicada mientras el usuario escribe.
///
/// No garantiza la unicidad: entre esta consulta y el alta puede entrar otro
/// registro. Quien garantiza es la restricción `clients_ci_unique`, y el
/// repositorio traduce su violación a un `ValidationFailure`.
class CheckCiAvailableUseCase {
  final ClientsRepository repository;

  const CheckCiAvailableUseCase(this.repository);

  Future<Either<Failure, bool>> call(String rawCi) async {
    return Ci.create(rawCi).fold(
      (failure) => Left<Failure, bool>(failure),
      (ci) async => (await repository.existsByCi(ci)).map((exists) => !exists),
    );
  }
}

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/validators/validators.dart' as validators;
import '../repositories/clients_repository.dart';

/// Aviso temprano de NIT duplicado mientras el usuario escribe.
///
/// No garantiza la unicidad: entre esta consulta y el alta puede entrar otro
/// registro. La base de datos no tiene restricción de unicidad sobre el NIT,
/// así que este aviso es la única barrera; si algún día se agrega el índice,
/// el repositorio ya traduce la violación a un `ValidationFailure`.
class CheckNitAvailableUseCase {
  final ClientsRepository repository;

  const CheckNitAvailableUseCase(this.repository);

  Future<Either<Failure, bool>> call(String rawNit) async {
    final value = rawNit.trim();

    // El NIT es opcional: sin valor no hay nada que comprobar.
    if (value.isEmpty) return const Right(true);

    final formatError = validators.nit(value);
    if (formatError != null) {
      return Left(ValidationFailure(message: formatError));
    }

    return (await repository.existsByNit(value)).map((exists) => !exists);
  }
}

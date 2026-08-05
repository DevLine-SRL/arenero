import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../validators/ci.dart' as validators;

/// Cédula de identidad válida. Un `Ci` construido siempre cumple el formato,
/// así que las capas de dominio y datos no vuelven a comprobarlo.
class Ci {
  final String value;

  const Ci._(this.value);

  static Either<Failure, Ci> create(String input) {
    final error = validators.ci(input);
    if (error != null) {
      return Left(ValidationFailure(message: error));
    }

    return Right(Ci._(input.trim()));
  }
}

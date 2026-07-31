import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';

class Password {
  final String value;

  const Password._(this.value);

  static Either<Failure, Password> create(String input) {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    if (!regex.hasMatch(input)) {
      return const Left(
        ValidationFailure(
          message: 'La contraseña debe tener al menos 8 caracteres, incluir letras y números',
        ),
      );
    }

    return Right(Password._(input));
  }
}

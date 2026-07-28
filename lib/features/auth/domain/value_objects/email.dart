import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

class Email {
  final String value;

  const Email._(this.value);

  static Either<Failure, Email> create(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const Left(ValidationFailure(message: 'El correo no puede estar vacio'));
    }

    final regex = RegExp(r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');
    if (!regex.hasMatch(trimmed)) {
      return const Left(ValidationFailure(message: 'No es un formato válido'));
    }

    return Right(Email._(trimmed));
  }
}

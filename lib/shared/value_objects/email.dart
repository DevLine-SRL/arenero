import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../validators/email.dart';

class Email {
  final String value;

  const Email._(this.value);

  static Either<Failure, Email> create(String input) {
    final error = email(input);
    if (error != null) {
      return Left(ValidationFailure(message: error));
    }

    return Right(Email._(input.trim()));
  }
}

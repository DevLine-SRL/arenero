import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../validators/verification_code.dart';

class VerificationCode {
  final String value;

  const VerificationCode._(this.value);

  static Either<Failure, VerificationCode> create(String input) {
    final error = verificationCode(input);
    if (error != null) {
      return Left(ValidationFailure(message: error));
    }

    return Right(VerificationCode._(input.trim()));
  }
}

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../validators/full_name.dart';

class FullName {
  final String value;

  const FullName._(this.value);

  static Either<Failure, FullName> create(String input) {
    final error = fullName(input);
    if (error != null) {
      return Left(ValidationFailure(message: error));
    }

    return Right(FullName._(collapseSpaces(input)));
  }
}

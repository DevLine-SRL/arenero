import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/email.dart';
import '../repositories/auth_repository.dart';

class ResetLoginAttemptsUseCase {
  final AuthRepository repository;

  const ResetLoginAttemptsUseCase(this.repository);

  Future<Either<Failure, Unit>> call({required Email email}) {
    return repository.resetLoginAttempts(email: email);
  }
}

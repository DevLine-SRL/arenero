import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ResetLoginAttemptsUseCase {
  final AuthRepository repository;

  const ResetLoginAttemptsUseCase(this.repository);

  Future<Either<Failure, Unit>> call() {
    return repository.resetLoginAttempts();
  }
}

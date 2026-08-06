import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/email.dart';
import '../entities/login_lock_status.dart';
import '../repositories/auth_repository.dart';

class RegisterFailedLoginUseCase {
  final AuthRepository repository;

  const RegisterFailedLoginUseCase(this.repository);

  Future<Either<Failure, LoginLockStatus>> call({
    required Email email,
  }) {
    return repository.registerFailedLogin(email: email);
  }
}
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/email.dart';
import '../entities/login_lock_status.dart';
import '../repositories/auth_repository.dart';

class CheckLoginLockUseCase {
  final AuthRepository repository;

  const CheckLoginLockUseCase(this.repository);

  Future<Either<Failure, LoginLockStatus>> call({
    required Email email,
  }) {
    return repository.getLoginLock(email: email);
  }
}
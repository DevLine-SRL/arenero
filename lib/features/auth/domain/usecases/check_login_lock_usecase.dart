import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/login_lock_status.dart';
import '../repositories/auth_repository.dart';

class CheckLoginLockUseCase {
  final AuthRepository repository;

  const CheckLoginLockUseCase(this.repository);

  Future<Either<Failure, LoginLockStatus>> call() {
    return repository.getLoginLock();
  }
}

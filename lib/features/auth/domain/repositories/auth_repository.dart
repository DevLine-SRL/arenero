import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/email.dart';
import '../../domain/entities/login_lock_status.dart';
import '../../domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required Email email,
    required String password,
  });

  Future<void> logout();

  Stream<User?> watchAuthState();

  Future<User?> currentUser();

  Future<Either<Failure, DateTime?>> touchLastSeen();

  Future<Either<Failure, LoginLockStatus>> getLoginLock({required Email email});

  Future<Either<Failure, LoginLockStatus>> registerFailedLogin({
    required Email email,
  });

  Future<Either<Failure, Unit>> resetLoginAttempts({required Email email});
}

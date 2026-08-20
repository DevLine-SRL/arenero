import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/email.dart';
import '../../../../shared/value_objects/password.dart';
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

  Future<Either<Failure, LoginLockStatus>> getLoginLock();

  Future<Either<Failure, LoginLockStatus>> registerFailedLogin();

  Future<Either<Failure, Unit>> resetLoginAttempts();

  Future<Either<Failure, Unit>> sendPasswordResetCode({required Email email});

  Future<Either<Failure, Unit>> verifyPasswordResetCode({
    required Email email,
    required String code,
  });

  Future<Either<Failure, Unit>> changePassword({required Password password});
}

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/email.dart';
import '../../domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required Email email,
    required String password,
  });

  Future<void> logout();

  Stream<User?> watchAuthState();

  Future<User?> currentUser();

  Future<Either<Failure, void> resetPassword({required Email email});
}

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/email.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required Email email,
    required String password,
  });

  Future<void> logout();

  Stream<User?> watchAuthState();

  User? get currentUser;
}

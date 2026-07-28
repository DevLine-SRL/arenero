import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/value_objects/email.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String rawEmail,
    required String rawPassword,
  }) async {
    final emailResult = Email.create(rawEmail);

    return emailResult.fold(
      (failure) => Left(failure),
      (email) => repository.login(email: email, password: rawPassword),
    );
  }
}

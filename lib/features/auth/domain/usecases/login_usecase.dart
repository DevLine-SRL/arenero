import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/email.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String rawEmail,
    required String rawPassword,
  }) async {
    final normalizedEmail = rawEmail.trim().toLowerCase();
    final emailResult = Email.create(normalizedEmail);

    return emailResult.fold(
      Left.new,
      (email) => repository.login(
        email: email,
        password: rawPassword,
      ),
    );
  }
}
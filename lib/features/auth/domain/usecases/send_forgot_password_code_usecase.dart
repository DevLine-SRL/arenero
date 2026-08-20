import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/email.dart';
import '../repositories/auth_repository.dart';

class SendForgotPasswordCodeUseCase {
  final AuthRepository repository;

  const SendForgotPasswordCodeUseCase(this.repository);

  Future<Either<Failure, Unit>> call({required String rawEmail}) async {
    final emailResult = Email.create(rawEmail);

    return emailResult.fold(
      (failure) => Left(failure),
      (email) => repository.sendPasswordResetCode(email: email),
    );
  }
}

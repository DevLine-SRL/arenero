import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/email.dart';
import '../../../../shared/value_objects/verification_code.dart';
import '../repositories/auth_repository.dart';

class VerifyForgotPasswordCodeUseCase {
  final AuthRepository repository;

  const VerifyForgotPasswordCodeUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String rawEmail,
    required String rawCode,
  }) async {
    final emailResult = Email.create(rawEmail);
    final codeResult = VerificationCode.create(rawCode);

    return emailResult.fold(
      (failure) => Left(failure),
      (email) => codeResult.fold(
        (failure) => Left(failure),
        (code) =>
            repository.verifyPasswordResetCode(email: email, code: code.value),
      ),
    );
  }
}

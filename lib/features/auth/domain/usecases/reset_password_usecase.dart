import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/email.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;
  const ResetPasswordUseCase(this.repository);
  Future<Either<Failure, void>> call({required String rawEmail}) async {
    final emailResult = Email.create(rawEmail);
    return emailResult.fold(
      (failure) => Left(failure),
      (email) => repository.resetPassword(email: email),
    );
  }
}
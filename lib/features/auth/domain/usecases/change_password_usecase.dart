import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/password.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository repository;

  const ChangePasswordUseCase(this.repository);

  Future<Either<Failure, Unit>> call({required String rawPassword}) async {
    final passwordResult = Password.create(rawPassword);

    return passwordResult.fold(
      (failure) => Left(failure),
      (password) => repository.changePassword(password: password),
    );
  }
}

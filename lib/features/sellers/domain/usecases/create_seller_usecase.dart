import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/value_objects/value_objects.dart';
import '../repositories/sellers_repository.dart';

class CreateSellerUseCase {
  final SellersRepository repository;

  const CreateSellerUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String name,
    required String rawEmail,
    required String rawPassword,
  }) async {
    return FullName.create(name).fold(
      (failure) => Left<Failure, Unit>(failure),
      (fullName) => Email.create(rawEmail).fold(
        (failure) => Left<Failure, Unit>(failure),
        (email) => Password.create(rawPassword).fold(
          (failure) => Left<Failure, Unit>(failure),
          (password) => repository.createSeller(
            name: fullName,
            email: email,
            password: password,
          ),
        ),
      ),
    );
  }
}

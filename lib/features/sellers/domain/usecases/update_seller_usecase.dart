import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/validators/validators.dart';
import '../../../../shared/value_objects/value_objects.dart';
import '../entities/seller.dart';
import '../repositories/sellers_repository.dart';

class UpdateSellerUseCase {
  final SellersRepository repository;

  const UpdateSellerUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String id,
    required String name,
    required String rawEmail,
    required List<Seller> existingSellers,
  }) async {
    final normalizedName = collapseSpaces(name);
    final nameError = fullName(normalizedName);
    if (nameError != null) {
      return Left(ValidationFailure(message: nameError));
    }

    final emailResult = Email.create(rawEmail);
    return emailResult.fold(
      (failure) => Left<Failure, Unit>(failure),
      (email) {
        final duplicate = existingSellers.any(
          (seller) =>
              seller.email.toLowerCase() == email.value.toLowerCase() &&
              seller.id != id,
        );

        if (duplicate) {
          return const Left(
            ValidationFailure(
              message: 'Ya existe un vendedor registrado con ese correo electrónico.',
              code: 'EMAIL_TAKEN',
            ),
          );
        }

        return FullName.create(normalizedName).fold(
          (failure) => Left<Failure, Unit>(failure),
          (fullName) => repository.updateSeller(
            id: id,
            name: fullName,
            email: email,
          ),
        );
      },
    );
  }
}

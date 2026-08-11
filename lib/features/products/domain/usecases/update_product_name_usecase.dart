import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/validators/validators.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';
import '../services/product_duplicate_guard.dart';

class UpdateProductNameUseCase {
  final ProductsRepository repository;

  const UpdateProductNameUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String id,
    required String name,
    required Iterable<Product> existingProducts,
  }) async {
    final normalizedName = normalizeProductName(name);
    final nameError = required(normalizedName);
    if (nameError != null) return Left(ValidationFailure(message: nameError));

    if (isDuplicateProductName(
      products: existingProducts,
      name: normalizedName,
      ignoringProductId: id,
    )) {
      return const Left(
        ValidationFailure(
          message: 'Ya existe un producto registrado con ese nombre.',
          code: 'PRODUCT_DUPLICATE',
        ),
      );
    }

    return repository.updateProductName(
      id: id,
      name: _displayName(normalizedName),
    );
  }

  String _displayName(String normalizedName) {
    return normalizedName
        .split(' ')
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

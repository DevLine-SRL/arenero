import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/validators/validators.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';
import '../services/product_duplicate_guard.dart';

class CreateProductUseCase {
  final ProductsRepository repository;

  const CreateProductUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String name,
    required ProductUnitOfMeasure unit,
    required double unitPrice,
    required Iterable<Product> existingProducts,
  }) async {
    final nameError = required(name);
    if (nameError != null) {
      return Left(ValidationFailure(message: nameError));
    }

    if (isDuplicateProductName(products: existingProducts, name: name)) {
      return const Left(
        ValidationFailure(
          message: 'Ya existe un producto registrado con ese nombre.',
          code: 'PRODUCT_DUPLICATE',
        ),
      );
    }

    if (unitPrice <= 0) {
      return const Left(
        ValidationFailure(
          message: 'El precio unitario debe ser mayor a cero.',
          code: 'INVALID_UNIT_PRICE',
        ),
      );
    }

    return repository.createProduct(
      name: normalizeProductName(name)
          .split(' ')
          .map(
            (word) => word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1)}',
          )
          .join(' '),
      unit: unit,
      unitPrice: unitPrice,
    );
  }
}

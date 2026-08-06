import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

class UpdateProductPriceUseCase {
  final ProductsRepository repository;

  const UpdateProductPriceUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required Product product,
    required ProductUnitPrice unit,
    required double unitPrice,
  }) async {
    if (!product.active || !unit.active) {
      return const Left(
        ValidationFailure(
          message: 'Solo se puede actualizar el precio de productos activos.',
          code: 'PRODUCT_INACTIVE',
        ),
      );
    }
    if (unitPrice <= 0) {
      return const Left(
        ValidationFailure(
          message: 'El precio debe ser mayor a cero.',
          code: 'INVALID_UNIT_PRICE',
        ),
      );
    }
    return repository.updateUnitPrice(unitId: unit.id, unitPrice: unitPrice);
  }
}

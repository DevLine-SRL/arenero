import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product.dart';

abstract class ProductsRepository {
  Future<Either<Failure, List<Product>>> getProducts();

  Future<Either<Failure, List<Product>>> getCachedProducts();

  Future<Either<Failure, Unit>> createProduct({
    required String name,
    required ProductUnitOfMeasure unit,
    required double unitPrice,
  });

  Future<Either<Failure, Unit>> updateProductName({
    required String id,
    required String name,
  });

  Future<Either<Failure, Unit>> updateUnitPrice({
    required String unitId,
    required double unitPrice,
  });

  Future<Either<Failure, Unit>> setActive(String id, bool active);
}

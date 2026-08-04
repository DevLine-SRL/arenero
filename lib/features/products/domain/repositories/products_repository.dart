import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product.dart';

abstract class ProductsRepository {
  Future<Either<Failure, List<Product>>> getProducts();

  Future<Either<Failure, Unit>> createProduct({
    required String name,
    required ProductUnitOfMeasure unit,
    required double unitPrice,
  });

  Future<Either<Failure, Unit>> setActive(String id, bool active);
}

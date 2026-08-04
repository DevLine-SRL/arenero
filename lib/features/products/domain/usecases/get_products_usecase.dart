import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetProductsUseCase {
  final ProductsRepository repository;

  const GetProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call() {
    return repository.getProducts();
  }
}

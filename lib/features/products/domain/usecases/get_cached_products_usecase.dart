import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetCachedProductsUseCase {
  final ProductsRepository repository;

  const GetCachedProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call() {
    return repository.getCachedProducts();
  }
}

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/sales_repository.dart';

class VoidSaleUseCase {
  final SalesRepository repository;

  const VoidSaleUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String saleId) {
    return repository.voidSale(saleId);
  }
}
